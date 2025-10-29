// Supabase Database Models for ResQ App
// Generated from database_schema.md
// File: lib/models/supabase_models.dart

/// User account information
class ResqUser {
  final String userId;
  final String? role;
  final String? phoneNumber;
  final String? username;
  final String? city;

  ResqUser({
    required this.userId,
    this.role,
    this.phoneNumber,
    this.username,
    this.city,
  });

  factory ResqUser.fromJson(Map<String, dynamic> json) {
    return ResqUser(
      userId: json['user_id'] as String,
      role: json['role'] as String?,
      phoneNumber: json['phone_number'] as String?,
      username: json['username'] as String?,
      city: json['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'phone_number': phoneNumber,
      'username': username,
      'city': city,
    };
  }

  ResqUser copyWith({
    String? userId,
    String? role,
    String? phoneNumber,
    String? username,
    String? city,
  }) {
    return ResqUser(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      city: city ?? this.city,
    );
  }
}

/// OTP verification code
class OtpCode {
  final String verificationId;
  final String? userId;
  final String? otpCode;
  final bool? isValid;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  OtpCode({
    required this.verificationId,
    this.userId,
    this.otpCode,
    this.isValid,
    this.createdAt,
    this.expiresAt,
  });

  factory OtpCode.fromJson(Map<String, dynamic> json) {
    return OtpCode(
      verificationId: json['verification_id'] as String,
      userId: json['user_id'] as String?,
      otpCode: json['otp_code'] as String?,
      isValid: json['is_valid'] as bool?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verification_id': verificationId,
      'user_id': userId,
      'otp_code': otpCode,
      'is_valid': isValid,
      'created_at': createdAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => isValid == true && !isExpired;
}

/// Emergency contact for user
class Contact {
  final String userId;
  final String contactName;
  final String? phoneNumber;

  Contact({
    required this.userId,
    required this.contactName,
    this.phoneNumber,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      userId: json['user_id'] as String,
      contactName: json['contact_name'] as String,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'contact_name': contactName,
      'phone_number': phoneNumber,
    };
  }
}

/// Disaster event
class Disaster {
  final String disasterId;
  final DateTime? occurredAt;
  final double? centerLat;
  final double? centerLng;
  final double? magnitude;
  final String? depth;
  final String? shakemap;

  Disaster({
    required this.disasterId,
    this.occurredAt,
    this.centerLat,
    this.centerLng,
    this.magnitude,
    this.depth,
    this.shakemap,
  });

  factory Disaster.fromJson(Map<String, dynamic> json) {
    return Disaster(
      disasterId: json['disaster_id'] as String,
      occurredAt: json['occurred_at'] != null ? DateTime.parse(json['occurred_at']) : null,
      centerLat: json['center_lat'] != null ? (json['center_lat'] as num).toDouble() : null,
      centerLng: json['center_lng'] != null ? (json['center_lng'] as num).toDouble() : null,
      magnitude: json['magnitude'] != null ? (json['magnitude'] as num).toDouble() : null,
      depth: json['depth'] as String?,
      shakemap: json['shakemap'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disaster_id': disasterId,
      'occurred_at': occurredAt?.toIso8601String(),
      'center_lat': centerLat,
      'center_lng': centerLng,
      'magnitude': magnitude,
      'depth': depth,
      'shakemap': shakemap,
    };
  }
}

/// Response team member
class ResponseTeam {
  final String responseTeamId;
  final String? role;
  final String? password; // Should be hashed

  ResponseTeam({
    required this.responseTeamId,
    this.role,
    this.password,
  });

  factory ResponseTeam.fromJson(Map<String, dynamic> json) {
    return ResponseTeam(
      responseTeamId: json['response_team_id'] as String,
      role: json['role'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_team_id': responseTeamId,
      'role': role,
      'password': password,
    };
  }
}

/// Evacuation point
class EvacuationPoint {
  final String evacuationId;
  final String? responseTeamId;
  final double? locationLat;
  final double? locationLng;
  final String? city;

  EvacuationPoint({
    required this.evacuationId,
    this.responseTeamId,
    this.locationLat,
    this.locationLng,
    this.city,
  });

  factory EvacuationPoint.fromJson(Map<String, dynamic> json) {
    return EvacuationPoint(
      evacuationId: json['evacuation_id'] as String,
      responseTeamId: json['response_team_id'] as String?,
      locationLat: json['location_lat'] != null ? (json['location_lat'] as num).toDouble() : null,
      locationLng: json['location_lng'] != null ? (json['location_lng'] as num).toDouble() : null,
      city: json['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evacuation_id': evacuationId,
      'response_team_id': responseTeamId,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'city': city,
    };
  }

  bool hasLocation() => locationLat != null && locationLng != null;
}

/// SOS emergency event
class SosEvent {
  final String sosId;
  final String? userId;
  final bool? sosPressed;
  final DateTime? pressedAt;
  final double? locationLat;
  final double? locationLng;

  SosEvent({
    required this.sosId,
    this.userId,
    this.sosPressed,
    this.pressedAt,
    this.locationLat,
    this.locationLng,
  });

  factory SosEvent.fromJson(Map<String, dynamic> json) {
    return SosEvent(
      sosId: json['sos_id'] as String,
      userId: json['user_id'] as String?,
      sosPressed: json['sos_pressed'] as bool?,
      pressedAt: json['pressed_at'] != null ? DateTime.parse(json['pressed_at']) : null,
      locationLat: json['location_lat'] != null ? (json['location_lat'] as num).toDouble() : null,
      locationLng: json['location_lng'] != null ? (json['location_lng'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sos_id': sosId,
      'user_id': userId,
      'sos_pressed': sosPressed,
      'pressed_at': pressedAt,
      'location_lat': locationLat,
      'location_lng': locationLng,
    };
  }

  bool hasLocation() => locationLat != null && locationLng != null;
}

/// SOS assignment to response team
class SosAssignment {
  final String sosId;
  final String? responseTeamId;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final bool? isCurrent;

  SosAssignment({
    required this.sosId,
    this.responseTeamId,
    this.assignedAt,
    this.resolvedAt,
    this.isCurrent,
  });

  factory SosAssignment.fromJson(Map<String, dynamic> json) {
    return SosAssignment(
      sosId: json['sos_id'] as String,
      responseTeamId: json['response_team_id'] as String?,
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      isCurrent: json['is_current'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sos_id': sosId,
      'response_team_id': responseTeamId,
      'assigned_at': assignedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'is_current': isCurrent,
    };
  }

  bool get isResolved => resolvedAt != null;
  bool get isActive => isCurrent == true && !isResolved;
}

/// Junction table linking disasters to response teams
class DisasterResponseTeam {
  final String disasterId;
  final String responseTeamId;

  DisasterResponseTeam({
    required this.disasterId,
    required this.responseTeamId,
  });

  factory DisasterResponseTeam.fromJson(Map<String, dynamic> json) {
    return DisasterResponseTeam(
      disasterId: json['disaster_id'] as String,
      responseTeamId: json['response_team_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disaster_id': disasterId,
      'response_team_id': responseTeamId,
    };
  }
}

