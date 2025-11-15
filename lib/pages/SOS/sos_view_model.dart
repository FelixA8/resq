import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'dart:developer' as developer;

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
      developer.log('UserMapViewModel not found in SOSViewModel');
    }
  }

  /// Handles the SOS button press
  Future<Map<String, dynamic>> handleSOSButtonPress() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return {
          'success': false,
          'error': 'Error: User not logged in',
        };
      }

      if (_userMapViewModel == null) {
        return {
          'success': false,
          'error': 'Error: Location service not available',
        };
      }

      final currentLat = _userMapViewModel!.currentLocation.value.latitude;
      final currentLng = _userMapViewModel!.currentLocation.value.longitude;

      final sosEvent = await SupabaseService.createSosEvent(
        userId: userId,
        lat: currentLat,
        lng: currentLng,
      );

      if (sosEvent == null) {
        return {
          'success': false,
          'error': 'Failed to send SOS. Please try again.',
        };
      }
      _userMapViewModel?.updateActiveSosEvent(sosEvent);

      final sosWaitingViewModel = triggerSOS();
      
      return {
        'success': true,
        'sosWaitingViewModel': sosWaitingViewModel,
        'sosEvent': sosEvent,
      };
    } catch (e) {
      developer.log('Error in SOS button press: $e');
      return {
        'success': false,
        'error': 'Error: ${e.toString()}',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers the SOS process
  SOSWaitingViewModel? triggerSOS() {
    isSOSActive.value = true;
    
    _userMapViewModel?.startSOS();
    
    return _userMapViewModel?.sosWaitingViewModel;
  }

  void resetSOS() {
    isSOSActive.value = false;
    _userMapViewModel?.stopSOS();
  }
  
  void cleanup() {
    isSOSActive.value = false;
  }
}
