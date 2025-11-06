import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'SettingsViewModel.dart';
import 'sections/profile_section.dart';
import 'sections/emergency_contacts_section.dart';
import 'sections/logout_section.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(theme.colors.primary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(theme.colors.primary),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: const [
              SizedBox(height: 16),
              ProfileSection(),
              SizedBox(height: 24),
              EmergencyContactsSection(),
              SizedBox(height: 32),
              LogoutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
