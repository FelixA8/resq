import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/models/supabase_models.dart';

class SOSViewModel extends GetxController {
  final RxBool isSOSActive = false.obs;
  final RxBool isLoading = false.obs;
  
  // Reference to UserMapViewModel
  UserMapViewModel? _userMapViewModel;
  
  @override
  void onInit() {
    super.onInit();
    // Get reference to UserMapViewModel
    try {
      _userMapViewModel = Get.find<UserMapViewModel>();
    } catch (e) {
      print('⚠️ UserMapViewModel not found in SOSViewModel');
    }
  }

  /// Handles the SOS button press
  /// Returns a map with success status, error message, and SOSWaitingViewModel
  Future<Map<String, dynamic>> handleSOSButtonPress() async {
    try {
      isLoading.value = true;
      
      // Get user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print('❌ User ID not found in shared preferences');
        return {
          'success': false,
          'error': 'Error: User not logged in',
        };
      }

      // Get current location from UserMapViewModel
      if (_userMapViewModel == null) {
        print('❌ UserMapViewModel not available');
        return {
          'success': false,
          'error': 'Error: Location service not available',
        };
      }

      final currentLat = _userMapViewModel!.currentLocation.value.latitude;
      final currentLng = _userMapViewModel!.currentLocation.value.longitude;

      print('🆘 Creating SOS event for user: $userId at ($currentLat, $currentLng)');

      // Insert SOS data to Supabase
      final sosEvent = await SupabaseService.createSosEvent(
        userId: userId,
        lat: currentLat,
        lng: currentLng,
      );

      if (sosEvent == null) {
        // Show error if SOS creation failed
        print('❌ Failed to create SOS event');
        return {
          'success': false,
          'error': 'Failed to send SOS. Please try again.',
        };
      }

      print('✅ SOS event created successfully: ${sosEvent.sosId}');

      // Store the active SOS event in UserMapViewModel
      _userMapViewModel?.updateActiveSosEvent(sosEvent);

      // Trigger SOS in view model
      final sosWaitingViewModel = triggerSOS();
      
      return {
        'success': true,
        'sosWaitingViewModel': sosWaitingViewModel,
        'sosEvent': sosEvent,
      };
    } catch (e) {
      print('❌ Error in SOS button press: $e');
      return {
        'success': false,
        'error': 'Error: ${e.toString()}',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers the SOS process
  /// This method handles all the business logic for starting an SOS
  /// Returns the SOSWaitingViewModel to be used by the waiting view
  SOSWaitingViewModel? triggerSOS() {
    isSOSActive.value = true;
    
    // Start SOS in UserMapViewModel
    _userMapViewModel?.startSOS();
    
    // Return the SOSWaitingViewModel for the waiting view
    return _userMapViewModel?.sosWaitingViewModel;
  }

  /// Resets the SOS state
  void resetSOS() {
    isSOSActive.value = false;
    _userMapViewModel?.stopSOS();
  }
  
  /// Cleanup when this view model is disposed
  void cleanup() {
    // This is called when the modal is closed
    // Reset local state but don't stop the SOS in UserMapViewModel
    isSOSActive.value = false;
  }
}
