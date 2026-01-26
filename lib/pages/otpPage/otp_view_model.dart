import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:uuid/uuid.dart';
import 'models/otp_model.dart';
import '../../services/login_services.dart';
import '../../models/supabase_models.dart';
import '../../services/sms_service.dart';
import '../../services/message_central_service.dart';

enum ViewState { otpInput, usernameInput, authenticated }

// FEATURE FLAG: Toggle between Message Central API and Local SMS
const bool USE_MESSAGE_CENTRAL = true;

class OTPViewModel extends ChangeNotifier {
  OTPModel? _otpModel;
  bool _isLoading = false;
  final theme = ResQTheme();

  Timer? _resendTimer;
  int _resendTimeLeft = 0;
  Timer? _expiryTimer;
  ViewState _currentState = ViewState.otpInput;

  String? _verificationId;
  String? _generatedOtpCode;
  String userId = "";

  OTPModel? get otpModel => _otpModel;
  bool get isLoading => _isLoading;

  int get resendTimeLeft => _resendTimeLeft;
  bool get canResendOTP => _resendTimeLeft == 0;
  bool get isOTPExpired => _otpModel?.isExpired ?? false;
  ViewState get currentState => _currentState;
  String? get verificationId => _verificationId;

  String _generateOtpCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  String get username => _otpModel?.username ?? '';
  bool get isUsernameValid => _otpModel?.isUsernameValid ?? false;

  Future<void> initialize(String phoneNumber) async {
    _otpModel = OTPModel(phoneNumber: phoneNumber, sentTime: DateTime.now());

    await _getOtp(phoneNumber);

    _startResendTimer();
    _startExpiryTimer();
    notifyListeners();
  }

  Future<void> _getOtp(String phoneNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (USE_MESSAGE_CENTRAL) {
        final result = await MessageCentralService.sendOtp(
          phoneNumber: phoneNumber,
          otpLength: 6,
        );

        if (result['success']) {
          _verificationId = result['verificationId'];
          developer.log('OTP sent via Message Central: $_verificationId');
        } else {
          Get.snackbar(
            'Error',
            result['message'] ?? 'Gagal mengirim OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.colors.primary,
            colorText: Colors.white,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 2),
          );
        }
      } else {
        _generatedOtpCode = _generateOtpCode();
        print("OTP Code: ${_generatedOtpCode}");
        _verificationId =
            'otp_${DateTime.now().millisecondsSinceEpoch}_${phoneNumber.replaceAll('+', '')}';

        final otpCode = OtpCode(
          verificationId: _verificationId!,
          otpCode: _generatedOtpCode,
          isValid: true,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(
            const Duration(minutes: OTPModel.expirationMinutes),
          ),
        );

        final connectionOk = await LoginServices.testConnection();

        OtpCode? result;

        if (!connectionOk) {
          result = otpCode;
        } else {
          result = await LoginServices.createOtpCode(otpCode);
        }

        if (result != null) {
          final smsSent = await SmsService.sendOtpSms(
            phoneNumber: phoneNumber,
            otpCode: _generatedOtpCode!,
          );

          if (smsSent) {
            Get.snackbar(
              'OTP',
              'Kode telah dikirimkan',
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              animationDuration: Duration(milliseconds: 500),
              duration: Duration(seconds: 2),
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Gagal membuat kode OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: theme.colors.primary,
            colorText: Colors.white,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 2),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      Get.snackbar(
        'Error',
        'Gagal membuat kode OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );

      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String code) async {
    if (isOTPExpired) {
      Get.snackbar(
        'OTP Kadaluarsa',
        'Kode OTP telah kadaluarsa, silahkan meminta ulang kode OTP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );

      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      bool isValid = false;

      if (USE_MESSAGE_CENTRAL) {
        final result = await MessageCentralService.validateOtp(
          verificationId: _verificationId!,
          code: code,
          phoneNumber: _otpModel!.phoneNumber,
        );
        isValid = result['success'];
      } else {
        try {
          isValid = await LoginServices.verifyOtpCode(_verificationId!, code);

          if (isValid) {
            await LoginServices.invalidateOtpCode(_verificationId!);
          }
        } catch (e) {
          isValid = _generatedOtpCode == code;
        }
      }

      if (isValid) {
        _otpModel = _otpModel?.copyWith(otpCode: code);

        final existingUser = await LoginServices.getUserByPhone(
          _otpModel!.phoneNumber,
        );

        if (existingUser != null) {
          userId = existingUser.userId;
          _otpModel = _otpModel?.copyWith(username: existingUser.username);
          _currentState = ViewState.authenticated;
        } else {
          _currentState = ViewState.usernameInput;
        }
      } else {
        Get.snackbar(
          'OTP Tidak valid',
          'Kode OTP salah, silahkan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
      }

      _isLoading = false;
      notifyListeners();

      return isValid;
    } catch (e) {
      Get.snackbar(
        'Verifikasi',
        'Verifikasi gagal, silahkan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResendOTP || _otpModel?.phoneNumber == null) return;

    _isLoading = true;

    notifyListeners();

    try {
      if (_verificationId != null) {
        await LoginServices.invalidateOtpCode(_verificationId!);
      }
      await _getOtp(_otpModel!.phoneNumber);

      _otpModel = _otpModel?.copyWith(
        resendAttempts: (_otpModel?.resendAttempts ?? 0) + 1,
        sentTime: DateTime.now(),
      );

      _startResendTimer();
      _startExpiryTimer();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      Get.snackbar(
        'Gagal',
        'Gagal mengirim OTP. Silahkan coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
      notifyListeners();
    }
  }

  void _startResendTimer() {
    _resendTimeLeft = 5;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeLeft > 0) {
        _resendTimeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isOTPExpired) {
        Get.snackbar(
          'OTP Kadaluarsa',
          'Kode OTP telah kadaluarsa, silahkan meminta ulang kode OTP.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
        notifyListeners();
        timer.cancel();
      }
    });
  }

  void setUsername(String value) {
    _otpModel = _otpModel?.copyWith(username: value);
    notifyListeners();
  }

  Future<bool> saveUsername() async {
    if (!isUsernameValid || _otpModel?.phoneNumber == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = Uuid().v4();

      final newUser = ResqUser(
        userId: userId,
        phoneNumber: _otpModel!.phoneNumber,
        username: _otpModel!.username,
        role: 'citizen',
      );

      final result = await LoginServices.createUser(newUser);

      if (result != null) {
        this.userId = userId;

        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal membuat akun, silahkan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan akun: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }
}
