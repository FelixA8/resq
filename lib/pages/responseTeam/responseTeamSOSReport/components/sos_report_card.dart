import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../models/sos_report_item.dart';
import 'report_card_button.dart';

/// Reusable SOS Report Card Component
class SOSReportCard extends StatelessWidget {
  final SosReportItem reportItem;
  final VoidCallback? onViewMapPressed;
  final String Function(DateTime) formatTimestamp;

  const SOSReportCard({
    Key? key,
    required this.reportItem,
    this.onViewMapPressed,
    required this.formatTimestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    final sosEvent = reportItem.sosEvent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.all(theme.padding.ms),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 2),
              blurRadius: 10,
              spreadRadius: 0,
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
                      reportItem.username,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: theme.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reportItem.phoneNumber,
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
                  reportItem.formattedTime,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: theme.colors.primary,
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
                '${reportItem.formattedDistance} Km',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                  color: theme.colors.primary,
                ),
              ),
              // Right: Button
              sosEvent.responseTeamId != null
                  ? ReportCardButton(
                      isAssigned: sosEvent.isAssigned,
                      assignedUnitId: sosEvent.responseTeamId,
                      onPressed: sosEvent.isAssigned ? null : onViewMapPressed,
                    )
                  : ReportCardButton(
                      isAssigned: false,
                      onPressed: onViewMapPressed,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

