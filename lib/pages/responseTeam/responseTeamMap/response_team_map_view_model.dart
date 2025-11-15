import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  
  final RxList<Disaster> _disasterPointsData = <Disaster>[].obs;
  final RxList<LatLng> disasterPoints = <LatLng>[].obs;
  final RxList<EvacuationPoint> _evacuationPointsData = <EvacuationPoint>[].obs;
  final RxList<LatLng> evacuationPoints = <LatLng>[].obs;
  final RxList<LatLng> sosPoints = <LatLng>[].obs;

  // Realtime subscriptions
  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    _initializeLocation();
    _initializeData();
    _subscribeToEvacuationPoints();
    _subscribeToDisasters();
    super.onInit();
  }

  @override
  void onClose() {
    // Clean up realtime subscriptions
    _evacuationPointsSubscription?.unsubscribe();
    _disastersSubscription?.unsubscribe();
    super.onClose();
  }

  void _initializeData() {
    // Load disaster points from API (using dummy data for now)
    _loadDisasterPoints();
    // Load evacuation points (using dummy data for now)
    _loadEvacuationPoints();
    // Load SOS points (these come from users, using dummy data for now)
    _loadSOSPoints();
  }

  /// Update the display list from the disaster data list
  void _updateDisasterPointsDisplay() {
    disasterPoints.value = _disasterPointsData
        .where((disaster) => disaster.centerLat != null && disaster.centerLng != null)
        .map((disaster) => LatLng(disaster.centerLat!, disaster.centerLng!))
        .toList();
  }

  /// Load disaster points from Supabase
  /// This is called once on initialization, then realtime updates take over
  Future<void> _loadDisasterPoints() async {
    try {
      print('🌋 Loading disaster points from Supabase...');
      final disasters = await SupabaseService.getAllDisasters();
      
      _disasterPointsData.value = disasters;
      _updateDisasterPointsDisplay();
      
      print('✅ Loaded ${_disasterPointsData.length} disaster points');
    } catch (e) {
      print('❌ Error loading disaster points: $e');
      _disasterPointsData.clear();
      _updateDisasterPointsDisplay();
    }
  }

  /// Update the display list from the data list
  void _updateEvacuationPointsDisplay() {
    evacuationPoints.value = _evacuationPointsData
        .where((point) => point.hasLocation())
        .map((point) => LatLng(point.locationLat!, point.locationLng!))
        .toList();
  }

  /// Load evacuation points from Supabase
  /// This is called once on initialization, then realtime updates take over
  Future<void> _loadEvacuationPoints() async {
    try {
      print('📍 Loading evacuation points from Supabase...');
      final points = await SupabaseService.getEvacuationPoints();
      
      _evacuationPointsData.value = points;
      _updateEvacuationPointsDisplay();
      
      print('✅ Loaded ${_evacuationPointsData.length} evacuation points');
    } catch (e) {
      print('❌ Error loading evacuation points: $e');
      _evacuationPointsData.clear();
      _updateEvacuationPointsDisplay();
    }
  }

  /// Subscribe to realtime changes on evacuation_points table
  void _subscribeToEvacuationPoints() {
    try {
      print('🔔 Setting up realtime subscription for evacuation_points...');
      
      final supabaseClient = Supabase.instance.client;
      
      _evacuationPointsSubscription = supabaseClient
          .channel('evacuation_points_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'evacuation_points',
            callback: (payload) {
              print('🔔 Realtime event received: ${payload.eventType}');
              _handleEvacuationPointChange(payload);
            },
          )
          .subscribe();
      
      print('✅ Realtime subscription established');
    } catch (e) {
      print('❌ Error setting up realtime subscription: $e');
    }
  }

  /// Subscribe to realtime changes on disasters table
  void _subscribeToDisasters() {
    try {
      print('🔔 Setting up realtime subscription for disasters...');
      
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
      
      print('✅ Disaster realtime subscription established');
    } catch (e) {
      print('❌ Error setting up disaster realtime subscription: $e');
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
          print('✅ Added new evacuation point: ${point.evacuationId}');
        }
      }
    } catch (e) {
      print('❌ Error handling INSERT: $e');
    }
  }

  /// Handle UPDATE event - update existing evacuation point
  void _handleEvacuationPointUpdate(
    Map<String, dynamic> oldRecord,
    Map<String, dynamic> newRecord,
  ) {
    try {
      final newPoint = EvacuationPoint.fromJson(newRecord);
      
      if (newPoint.evacuationId != null) {
        // Find and replace the existing point by ID
        final index = _evacuationPointsData.indexWhere(
          (p) => p.evacuationId == newPoint.evacuationId,
        );
        
        if (index != -1) {
          _evacuationPointsData[index] = newPoint;
          _updateEvacuationPointsDisplay();
          print('✅ Updated evacuation point: ${newPoint.evacuationId}');
        } else {
          // If not found, add it (shouldn't happen, but handle gracefully)
          _evacuationPointsData.add(newPoint);
          _updateEvacuationPointsDisplay();
        }
      }
    } catch (e) {
      print('❌ Error handling UPDATE: $e');
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
        print('✅ Removed evacuation point: ${point.evacuationId}');
      }
    } catch (e) {
      print('❌ Error handling DELETE: $e');
    }
  }

  /// Handle realtime changes to disasters
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

  /// Check if a disaster occurred today
  bool _isDisasterFromToday(Disaster disaster) {
    if (disaster.occurredAt == null) {
      print('⚠️ Disaster ${disaster.disasterId} has no occurredAt timestamp');
      return false;
    }
    
    try {
      // Convert milliseconds timestamp to DateTime
      final disasterDate = DateTime.fromMillisecondsSinceEpoch(disaster.occurredAt!.toInt());
      final now = DateTime.now();
      
      // Check if disaster occurred today
      final isToday = disasterDate.year == now.year &&
                      disasterDate.month == now.month &&
                      disasterDate.day == now.day;
      
      if (!isToday) {
        print('🚫 Disaster ${disaster.disasterId} is not from today (occurred: ${disasterDate})');
      }
      
      return isToday;
    } catch (e) {
      print('❌ Error checking disaster date: $e');
      return false;
    }
  }

  /// Handle INSERT event - add new disaster to map (only if from today)
  void _handleDisasterInsert(Map<String, dynamic> record) {
    try {
      final disaster = Disaster.fromJson(record);
      
      if (disaster.disasterId != null) {
        // Check if disaster is from today
        if (!_isDisasterFromToday(disaster)) {
          print('⏭️ Skipping disaster ${disaster.disasterId} - not from today');
          return;
        }
        
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
      
      if (newDisaster.disasterId != null) {
        // Check if updated disaster is from today
        if (!_isDisasterFromToday(newDisaster)) {
          print('⏭️ Skipping disaster update ${newDisaster.disasterId} - not from today');
          // If it was previously shown but now updated to a different date, remove it
          final index = _disasterPointsData.indexWhere(
            (d) => d.disasterId == newDisaster.disasterId,
          );
          if (index != -1) {
            _disasterPointsData.removeAt(index);
            _updateDisasterPointsDisplay();
            print('🗑️ Removed disaster ${newDisaster.disasterId} - date changed to non-today');
          }
          return;
        }
        
        // Find and replace the existing disaster by ID
        final index = _disasterPointsData.indexWhere(
          (d) => d.disasterId == newDisaster.disasterId,
        );
        
        if (index != -1) {
          _disasterPointsData[index] = newDisaster;
          _updateDisasterPointsDisplay();
          print('✅ Updated disaster: ${newDisaster.disasterId}');
        } else {
          // If not found, add it (could happen if date was updated to today)
          _disasterPointsData.add(newDisaster);
          _updateDisasterPointsDisplay();
          print('✅ Added disaster ${newDisaster.disasterId} - date updated to today');
        }
      }
    } catch (e) {
      print('❌ Error handling disaster UPDATE: $e');
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
        print('✅ Removed disaster: ${disaster.disasterId}');
      }
    } catch (e) {
      print('❌ Error handling disaster DELETE: $e');
    }
  }

  /// Refresh disaster points (manual refresh if needed)
  /// Note: Realtime subscription should handle updates automatically
  Future<void> refreshDisasterPoints() async {
    await _loadDisasterPoints();
  }

  /// Refresh evacuation points (manual refresh if needed)
  /// Note: Realtime subscription should handle updates automatically
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

  /// Get location after permission has been granted
  Future<void> _getLocationAfterPermission() async {
    try {
      // Try to get last known position first (quick)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        currentLocation.value = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        mapController.move(currentLocation.value, 15.0);
        return;
      }
      
      await _getCurrentLocation();
    } catch (e) {
      await _getCurrentLocation();
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

  // ---------- Annotations API ----------
  
  /// Replace all disaster points (called after fetching from API)
  /// Note: This is kept for backwards compatibility but realtime should handle updates
  void setDisasterPoints(List<LatLng> points) {
    // This method is deprecated in favor of realtime updates
    // If you need to manually set points, consider using _disasterPointsData directly
    print('⚠️ setDisasterPoints called - consider using realtime updates instead');
  }

  /// Replace all evacuation points (called when evacuation points are updated)
  /// Note: This is kept for backwards compatibility but realtime should handle updates
  void setEvacuationPoints(List<LatLng> points) {
    // This method is deprecated in favor of realtime updates
    // If you need to manually set points, consider using _evacuationPointsData directly
    print('⚠️ setEvacuationPoints called - consider using realtime updates instead');
  }

  /// Add a single evacuation point (called when response team creates one)
  /// The point will be automatically added to the map via realtime subscription
  /// This method is kept for API compatibility but the local add is handled by realtime
  Future<void> addEvacuationPoint(LatLng point) async {
    // Note: The actual insertion happens in addEvacuationPointPage
    // When SupabaseService.addEvacuationPoint() is called, the realtime
    // subscription will automatically receive the INSERT event and update the map
    // No need to manually add to evacuationPoints list here
    print('ℹ️ addEvacuationPoint called - realtime will handle the update');
  }

  /// Remove a single evacuation point (called when response team removes one)
  /// The point will be automatically removed from the map via realtime subscription
  /// This method is kept for API compatibility but the local removal is handled by realtime
  Future<void> removeEvacuationPoint(LatLng point) async {
    // Note: When SupabaseService.deleteEvacuationPoint() is called, the realtime
    // subscription will automatically receive the DELETE event and update the map
    // No need to manually remove from evacuationPoints list here
    print('ℹ️ removeEvacuationPoint called - realtime will handle the update');
  }

  /// Add a single disaster point (called when a new disaster event is received)
  /// The point will be automatically added to the map via realtime subscription
  /// This method is kept for API compatibility but the local add is handled by realtime
  void addDisasterPoint(LatLng point) {
    // Note: When a disaster is inserted into Supabase, the realtime
    // subscription will automatically receive the INSERT event and update the map
    // No need to manually add to disasterPoints list here
    print('ℹ️ addDisasterPoint called - realtime will handle the update');
  }

  /// Remove a single disaster point (called when a disaster is resolved/removed)
  /// The point will be automatically removed from the map via realtime subscription
  /// This method is kept for API compatibility but the local removal is handled by realtime
  void removeDisasterPoint(LatLng point) {
    // Note: When a disaster is deleted from Supabase, the realtime
    // subscription will automatically receive the DELETE event and update the map
    // No need to manually remove from disasterPoints list here
    print('ℹ️ removeDisasterPoint called - realtime will handle the update');
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

