import 'package:flutter/material.dart';

class DropdownComponent extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? iconColor;
  final TextStyle? itemTextStyle;
  final TextStyle? labelTextStyle;

  const DropdownComponent({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.padding,
    this.borderRadius = 14,
    this.backgroundColor = Colors.white,
    this.shadowColor,
    this.iconColor = const Color(0xFFB71C1C),
    this.itemTextStyle,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: labelTextStyle ?? const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        if (label != null) const SizedBox(height: 8),
        Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: shadowColor ?? Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value ?? (options.isNotEmpty ? options[0] : null),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: iconColor),
              items: options.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: itemTextStyle ?? const TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
