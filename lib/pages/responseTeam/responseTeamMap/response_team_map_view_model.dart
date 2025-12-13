import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/helpers/map_helper.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/route_warning_dialog.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/managers/response_team_map_realtime_manager.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/extensions/map_animation_config.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/services/distance_calculator.dart' as distance_calc;
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

class ResponseTeamMapViewModel extends GetxController with GetTickerProviderStateMixin {
  final String instanceCode;
  late final AnimatedMapController mapController;
  
  final Map<String, String> _addressCache = {};
  late final ResponseTeamRealtimeManager _realtimeManager;

  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;

  // Response team location address
  final RxString currentAddress = 'Loading...'.obs;

  final RxList<Disaster> _disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  
  final RxList<EvacuationPoint> _evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  
  final RxList<SosEvent> _sosEventsData = <SosEvent>[].obs;
  final RxList<LatLng> sosPoints = <LatLng>[].obs;

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  
  final Rx<SosEvent?> _currentNavigatingSos = Rx<SosEvent?>(null);
  final Rx<EvacuationPoint?> _currentNavigatingEvacuationPoint = Rx<EvacuationPoint?>(null);
  
  String? _currentResponseTeamId;

  StreamSubscription<Position>? _positionStreamSubscription;

  // Enhanced Navigation State
  final RxBool isNavigating = false.obs;
  final RxDouble currentHeading = 0.0.obs;
  final RxBool isMapCentering = true.obs;
  final RxDouble distanceToDestination = 0.0.obs;
  final Rx<LatLng?> navigationDestination = Rx<LatLng?>(null);
  final RxInt currentRouteSegment = 0.obs;
  final RxList<LatLng> remainingRoutePoints = <LatLng>[].obs;
  
  // Navigation Instructions
  final RxString currentInstruction = ''.obs;
  final RxDouble distanceToNextTurn = 0.0.obs;
  final RxString turnType = ''.obs; // 'left', 'right', 'straight', etc.
  List<RouteStep> _routeSteps = [];
  int _currentStepIndex = 0;
  
  // Arrival State
  final RxBool hasArrived = false.obs;
  
