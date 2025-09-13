import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class LoginPage extends StatefulWidget {
   const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isResponseTeam = false;

  static const theme = ResQTheme();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    // TODO: Implement OTP sending logic
    if (_phoneController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to +62${_phoneController.text}'),
          backgroundColor:  Color(theme.colors.primary),
        ),
      );
      Navigator.pushNamed(
        context,
        '/otpView', // Make sure this route is defined in your MaterialApp routes
        arguments: {
          'phone': _phoneController.text,
          'isResponseTeam': _isResponseTeam,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Color(theme.colors.primary),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 100), // Reduced from 140 to 40
                // Logo section
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
                ),
               
                // Login form section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: theme.padding.lm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Push content to the bottom
                      children: [
                        // Phone number input
                        Row(
                          children: [
                            // Country code container with flag and code
                            Container(
                              width: 67,
                              height: 51,
                              decoration: BoxDecoration(
                                color:  Color(theme.colors.neutral.low),
                                borderRadius: BorderRadius.circular(10), // All corners radius 10
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Flag image
                                  Padding(
                                    padding:  EdgeInsets.only(right: 4),
                                    child: Image.asset(
                                      'assets/images/icons/indonesian-flag.png', // Make sure this asset exists
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
                             SizedBox(width: 8), // Add space between the two containers
                            // Phone number input container
                            Expanded(
                              child: Container(
                                height: 51,
                                decoration: BoxDecoration(
                                  color:  Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(theme.size.s), // All corners radius 10
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style:  TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: theme.text.m,
                                      color: Colors.black,
                                    ),
                                    textAlignVertical: TextAlignVertical.center, // Center text vertically
                                    decoration:  InputDecoration(
                                      hintText: 'Nomor telepon',
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(theme.colors.neutral.med),
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: theme.padding.m), // Only horizontal padding
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                         SizedBox(height: 28),
                        
                        // Send OTP button
                        SizedBox(
                          width: 359,
                          height: 51,
                          child: ElevatedButton(
                            onPressed: _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Color(theme.colors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:  EdgeInsets.symmetric(
                                horizontal: 143,
                                vertical: 16,
                              ),
                            ),
                            child:  Text(
                              'Kirim OTP',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                         SizedBox(height: 9),
                        
                        // Response team checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             SizedBox(width: 8),
                             Text(
                              'Masuk sebagai response team',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                fontSize: theme.text.m,
                                color: Colors.black,
                              ),
                            ),
                             SizedBox(width: 3),
                             Icon(
                              Icons.keyboard_arrow_right,
                              size: 18,
                              color: Color(theme.colors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Add bottom padding to move content slightly up from the bottom
                 SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
