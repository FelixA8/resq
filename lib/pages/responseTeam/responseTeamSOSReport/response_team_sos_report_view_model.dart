import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/response_team_dashboard_view_model.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view_model.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/distance_calculator.dart' as distance_calc;
import 'package:resqapp/services/location_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/sos_report_item.dart';
import 'dart:developer' as developer;

class ResponseTeamSOSReportViewModel extends GetxController {
  final RxList<SosReportItem> sosReports = <SosReportItem>[].obs;
  final Map<String, ResqUser> _userCache = {};
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<LatLng?> responseTeamLocation = Rx<LatLng?>(null);

  static const int _pageSize = 10;
  int _currentOffset = 0;
  final RxBool hasMoreData = true.obs;

  RealtimeChannel? _sosEventsSubscription;
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _initialize();
  }

  /// Initialize: load first page and set up real-time subscription
  Future<void> _initialize() async {
    await _loadSOSReports();
    await _initializeLocation();
    _subscribeToSOSEvents();
  }

  /// Initialize response team location
  Future<void> _initializeLocation() async {
    try {
      final result = await LocationHelper.getCurrentLocationSilent();
      if (result.hasPermission) {
        responseTeamLocation.value = result.location;
      } else {
        developer.log(
          'Location permission not granted, using default location',
        );
        responseTeamLocation.value = LocationHelper.defaultLocation;
      }
    } catch (e) {
      developer.log('Could not get response team location: $e');
      responseTeamLocation.value = LocationHelper.defaultLocation;
    }
  }

  @override
  void onClose() {
    _sosEventsSubscription?.unsubscribe();
    super.onClose();
  }

  /// Load initial SOS reports from Supabase
  Future<void> _loadSOSReports() async {
    isLoading.value = true;
    errorMessage.value = null;
    _currentOffset = 0;
    hasMoreData.value = true;

    try {
      final sosEvents = await SupabaseService.getPaginatedSosEvents(
        limit: _pageSize,
        offset: _currentOffset,
      );

      hasMoreData.value = sosEvents.length >= _pageSize;
      _currentOffset = sosEvents.length;

      final reportItems = await _enrichSOSEventsWithUserData(sosEvents);

      sosReports.value = reportItems;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to load SOS reports: ${e.toString()}';
      developer.log('Error loading SOS reports: $e');
    }
  }

  /// Load more SOS reports (pagination)
  Future<void> loadMoreReports() async {
    if (isLoadingMore.value || !hasMoreData.value || isLoading.value) return;

    isLoadingMore.value = true;

    try {
      developer.log('📋 Loading more SOS reports (offset: $_currentOffset)...');

      // Fetch next page
      final sosEvents = await SupabaseService.getPaginatedSosEvents(
        limit: _pageSize,
        offset: _currentOffset,
      );

      hasMoreData.value = sosEvents.length >= _pageSize;
      _currentOffset += sosEvents.length;

      final reportItems = await _enrichSOSEventsWithUserData(sosEvents);

      sosReports.addAll(reportItems);
      isLoadingMore.value = false;
    } catch (e) {
      isLoadingMore.value = false;
      developer.log('Error loading more SOS reports: $e');
    }
  }

  /// Enrich SOS events with user data and calculate distances
  Future<List<SosReportItem>> _enrichSOSEventsWithUserData(
    List<SosEvent> sosEvents,
  ) async {
    final reportItems = <SosReportItem>[];

    if (responseTeamLocation.value == null) {
      developer.log('⚠️ Response team location not available yet, waiting...');
      await _initializeLocation();
    }

    for (final sosEvent in sosEvents) {
      ResqUser? user;

      if (sosEvent.userId != null && _userCache.containsKey(sosEvent.userId)) {
        user = _userCache[sosEvent.userId];
      } else if (sosEvent.userId != null) {
        try {
          user = await SupabaseService.getUserById(sosEvent.userId!);
          if (user != null) {
            _userCache[sosEvent.userId!] = user;
          }
        } catch (e) {
          developer.log('⚠️ Error fetching user ${sosEvent.userId}: $e');
        }
      }

      double distanceKm = 0.0;
      if (responseTeamLocation.value != null &&
          sosEvent.locationLat != null &&
          sosEvent.locationLng != null) {
        distanceKm = distance_calc.GeoDistanceCalculator.calculateDistance(
          responseTeamLocation.value!,
          LatLng(sosEvent.locationLat!, sosEvent.locationLng!),
        );
        developer.log(
          'Distance to SOS ${sosEvent.sosId}: ${distanceKm.toStringAsFixed(2)} km',
        );
      } else {
        developer.log(
          'Cannot calculate distance for SOS ${sosEvent.sosId}: location data missing',
        );
      }

      reportItems.add(
        SosReportItem(sosEvent: sosEvent, user: user, distanceKm: distanceKm),
      );
    }

    return reportItems;
  }

  void _subscribeToSOSEvents() {
    try {
      final supabaseClient = Supabase.instance.client;

      _sosEventsSubscription =
          supabaseClient
              .channel('sos_events_report_changes')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'sos_events',
                callback: (payload) {
                  _handleSOSEventChange(payload);
                },
              )
              .subscribe();
    } catch (e) {
      developer.log('Error setting up SOS realtime subscription: $e');
    }
  }

  void _handleSOSEventChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          _handleSOSEventInsert(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          _handleSOSEventUpdate(payload.oldRecord, payload.newRecord);
          break;
        case PostgresChangeEvent.delete:
          _handleSOSEventDelete(payload.oldRecord);
          break;
        default:
      }
    } catch (e) {
      developer.log('Error handling SOS event change: $e');
    }
  }

  Future<void> _handleSOSEventInsert(Map<String, dynamic> record) async {
    try {
      final sosEvent = SosEvent.fromJson(record);

      if (sosEvent.sosId.isNotEmpty) {
        final exists = sosReports.any(
          (item) => item.sosEvent.sosId == sosEvent.sosId,
        );

        if (!exists) {
          if (responseTeamLocation.value == null) {
            await _initializeLocation();
          }

          ResqUser? user;
          if (sosEvent.userId != null) {
            if (_userCache.containsKey(sosEvent.userId)) {
              user = _userCache[sosEvent.userId];
            } else {
              user = await SupabaseService.getUserById(sosEvent.userId!);
              if (user != null) {
                _userCache[sosEvent.userId!] = user;
              }
            }
          }

          double distanceKm = 0.0;
          if (responseTeamLocation.value != null &&
              sosEvent.locationLat != null &&
              sosEvent.locationLng != null) {
            distanceKm = distance_calc.GeoDistanceCalculator.calculateDistance(
              responseTeamLocation.value!,
              LatLng(sosEvent.locationLat!, sosEvent.locationLng!),
            );
          }

          sosReports.insert(
            0,
            SosReportItem(
              sosEvent: sosEvent,
              user: user,
              distanceKm: distanceKm,
            ),
          );

          _currentOffset++;
        }
      }
    } catch (e) {
      developer.log('Error handling SOS INSERT: $e');
    }
  }

  Future<void> _handleSOSEventUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) async {
    try {
      final newSosEvent = SosEvent.fromJson(newRecord);

      if (newSosEvent.sosId.isNotEmpty) {
        final index = sosReports.indexWhere(
          (item) => item.sosEvent.sosId == newSosEvent.sosId,
        );

        if (index != -1) {
          // Update the existing item
          final oldItem = sosReports[index];
          sosReports[index] = oldItem.copyWith(sosEvent: newSosEvent);
        }
      }
    } catch (e) {
      developer.log('Error handling SOS UPDATE: $e');
    }
  }

  void _handleSOSEventDelete(Map<String, dynamic> record) {
    try {
      final sosEvent = SosEvent.fromJson(record);

      if (sosEvent.sosId.isNotEmpty) {
        final initialLength = sosReports.length;
        sosReports.removeWhere((item) => item.sosEvent.sosId == sosEvent.sosId);

        if (sosReports.length < initialLength) {
          _currentOffset--;
          developer.log('✅ Removed SOS event: ${sosEvent.sosId}');
        }
      }
    } catch (e) {
      developer.log('Error handling SOS DELETE: $e');
    }
  }

  Future<void> refreshReports() async {
    await _initializeLocation();
    await _loadSOSReports();
  }

  Future<void> updateLocation(LatLng newLocation) async {
    responseTeamLocation.value = newLocation;
    final updatedReports =
        sosReports.map((item) {
          if (item.sosEvent.locationLat != null &&
              item.sosEvent.locationLng != null) {
            final distanceKm = distance_calc
                .GeoDistanceCalculator.calculateDistance(
              newLocation,
              LatLng(item.sosEvent.locationLat!, item.sosEvent.locationLng!),
            );
            return item.copyWith(distanceKm: distanceKm);
          }
          return item;
        }).toList();

    sosReports.value = updatedReports;
  }

  Future<void> viewOnMap(String reportId) async {
    try {
      SosReportItem reportItem;
      try {
        reportItem = sosReports.firstWhere(
          (item) => item.sosEvent.sosId == reportId,
        );
      } catch (e) {
        developer.log('SOS report not found: $reportId');
        return;
      }

      final sosEvent = reportItem.sosEvent;

      if (sosEvent.locationLat == null || sosEvent.locationLng == null) {
        developer.log('SOS event has no location data: $reportId');
        return;
      }

      final location = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);

      final instanceCode =
          await ResponseLoginPageViewModel.getSavedInstanceCode();
      if (instanceCode == null || instanceCode.isEmpty) {
        developer.log('⚠️ Instance code not found');
        return;
      }

      final dashboardViewModel = Get.find<ResponseTeamDashboardViewModel>();
      dashboardViewModel.onTabChanged(1);

      await Future.delayed(const Duration(milliseconds: 300));

      ResponseTeamMapViewModel mapViewModel;
      if (Get.isRegistered<ResponseTeamMapViewModel>()) {
        mapViewModel = Get.find<ResponseTeamMapViewModel>();
      } else {
        mapViewModel = Get.put(
          ResponseTeamMapViewModel(instanceCode: instanceCode),
          permanent: false,
        );
      }

      mapViewModel.moveToLocation(location);
    } catch (e) {
      developer.log('Error in viewOnMap: $e');
    }
  }

  String formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
