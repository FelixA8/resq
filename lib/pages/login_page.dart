import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isResponseTeam = false;

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
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Colors.red,
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
              color: Colors.white
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.19, 
              child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            )
            ,
            ),
            
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70), // Add space between top and logo
                // Logo section
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Login form section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21),
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
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(10), // All corners radius 10
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Flag image
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Image.asset(
                                      'assets/images/indonesia_flag.png', // Make sure this asset exists
                                      width: 18,
                                      height: 12,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const Text(
                                    '+62',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Add space between the two containers
                            // Phone number input container
                            Expanded(
                              child: Container(
                                height: 51,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(10), // All corners radius 10
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                    textAlignVertical: TextAlignVertical.center, // Center text vertically
                                    decoration: const InputDecoration(
                                      hintText: 'Nomor telepon',
                                      hintStyle: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFF7B7B7D),
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16), // Only horizontal padding
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Send OTP button
                        SizedBox(
                          width: 359,
                          height: 51,
                          child: ElevatedButton(
                            onPressed: _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 143,
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
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
                        
                        const SizedBox(height: 9),
                        
                        // Response team checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isResponseTeam = !_isResponseTeam;
                                });
                              },
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isResponseTeam ? const Color(0xFFB71C1C) : Colors.transparent,
                                  border: Border.all(
                                    color: const Color(0xFF7B7979),
                                    width: 0.1,
                                  ),
                                ),
                                child: _isResponseTeam
                                    ? const Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
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
                            const Icon(
                              Icons.keyboard_arrow_right,
                              size: 18,
                              color: Color(0xFFB71C1C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Add bottom padding to move content slightly up from the bottom
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
