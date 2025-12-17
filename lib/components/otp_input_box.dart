import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputBox extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final Function(String) onChanged;
  final VoidCallback? onBackspace;
  final FocusNode focusNode;

  const OTPInputBox({
    super.key,
    required this.controller,
    required this.autoFocus,
    required this.onChanged,
    required this.focusNode,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      // 1. Keep the KeyboardListener for backspace detection
      child: KeyboardListener(
        // Use the passed-in focusNode so it listens to the correct field
        focusNode: focusNode, 
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty &&
              onBackspace != null) {
            onBackspace!();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autoFocus,
          textAlign: TextAlign.center,
          // 2. Incorporate the iOS-specific keyboard fix
          keyboardType: Platform.isIOS
              ? const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                )
              : TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.length == 1) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
