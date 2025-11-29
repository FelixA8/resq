import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqapp/helpers/map_helper.dart';
import 'package:resqapp/services/distance_calculator.dart' as distance_calc;
import 'package:geocoding/geocoding.dart';

class UserMapViewModel extends GetxController {
  final Rx<ResqUser?> _currentUser = Rx(null);
  ResqUser? get currentUser => _currentUser.value;

  final MapController mapController = MapController();
  final Map<String, String> _disasterAddressCache = {};
  
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; 
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  
  final RxList<Disaster> _disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  
  final RxList<EvacuationPoint> _evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  
  final Rx<SOSWaitingViewModel?> _sosWaitingViewModel = Rx<SOSWaitingViewModel?>(null);
  final RxBool _isSOSActive = false.obs;
  final Rx<SosEvent?> _activeSosEvent = Rx<SosEvent?>(null);

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  final Rx<EvacuationPoint?> _currentNavigatingEvacuationPoint = Rx<EvacuationPoint?>(null);
  
  static const String _kSavedEvacuationId = 'saved_evacuation_point_id';

  // User location address
  final RxString currentAddress = 'Loading...'.obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  
  bool get isSOSActive => _isSOSActive.value;
  SOSWaitingViewModel? get sosWaitingViewModel => _sosWaitingViewModel.value;
  SosEvent? get activeSosEvent => _activeSosEvent.value;

  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    _startLocationStream();
    _initializeData();
    _checkForActiveSOS();
    _subscribeToEvacuationPoints();
    _subscribeToDisasters();
    _restoreNavigationState();

