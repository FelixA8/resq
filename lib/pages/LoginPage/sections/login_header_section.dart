import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

static const theme = ResQTheme();
  
  @override
  Widget build(BuildContext context) {
    return // Logo section
                Container(
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: theme.padding.xl3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.58,
                            child: Image.asset(
                              'assets/images/logos/resq-logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            child: Image.asset(
                              'assets/images/illustrations/login-illustration.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
  }
}
