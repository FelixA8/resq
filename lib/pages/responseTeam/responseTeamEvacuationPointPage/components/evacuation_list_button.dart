import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationActionButton extends StatelessWidget {
  final String iconPath;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const EvacuationActionButton({
    super.key,
    required this.iconPath,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.padding.ms,
            vertical: theme.padding.s,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 22,
                height: 22,
              ),
              Container(
                width: 2,
                height: 30,
                margin: EdgeInsets.symmetric(
                  horizontal: theme.padding.s,
                ),
                color: Color(0x757B7979), // rgba(123, 121, 121, 0.46)
              ),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

