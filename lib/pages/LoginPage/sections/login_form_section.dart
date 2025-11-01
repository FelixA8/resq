import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/loginPage/lower_case_view_model.dart';
import '../../../theme/theme_app.dart';
import '../../../components/confirmation_button.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginPageViewModel>(context);
    const theme = ResQTheme();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.padding.lm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 67,
                height: 51,
                decoration: BoxDecoration(
                  color: Color(theme.colors.neutral.low),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Image.asset(
                        'assets/images/icons/indonesian-flag.png',
                        width: 18,
                        height: 12,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      '+62',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: theme.text.m,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 51,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      controller: viewModel.phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: theme.text.m,
                        color: Colors.black,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Nomor telepon',
                        hintStyle: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(theme.colors.neutral.med),
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: theme.padding.m,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            child: ConfirmationButton(
              onPressed: () => viewModel.handleSendOTP(context),
              isEnabled: true, // Set to true or use your logic
              text: 'Kirim OTP',
            ),
          ),
          const SizedBox(height: 9),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/responseLogin');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                const Text(
                  'Masuk sebagai response team',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 18,
                  color: Color(theme.colors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
