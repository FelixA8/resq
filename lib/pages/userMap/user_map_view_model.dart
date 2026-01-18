import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:resqapp/pages/userMap/extensions/map_animation_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqapp/helpers/map_helper.dart';
import 'package:resqapp/services/distance_calculator.dart' as distance_calc;
import 'package:resqapp/pages/userMap/components/evacuation_deleted_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:resqapp/pages/userMap/components/location_disabled_dialog.dart';

class UserMapViewModel extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  final Rx<ResqUser?> _currentUser = Rx(null);
  ResqUser? get currentUser => _currentUser.value;
  final theme = ResQTheme();

  late final AnimatedMapController mapController;
  final Map<String, String> _disasterAddressCache = {};

  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;

  final RxList<Disaster> disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;

  final RxList<EvacuationPoint> evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;

  final Rx<SOSWaitingViewModel?> _sosWaitingViewModel =
      Rx<SOSWaitingViewModel?>(null);
  final RxBool _isSOSActive = false.obs;
  final RxBool isLocationServiceEnabled = false.obs;
  final Rx<SosEvent?> _activeSosEvent = Rx<SosEvent?>(null);

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  final Rx<EvacuationPoint?> _currentNavigatingEvacuationPoint =
      Rx<EvacuationPoint?>(null);

  static const String _kSavedEvacuationId = 'saved_evacuation_point_id';

  // User location address
  final RxString currentAddress = 'Loading...'.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

  bool get isSOSActive => _isSOSActive.value;
  SOSWaitingViewModel? get sosWaitingViewModel => _sosWaitingViewModel.value;
  SosEvent? get activeSosEvent => _activeSosEvent.value;

  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;

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

  @override
  void onInit() {
    super.onInit();
    mapController = AnimatedMapController(vsync: this);
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _evacuationPointsSubscription?.unsubscribe();
    _disastersSubscription?.unsubscribe();
    _idleTimer?.cancel();
    _arrivalCheckTimer?.cancel();

    mapController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshLocationStatus();
    }
  }

  Future<bool> refreshLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    bool isPermissionGranted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (serviceEnabled && isPermissionGranted) {
      isLocationServiceEnabled.value = true;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _initializeLocation();
      return true;
    } else {
      isLocationServiceEnabled.value = false;
      _showLocationDisabledDialog();
      return false;
    }
  }

  void _showLocationDisabledDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      LocationDisabledDialog(
        onRetry: () async {
          return await refreshLocationStatus();
        },
      ),
      barrierDismissible: false,
    );
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
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (!isLocationServiceEnabled.value) {
        isLocationServiceEnabled.value = true;
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }

      final newLocation = LatLng(position.latitude, position.longitude);

      // Update heading/bearing for arrow rotation
      if (_lastLocation != null && isNavigating.value) {
        final heading = _calculateHeading(_lastLocation!, newLocation);
        if (heading >= 0) {
          currentHeading.value = heading;
        }
      }

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
    final validDisasters =
        disasterPointsData
            .where(
              (disaster) =>
                  disaster.centerLat != null && disaster.centerLng != null,
            )
            .toList();

    disasterPoints.value =
        validDisasters
            .map((disaster) => LatLng(disaster.centerLat!, disaster.centerLng!))
            .toList();
  }

  Future<void> _loadDisasterPoints() async {
    try {
      final disasters = await SupabaseService.getFilteredDisasters();
      disasterPointsData.value = disasters;
      _updateDisasterPointsDisplay();
    } catch (e) {
      disasterPointsData.clear();
      _updateDisasterPointsDisplay();
    }
  }

  void _updateEvacuationPointsDisplay() {
    evacuationPoints.value =
        evacuationPointsData
            .where((point) => point.hasLocation())
            .map((point) => LatLng(point.locationLat!, point.locationLng!))
            .toList();
  }

  Future<void> _loadEvacuationPoints() async {
    try {
      final points = await SupabaseService.getEvacuationPoints();
      evacuationPointsData.value = points;
      _updateEvacuationPointsDisplay();
    } catch (e) {
      evacuationPointsData.clear();
      _updateEvacuationPointsDisplay();
    }
  }

  void _subscribeToEvacuationPoints() {
    try {
      final supabaseClient = Supabase.instance.client;
      _evacuationPointsSubscription =
          supabaseClient
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
      _disastersSubscription =
          supabaseClient
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
        final exists = evacuationPointsData.any(
          (p) => p.evacuationId == point.evacuationId,
        );
        if (!exists) {
          evacuationPointsData.add(point);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling INSERT: $e');
    }
  }

  void _handleEvacuationPointUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newPoint = EvacuationPoint.fromJson(newRecord);
      if (newPoint.evacuationId != null) {
        final index = evacuationPointsData.indexWhere(
          (p) => p.evacuationId == newPoint.evacuationId,
        );
        if (index != -1) {
          evacuationPointsData[index] = newPoint;
          _updateEvacuationPointsDisplay();
        } else {
          evacuationPointsData.add(newPoint);
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
        // Check if currently navigating to this point
        if (_currentNavigatingEvacuationPoint.value?.evacuationId ==
            point.evacuationId) {
          EvacuationDeletedDialog.show();
          cancelEvacuationRoute();
        }

        evacuationPointsData.removeWhere(
          (p) => p.evacuationId == point.evacuationId,
        );
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
      final disasterDate = DateTime.fromMillisecondsSinceEpoch(
        disaster.occurredAt!.toInt() * 1000,
      );
      final now = DateTime.now();
      return disasterDate.year == now.year &&
          disasterDate.month == now.month &&
          disasterDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  void _handleDisasterInsert(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      if (disaster.disasterId != null) {
        if (!_isDisasterFromToday(disaster)) return;
        final exists = disasterPointsData.any(
          (d) => d.disasterId == disaster.disasterId,
        );
        if (!exists) {
          disasterPointsData.add(disaster);
          _updateDisasterPointsDisplay();
        }
      }
    } catch (e) {
      developer.log('Error handling disaster INSERT: $e');
    }
  }

  void _handleDisasterUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newDisaster = Disaster.fromJson(newRecord);
      if (newDisaster.disasterId != null) {
        if (!_isDisasterFromToday(newDisaster)) {
          final index = disasterPointsData.indexWhere(
            (d) => d.disasterId == newDisaster.disasterId,
          );
          if (index != -1) {
            disasterPointsData.removeAt(index);
            _updateDisasterPointsDisplay();
          }
          return;
        }
        final index = disasterPointsData.indexWhere(
          (d) => d.disasterId == newDisaster.disasterId,
        );
        if (index != -1) {
          disasterPointsData[index] = newDisaster;
          _updateDisasterPointsDisplay();
        } else {
          disasterPointsData.add(newDisaster);
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
        disasterPointsData.removeWhere(
          (d) => d.disasterId == disaster.disasterId,
        );
        _updateDisasterPointsDisplay();
      }
    } catch (e) {
      developer.log('Error handling disaster DELETE: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocation();
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      hasLocationPermission.value = result.hasPermission;
      isLocationServiceEnabled.value = result.hasPermission;

      if (!result.hasPermission) {
        _showLocationDisabledDialog();
      }

      await mapController.animateTo(
        dest: currentLocation.value,
        zoom: MapAnimationConfig.initialZoom,
        curve: MapAnimationConfig.defaultCurve,
        duration: MapAnimationConfig.initialCenterDuration,
      );
      _updateAddress(currentLocation.value);
    } catch (e) {
      hasLocationPermission.value = false;
      hasLocationPermission.value = false;
      isLocationServiceEnabled.value = false;

      _showLocationDisabledDialog();
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
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          address = place.subAdministrativeArea!;
        }

        if (address.isEmpty) {
          address = 'Unknown Location';
        }

        currentAddress.value = address;
        developer.log(
          'User Location: ${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}',
        );
      }
    } catch (e) {
      developer.log('Error getting address: $e');
      if (currentAddress.value.isEmpty) {
        currentAddress.value = 'Location Unavailable';
      }
    }
  }

  void moveToLocation(LatLng location) {
    mapController.animateTo(
      dest: location,
      zoom: MapAnimationConfig.manualLocationZoom,
      curve: MapAnimationConfig.defaultCurve,
      duration: MapAnimationConfig.userTriggeredDuration,
    );
  }

  //get disaster detail based on location
  Disaster? findDisasterByLocation(LatLng location) {
    return MapHelper.findDisasterByLocation(disasterPointsData, location);
  }

  //get disaster detail based on id
  Disaster? findDisasterById(String id) {
    final disaster = disasterPointsData.where((d) => d.disasterId == id);
    return disaster.first;
  }

  EvacuationPoint? findEvacuationPointByLocation(LatLng location) {
    return MapHelper.findEvacuationPointByLocation(
      evacuationPointsData,
      location,
    );
  }

  EvacuationPoint? findEvacuationPointById(String id) {
    final evacuationPoint = evacuationPointsData.where((e) => e.evacuationId == id);
    return evacuationPoint.first;
  }

  Future<String> fetchDisasterAddress(Disaster disaster) {
    return MapHelper.getAddressFromLocation(
      disaster.centerLat,
      disaster.centerLng,
      _disasterAddressCache,
      disaster.disasterId,
    );
  }

  String formatDisasterDate(double? timestamp) =>
      MapHelper.formatDisasterDate(timestamp);
  String formatDisasterMagnitude(double? magnitude) =>
      MapHelper.formatMagnitude(magnitude);
  String getTsunamiPotential(double? magnitude) =>
      MapHelper.getTsunamiPotential(magnitude);
  String formatDisasterDepth(String? depth) => MapHelper.formatDepth(depth);
  Future<void> openDisasterShakeMap(Disaster disaster) =>
      MapHelper.launchShakeMap(disaster.shakemap);

  Future<void> showRouteToEvacuationPoint(
    EvacuationPoint point, {
    bool saveState = true,
  }) async {
    if (!point.hasLocation()) {
      Get.snackbar(
        'Error',
        'Lokasi Poin Evakuasi tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
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
      final routeData = await MapHelper.getRouteWithInstructions(start, end);

      if (routeData != null && routeData.polyline.isNotEmpty) {
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

        // Defer route points update to next frame to prevent overlap with current location icon rendering
        await Future.delayed(const Duration(milliseconds: 100));

        routePoints.value = routeData.polyline;
        remainingRoutePoints.value = routeData.polyline;

        // Center on user location with animation
        _centerOnUserLocation(animate: true);
      } else {
        Get.snackbar(
          'Info',
          "Rute tidak ditemukan",
          snackPosition: SnackPosition.BOTTOM,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "Gagal memuat rute",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
    } finally {
      isRouteLoading.value = false;
    }
  }

  void clearRoute() {
    routePoints.clear();
    remainingRoutePoints.clear();
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
  }

  Future<void> cancelEvacuationRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSavedEvacuationId);

    clearRoute();
  }

  bool isCurrentlyNavigatingToEvacuationPoint(EvacuationPoint point) {
    return _currentNavigatingEvacuationPoint.value?.evacuationId ==
        point.evacuationId;
  }

  double calculateDistanceToEvacuationPoint(EvacuationPoint point) {
    if (!point.hasLocation()) return 0.0;
    return distance_calc.GeoDistanceCalculator.calculateDistance(
      currentLocation.value,
      LatLng(point.locationLat!, point.locationLng!),
    );
  }

  void _checkAndReroute(LatLng userLocation) {
    if (_currentNavigatingEvacuationPoint.value == null ||
        routePoints.isEmpty ||
        isRouteLoading.value) {
      return;
    }

    bool isOffRoute = MapHelper.isUserOffRoute(
      userLocation,
      routePoints,
      thresholdMeters: 50,
    );

    if (isOffRoute) {
      final dest = _currentNavigatingEvacuationPoint.value!;
      if (dest.hasLocation()) {
        _silentReroute(
          userLocation,
          LatLng(dest.locationLat!, dest.locationLng!),
        );
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

  double _calculateHeading(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void _updateNavigationState(LatLng userLocation) {
    if (navigationDestination.value == null) {
      if (_currentNavigatingEvacuationPoint.value != null &&
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
      final distanceToStep = distance_calc
          .GeoDistanceCalculator.calculateDistance(
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
      else if (maneuverType.contains('roundabout') ||
          maneuverType == 'rotary') {
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
    const double arrivalThresholdKm = 0.10; // 100 meters

    // Set arrival state when within 100m radius
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
    clearRoute();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSavedEvacuationId);

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
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

  void onMapMoved() {
    _idleTimer?.cancel();
    if (!isNavigating.value) return;

    if (isMapCentering.value) {
      isMapCentering.value = false;
    }

    final mapCenter = mapController.mapController.camera.center;

    final distanceFromUser = distance_calc
        .GeoDistanceCalculator.calculateDistance(
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
