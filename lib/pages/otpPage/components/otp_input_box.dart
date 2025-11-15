import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputBox extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final Function(String) onChanged;
  final FocusNode focusNode;

  const OTPInputBox({
    Key? key,
    required this.controller,
    required this.autoFocus,
    required this.onChanged,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
