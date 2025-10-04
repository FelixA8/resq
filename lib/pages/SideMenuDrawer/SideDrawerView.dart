import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class SideDrawerView extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onGuideTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const SideDrawerView({
    Key? key,
    this.onClose,
    this.onGuideTap,
    this.onProfileTap,
    this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ResQTheme();
    final double drawerWidth = MediaQuery.of(context).size.width * 0.5; // Adjust this value as needed
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        side: BorderSide(color: Color(theme.colors.primary)),
      ),
      child: Container(
        width: drawerWidth,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 12),
                child: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Color(theme.colors.primary),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                ),
              ),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Image.asset(
                  'assets/images/logos/resq-logo.png',
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),
              // Menu items
              _DrawerMenuItem(
                icon: Icons.menu_book_outlined,
                text: 'Panduan Bencana',
                iconColor: Color(theme.colors.primary),
                onTap: onGuideTap,
              ),
              _DrawerMenuItem(
                icon: Icons.person_outline,
                text: 'Profil',
                onTap: onProfileTap,
              ),
              const Spacer(),
              // Logout
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: _DrawerMenuItem(
                  icon: Icons.logout,
                  text: 'Keluar',
                  iconColor: Color(theme.colors.primary),
                  textColor: Color(theme.colors.primary),
                  onTap: onLogoutTap,
                  showChevron: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const _DrawerMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.onTap,
    this.showChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ResQTheme();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Color(theme.colors.primary), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: Color(theme.colors.primary), size: 20),
          ],
        ),
      ),
    );
  }
}
