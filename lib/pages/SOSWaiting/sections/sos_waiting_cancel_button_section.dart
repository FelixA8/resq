import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/SOSWaiting/sections/sos_waiting_cancel_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/services/sos_services.dart';
import 'package:resqapp/theme/theme_app.dart';

class SOSWaitingCancelButtonSection extends StatelessWidget {
  const SOSWaitingCancelButtonSection({super.key});

  void _showCancelConfirmationDialog(BuildContext context) {
    final theme = ResQTheme();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SosWaitingCancelButton(
          onConfirm: () async {
            Navigator.of(dialogContext).pop();

            try {
              // Get user ID from shared preferences
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId');

              if (userId != null) {
                // Delete SOS event from database
                print('🗑️ Cancelling SOS for user: $userId');
                final deleted = await SosServices.deleteSosEventByUserId(
                  userId,
                );

                if (deleted) {
                  print('SOS event successfully deleted from database');
                } else {
                  print('Failed to delete SOS event from database');
                }
              } else {
                print('User ID not found, cannot delete SOS event');
              }
            } catch (e) {
              print('Error cancelling SOS: $e');
            }

            // Get UserMapViewModel from GetX and cancel SOS
            final userMapViewModel = Get.find<UserMapViewModel>();
            userMapViewModel.stopSOS();

            // Navigate back to map view
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive button size and font
    final buttonWidth = (screenWidth * 0.35).clamp(120.0, 140.0);
    final buttonHeight = (screenWidth * 0.10).clamp(38.0, 42.0);
    final responsiveFontSize = screenWidth * 0.05;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.06),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            _showCancelConfirmationDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colors.primary,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Batalkan',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: responsiveFontSize.clamp(16.0, 20.0),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
