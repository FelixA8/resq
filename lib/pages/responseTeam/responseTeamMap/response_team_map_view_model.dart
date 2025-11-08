import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/services/location_helper.dart';

class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  
  // Map annotations
  // Disaster points: Retrieved via API, appear in both maps
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  // Evacuation points: Created by response team, appear in both maps
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  // SOS points: Sent by users when they press SOS button, only visible to response team
  final RxList<LatLng> sosPoints = <LatLng>[].obs;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    _initializeLocation();
    _initializeData();
    super.onInit();
  }

  void _initializeData() {
    // Load disaster points from API (using dummy data for now)
    _loadDisasterPoints();
    // Load evacuation points (using dummy data for now)
    _loadEvacuationPoints();
    // Load SOS points (these come from users, using dummy data for now)
    _loadSOSPoints();
  }

  /// Load disaster points from API
  /// TODO: Replace with actual API call
  Future<void> _loadDisasterPoints() async {
    try {
      // TODO: Replace with actual API call
      // Example: final response = await disasterService.getDisasterPoints();
      // disasterPoints.value = response.map((point) => LatLng(point.lat, point.lng)).toList();
      
      // Dummy data for now - same as user map
      disasterPoints.value = [
        LatLng(-6.2200, 106.8400),
        LatLng(-6.2000, 106.8600),
      ];
    } catch (e) {
      // Handle error - for now, just use empty list
      disasterPoints.clear();
    }
  }

  /// Load evacuation points
  /// TODO: Replace with actual API call or real-time listener
  Future<void> _loadEvacuationPoints() async {
    try {
      // TODO: Replace with actual API call
      // Example: final response = await evacuationService.getEvacuationPoints();
      // evacuationPoints.value = response.map((point) => LatLng(point.lat, point.lng)).toList();
      
      // Dummy data for now - same as user map
      evacuationPoints.value = [
        LatLng(-6.2075, 106.8450),
        LatLng(-6.2130, 106.8500),
      ];
    } catch (e) {
      // Handle error - for now, just use empty list
      evacuationPoints.clear();
    }
  }

  /// Refresh disaster points from API
  Future<void> refreshDisasterPoints() async {
    await _loadDisasterPoints();
  }

  /// Refresh evacuation points
  Future<void> refreshEvacuationPoints() async {
    await _loadEvacuationPoints();
  }

  /// Load SOS points (sent by users when they press SOS button)
  /// TODO: Replace with actual API call or real-time listener
  Future<void> _loadSOSPoints() async {
    try {
      // TODO: Replace with actual API call or real-time listener
      // Example: final response = await sosService.getSOSPoints();
      // sosPoints.value = response.map((point) => LatLng(point.lat, point.lng)).toList();
      
      // Dummy data for now - will be populated when users send SOS
      // Adding one dummy SOS location for testing
      sosPoints.value = [
        LatLng(-6.2150, 106.8475), // Dummy SOS location near Jakarta
      ];
    } catch (e) {
      // Handle error - for now, just use empty list
      sosPoints.clear();
    }
  }

  /// Refresh SOS points
  Future<void> refreshSOSPoints() async {
    await _loadSOSPoints();
  }

  /// Initialize location using the LocationHelper
  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      
      LocationResult result = await LocationHelper.initializeLocation();
      
      currentLocation.value = result.location;
      hasLocationPermission.value = result.hasPermission;
      
      // Move map to the location
      mapController.move(currentLocation.value, 15.0);
      
    } catch (e) {
      // LocationHelper already handles error messages
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
      // LocationHelper handles error messages
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

  // ---------- Annotations API ----------
  
  /// Replace all disaster points (called after fetching from API)
  /// This should be called when disaster data is retrieved from API
  void setDisasterPoints(List<LatLng> points) {
    disasterPoints.value = points;
  }

  /// Replace all evacuation points (called when evacuation points are updated)
  void setEvacuationPoints(List<LatLng> points) {
    evacuationPoints.value = points;
  }

  /// Add a single evacuation point (called when response team creates one)
  /// TODO: This should also call API to persist the evacuation point
  /// After API call succeeds, the point will appear in both maps
  Future<void> addEvacuationPoint(LatLng point) async {
    try {
      // TODO: Call API to create evacuation point
      // Example: await evacuationService.createEvacuationPoint(point);
      // After API call succeeds, add to local list
      
      if (!evacuationPoints.contains(point)) {
        evacuationPoints.add(point);
        // TODO: Notify backend/other clients via real-time listener or API
      }
    } catch (e) {
      // Handle error - could show error message to user
      rethrow;
    }
  }

  /// Remove a single evacuation point (called when response team removes one)
  /// TODO: This should also call API to remove the evacuation point
  Future<void> removeEvacuationPoint(LatLng point) async {
    try {
      // TODO: Call API to remove evacuation point
      // Example: await evacuationService.removeEvacuationPoint(point);
      // After API call succeeds, remove from local list
      
      evacuationPoints.remove(point);
      // TODO: Notify backend/other clients via real-time listener or API
    } catch (e) {
      // Handle error - could show error message to user
      rethrow;
    }
  }

  /// Add a single disaster point (called when a new disaster event is received from API)
  void addDisasterPoint(LatLng point) {
    if (!disasterPoints.contains(point)) {
      disasterPoints.add(point);
    }
  }

  /// Remove a single disaster point (called when a disaster is resolved/removed)
  void removeDisasterPoint(LatLng point) {
    disasterPoints.remove(point);
  }

  // ---------- SOS Points API ----------
  
  /// Add a single SOS point (called when a user sends SOS)
  /// This should be called via real-time listener or API callback when user sends SOS
  /// TODO: This will be called automatically when backend receives SOS from user
  void addSOSPoint(LatLng point) {
    if (!sosPoints.contains(point)) {
      sosPoints.add(point);
      // TODO: Notify via real-time listener or API callback
    }
  }

  /// Remove a single SOS point (called when SOS is resolved/cancelled)
  /// TODO: This should also call API to mark SOS as resolved
  Future<void> removeSOSPoint(LatLng point) async {
    try {
      // TODO: Call API to mark SOS as resolved
      // Example: await sosService.resolveSOS(point);
      // After API call succeeds, remove from local list
      
      sosPoints.remove(point);
      // TODO: Notify via real-time listener or API callback
    } catch (e) {
      // Handle error - could show error message to user
      rethrow;
    }
  }

  /// Replace all SOS points (called when SOS points are updated)
  void setSOSPoints(List<LatLng> points) {
    sosPoints.value = points;
  }
}
