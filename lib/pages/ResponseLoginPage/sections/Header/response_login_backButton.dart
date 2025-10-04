import 'package:flutter/material.dart';

class ResponseLoginBackButton extends StatelessWidget {
  const ResponseLoginBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 24),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.asset(
            'assets/images/icons/menu-back.png',
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }
}
