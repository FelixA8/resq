import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/loginPage/lower_case_view_model.dart';
import 'sections/login_header_section.dart';
import 'sections/login_form_section.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginPageViewModel(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
              ),
            ),
            SafeArea(
              child: Column(
                children: const [
                  SizedBox(height: 100),
                  LoginHeaderSection(),
                  Expanded(child: LoginFormSection()),
                  SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
