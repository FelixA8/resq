import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:resqapp/services/sos_services.dart';
import 'dart:developer' as developer;

class SOSViewModel extends GetxController {
  final RxBool isSOSActive = false.obs;
  final RxBool isLoading = false.obs;

  UserMapViewModel? _userMapViewModel;

  @override
  void onInit() {
    super.onInit();
    try {
      _userMapViewModel = Get.find<UserMapViewModel>();
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<Map<String, dynamic>> sosReport() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return {'success': false, 'error': 'Error: User not logged in'};
      }

      if (_userMapViewModel == null) {
        return {
          'success': false,
          'error': 'Error: Location service not available',
        };
      }

      final currentLat = _userMapViewModel!.currentLocation.value.latitude;
      final currentLng = _userMapViewModel!.currentLocation.value.longitude;

      final sosEvent = await SosServices.createSosEvent(
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

      _sendEmergencyAlerts(userId, currentLat, currentLng);

      final sosWaitingViewModel = triggerSOS();

      return {
        'success': true,
        'sosWaitingViewModel': sosWaitingViewModel,
        'sosEvent': sosEvent,
      };
    } catch (e) {
      developer.log('Error in SOS button press: $e');
      return {'success': false, 'error': 'Error: ${e.toString()}'};
    } finally {
      isLoading.value = false;
    }
  }

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

  void _sendEmergencyAlerts(String userId, double lat, double lng) async {
    try {
      developer.log('SOS: Sending emergency SMS alerts...');

      final locationName =
          _userMapViewModel?.currentAddress.value ?? 'Unknown Location';

      final result = await EmergencySmsService.sendEmergencyAlerts(
        userId: userId,
        locationName: locationName,
        latitude: lat,
        longitude: lng,
      );

      if (result['skipped'] == true) {
        developer.log('SOS: Emergency SMS disabled');
      } else {
        developer.log(
          'SOS: Emergency SMS sent to ${result['sent']}/${result['total']} contacts',
        );
        if (result['failed'] > 0) {
          developer.log('SOS: Failed to send to ${result['failed']} contacts');
        }
      }
    } catch (e) {
      developer.log('SOS: Error sending emergency SMS - $e');
    }
  }
}
