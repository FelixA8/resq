import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/theme/theme_app.dart';

class SOSWaitingCancelButtonSection extends StatelessWidget {
  const SOSWaitingCancelButtonSection({Key? key}) : super(key: key);

  void _showCancelConfirmationDialog(BuildContext context) {
    final theme = ResQTheme();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Batalkan SOS?',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan permintaan bantuan?',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            // Kembali button (closes the dialog) - Left side, red button
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(theme.colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Kembali',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            // Konfirmasi button (actually cancels SOS) - Right side, grey text button
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                
                try {
                  // Get user ID from shared preferences
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');

                  if (userId != null) {
                    // Delete SOS event from database
                    print('🗑️ Cancelling SOS for user: $userId');
                    final deleted = await SupabaseService.deleteSosEventByUserId(userId);
                    
                    if (deleted) {
                      print('✅ SOS event successfully deleted from database');
                    } else {
                      print('⚠️ Failed to delete SOS event from database');
                    }
                  } else {
                    print('⚠️ User ID not found, cannot delete SOS event');
                  }
                } catch (e) {
                  print('❌ Error cancelling SOS: $e');
                }
                
                // Get UserMapViewModel from GetX and cancel SOS
                final userMapViewModel = Get.find<UserMapViewModel>();
                userMapViewModel.stopSOS();
                
                // Navigate back to map view
                Navigator.of(context).pop();
              },
              child: Text(
                'Konfirmasi',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.06,
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            _showCancelConfirmationDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(theme.colors.primary),
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
