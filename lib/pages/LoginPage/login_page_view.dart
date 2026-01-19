import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/loginPage/login_page_view_model.dart';
import 'sections/login_header_section.dart';
import 'sections/login_form_section.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: const [
                        SizedBox(height: 100),
                        
                        LoginHeaderSection(),
                        
                        Spacer(),
                        
                        LoginFormSection(),
                        
                        SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
