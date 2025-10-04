import 'package:flutter/material.dart';
import 'Header/response_login_backButton.dart';
import 'Header/response_login_logo.dart';

class ResponseLoginViewSection extends StatelessWidget {
  const ResponseLoginViewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ResponseLoginBackButton(),
        Expanded(
          child: Center(
            child: ResponseLoginLogo(),
          ),
        ),
      ],
    );
  }
}
