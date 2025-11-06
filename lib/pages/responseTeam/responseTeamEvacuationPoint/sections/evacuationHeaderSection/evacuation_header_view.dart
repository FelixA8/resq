import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationHeaderView extends StatelessWidget {
  const EvacuationHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(theme.colors.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jumlah Poin Evakuasi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                ),
              ),
              Text(
                "14 Poin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Color(0xFFB71C1C),
                  size: 19,
                ), // red accent
                SizedBox(width: 4),
                Text(
                  "Tambahkan",
                  style: TextStyle(
                    color: Color(theme.colors.primary),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