    _loadUserData();
    _loadDisasterPoints();
    _loadEvacuationPoints();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    _evacuationPointsSubscription?.unsubscribe();
    _disastersSubscription?.unsubscribe();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final user = await SupabaseService.getUserById(userId);
        _currentUser.value = user;
      }
    } catch (e) {
      developer.log('Error loading user data: $e');
    }
  }

  Future<void> _restoreNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kSavedEvacuationId);
      
      if (savedId != null) {
        final point = await SupabaseService.getEvacuationPointById(savedId);
        
        if (point != null) {
          showRouteToEvacuationPoint(point, saveState: false);
        } else {
          await prefs.remove(_kSavedEvacuationId);
        }
      }
    } catch (e) {
      developer.log('Error restoring navigation: $e');
    }
  }

  void _initializeData() {
    _loadDisasterPoints();
    _loadEvacuationPoints();
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      currentLocation.value = newLocation;
      _updateAddress(newLocation);
      _checkAndReroute(newLocation);
    });
  }

  Future<void> _checkForActiveSOS() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final sosEvent = await SupabaseService.getUserSosEvents(userId);

      if (sosEvent != null) {
        _activeSosEvent.value = sosEvent;
        _isSOSActive.value = true;
        
        if (_sosWaitingViewModel.value == null) {
          _sosWaitingViewModel.value = SOSWaitingViewModel(
            pressedAtMillis: sosEvent.pressedAt,
          );
        }
      }
    } catch (e) {
      developer.log('Error checking for active SOS: $e');
    }
  }

  void _updateDisasterPointsDisplay() {
    final validDisasters = _disasterPointsData
        .where((disaster) => disaster.centerLat != null && disaster.centerLng != null)
        .toList();
    
    disasterPoints.value = validDisasters
        .map((disaster) => LatLng(disaster.centerLat!, disaster.centerLng!))
        .toList();
  }

  Future<void> _loadDisasterPoints() async {
    try {
      final disasters = await SupabaseService.getFilteredDisasters();
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

  void _subscribeToEvacuationPoints() {
    try {
      final supabaseClient = Supabase.instance.client;
      _evacuationPointsSubscription = supabaseClient
          .channel('evacuation_points_changes_user')
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
      developer.log('Error setting up realtime subscription: $e');
    }
  }

  void _subscribeToDisasters() {
    try {
      final supabaseClient = Supabase.instance.client;
      _disastersSubscription = supabaseClient
          .channel('disasters_changes_user')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'disasters',
            callback: (payload) {
              _handleDisasterChange(payload);
            },
          )
          .subscribe();
    } catch (e) {
      developer.log('Error setting up disaster realtime subscription: $e');
    }
  }

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
      }
    } catch (e) {
      developer.log('Error handling evacuation point change: $e');
    }
  }

  void _handleEvacuationPointInsert(Map<String, dynamic> record) {
    try {
      final point = EvacuationPoint.fromJson(record);
      if (point.evacuationId != null) {
        final exists = _evacuationPointsData.any((p) => p.evacuationId == point.evacuationId);
        if (!exists) {
          _evacuationPointsData.add(point);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling INSERT: $e');
    }
  }

  void _handleEvacuationPointUpdate(Map<String, dynamic> oldRecord, Map<String, dynamic> newRecord) {
    try {
      final newPoint = EvacuationPoint.fromJson(newRecord);
      if (newPoint.evacuationId != null) {
        final index = _evacuationPointsData.indexWhere((p) => p.evacuationId == newPoint.evacuationId);
        if (index != -1) {
          _evacuationPointsData[index] = newPoint;
          _updateEvacuationPointsDisplay();
        } else {
          _evacuationPointsData.add(newPoint);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling UPDATE: $e');
    }
  }

  void _handleEvacuationPointDelete(Map<String, dynamic> record) {
    try {
      final point = EvacuationPoint.fromJson(record);
      if (point.evacuationId != null) {
        _evacuationPointsData.removeWhere((p) => p.evacuationId == point.evacuationId);
        _updateEvacuationPointsDisplay();
      }
    } catch (e) {
      developer.log('Error handling DELETE: $e');
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
      }
    } catch (e) {
      developer.log('Error handling disaster change: $e');
    }
  }

  bool _isDisasterFromToday(Disaster disaster) {
    if (disaster.occurredAt == null) return false;
    try {
      final disasterDate = DateTime.fromMillisecondsSinceEpoch(disaster.occurredAt!.toInt()*1000);
      final now = DateTime.now();
      return disasterDate.year == now.year && disasterDate.month == now.month && disasterDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  void _handleDisasterInsert(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      if (disaster.disasterId != null) {
        if (!_isDisasterFromToday(disaster)) return;
        final exists = _disasterPointsData.any((d) => d.disasterId == disaster.disasterId);
        if (!exists) {
          _disasterPointsData.add(disaster);
          _updateDisasterPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling disaster INSERT: $e');
    }
  }

  void _handleDisasterUpdate(Map<String, dynamic> oldRecord, Map<String, dynamic> newRecord) {
    try {
      final newDisaster = Disaster.fromJson(newRecord);
      if (newDisaster.disasterId != null) {
        if (!_isDisasterFromToday(newDisaster)) {
          final index = _disasterPointsData.indexWhere((d) => d.disasterId == newDisaster.disasterId);
          if (index != -1) {
            _disasterPointsData.removeAt(index);
            _updateDisasterPointsDisplay();
          }
          return;
        }
        final index = _disasterPointsData.indexWhere((d) => d.disasterId == newDisaster.disasterId);
        if (index != -1) {
          _disasterPointsData[index] = newDisaster;
          _updateDisasterPointsDisplay();
        } else {
          _disasterPointsData.add(newDisaster);
          _updateDisasterPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling disaster UPDATE: $e');
    }
  }

  void _handleDisasterDelete(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      if (disaster.disasterId != null) {
        _disasterPointsData.removeWhere((d) => d.disasterId == disaster.disasterId);
        _updateDisasterPointsDisplay();
      }
    } catch (e) {
      developer.log('Error handling disaster DELETE: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.initializeLocation();
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      mapController.move(currentLocation.value, 15.0);
      _updateAddress(currentLocation.value);
    } catch (e) {
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        // Priority: locality (district) > subLocality (neighborhood) > subAdministrativeArea (city)
        if (place.locality != null && place.locality!.isNotEmpty) {
          address = place.locality!;
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address = place.subLocality!;
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          address = place.subAdministrativeArea!;
        }
        
        if (address.isEmpty) {
          address = 'Unknown Location';
        }

        currentAddress.value = address;
        developer.log('User Location: ${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}');
      }
    } catch (e) {
      developer.log('Error getting address: $e');
      currentAddress.value = 'Location Unavailable';
    }
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  Disaster? findDisasterByLocation(LatLng location) {
    return MapHelper.findDisasterByLocation(_disasterPointsData, location);
  }

  EvacuationPoint? findEvacuationPointByLocation(LatLng location) {
    return MapHelper.findEvacuationPointByLocation(_evacuationPointsData, location);
  }

  Future<String> fetchDisasterAddress(Disaster disaster) {
    return MapHelper.getAddressFromLocation(
      disaster.centerLat,
      disaster.centerLng,
      _disasterAddressCache,
      disaster.disasterId,
    );
  }

  String formatDisasterDate(double? timestamp) => MapHelper.formatDisasterDate(timestamp);
  String formatDisasterMagnitude(double? magnitude) => MapHelper.formatMagnitude(magnitude);
  String getTsunamiPotential(double? magnitude) => MapHelper.getTsunamiPotential(magnitude);
  String formatDisasterDepth(String? depth) => MapHelper.formatDepth(depth);
  Future<void> openDisasterShakeMap(Disaster disaster) => MapHelper.launchShakeMap(disaster.shakemap);

  Future<void> showRouteToEvacuationPoint(EvacuationPoint point, {bool saveState = true}) async {
    if (!point.hasLocation()) {
      Get.snackbar("Error", "Lokasi Poin Evakuasi tidak valid");
      return;
    }

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }

    if (saveState) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedEvacuationId, point.evacuationId!);
    }

    _currentNavigatingEvacuationPoint.value = point;
    isRouteLoading.value = true;

    final start = currentLocation.value;
    final end = LatLng(point.locationLat!, point.locationLng!);

    try {
      final points = await MapHelper.getRoutePolyline(start, end);

      if (points.isNotEmpty) {
        routePoints.value = points;
      } else {
        Get.snackbar("Info", "Rute tidak ditemukan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat rute");
    } finally {
      isRouteLoading.value = false;
    }
  }

  void clearRoute() {
    routePoints.clear();
    _currentNavigatingEvacuationPoint.value = null;
  }

  Future<void> cancelEvacuationRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSavedEvacuationId);
    
    clearRoute();
  }

  bool isCurrentlyNavigatingToEvacuationPoint(EvacuationPoint point) {
    return _currentNavigatingEvacuationPoint.value?.evacuationId == point.evacuationId;
  }

  double calculateDistanceToEvacuationPoint(EvacuationPoint point) {
    if (!point.hasLocation()) return 0.0;
    return distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      LatLng(point.locationLat!, point.locationLng!),
    );
  }

  void _checkAndReroute(LatLng userLocation) {
    if (_currentNavigatingEvacuationPoint.value == null || routePoints.isEmpty || isRouteLoading.value) {
      return;
    }

    bool isOffRoute = MapHelper.isUserOffRoute(
      userLocation,
      routePoints,
      thresholdMeters: 50
    );

    if (isOffRoute) {
      final dest = _currentNavigatingEvacuationPoint.value!;
      if (dest.hasLocation()) {
        _silentReroute(userLocation, LatLng(dest.locationLat!, dest.locationLng!));
      }
    }
  }

  Future<void> _silentReroute(LatLng start, LatLng end) async {
    final points = await MapHelper.getRoutePolyline(start, end);
    if (points.isNotEmpty) {
      routePoints.value = points;
    }
  }

  void startSOS() {
    _isSOSActive.value = true;
    if (_sosWaitingViewModel.value == null) {
      _sosWaitingViewModel.value = SOSWaitingViewModel(
        pressedAtMillis: _activeSosEvent.value?.pressedAt,
      );
    }
  }
  
  void stopSOS() {
    _isSOSActive.value = false;
    _sosWaitingViewModel.value?.dispose();
    _sosWaitingViewModel.value = null;
    _activeSosEvent.value = null;
  }
  
  void updateActiveSosEvent(SosEvent sosEvent) {
    _activeSosEvent.value = sosEvent;
  }
}