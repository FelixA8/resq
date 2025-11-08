import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/components/evacuation_list_button.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationPointCard extends StatelessWidget {
  final EvacuationPoint evacuationPoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EvacuationPointCard({
    super.key,
    required this.evacuationPoint,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: theme.padding.xs,
        vertical: theme.padding.xs,
      ),
      child: Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Poin Evakuasi (${evacuationPoint.evacuationId})",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                ),
              ),
              Text(
                evacuationPoint.city ?? "Unknown Location",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          Text(
            "Ditetapkan Mulai 12/08/2003", // Mock date as shown in Figma
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              fontFamily: 'SF Pro',
            ),
          ),

          SizedBox(height: theme.size.ms),

          // Action buttons row
          Row(
            children: [
              EvacuationActionButton(
                iconPath: 'assets/images/icons/modify.png',
                text: "Modifikasi Data",
                backgroundColor: Color(0x8F2880CE).withValues(alpha: 0.5),
                textColor: Colors.black,
                onTap: onEdit,
              ),

              SizedBox(width: theme.size.ms),

              EvacuationActionButton(
                iconPath: 'assets/images/icons/remove.png',
                text: "Hapus Data",
                backgroundColor: Color(0x78F2D6D6), // rgba(242, 214, 214, 0.47)
                textColor: Color(theme.colors.primary),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
