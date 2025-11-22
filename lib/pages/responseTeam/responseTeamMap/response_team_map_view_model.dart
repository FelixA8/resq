import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/helpers/response_team_map_helper.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/managers/response_team_map_realtime_manager.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/services/distance_calculator.dart' as distance_calc;

class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  final Map<String, String> _addressCache = {};
  late final ResponseTeamRealtimeManager _realtimeManager;

  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;

  final RxList<Disaster> _disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  
  final RxList<EvacuationPoint> _evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  
  final RxList<SosEvent> _sosEventsData = <SosEvent>[].obs;
  final RxList<LatLng> sosPoints = <LatLng>[].obs;

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  final Rx<SosEvent?> _currentNavigatingSos = Rx<SosEvent?>(null);
  String? _currentResponseTeamId;

  StreamSubscription<Position>? _positionStreamSubscription;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await _loadCurrentResponseTeamId();
    await _initializeLocation();
    _startLocationStream();
    await _initializeData();
    _setupRealtimeManager();
    await _restoreNavigationIfNeeded();
  }

  Future<void> _loadCurrentResponseTeamId() async {
    final responseTeam = await SupabaseService.getStoredResponseTeam();
    _currentResponseTeamId = responseTeam?.responseTeamId;
  }

  @override
  void onClose() {
    _realtimeManager.dispose();
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _setupRealtimeManager() {
    _realtimeManager = ResponseTeamRealtimeManager(
      onEvacuationInsert: _onEvacuationInsert,
      onEvacuationUpdate: _onEvacuationUpdate,
      onEvacuationDelete: _onEvacuationDelete,
      onDisasterInsert: _onDisasterInsert,
      onDisasterUpdate: _onDisasterUpdate,
      onDisasterDelete: _onDisasterDelete,
      onSosInsert: _onSosInsert,
      onSosUpdate: _onSosUpdate,
      onSosDelete: _onSosDelete,
    );
    _realtimeManager.initSubscriptions();
  }

  Future<void> _initializeData() async {
    _loadDisasterPoints();
    _loadEvacuationPoints();
    await _loadSOSPoints();
  }

  Future<void> _loadDisasterPoints() async {
    try {
      final disasters = await SupabaseService.getAllDisasters();
      _disasterPointsData.value = disasters;
      _updateDisasterPointsDisplay();
    } catch (_) {
      _disasterPointsData.clear();
      _updateDisasterPointsDisplay();
    }
  }

  Future<void> _loadEvacuationPoints() async {
    try {
      final points = await SupabaseService.getEvacuationPoints();
      _evacuationPointsData.value = points;
      _updateEvacuationPointsDisplay();
    } catch (_) {
      _evacuationPointsData.clear();
      _updateEvacuationPointsDisplay();
    }
  }

  Future<void> _loadSOSPoints() async {
    try {
      final sosEvents = await SupabaseService.getSoSEvents();
      final activeSOSEvents = sosEvents.where((sos) => sos.isActive).toList();
      _sosEventsData.value = activeSOSEvents;
      _updateSOSPointsDisplay();
    } catch (_) {
      _sosEventsData.clear();
      _updateSOSPointsDisplay();
    }
  }


  Future<void> _restoreRoute(SosEvent sosEvent) async {
    if (sosEvent.locationLat == null || sosEvent.locationLng == null) {
      return;
    }

    _currentNavigatingSos.value = sosEvent;

    isRouteLoading.value = true;

    final start = currentLocation.value;
    final end = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);

    final points = await ResponseTeamMapHelper.getRoutePolyline(start, end);

    if (points.isNotEmpty) {
      routePoints.value = points;
    }

    isRouteLoading.value = false;
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.initializeLocation();
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      mapController.move(currentLocation.value, 15.0);
    } catch (_) {
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateDisasterPointsDisplay() {
    disasterPoints.value = _disasterPointsData
        .where((d) => d.centerLat != null && d.centerLng != null)
        .map((d) => LatLng(d.centerLat!, d.centerLng!))
        .toList();
  }

  void _updateEvacuationPointsDisplay() {
    evacuationPoints.value = _evacuationPointsData
        .where((p) => p.hasLocation())
        .map((p) => LatLng(p.locationLat!, p.locationLng!))
        .toList();
  }

  void _updateSOSPointsDisplay() {
    sosPoints.value = _sosEventsData
        .where((s) => s.hasLocation() && s.isActive)
        .map((s) => LatLng(s.locationLat!, s.locationLng!))
        .toList();
  }

  void _onEvacuationInsert(EvacuationPoint point) {
    if (point.evacuationId == null) return;
    final exists = _evacuationPointsData.any((p) => p.evacuationId == point.evacuationId);
    if (!exists) {
      _evacuationPointsData.add(point);
      _updateEvacuationPointsDisplay();
    }
  }

  void _onEvacuationUpdate(EvacuationPoint point) {
    if (point.evacuationId == null) return;
    final index = _evacuationPointsData.indexWhere((p) => p.evacuationId == point.evacuationId);
    if (index != -1) {
      _evacuationPointsData[index] = point;
      _updateEvacuationPointsDisplay();
    } else {
      _evacuationPointsData.add(point);
      _updateEvacuationPointsDisplay();
    }
  }

  void _onEvacuationDelete(EvacuationPoint point) {
    if (point.evacuationId == null) return;
    _evacuationPointsData.removeWhere((p) => p.evacuationId == point.evacuationId);
    _updateEvacuationPointsDisplay();
  }

  void _onDisasterInsert(Disaster disaster) {
    if (disaster.disasterId == null) return;
    final exists = _disasterPointsData.any((d) => d.disasterId == disaster.disasterId);
    if (!exists) {
      _disasterPointsData.add(disaster);
      _updateDisasterPointsDisplay();
    }
  }

  void _onDisasterUpdate(Disaster disaster) {
    if (disaster.disasterId == null) return;
    final index = _disasterPointsData.indexWhere((d) => d.disasterId == disaster.disasterId);
    if (index != -1) {
      _disasterPointsData[index] = disaster;
      _updateDisasterPointsDisplay();
    } else {
      _disasterPointsData.add(disaster);
      _updateDisasterPointsDisplay();
    }
  }

  void _onDisasterDelete(Disaster disaster) {
    if (disaster.disasterId == null) return;
    _disasterPointsData.removeWhere((d) => d.disasterId == disaster.disasterId);
    _updateDisasterPointsDisplay();
  }

  void _onSosInsert(SosEvent sos) {
    if (sos.sosId.isNotEmpty && sos.isActive) {
      final exists = _sosEventsData.any((s) => s.sosId == sos.sosId);
      if (!exists) {
        _sosEventsData.add(sos);
        _updateSOSPointsDisplay();
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _onSosUpdate(SosEvent sos) {
    if (sos.sosId.isEmpty) return;
    final index = _sosEventsData.indexWhere((s) => s.sosId == sos.sosId);
    if (index != -1) {
      _sosEventsData[index] = sos;
      _updateSOSPointsDisplay();
    } else if (sos.isActive) {
      _sosEventsData.add(sos);
      _updateSOSPointsDisplay();
      HapticFeedback.heavyImpact();
    }
  }

  void _onSosDelete(SosEvent sos) {
    if (sos.sosId.isEmpty) return;
    _sosEventsData.removeWhere((s) => s.sosId == sos.sosId);
    _updateSOSPointsDisplay();
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  Future<void> refreshData() async {
    if (!hasLocationPermission.value) return;
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocationSilent();
      if (result.hasPermission) {
        currentLocation.value = result.location;
        mapController.move(currentLocation.value, 15.0);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Disaster? findDisasterByLocation(LatLng location) {
    return ResponseTeamMapHelper.findDisasterByLocation(_disasterPointsData, location);
  }

  EvacuationPoint? findEvacuationPointByLocation(LatLng location) {
    return ResponseTeamMapHelper.findEvacuationPointByLocation(_evacuationPointsData, location);
  }

  SosEvent? findSOSByLocation(LatLng location) {
    return ResponseTeamMapHelper.findSOSByLocation(_sosEventsData, location);
  }

  SosEvent? findSOSById(String sosId) {
    try {
      final list = _sosEventsData;
      return list.firstWhere((s) => s.sosId == sosId);
    } catch (_) {
      return null;
    }
  }

  int get sosEventsCount => _sosEventsData.length;

  Future<ResqUser?> fetchUserById(String userId) async {
    try {
      return await SupabaseService.getUserById(userId);
    } catch (_) {
      return null;
    }
  }

  Future<String> fetchSOSAddress(SosEvent sosEvent) {
    return ResponseTeamMapHelper.getAddressFromLocation(
      sosEvent.locationLat,
      sosEvent.locationLng,
      _addressCache,
      sosEvent.sosId,
    );
  }

  Future<String> fetchDisasterAddress(Disaster disaster) {
    return ResponseTeamMapHelper.getAddressFromLocation(
      disaster.centerLat,
      disaster.centerLng,
      _addressCache,
      disaster.disasterId,
    );
  }

  String formatSOSReportTime(double? timestamp) {
    return ResponseTeamMapHelper.formatSOSReportTime(timestamp);
  }

  String formatDisasterDate(double? timestamp) {
    return ResponseTeamMapHelper.formatDisasterDate(timestamp);
  }

  String formatDisasterMagnitude(double? magnitude) {
    return ResponseTeamMapHelper.formatMagnitude(magnitude);
  }

  String getTsunamiPotential(double? magnitude) {
    return ResponseTeamMapHelper.getTsunamiPotential(magnitude);
  }

  String formatDisasterDepth(String? depth) {
    return ResponseTeamMapHelper.formatDepth(depth);
  }

  Future<void> openDisasterShakeMap(Disaster disaster) {
    return ResponseTeamMapHelper.launchShakeMap(disaster.shakemap);
  }

  Future<void> showRouteToSos(SosEvent sosEvent) async {
    if (sosEvent.locationLat == null || sosEvent.locationLng == null) {
      Get.snackbar("Error", "Lokasi SOS tidak valid");
      return;
    }

    if (_currentResponseTeamId == null) {
      await _loadCurrentResponseTeamId();
    }

    if (_currentResponseTeamId == null) {
      Get.snackbar("Error", "Response team ID tidak ditemukan");
      return;
    }

    final success = await SupabaseService.assignSosToTeam(
      sosId: sosEvent.sosId,
      responseTeamId: _currentResponseTeamId!,
    );

    if (!success) {
      Get.snackbar("Error", "Gagal mengassign SOS");
      return;
    }

    _currentNavigatingSos.value = sosEvent;
    
    Get.back();

    isRouteLoading.value = true;
    
    final start = currentLocation.value;
    final end = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);

    final points = await ResponseTeamMapHelper.getRoutePolyline(start, end);
    
    if (points.isNotEmpty) {
      routePoints.value = points;
    } else {
      Get.snackbar("Info", "Rute tidak ditemukan");
    }
    
    isRouteLoading.value = false;
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

      _checkAndReroute(newLocation);
    });
  }

  void _checkAndReroute(LatLng userLocation) {
    if (_currentNavigatingSos.value == null || routePoints.isEmpty || isRouteLoading.value) {
      return;
    }
    bool isOffRoute = ResponseTeamMapHelper.isUserOffRoute(
      userLocation, 
      routePoints, 
      thresholdMeters: 50
    );

    if (isOffRoute) {
      _silentReroute(userLocation, _currentNavigatingSos.value!);
    }
  }

  Future<void> _silentReroute(LatLng start, SosEvent destination) async {
    final end = LatLng(destination.locationLat!, destination.locationLng!);
    final points = await ResponseTeamMapHelper.getRoutePolyline(start, end);

    if (points.isNotEmpty) {
      routePoints.value = points;
    }
  }
  
  void clearRoute() {
    routePoints.clear();
    _currentNavigatingSos.value = null;
  }

  Future<void> cancelRoute(SosEvent sosEvent) async {
    final success = await SupabaseService.unassignSosFromTeam(sosEvent.sosId);
    
    if (success) {
      clearRoute();
      Get.back();
    } else {
      Get.snackbar("Error", "Gagal membatalkan rute");
    }
  }

  bool isCurrentlyNavigatingTo(SosEvent sosEvent) {
    return _currentNavigatingSos.value?.sosId == sosEvent.sosId;
  }

  String? getCurrentResponseTeamId() => _currentResponseTeamId;

  double calculateDistanceToSos(SosEvent sosEvent) {
    if (sosEvent.locationLat == null || sosEvent.locationLng == null) {
      return 0.0;
    }
    return distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      LatLng(sosEvent.locationLat!, sosEvent.locationLng!),
    );
  }

  Future<void> _restoreNavigationIfNeeded() async {
    if (_currentResponseTeamId == null) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (currentLocation.value == LatLng(-6.2088, 106.8456)) {
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      final assignedSos = _sosEventsData.firstWhere(
        (sos) => sos.responseTeamId == _currentResponseTeamId && 
                 sos.isActive &&
                 sos.hasLocation(),
        orElse: () => SosEvent(sosId: ''),
      );

      if (assignedSos.sosId.isNotEmpty) {
        await _restoreRoute(assignedSos);
      }
    } catch (_) {}
  }
}