import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/component/response_login_back_button.dart';
import 'package:resqapp/pages/responseLoginPage/component/response_login_logo.dart';
import 'response_login_page_view_model.dart';
import 'sections/response_login_form_section.dart';

class ResponseLoginPageView extends GetView<ResponseLoginPageViewModel> {
  const ResponseLoginPageView({super.key});

  @override
  Widget build(BuildContext context) {

    if (!Get.isRegistered<ResponseLoginPageViewModel>()) {
      Get.put(ResponseLoginPageViewModel(), permanent: false);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: Column(
                children: [
                  ResponseLoginBackButton(),
                  Expanded(child: Center(child: ResponseLoginLogo())),
                ],
              ),
            ),
            const ResponseLoginFormSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
