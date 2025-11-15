import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqapp/components/disaster_detail_modal.dart';

class UserMapViewModel extends GetxController {
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

  // SOS State Management
  final Rx<SOSWaitingViewModel?> _sosWaitingViewModel = Rx<SOSWaitingViewModel?>(null);
  final RxBool _isSOSActive = false.obs;
  final Rx<SosEvent?> _activeSosEvent = Rx<SosEvent?>(null);
  
  bool get isSOSActive => _isSOSActive.value;
  SOSWaitingViewModel? get sosWaitingViewModel => _sosWaitingViewModel.value;
  SosEvent? get activeSosEvent => _activeSosEvent.value;

  // Realtime subscriptions
  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;

  @override
  void onInit() {
    _initializeLocation();
    _initializeData();
    _checkForActiveSOS();
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
    // Load disaster points from API
    _loadDisasterPoints();
    // Load evacuation points
    _loadEvacuationPoints();
    // Debug: Check all disasters (will run automatically and log results)
    debugCheckAllDisasters();
  }

  /// Check if user has an active SOS event in the database
  /// This is called on initialization to restore SOS state if the app was closed
  Future<void> _checkForActiveSOS() async {
    try {
      print('🔍 Checking for active SOS event...');
      
      // Get user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print('ℹ️ No user ID found, skipping SOS check');
        return;
      }

      // Check database for active SOS event
      final sosEvent = await SupabaseService.getUserSosEvents(userId);

      if (sosEvent != null) {
        // Store the active SOS event
        _activeSosEvent.value = sosEvent;
        
        // Restore SOS state
        _isSOSActive.value = true;
        
        // Create SOSWaitingViewModel with the pressedAt timestamp from the SOS event
        if (_sosWaitingViewModel.value == null) {
          _sosWaitingViewModel.value = SOSWaitingViewModel(
            pressedAtMillis: sosEvent.pressedAt,
          );
        }
        
        print('🆘 SOS state restored successfully');
      } else {
        print('ℹ️ No active SOS event found for user');
      }
    } catch (e) {
      print('❌ Error checking for active SOS: $e');
    }
  }

  /// Update the display list from the disaster data list
  void _updateDisasterPointsDisplay() {
    final validDisasters = _disasterPointsData
        .where((disaster) => disaster.centerLat != null && disaster.centerLng != null)
        .toList();
    
    disasterPoints.value = validDisasters
        .map((disaster) => LatLng(disaster.centerLat!, disaster.centerLng!))
        .toList();
    
    print('📍 Updated disaster points display: ${disasterPoints.length} markers');
    if (validDisasters.length != _disasterPointsData.length) {
      print('⚠️ ${_disasterPointsData.length - validDisasters.length} disasters filtered out (missing location)');
    }
  }

  /// Load disaster points from Supabase
  /// This is called once on initialization, then realtime updates take over
  Future<void> _loadDisasterPoints() async {
    try {
      print('🌋 Loading disaster points from Supabase...');
      final disasters = await SupabaseService.getDisasters();
      
      _disasterPointsData.value = disasters;
      _updateDisasterPointsDisplay();
      
      print('✅ Loaded ${_disasterPointsData.length} disaster points');
      print('📍 Displaying ${disasterPoints.length} markers on map');
      
      // Debug: Print disaster details
      if (_disasterPointsData.isEmpty) {
        print('⚠️ No disasters loaded. This could mean:');
        print('   1. No disasters occurred today');
        print('   2. Database connection issue');
        print('   3. Disasters exist but have no location data');
      } else {
        print('📋 Loaded disasters:');
        for (var i = 0; i < _disasterPointsData.length && i < 3; i++) {
          final d = _disasterPointsData[i];
          print('   ${i + 1}. ${d.disasterId} - Lat: ${d.centerLat}, Lng: ${d.centerLng}, Mag: ${d.magnitude}');
        }
      }
    } catch (e) {
      print('❌ Error loading disaster points: $e');
      print('📊 Error type: ${e.runtimeType}');
      _disasterPointsData.clear();
      _updateDisasterPointsDisplay();
    }
  }

  /// Debug method: Check all disasters in database (not just today's)
  /// Use this to verify if disasters exist in the database
  Future<void> debugCheckAllDisasters() async {
    try {
      print('🔍 [DEBUG] Checking all disasters in database...');
      final allDisasters = await SupabaseService.getAllDisasters();
      
      print('📊 [DEBUG] Total disasters in database: ${allDisasters.length}');
      
      if (allDisasters.isEmpty) {
        print('⚠️ [DEBUG] Database is empty - no disasters found');
        return;
      }
      
      print('📋 [DEBUG] Recent disasters:');
      for (var i = 0; i < allDisasters.length && i < 10; i++) {
        final d = allDisasters[i];
        final dateStr = d.occurredAt != null 
            ? DateTime.fromMillisecondsSinceEpoch(d.occurredAt!.toInt()*1000).toString()
            : 'No date';
        print('   ${i + 1}. ${d.disasterId}');
        print('      Date: $dateStr');
        print('      Location: ${d.centerLat}, ${d.centerLng}');
        print('      Magnitude: ${d.magnitude} SR');
        print('      Has location: ${d.hasLocation()}');
      }
      
      // Check how many are from today
      final now = DateTime.now();
      final todayDisasters = allDisasters.where((d) {
        if (d.occurredAt == null) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(d.occurredAt!.toInt()*1000);
        return date.year == now.year && 
               date.month == now.month && 
               date.day == now.day;
      }).toList();
      
      print('📅 [DEBUG] Disasters from today: ${todayDisasters.length}');
      print('📅 [DEBUG] Disasters from other dates: ${allDisasters.length - todayDisasters.length}');
      
    } catch (e) {
      print('❌ [DEBUG] Error checking all disasters: $e');
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
          .channel('evacuation_points_changes_user')
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
          .channel('disasters_changes_user')
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
      final disasterDate = DateTime.fromMillisecondsSinceEpoch(disaster.occurredAt!.toInt()*1000);
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

  // ---------- SOS Management Methods ----------
  
  void startSOS() {
    _isSOSActive.value = true;
    // Create SOSWaitingViewModel if it doesn't exist, or reuse existing one
    if (_sosWaitingViewModel.value == null) {
      // Use the pressedAt timestamp from the active SOS event if available
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
  
  /// Update the active SOS event data
  /// This can be called when SOS event is updated (e.g., assigned to a team)
  void updateActiveSosEvent(SosEvent sosEvent) {
    _activeSosEvent.value = sosEvent;
    print('📝 Active SOS event updated: ${sosEvent.sosId}');
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

  /// Find disaster by location coordinates
  /// Returns the disaster that matches the given coordinates (with tolerance for floating point comparison)
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
      print('⚠️ No disaster found at location: ${location.latitude}, ${location.longitude}');
      return null;
    }
  }

  /// Find evacuation point by location coordinates
  /// Returns the evacuation point that matches the given coordinates (with tolerance for floating point comparison)
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

  // ---------- Disaster Detail Helpers ----------

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

  // ---------- SOS Functionality ----------
  
  /// Send SOS with current location to response team
  /// This will send the user's current location to the backend,
  /// which will then notify the response team
  /// TODO: Replace with actual API call
  Future<void> sendSOS() async {
    try {
      // TODO: Call API to send SOS with current location
      // Example: await sosService.sendSOS(currentLocation);
      // The backend will then notify response team via real-time listener or API
      
      // For now, this is a placeholder - in real implementation,
      // the backend will receive this and notify response team
      // Response team will receive it via their API listener and call addSOSPoint()
      
      // TODO: After API call succeeds, you might want to show success message
    } catch (e) {
      // Handle error - could show error message to user
      rethrow;
    }
  }
}

// DisasterActionException is now defined in lib/components/disaster_detail_modal.dart
// Import it from there if needed elsewhere