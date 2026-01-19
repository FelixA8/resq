import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/component/response_login_back_button.dart';
import 'package:resqapp/pages/responseLoginPage/component/response_login_logo.dart';
import 'response_login_page_view_model.dart';
import 'sections/response_login_form_section.dart';

class ResponseTeamLoginView extends GetView<ResponseTeamLoginViewModel> {
  const ResponseTeamLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ResponseTeamLoginViewModel>()) {
      Get.put(ResponseTeamLoginViewModel(), permanent: false);
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const ResponseLoginBackButton(),

                        SizedBox(height: screenHeight * 0.10),

                        const ResponseLoginLogo(),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 0.0,
                          ),
                          child: SizedBox(
                            height: screenHeight * 0.11,
                            child: Image.asset(
                              'assets/images/illustrations/response-team.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const ResponseLoginFormSection(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
