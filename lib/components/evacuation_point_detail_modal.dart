import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/confirmation_button.dart';

class EvacuationPointDetailModal extends StatelessWidget {
  final EvacuationPoint evacuationPoint;
  final VoidCallback onShowRoute;

  const EvacuationPointDetailModal({
    Key? key,
    required this.evacuationPoint,
    required this.onShowRoute,
  }) : super(key: key);

  static const theme = ResQTheme();

  // -----------------------------
  // UI Builders
  // -----------------------------
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
              style: TextStyle(
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

  // -----------------------------
  // Build Method
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Scrollable content
          Padding(
            padding: const EdgeInsets.only(top: 18), // spacing below handle bar
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Title and Location
                    _buildHeader(),
                    const SizedBox(height: 30),
                    // Show Route Button
                    _buildShowRouteButton(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed handle bar
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 8) {
                  Navigator.pop(context); // pull down to dismiss
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

