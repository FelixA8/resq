import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/confirmation_button.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';

class EvacuationPointDetailModal extends StatelessWidget {
  final EvacuationPoint evacuationPoint;

  const EvacuationPointDetailModal({super.key, required this.evacuationPoint});

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

  String _getFormattedTitle() {
    final id = evacuationPoint.evacuationId ?? 'N/A';
    final shortId =
        id.length > 4 ? id.substring(0, 4).toUpperCase() : id.toUpperCase();
    return 'Posko #$shortId';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<UserMapViewModel>();

    return Obx(() {
      final isNavigating = viewModel.isCurrentlyNavigatingToEvacuationPoint(
        evacuationPoint,
      );
      final distanceKm = viewModel.calculateDistanceToEvacuationPoint(
        evacuationPoint,
      );

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),

                    if (isNavigating) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${distanceKm.toStringAsFixed(2)} Km',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              color: theme.colors.primary,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                viewModel.cancelEvacuationRoute();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 1.5, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),
                    ],

                    Text(
                      _getFormattedTitle(),
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

                    if (!isNavigating) ...[
                      const SizedBox(height: 30),
                      ConfirmationButton(
                        onPressed: () {
                          viewModel.showRouteToEvacuationPoint(evacuationPoint);
                          Navigator.pop(context);
                        },
                        isEnabled: true,
                        text: 'Tunjukkan Rute',
                      ),
                    ],
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null &&
                      details.primaryDelta! > 8) {
                    Navigator.pop(context);
                  }
                },
                child: _buildHandleBar(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
