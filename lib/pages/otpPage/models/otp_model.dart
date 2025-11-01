class OTPModel {
  final String phoneNumber;
  final String otpCode;
  final DateTime? sentTime;
  final int resendAttempts;
  final String username;
  static const otpLength = 6;
  static const expirationMinutes = 15;

  OTPModel({
    required this.phoneNumber,
    this.otpCode = '',
    this.sentTime,
    this.resendAttempts = 0,
    this.username = '',
  });

  DateTime? get expiryTime =>
      sentTime?.add(const Duration(minutes: expirationMinutes));

  bool get isExpired {
    if (sentTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  String get formattedPhoneNumber {
    // Basic phone number formatting - you might want to enhance this
    if (phoneNumber.length < 4) return phoneNumber;
    return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4)}';
  }

  bool get isUsernameValid {
    return username.trim().isNotEmpty &&
        username.trim().length >= 3 &&
        username.trim().length <= 30;
  }

  OTPModel copyWith({
    String? phoneNumber,
    String? otpCode,
    DateTime? sentTime,
    int? resendAttempts,
    String? username,
  }) {
    return OTPModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      sentTime: sentTime ?? this.sentTime,
      resendAttempts: resendAttempts ?? this.resendAttempts,
      username: username ?? this.username,
    );
  }
}
