import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class LogoutSection extends StatelessWidget {
  const LogoutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opsi Lainnya',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Keluar akun',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(theme.colors.primary),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Konfirmasi Logout'),
                        content: Text('Apakah Anda yakin ingin keluar akun?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Konfirmasi'),
                          ),
                        ],
                      ),
                    );
                    if (result == true) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/icons/logout.png', // Use your signout icon asset
                      width: 22,
                      height: 22,
                      color: Color(theme.colors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
