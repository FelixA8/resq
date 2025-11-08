import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models/otp_model.dart';
import '../../service/supabase_service.dart';
import '../../models/supabase_models.dart';
import '../../services/sms_service.dart';

enum ViewState { otpInput, usernameInput }

class OTPViewModel extends ChangeNotifier {
  OTPModel? _otpModel;
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _resendTimer;
  int _resendTimeLeft = 0;
  Timer? _expiryTimer;
  ViewState _currentState = ViewState.otpInput;

  String? _verificationId;
  String? _generatedOtpCode;

  // Getters
  OTPModel? get otpModel => _otpModel;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get resendTimeLeft => _resendTimeLeft;
  bool get canResendOTP => _resendTimeLeft == 0;
  bool get isOTPExpired => _otpModel?.isExpired ?? false;
  ViewState get currentState => _currentState;
  String? get verificationId => _verificationId;

  String _generateOtpCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Username-related getters
  String get username => _otpModel?.username ?? '';
  bool get isUsernameValid => _otpModel?.isUsernameValid ?? false;

  // Initialize with phone number
  Future<void> initialize(String phoneNumber) async {
    _otpModel = OTPModel(phoneNumber: phoneNumber, sentTime: DateTime.now());

    await _createAndStoreOtpCode(phoneNumber);

    _startResendTimer();
    _startExpiryTimer();
    notifyListeners();
  }

  Future<void> _createAndStoreOtpCode(String phoneNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      _generatedOtpCode = _generateOtpCode();
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

      // Test Supabase connection first
      print('🔄 Testing Supabase connection...');
      final connectionOk = await SupabaseService.testConnection();

      OtpCode? result;

      if (!connectionOk) {
        // POC Fallback: Generate OTP even without database connection
        print(
          '⚠️ Database connection failed - using POC mode (OTP not saved to database)',
        );
        print('🔐 Generated OTP code: ${_generatedOtpCode}');
        print('📝 Note: In production, database connection is required');

        // For POC, we still allow OTP generation but warn the user
        result = otpCode; // Use the generated code even without database save
        _errorMessage = ''; // Clear error since we're in POC mode
      } else {
        print('🔄 Calling SupabaseService.createOtpCode...');
        result = await SupabaseService.createOtpCode(otpCode);
        print('📤 OTP creation result: $result');
      }

      if (result != null) {
        // Send SMS with OTP code (opens SMS app)
        final smsSent = await SmsService.sendOtpSms(
          phoneNumber: phoneNumber,
          otpCode: _generatedOtpCode!,
        );

        // Show OTP code for testing purposes
        SmsService.showOtpForTesting(
          phoneNumber: phoneNumber,
          otpCode: _generatedOtpCode!,
        );

        if (smsSent) {
          print(
            '✅ OTP Code generated and SMS app opened: ${_generatedOtpCode!} to $phoneNumber',
          );
          _errorMessage = '';
        } else {
          print(
            '⚠️ OTP Code generated: ${_generatedOtpCode!} but SMS app failed to open for $phoneNumber',
          );
          _errorMessage =
              'OTP generated but SMS app failed to open. Code: $_generatedOtpCode';
        }
      } else {
        _errorMessage = 'Failed to generate OTP code';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error generating OTP code';
      notifyListeners();
    }
  }

  Future<bool> validateOTP(String code) async {
    if (isOTPExpired) {
      _errorMessage = 'OTP has expired. Please request a new one.';
      notifyListeners();
      return false;
    }

    if (_verificationId == null) {
      _errorMessage = 'No OTP verification session found.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      bool isValid = false;

      // Try to verify with Supabase first
      try {
        isValid = await SupabaseService.verifyOtpCode(_verificationId!, code);

        if (isValid) {
          // Invalidate the OTP code in Supabase (mark as used)
          await SupabaseService.invalidateOtpCode(_verificationId!);
        }
      } catch (e) {
        // POC Fallback: If database unavailable, verify against locally generated code
        print(
          '⚠️ Database verification failed - using local verification (POC mode)',
        );
        print('🔍 Verifying code locally: ${_generatedOtpCode} == $code');
        isValid = _generatedOtpCode == code;

        if (isValid) {
          print('✅ Local verification successful (POC mode)');
        }
      }

      if (isValid) {
        _otpModel = _otpModel?.copyWith(otpCode: code);

        // Transition to username input state after successful OTP verification
        _currentState = ViewState.usernameInput;
      } else {
        _errorMessage = 'Invalid OTP code';
      }

      _isLoading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to verify OTP: $e';
      notifyListeners();
      return false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (!canResendOTP || _otpModel?.phoneNumber == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Invalidate the old OTP code
      if (_verificationId != null) {
        await SupabaseService.invalidateOtpCode(_verificationId!);
      }

      // Create new OTP code
      await _createAndStoreOtpCode(_otpModel!.phoneNumber);

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
      _errorMessage = 'Failed to resend OTP: $e';
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

  // Username-related methods
  void setUsername(String value) {
    _otpModel = _otpModel?.copyWith(username: value);
    notifyListeners();
  }

  Future<bool> saveUsername() async {
    if (!isUsernameValid || _otpModel?.phoneNumber == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Generate a unique user ID (you can use UUID package or timestamp-based)
      final userId = Uuid().v4();

      // Create ResqUser object
      final newUser = ResqUser(
        userId: userId,
        phoneNumber: _otpModel!.phoneNumber,
        username: _otpModel!.username,
        role: 'citizen', // Default role for regular users
        // city can be added later through profile setup
      );

      // Save user to Supabase
      final result = await SupabaseService.createUser(newUser);

      if (result != null) {
        print(
          '✅ User created successfully: ${result.username} (${result.userId})',
        );
        _errorMessage = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create user account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save username: $e';
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
