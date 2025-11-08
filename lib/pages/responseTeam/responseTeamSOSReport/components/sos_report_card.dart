import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../models/sos_report_item.dart';
import 'report_card_button.dart';

/// Reusable SOS Report Card Component
class SOSReportCard extends StatelessWidget {
  final SOSReportItem report;
  final VoidCallback? onViewMapPressed;
  final String Function(DateTime) formatTimestamp;

  const SOSReportCard({
    Key? key,
    required this.report,
    this.onViewMapPressed,
    required this.formatTimestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Name and Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Name and Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.userName,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Color(theme.colors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.phoneNumber,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Timestamp badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1C8C8), // Pink
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formatTimestamp(report.timestamp),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(theme.colors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom row: Distance and Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Distance
              Text(
                '${report.distanceKm.toStringAsFixed(1)} Km',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                  color: Color(theme.colors.primary),
                ),
              ),
              // Right: Button
              ReportCardButton(
                isAssigned: report.isAssigned,
                assignedUnitId: report.assignedUnitId,
                onPressed: report.isAssigned ? null : onViewMapPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

