import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/otp_model.dart';

class OTPViewModel extends ChangeNotifier {
  OTPModel? _otpModel;
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _resendTimer;
  int _resendTimeLeft = 0;
  Timer? _expiryTimer;

  // Getters
  OTPModel? get otpModel => _otpModel;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get resendTimeLeft => _resendTimeLeft;
  bool get canResendOTP => _resendTimeLeft == 0;
  bool get isOTPExpired => _otpModel?.isExpired ?? false;

  // Initialize with phone number
  void initialize(String phoneNumber) {
    _otpModel = OTPModel(
      phoneNumber: phoneNumber,
      sentTime: DateTime.now(),
    );
    _startResendTimer();
    _startExpiryTimer();
    notifyListeners();
  }

  // Validate OTP code
  Future<bool> validateOTP(String code) async {
    if (isOTPExpired) {
      _errorMessage = 'OTP has expired. Please request a new one.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // TODO: Implement actual SMS verification logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      bool isValid = code.length == OTPModel.otpLength; // Replace with actual validation
      
      if (isValid) {
        _otpModel = _otpModel?.copyWith(otpCode: code);
      } else {
        _errorMessage = 'Invalid OTP code';
      }

      _isLoading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to verify OTP';
      notifyListeners();
      return false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (!canResendOTP) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // TODO: Implement actual SMS resend logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
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
      _errorMessage = 'Failed to resend OTP';
      notifyListeners();
    }
  }

  void _startResendTimer() {
    _resendTimeLeft = 5; // 5 seconds cooldown as requested
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
        _errorMessage = 'OTP has expired. Please request a new one.';
        notifyListeners();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }
}
