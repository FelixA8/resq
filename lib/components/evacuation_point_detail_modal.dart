// lib/components/evacuation_point_detail_modal.dart
import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/confirmation_button.dart';

class EvacuationPointDetailModal extends StatelessWidget {
  final EvacuationPoint evacuationPoint;
  final VoidCallback onShowRoute;
  final bool isNavigating;
  final double distanceKm;
  final VoidCallback? onCancelRoute;

  const EvacuationPointDetailModal({
    super.key,
    required this.evacuationPoint,
    required this.onShowRoute,
    this.isNavigating = false,
    this.distanceKm = 0.0,
    this.onCancelRoute,
  });

  static const theme = ResQTheme();

  Widget _buildHandleBar() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  String _getTrimmedId() {
    final id = evacuationPoint.evacuationId ?? 'N/A';
    if (id == 'N/A' || id.length <= 5) {
      return id;
    }
    return id.substring(0, 5);
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poin Evakuasi (${_getTrimmedId()})',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              evacuationPoint.locationDetail ?? 'Lokasi tidak tersedia',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );

  Widget _buildShowRouteButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConfirmationButton(
          onPressed: onShowRoute,
          isEnabled: true,
          text: 'Tunjukkan Rute',
        ),
      );

  Widget _buildNavigatingUI() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${distanceKm.toStringAsFixed(2)} Km',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: theme.colors.primary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: 65,
              child: ElevatedButton(
                onPressed: onCancelRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    _buildHeader(),
                    
                    const SizedBox(height: 30),
                    
                    if (isNavigating)
                      _buildNavigatingUI()
                    else
                      _buildShowRouteButton(),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 8) {
                  Navigator.pop(context);
                }
              },
              child: _buildHandleBar(),
            ),
          ),
        ],
      ),
    );
  }
}