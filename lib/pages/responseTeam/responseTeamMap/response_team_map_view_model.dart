import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqapp/components/disaster_detail_modal.dart';
import 'package:flutter/services.dart';


class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  final DateFormat _disasterDateFormatter =
      DateFormat('d MMMM yyyy, HH:mm:ss', 'id_ID');
  final Map<String, String> _disasterAddressCache = {};
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  
  final RxList<Disaster> _disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  final RxList<EvacuationPoint> _evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  final RxList<SosEvent> _sosEventsData = <SosEvent>[].obs;
  final RxList<LatLng> sosPoints = <LatLng>[].obs;

  // Realtime subscriptions
  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;
  RealtimeChannel? _sosEventsSubscription;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    _initializeLocation();
    _initializeData();
    _subscribeToEvacuationPoints();
    _subscribeToDisasters();
    _subscribeToSOSEvents();
    super.onInit();
    _loadSOSPoints();
    subscribeToSOSUpdates();
  }

  void subscribeToSOSUpdates() {
  Supabase.instance.client
      .channel('public:sos_events')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        table: 'sos_events',
        callback: (payload) async {
          print('🔄 Realtime SOS update received: ${payload.eventType}');
          final previousCount = sosPoints.length;

          await _loadSOSPoints();

          final newCount = sosPoints.length;
          if (newCount > previousCount) {
            HapticFeedback.heavyImpact();
          }
          update();
        },
      )
      .subscribe();
}


  @override
  void onClose() {
    _evacuationPointsSubscription?.unsubscribe();
    _disastersSubscription?.unsubscribe();
    _sosEventsSubscription?.unsubscribe();
    super.onClose();
  }
  
  @override void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _loadDisasterPoints();
    _loadEvacuationPoints();
    _loadSOSPoints();
  }

  void _updateDisasterPointsDisplay() {
    disasterPoints.value = _disasterPointsData
        .where((disaster) => disaster.centerLat != null && disaster.centerLng != null)
        .map((disaster) => LatLng(disaster.centerLat!, disaster.centerLng!))
        .toList();
  }

  Future<void> _loadDisasterPoints() async {
    try {
      final disasters = await SupabaseService.getAllDisasters();
      
      _disasterPointsData.value = disasters;
      _updateDisasterPointsDisplay();
    } catch (e) {
      _disasterPointsData.clear();
      _updateDisasterPointsDisplay();
    }
  }

  void _updateEvacuationPointsDisplay() {
    evacuationPoints.value = _evacuationPointsData
        .where((point) => point.hasLocation())
        .map((point) => LatLng(point.locationLat!, point.locationLng!))
        .toList();
  }

  Future<void> _loadEvacuationPoints() async {
    try {
      final points = await SupabaseService.getEvacuationPoints();
      
      _evacuationPointsData.value = points;
      _updateEvacuationPointsDisplay();

    } catch (e) {
      _evacuationPointsData.clear();
      _updateEvacuationPointsDisplay();
    }
  }
  
  /// Subscribe to realtime changes on evacuation_points table
  void _subscribeToEvacuationPoints() {
    try {
      final supabaseClient = Supabase.instance.client;
      
      _evacuationPointsSubscription = supabaseClient
          .channel('evacuation_points_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'evacuation_points',
            callback: (payload) {
              _handleEvacuationPointChange(payload);
            },
          )
          .subscribe();
    } catch (e) {
      print('Error setting up realtime subscription: $e');
    }
  }

  /// Subscribe to realtime changes on sos_events table
  void _subscribeToSOSEvents() {
    try {
      final supabaseClient = Supabase.instance.client;
      
      _sosEventsSubscription = supabaseClient
          .channel('sos_events_changes')
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
      print('Error setting up SOS realtime subscription: $e');
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
      print('Error handling SOS event change: $e');
    }
  }

  void _handleSOSEventInsert(Map<String, dynamic> record) {
    try {
      final sosEvent = SosEvent.fromJson(record);
      
      if (sosEvent.sosId.isNotEmpty && sosEvent.isActive) {
        final exists = _sosEventsData.any(
          (s) => s.sosId == sosEvent.sosId,
        );
        
        if (!exists) {
          _sosEventsData.add(sosEvent);
          _updateSOSPointsDisplay();
        }
      }
    } catch (e) {
      print('Error handling SOS INSERT: $e');
    }
  }

  void _handleSOSEventUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newSosEvent = SosEvent.fromJson(newRecord);
      
      if (newSosEvent.sosId.isNotEmpty) {
        // Find and replace the existing SOS event by ID
        final index = _sosEventsData.indexWhere(
          (s) => s.sosId == newSosEvent.sosId,
        );
        
        if (index != -1) {
          _sosEventsData[index] = newSosEvent;
          _updateSOSPointsDisplay();
        } else if (newSosEvent.isActive) {
          _sosEventsData.add(newSosEvent);
          _updateSOSPointsDisplay();
        }
      }
    } catch (e) {
      print('Error handling SOS UPDATE: $e');
    }
  }

  /// Handle DELETE event - remove SOS event from map
  void _handleSOSEventDelete(Map<String, dynamic> record) {
    try {
      final sosEvent = SosEvent.fromJson(record);
      
      if (sosEvent.sosId.isNotEmpty) {
        _sosEventsData.removeWhere(
          (s) => s.sosId == sosEvent.sosId,
        );
        _updateSOSPointsDisplay();
      }
    } catch (e) {
      print('Error handling SOS DELETE: $e');
    }
  }

  /// Subscribe to realtime changes on disasters table
  void _subscribeToDisasters() {
    try {
      final supabaseClient = Supabase.instance.client;
      
      _disastersSubscription = supabaseClient
          .channel('disasters_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'disasters',
            callback: (payload) {
              print('🔔 Disaster realtime event received: ${payload.eventType}');
              _handleDisasterChange(payload);
            },
          )
          .subscribe();
    } catch (e) {
      print('Error setting up disaster realtime subscription: $e');
    }
  }

  /// Handle realtime changes to evacuation points
  void _handleEvacuationPointChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          _handleEvacuationPointInsert(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          _handleEvacuationPointUpdate(payload.oldRecord, payload.newRecord);
          break;
        case PostgresChangeEvent.delete:
          _handleEvacuationPointDelete(payload.oldRecord);
          break;
        default:
          print('⚠️ Unknown event type: ${payload.eventType}');
      }
    } catch (e) {
      print('❌ Error handling evacuation point change: $e');
    }
  }

  /// Handle INSERT event - add new evacuation point to map
  void _handleEvacuationPointInsert(Map<String, dynamic> record) {
    try {
      final point = EvacuationPoint.fromJson(record);
      
      if (point.evacuationId != null) {
        // Avoid duplicates by checking ID
        final exists = _evacuationPointsData.any(
          (p) => p.evacuationId == point.evacuationId,
        );
        
        if (!exists) {
          _evacuationPointsData.add(point);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      print('Error handling INSERT: $e');
    }
  }

  void _handleEvacuationPointUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newPoint = EvacuationPoint.fromJson(newRecord);
      
      if (newPoint.evacuationId != null) {
        final index = _evacuationPointsData.indexWhere(
          (p) => p.evacuationId == newPoint.evacuationId,
        );
        
        if (index != -1) {
          _evacuationPointsData[index] = newPoint;
          _updateEvacuationPointsDisplay();
          print('Updated evacuation point: ${newPoint.evacuationId}');
        } else {
          _evacuationPointsData.add(newPoint);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      print('Error handling UPDATE: $e');
    }
  }

  /// Handle DELETE event - remove evacuation point from map
  void _handleEvacuationPointDelete(Map<String, dynamic> record) {
    try {
      final point = EvacuationPoint.fromJson(record);
      
      if (point.evacuationId != null) {
        _evacuationPointsData.removeWhere(
          (p) => p.evacuationId == point.evacuationId,
        );
        _updateEvacuationPointsDisplay();
        print('Removed evacuation point: ${point.evacuationId}');
      }
    } catch (e) {
      print('Error handling DELETE: $e');
    }
  }

  void _handleDisasterChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          _handleDisasterInsert(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          _handleDisasterUpdate(payload.oldRecord, payload.newRecord);
          break;
        case PostgresChangeEvent.delete:
          _handleDisasterDelete(payload.oldRecord);
          break;
        default:
          print('⚠️ Unknown disaster event type: ${payload.eventType}');
      }
    } catch (e) {
      print('❌ Error handling disaster change: $e');
    }
  }

  /// Handle INSERT event - add new disaster to map (only if from today)
  void _handleDisasterInsert(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      
      if (disaster.disasterId != null) {
        
        // Avoid duplicates by checking ID
        final exists = _disasterPointsData.any(
          (d) => d.disasterId == disaster.disasterId,
        );
        
        if (!exists) {
          _disasterPointsData.add(disaster);
          _updateDisasterPointsDisplay();
          print('✅ Added new disaster: ${disaster.disasterId}');
        }
      }
    } catch (e) {
      print('❌ Error handling disaster INSERT: $e');
    }
  }

  /// Handle UPDATE event - update existing disaster (only if from today)
  void _handleDisasterUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newDisaster = Disaster.fromJson(newRecord);
      
      final index = _disasterPointsData.indexWhere(
          (d) => d.disasterId == newDisaster.disasterId,
        );
        
        if (index != -1) {
          _disasterPointsData[index] = newDisaster;
          _updateDisasterPointsDisplay();
          print('Updated disaster: ${newDisaster.disasterId}');
        } else {
          _disasterPointsData.add(newDisaster);
          _updateDisasterPointsDisplay();
          print('Added disaster ${newDisaster.disasterId} - date updated to today');
        }
    } catch (e) {
      print('Error handling disaster UPDATE: $e');
    }
  }

  /// Handle DELETE event - remove disaster from map
  void _handleDisasterDelete(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      
      if (disaster.disasterId != null) {
        _disasterPointsData.removeWhere(
          (d) => d.disasterId == disaster.disasterId,
        );
        _updateDisasterPointsDisplay();
      }
    } catch (e) {
      print('Error handling disaster DELETE: $e');
    }
  }

  /// Update the display list from the SOS events data list
  void _updateSOSPointsDisplay() {
    sosPoints.value = _sosEventsData
        .where((sos) => sos.hasLocation() && sos.isActive)
        .map((sos) => LatLng(sos.locationLat!, sos.locationLng!))
        .toList();
  }

  Future<void> _loadSOSPoints() async {
    try {
      final sosEvents = await SupabaseService.getSoSEvents();
      
      final activeSOSEvents = sosEvents
          .where((sos) => sos.isActive)
          .toList();
      
      _sosEventsData.value = activeSOSEvents;
      _updateSOSPointsDisplay();
    } catch (e) {
      print('Error loading SOS events: $e');
      _sosEventsData.clear();
      _updateSOSPointsDisplay();
    }
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      
      LocationResult result = await LocationHelper.initializeLocation();
      
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      
      mapController.move(currentLocation.value, 15.0);
      
    } catch (e) {
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _getCurrentLocation() async {
    if (!hasLocationPermission.value) return;
    
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocationSilent();
      
      if (result.hasPermission) {
        currentLocation.value = result.location;
        mapController.move(currentLocation.value, 15.0);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  void refreshData() {
    _getCurrentLocation();
  }

  Future<void> retryLocationRequest() async {
    await _initializeLocation();
  }

  Future<void> getQuickLocation() async {
    await _initializeLocation();
  }

  Disaster? findDisasterByLocation(LatLng location) {
    const tolerance = 0.0001; // Small tolerance for floating point comparison
    
    try {
      return _disasterPointsData.firstWhere(
        (disaster) =>
            disaster.centerLat != null &&
            disaster.centerLng != null &&
            (disaster.centerLat! - location.latitude).abs() < tolerance &&
            (disaster.centerLng! - location.longitude).abs() < tolerance,
        orElse: () => throw StateError('No disaster found at this location'),
      );
    } catch (e) {
      print('No disaster found at location: ${location.latitude}, ${location.longitude}');
      return null;
    }
  }

  EvacuationPoint? findEvacuationPointByLocation(LatLng location) {
    const tolerance = 0.0001; // Small tolerance for floating point comparison
    
    try {
      return _evacuationPointsData.firstWhere(
        (point) =>
            point.locationLat != null &&
            point.locationLng != null &&
            (point.locationLat! - location.latitude).abs() < tolerance &&
            (point.locationLng! - location.longitude).abs() < tolerance,
        orElse: () => throw StateError('No evacuation point found at this location'),
      );
    } catch (e) {
      print('⚠️ No evacuation point found at location: ${location.latitude}, ${location.longitude}');
      return null;
    }
  }

  SosEvent? findSOSByLocation(LatLng location) {
    const tolerance = 0.0001; // Small tolerance for floating point comparison
    
    try {
      return _sosEventsData.firstWhere(
        (sos) =>
            sos.locationLat != null &&
            sos.locationLng != null &&
            (sos.locationLat! - location.latitude).abs() < tolerance &&
            (sos.locationLng! - location.longitude).abs() < tolerance,
        orElse: () => throw StateError('No SOS event found at this location'),
      );
    } catch (e) {
      print('⚠️ No SOS event found at location: ${location.latitude}, ${location.longitude}');
      return null;
    }
  }

  Future<ResqUser?> fetchUserById(String userId) async {
    try {
      return await SupabaseService.getUserById(userId);
    } catch (e) {
      print('❌ Error fetching user: $e');
      return null;
    }
  }

  Future<String> fetchSOSAddress(SosEvent sosEvent) async {
    if (sosEvent.locationLat == null || sosEvent.locationLng == null) {
      return 'Lokasi tidak tersedia';
    }

    try {
      final location = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);
      final result = await LocationHelper.getLocationDetails(location);
      return result.locationDetail;
    } catch (_) {
      return 'Lokasi tidak tersedia';
    }
  }

  String formatSOSReportTime(double? timestamp) {
  if (timestamp == null || timestamp == 0) return '-';

  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());

  final time =
      "${dateTime.hour.toString().padLeft(2, '0')}:"
      "${dateTime.minute.toString().padLeft(2, '0')}:"
      "${dateTime.second.toString().padLeft(2, '0')}";

  const months = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  final date =
      "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";

  return "$time, $date";
}

  Future<String> fetchDisasterAddress(Disaster disaster) async {
    final cacheKey = disaster.disasterId;

    final cachedAddress = _disasterAddressCache[cacheKey];
    if (cachedAddress != null) {
      return cachedAddress;
    }

    if (disaster.centerLat == null || disaster.centerLng == null) {
      const fallback = 'Lokasi tidak tersedia';
      _disasterAddressCache[cacheKey] = fallback;
      return fallback;
    }

    try {
      final location = LatLng(disaster.centerLat!, disaster.centerLng!);
      final result = await LocationHelper.getLocationDetails(location);
      final address = result.locationDetail;
      _disasterAddressCache[cacheKey] = address;
      return address;
    } catch (_) {
      const fallback = 'Lokasi tidak tersedia';
      _disasterAddressCache[cacheKey] = fallback;
      return fallback;
    }
  }

  String formatDisasterDate(double? timestamp) {
    if (timestamp == null) return 'Tidak tersedia';
    try {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()*1000);
      return '${_disasterDateFormatter.format(dateTime)} WIB';
    } catch (_) {
      return 'Tidak tersedia';
    }
  }

  String formatDisasterMagnitude(double? magnitude) {
    return magnitude != null
        ? '${magnitude.toStringAsFixed(2)} SR'
        : 'Tidak tersedia';
  }

  String getTsunamiPotential(double? magnitude) {
    if (magnitude == null) return 'Tidak Berpotensi';
    return magnitude >= 7.0 ? 'Berpotensi' : 'Tidak Berpotensi';
  }

  String formatDisasterDepth(String? depth) {
    return (depth == null || depth.isEmpty) ? 'Tidak tersedia' : depth;
  }

  Future<void> openDisasterShakeMap(Disaster disaster) async {
    final url = disaster.shakemap;
    if (url == null || url.isEmpty) {
      throw const DisasterActionException('Peta guncangan tidak tersedia');
    }

    try {
      final uri = Uri.parse(url);
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) {
        throw const DisasterActionException(
            'Tidak dapat membuka peta guncangan');
      }

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw const DisasterActionException(
            'Tidak dapat membuka peta guncangan');
      }
    } catch (e) {
      if (e is DisasterActionException) rethrow;
      throw DisasterActionException('Error: ${e.toString()}');
    }
  }
}