  Timer? _idleTimer;
  Timer? _arrivalCheckTimer;
  bool _hasShownArrivalNotification = false;
  LatLng? _lastLocation;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    super.onInit();
    mapController = AnimatedMapController(vsync: this);
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await _loadCurrentResponseTeamId();
    await _initializeLocation();
    await _initializeData();
    await _restoreNavigationIfNeeded();
    _startLocationStream();
    _setupRealtimeManager();
   
  }

  Future<void> _loadCurrentResponseTeamId() async {
    final responseTeam = await SupabaseService.getStoredResponseTeam();
    _currentResponseTeamId = responseTeam?.responseTeamId;
  }

  @override
  void onClose() {
    _realtimeManager.dispose();
    _positionStreamSubscription?.cancel();
    _idleTimer?.cancel();
    _arrivalCheckTimer?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    mapController.dispose();
    _idleTimer?.cancel();
    _arrivalCheckTimer?.cancel();
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
    if (sosEvent.locationLat == null || sosEvent.locationLng == null) return;
    
    _currentNavigatingSos.value = sosEvent;
    _currentNavigatingEvacuationPoint.value = null;
    
    isRouteLoading.value = true;
    
    final start = currentLocation.value;
    final end = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);
    
    // Set navigation destination first
    navigationDestination.value = end;

    print("SOS EVENt:");
    print(sosEvent);
    
    final routeData = await MapHelper.getRouteWithInstructions(start, end);
    if (routeData != null && routeData.polyline.isNotEmpty) {
      // Set navigation state before updating route points
      isNavigating.value = true;
      currentRouteSegment.value = 0;
      _hasShownArrivalNotification = false;
      isMapCentering.value = true;
      
      // Store route steps for navigation instructions
      _routeSteps = routeData.steps;
      _currentStepIndex = 0;
      _updateNavigationInstructions();
      
      // Defer route points update to next frame to prevent overlap with current location icon rendering
      await Future.delayed(const Duration(milliseconds: 100));
      
      routePoints.value = routeData.polyline;
      remainingRoutePoints.value = routeData.polyline;
      
      // Center on user location after route is set
      _centerOnUserLocation(animate: true);
    }
    
    isRouteLoading.value = false;
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.initializeLocation();
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      await mapController.animateTo(
        dest: currentLocation.value,
        zoom: MapAnimationConfig.initialZoom,
        curve: MapAnimationConfig.defaultCurve,
        duration: MapAnimationConfig.initialCenterDuration,
      );
      _updateAddress(currentLocation.value);
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
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          address = place.subAdministrativeArea!;
        }

        if (address.isEmpty) {
          address = 'Unknown Location';
        }

        currentAddress.value = address;
        developer.log(
          'Response Team Location: ${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}',
        );
      }
    } catch (e) {
      developer.log('Error getting address: $e');
      currentAddress.value = 'Location Unavailable';
    }
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
      
      // Update route if currently navigating to this evacuation point
      if (_currentNavigatingEvacuationPoint.value?.evacuationId == point.evacuationId) {
        _restoreEvacuationRoute(point);
      }
    } else {
      _evacuationPointsData.add(point);
      _updateEvacuationPointsDisplay();
    }
  }

  void _onEvacuationDelete(EvacuationPoint point) {
    if (point.evacuationId == null) return;
    _evacuationPointsData.removeWhere((p) => p.evacuationId == point.evacuationId);
    
    // Clear route if currently navigating to this evacuation point
    if (_currentNavigatingEvacuationPoint.value?.evacuationId == point.evacuationId) {
      clearRoute();
    }
    
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

    if(_currentNavigatingSos.value?.sosId == sos.sosId) {
        clearRoute();
    }

    _updateSOSPointsDisplay();
  }

  void moveToLocation(LatLng location) {
    mapController.animateTo(
      dest: location,
      zoom: MapAnimationConfig.manualLocationZoom,
      curve: MapAnimationConfig.defaultCurve,
      duration: MapAnimationConfig.userTriggeredDuration,
    );
  }

  void onMapMoved() {
    _idleTimer?.cancel();
    if (!isNavigating.value) return;
    
    if (isMapCentering.value) {
      isMapCentering.value = false;
    }
    
    final mapCenter = mapController.mapController.camera.center;
    
    final distanceFromUser = distance_calc.GeoDistanceCalculator.calculateDistance(
      mapCenter,
      currentLocation.value,
    );
    
    const double proximityThresholdKm = 2;

    if (distanceFromUser < proximityThresholdKm) {
      _resetIdleTimer();
    }
  }

  void _resetIdleTimer() {
    _idleTimer = Timer(const Duration(seconds: 3), () {
      if (isNavigating.value && !isMapCentering.value) {
        _enableAutoCentering();
      }
    });
  }

  void _enableAutoCentering() {
    isMapCentering.value = true;
    _centerOnUserLocation(animate: true);
  }

  void _centerOnUserLocation({bool animate = true}) {
    if (!isNavigating.value || !isMapCentering.value) return;
    
    mapController.animateTo(
      dest: currentLocation.value,
      zoom: MapAnimationConfig.navigationZoom,
      curve: MapAnimationConfig.defaultCurve,
      duration: MapAnimationConfig.autoCenterDuration,
    );
  }

  Future<void> refreshData() async {
    if (!hasLocationPermission.value) return;
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocationSilent();
      if (result.hasPermission) {
        currentLocation.value = result.location;
        await mapController.animateTo(
          dest: currentLocation.value,
          zoom: MapAnimationConfig.initialZoom,
          curve: MapAnimationConfig.defaultCurve,
          duration: MapAnimationConfig.userTriggeredDuration,
        );
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Disaster? findDisasterByLocation(LatLng location) {
    return MapHelper.findDisasterByLocation(_disasterPointsData, location);
  }

  EvacuationPoint? findEvacuationPointByLocation(LatLng location) {
    return MapHelper.findEvacuationPointByLocation(_evacuationPointsData, location);
  }

  SosEvent? findSOSByLocation(LatLng location) {
    return MapHelper.findSOSByLocation(_sosEventsData, location);
  }

  SosEvent? findSOSById(String sosId) {
    try {
      return _sosEventsData.firstWhere((s) => s.sosId == sosId);
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
    return MapHelper.getAddressFromLocation(
      sosEvent.locationLat,
      sosEvent.locationLng,
      _addressCache,
      sosEvent.sosId,
    );
  }

  Future<String> fetchDisasterAddress(Disaster disaster) {
    return MapHelper.getAddressFromLocation(
      disaster.centerLat,
      disaster.centerLng,
      _addressCache,
      disaster.disasterId,
    );
  }

  String formatSOSReportTime(double? timestamp) => MapHelper.formatSOSReportTime(timestamp);
  String formatDisasterDate(double? timestamp) => MapHelper.formatDisasterDate(timestamp);
  String formatDisasterMagnitude(double? magnitude) => MapHelper.formatMagnitude(magnitude);
  String getTsunamiPotential(double? magnitude) => MapHelper.getTsunamiPotential(magnitude);
  String formatDisasterDepth(String? depth) => MapHelper.formatDepth(depth);
  Future<void> openDisasterShakeMap(Disaster disaster) => MapHelper.launchShakeMap(disaster.shakemap);

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

    // Clear Evacuation navigation if exists (no warning needed since SOS is higher priority usually)
    if (_currentNavigatingEvacuationPoint.value != null) {
      _currentNavigatingEvacuationPoint.value = null;
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
    _currentNavigatingEvacuationPoint.value = null;

    isRouteLoading.value = true;
    
    final start = currentLocation.value;
    final end = LatLng(sosEvent.locationLat!, sosEvent.locationLng!);

    final routeData = await MapHelper.getRouteWithInstructions(start, end);
    
    if (routeData != null && routeData.polyline.isNotEmpty) {
      routePoints.value = routeData.polyline;
      remainingRoutePoints.value = routeData.polyline;
      
      // Store route steps for navigation instructions
      _routeSteps = routeData.steps;
      _currentStepIndex = 0;
      _updateNavigationInstructions();
      
      isNavigating.value = true;
      navigationDestination.value = end;
      currentRouteSegment.value = 0;
      _hasShownArrivalNotification = false;
      isMapCentering.value = true;

      final distance = distance_calc.GeoDistanceCalculator.calculateDistance(
        currentLocation.value,
        navigationDestination.value!,
      );
      distanceToDestination.value = distance;

      await _saveNavigationState(sosId: sosEvent.sosId);

      _centerOnUserLocation(animate: true);
    } else {
      Get.snackbar("Info", "Rute tidak ditemukan");
    }
    
    isRouteLoading.value = false;
  }

  Future<void> showRouteToEvacuationPoint(EvacuationPoint point) async {
    if (!point.hasLocation()) {
      Get.snackbar("Error", "Lokasi Poin Evakuasi tidak valid");
      return;
    }

    if (_currentNavigatingSos.value != null) {
      RouteWarningDialog.show(onConfirmDelete: () async {
        Get.back(); // Close dialog
          
          // Unassign active SOS
          final sosId = _currentNavigatingSos.value!.sosId;
          final success = await SupabaseService.unassignSosFromTeam(sosId);
          
          if (success) {
             // Close the bottom sheet if open
             if (Get.isBottomSheetOpen ?? false) {
               Get.back();
             }
             
             _startNavigationToEvacuationPoint(point);
          } else {
             Get.snackbar("Error", "Gagal membatalkan rute SOS");
          }
      });
      return;
    }

    Get.back();
    
    _startNavigationToEvacuationPoint(point);
  }

  Future<void> _startNavigationToEvacuationPoint(EvacuationPoint point) async {
    _currentNavigatingEvacuationPoint.value = point;
    _currentNavigatingSos.value = null;

    isRouteLoading.value = true;

    final start = currentLocation.value;
    final end = LatLng(point.locationLat!, point.locationLng!);

    final routeData = await MapHelper.getRouteWithInstructions(start, end);

    if (routeData != null && routeData.polyline.isNotEmpty) {
      routePoints.value = routeData.polyline;
      remainingRoutePoints.value = routeData.polyline;
      
      // Store route steps for navigation instructions
      _routeSteps = routeData.steps;
      _currentStepIndex = 0;
      _updateNavigationInstructions();
      
      // Initialize navigation state
      isNavigating.value = true;
      navigationDestination.value = end;
      currentRouteSegment.value = 0;
      _hasShownArrivalNotification = false;
      isMapCentering.value = true;

      final distance = distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      navigationDestination.value!,
    );
    
    distanceToDestination.value = distance;
      
      await _saveNavigationState(evacuationId: point.evacuationId);
      
      // Center on user location with animation
      _centerOnUserLocation(animate: true);
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
      
      // Update heading/bearing for arrow rotation
      if (_lastLocation != null && isNavigating.value) {
        final heading = _calculateHeading(_lastLocation!, newLocation);
        if (heading >= 0) {
          currentHeading.value = heading;
        }
      }

      print(isNavigating.value.toString());

      _lastLocation = newLocation;
      currentLocation.value = newLocation;
      _updateAddress(newLocation);

      if (isNavigating.value) {
        _updateNavigationState(newLocation);
        
        // Auto-center if enabled
        if (isMapCentering.value) {
          _centerOnUserLocation(animate: true);
        }
      }

      _checkAndReroute(newLocation);
    });
  }

  double _calculateHeading(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void _updateNavigationState(LatLng userLocation) {
    // Ensure navigationDestination is set from current navigation target
    if (navigationDestination.value == null) {
      if (_currentNavigatingSos.value != null && _currentNavigatingSos.value!.hasLocation()) {
        navigationDestination.value = LatLng(
          _currentNavigatingSos.value!.locationLat!,
          _currentNavigatingSos.value!.locationLng!,
        );
      } else if (_currentNavigatingEvacuationPoint.value != null && 
                 _currentNavigatingEvacuationPoint.value!.hasLocation()) {
        navigationDestination.value = LatLng(
          _currentNavigatingEvacuationPoint.value!.locationLat!,
          _currentNavigatingEvacuationPoint.value!.locationLng!,
        );
      } else {
        return; // No valid destination
      }
    }

    final distance = distance_calc.GeoDistanceCalculator.calculateDistance(
      userLocation,
      navigationDestination.value!,
    );
    
    distanceToDestination.value = distance;

    _updateRouteProgress(userLocation);
    _updateNavigationInstructions();

    _checkArrival(distance);
  }

  void _updateRouteProgress(LatLng userLocation) {
    if (routePoints.isEmpty) return;

    // Find nearest point on route
    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final distance = distance_calc.GeoDistanceCalculator.calculateDistance(
        userLocation,
        routePoints[i],
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    // Update current segment and remaining route
    if (nearestIndex != currentRouteSegment.value) {
      currentRouteSegment.value = nearestIndex;
      
      // If user is at or past the last point, clear the remaining route
      if (nearestIndex >= routePoints.length - 1) {
        remainingRoutePoints.clear();
      } else {
        // Update remaining route points (from current position to end)
        remainingRoutePoints.value = routePoints.sublist(nearestIndex);
      }
    }
}


  void _updateNavigationInstructions() {
    if (_routeSteps.isEmpty || currentLocation.value == null) {
      currentInstruction.value = '';
      distanceToNextTurn.value = 0.0;
      turnType.value = '';
      return;
    }

    // Find the next step based on current location
    for (int i = _currentStepIndex; i < _routeSteps.length; i++) {
      final step = _routeSteps[i];
      final distanceToStep = distance_calc.GeoDistanceCalculator.calculateDistance(
        currentLocation.value,
        step.location,
      );

      // If we're close to this step's location (within 50m), move to next step
      if (distanceToStep < 0.05 && i < _routeSteps.length - 1) {
        _currentStepIndex = i + 1;
        continue;
      }

      // This is our current step
      _currentStepIndex = i;
      distanceToNextTurn.value = distanceToStep * 1000; // Convert km to meters
      
      // Set turn type based on maneuver type and modifier
      final maneuverType = step.maneuverType.toLowerCase();
      final modifier = step.maneuverModifier?.toLowerCase() ?? '';
      
      // Handle U-turns specifically
      if (modifier == 'uturn' || maneuverType == 'uturn') {
        turnType.value = 'uturn';
      }
      // Handle roundabouts
      else if (maneuverType.contains('roundabout') || maneuverType == 'rotary') {
        turnType.value = 'roundabout';
      }
      // Handle regular turns
      else if (modifier.contains('left')) {
        turnType.value = 'left';
      } else if (modifier.contains('right')) {
        turnType.value = 'right';
      } else if (modifier.contains('straight') || maneuverType == 'continue') {
        turnType.value = 'straight';
      } else {
        turnType.value = 'straight'; // Default
      }
      
      // Format instruction text
      final distanceText = _formatDistance(distanceToStep * 1000);
      final direction = _getDirectionText(maneuverType, modifier);
      currentInstruction.value = '$distanceText $direction';
      
      break;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  String _getDirectionText(String maneuverType, String modifier) {
    // Handle U-turns first
    if (modifier == 'uturn' || maneuverType == 'uturn') {
      return 'putar balik';
    }
    
    // Handle roundabouts
    if (maneuverType.contains('roundabout') || maneuverType == 'rotary') {
      if (modifier.contains('left')) {
        return 'keluar bundaran ke kiri';
      } else if (modifier.contains('right')) {
        return 'keluar bundaran ke kanan';
      } else {
        return 'masuk bundaran';
      }
    }
    
    // Handle regular turns
    if (modifier.contains('slight left')) {
      return 'belok kiri sedikit';
    } else if (modifier.contains('sharp left')) {
      return 'belok kiri tajam';
    } else if (modifier.contains('left')) {
      return 'belok kiri';
    } else if (modifier.contains('slight right')) {
      return 'belok kanan sedikit';
    } else if (modifier.contains('sharp right')) {
      return 'belok kanan tajam';
    } else if (modifier.contains('right')) {
      return 'belok kanan';
    } else if (modifier.contains('straight') || maneuverType == 'continue') {
      return 'lurus';
    } else {
      return 'lanjutkan';
    }
  }

  void _checkArrival(double distanceKm) {
    const double arrivalThresholdKm = 0.10; // 30 meters
    
    // Set arrival state when within 30m radius
    if (distanceKm <= arrivalThresholdKm) {
      hasArrived.value = true;
      
      // Show notification only once
      if (!_hasShownArrivalNotification) {
        _hasShownArrivalNotification = true;
        _onArrival();
      }
    } else {
      hasArrived.value = false;
    }
  }

  void _onArrival() {
    HapticFeedback.heavyImpact();
  }

  Future<void> completeNavigation() async {
    await SupabaseService.deleteSosEventById(_currentNavigatingSos.value!.sosId);
    clearRoute();

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
  void _checkAndReroute(LatLng userLocation) {
    if ((_currentNavigatingSos.value == null && _currentNavigatingEvacuationPoint.value == null) || 
        routePoints.isEmpty || 
        isRouteLoading.value) {
      return;
    }
    
    bool isOffRoute = MapHelper.isUserOffRoute(
      userLocation, 
      routePoints, 
      thresholdMeters: 50
    );

    if (isOffRoute) {
      if (_currentNavigatingSos.value != null) {
        _silentReroute(userLocation, LatLng(_currentNavigatingSos.value!.locationLat!, _currentNavigatingSos.value!.locationLng!));
      } else if (_currentNavigatingEvacuationPoint.value != null) {
        _silentReroute(userLocation, LatLng(_currentNavigatingEvacuationPoint.value!.locationLat!, _currentNavigatingEvacuationPoint.value!.locationLng!));
      }
    }
  }

  Future<void> _silentReroute(LatLng start, LatLng end) async {
    final routeData = await MapHelper.getRouteWithInstructions(start, end);
    if (routeData != null && routeData.polyline.isNotEmpty) {
      routePoints.value = routeData.polyline;
      remainingRoutePoints.value = routeData.polyline;
      
      _routeSteps = routeData.steps;
      _currentStepIndex = 0;
      
      currentRouteSegment.value = 0;
      
      navigationDestination.value = end;
      
      _updateNavigationInstructions();
    }
  }
  
  void clearRoute() {
    routePoints.clear();
    remainingRoutePoints.clear();
    _currentNavigatingSos.value = null;
    _currentNavigatingEvacuationPoint.value = null;
    
    isNavigating.value = false;
    isMapCentering.value = true;
    navigationDestination.value = null;
    currentRouteSegment.value = 0;
    distanceToDestination.value = 0.0;
    currentHeading.value = 0.0;
    _hasShownArrivalNotification = false;
    hasArrived.value = false;
    
    currentInstruction.value = '';
    distanceToNextTurn.value = 0.0;
    turnType.value = '';
    _routeSteps = [];
    _currentStepIndex = 0;
    
    _idleTimer?.cancel();
    _arrivalCheckTimer?.cancel();
    
    _clearNavigationState();
  }

  Future<void> cancelRoute(SosEvent sosEvent) async {
    await SupabaseService.unassignSosFromTeam(_currentNavigatingSos.value!.sosId);
    clearRoute();
    Get.back();
  }

  void cancelEvacuationRoute() {
    clearRoute();
    Get.back();
  }

  bool isCurrentlyNavigatingTo(SosEvent sosEvent) {
    return _currentNavigatingSos.value?.sosId == sosEvent.sosId;
  }

  bool isCurrentlyNavigatingToEvacuationPoint(EvacuationPoint point) {
    return _currentNavigatingEvacuationPoint.value?.evacuationId == point.evacuationId;
  }

  String? getCurrentResponseTeamId() => _currentResponseTeamId;

  double calculateDistanceToSos(SosEvent sosEvent) {
    if (!sosEvent.hasLocation()) return 0.0;
    return distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      LatLng(sosEvent.locationLat!, sosEvent.locationLng!),
    );
  }

  double calculateDistanceToEvacuationPoint(EvacuationPoint point) {
    if (!point.hasLocation()) return 0.0;
    return distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      LatLng(point.locationLat!, point.locationLng!),
    );
  }

  Future<void> _saveNavigationState({String? sosId, String? evacuationId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (sosId != null) {
      await prefs.setString('navigating_sos_id', sosId);
      await prefs.remove('navigating_evacuation_id');
    } else if (evacuationId != null) {
      await prefs.setString('navigating_evacuation_id', evacuationId);
      await prefs.remove('navigating_sos_id');
    }
  }

  Future<Map<String, String?>> _loadNavigationState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'sosId': prefs.getString('navigating_sos_id'),
      'evacuationId': prefs.getString('navigating_evacuation_id'),
    };
  }

  Future<void> _clearNavigationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('navigating_sos_id');
    await prefs.remove('navigating_evacuation_id');
  }

  Future<void> _restoreNavigationIfNeeded() async {
    if (_currentResponseTeamId == null) return;
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final navigationState = await _loadNavigationState();
      final savedSosId = navigationState['sosId'];
      final savedEvacuationId = navigationState['evacuationId'];

      if (savedSosId != null) {
        final assignedSos = _sosEventsData.firstWhere(
          (sos) => sos.sosId == savedSosId && 
                   sos.responseTeamId == _currentResponseTeamId && 
                   sos.isActive &&
                   sos.hasLocation(),
          orElse: () => SosEvent(sosId: ''),
        );

        if (assignedSos.sosId.isNotEmpty) {
          await _restoreRoute(assignedSos);
          return;
        } else {
          await _clearNavigationState();
        }
      }

      if (savedEvacuationId != null) {
        final evacuationPoint = _evacuationPointsData.firstWhere(
          (point) => point.evacuationId == savedEvacuationId && point.hasLocation(),
          orElse: () => EvacuationPoint(evacuationId: null),
        );

        if (evacuationPoint.evacuationId != null) {
          await _restoreEvacuationRoute(evacuationPoint);
        } else {
          await _clearNavigationState();
        }
      }
    } catch (_) {
      await _clearNavigationState();
    }
  }

  Future<void> _restoreEvacuationRoute(EvacuationPoint point) async {
    if (!point.hasLocation()) return;
    
    _currentNavigatingEvacuationPoint.value = point;
    _currentNavigatingSos.value = null;
    
    isRouteLoading.value = true;
    
    final start = currentLocation.value;
    final end = LatLng(point.locationLat!, point.locationLng!);
    
    navigationDestination.value = end;
    
    final routeData = await MapHelper.getRouteWithInstructions(start, end);
    if (routeData != null && routeData.polyline.isNotEmpty) {
      isNavigating.value = true;
      currentRouteSegment.value = 0;
      _hasShownArrivalNotification = false;
      isMapCentering.value = true;
      
      _routeSteps = routeData.steps;
      _currentStepIndex = 0;
      _updateNavigationInstructions();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      routePoints.value = routeData.polyline;
      remainingRoutePoints.value = routeData.polyline;
      
      _centerOnUserLocation(animate: true);
    }
    
    isRouteLoading.value = false;
  }
}