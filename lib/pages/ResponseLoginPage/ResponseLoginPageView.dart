import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ResponseLoginPageViewModel.dart';
import 'sections/response_login_form_section.dart';
import 'sections/response_login_view_section.dart';

class ResponseLoginPageView extends StatelessWidget {
  const ResponseLoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResponseLoginPageViewModel(),
      child: const _ResponseLoginPageBody(),
    );
  }
}

class _ResponseLoginPageBody extends StatelessWidget {
  const _ResponseLoginPageBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: ResponseLoginViewSection()),
            const ResponseLoginFormSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
