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
  final bool isValid;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  OtpCode({
    required this.verificationId,
    this.userId,
    this.otpCode,
    required this.isValid,
    this.createdAt,
    this.expiresAt,
  });

  factory OtpCode.fromJson(Map<String, dynamic> json) {
    return OtpCode(
      verificationId: json['verification_id'] as String,
      userId: json['user_id'] as String?,
      otpCode: json['otp_code'] as String?,
      isValid: json['is_valid'] as bool,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'])
              : null,
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

  Contact({required this.userId, required this.contactName, this.phoneNumber});

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
  final double? occurredAt;
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
      occurredAt:
          json['occurred_at'] != null
              ? (json['occurred_at'] as num).toDouble()
              : null,
      centerLat:
          json['center_lat'] != null
              ? (json['center_lat'] as num).toDouble()
              : null,
      centerLng:
          json['center_lng'] != null
              ? (json['center_lng'] as num).toDouble()
              : null,
      magnitude:
          json['magnitude'] != null
              ? (json['magnitude'] as num).toDouble()
              : null,
      depth: json['depth'] as String?,
      shakemap: json['shakemap'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disaster_id': disasterId,
      'occurred_at': occurredAt,
      'center_lat': centerLat,
      'center_lng': centerLng,
      'magnitude': magnitude,
      'depth': depth,
      'shakemap': shakemap,
    };
  }

  bool hasLocation() => centerLat != null && centerLng != null;
}

/// Response team member
class ResponseTeam {
  final String responseTeamId;
  final String? role;
  final String? password; // Should be hashed
  final String? instanceCode;

  ResponseTeam({
    required this.responseTeamId,
    this.role,
    this.password,
    this.instanceCode,
  });

  factory ResponseTeam.fromJson(Map<String, dynamic> json) {
    return ResponseTeam(
      responseTeamId: json['response_team_id'] as String,
      role: json['role'] as String?,
      password: json['password'] as String?,
      instanceCode: json['instance_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_team_id': responseTeamId,
      'role': role,
      'password': password,
      'instance_code': instanceCode,
    };
  }

  /// Convert to JSON for shared preferences (exclude password for security)
  Map<String, dynamic> toSharedPrefsJson() {
    return {
      'response_team_id': responseTeamId,
      'role': role,
      'instance_code': instanceCode,
    };
  }

  /// Create from shared preferences JSON
  factory ResponseTeam.fromSharedPrefsJson(Map<String, dynamic> json) {
    return ResponseTeam(
      responseTeamId: json['response_team_id'] as String,
      role: json['role'] as String?,
      password: null, // Don't store password in shared preferences
      instanceCode: json['instance_code'] as String?,
    );
  }
}

/// Evacuation point
class EvacuationPoint {
  final String? evacuationId;
  final String? responseTeamId;
  final double? locationLat;
  final double? locationLng;
  final String? city;
  final double? createdAt;
  final String? locationDetail;

  EvacuationPoint({
    required this.evacuationId,
    this.responseTeamId,
    this.locationLat,
    this.locationLng,
    this.city,
    this.createdAt,
    this.locationDetail,
  });

  factory EvacuationPoint.fromJson(Map<String, dynamic> json) {
    return EvacuationPoint(
      evacuationId: json['evacuation_id'] as String,
      responseTeamId: json['response_team_id'] as String?,
      locationLat:
          json['location_lat'] != null
              ? (json['location_lat'] as num).toDouble()
              : null,
      locationLng:
          json['location_lng'] != null
              ? (json['location_lng'] as num).toDouble()
              : null,
      createdAt:
          json['created_at'] != null
              ? (json['created_at'] as num).toDouble()
              : null,
      city: json['city'] as String?,
      locationDetail: json['location_detail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evacuation_id': evacuationId,
      'response_team_id': responseTeamId,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'city': city,
      'created_at': createdAt,
      'location_detail': locationDetail,
    };
  }

  bool hasLocation() => locationLat != null && locationLng != null;
}

/// SOS emergency event
class SosEvent {
  final String sosId;
  final String? userId;
  final double? locationLat;
  final double? locationLng;
  final String? responseTeamId;
  final bool? isCurrent;
  final double? pressedAt;
  final double? assignedAt;
  final double? resolvedAt;

  SosEvent({
    required this.sosId,
    this.userId,
    this.locationLat,
    this.locationLng,
    this.responseTeamId,
    this.isCurrent,
    this.pressedAt,
    this.assignedAt,
    this.resolvedAt,
  });

  // bool get isActive {
  //   return isCurrent == true && resolvedAt == null;
  // }

  factory SosEvent.fromJson(Map<String, dynamic> json) {
    print(json);
    return SosEvent(
      sosId: json['sos_id'] as String,
      userId: json['user_id'] as String?,
      locationLat:
          json['location_lat'] != null
              ? (json['location_lat'] as num).toDouble()
              : null,
      locationLng:
          json['location_lng'] != null
              ? (json['location_lng'] as num).toDouble()
              : null,
      responseTeamId: json['response_team_id'] as String?,
      isCurrent: json['is_current'] as bool?,
      pressedAt: json['pressed_at'] != null
    ? (json['pressed_at'] as num).toDouble()
    : null,
      assignedAt: json['assigned_at'] != null
    ? (json['assigned_at'] as num).toDouble()
    : null,
      resolvedAt: json['resolved_at'] != null
    ? (json['resolved_at'] as num).toDouble()
    : null,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sos_id': sosId,
      'user_id': userId,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'response_team_id': responseTeamId,
      'is_current': isCurrent,
      'pressed_at': pressedAt,
      'assigned_at': assignedAt,
      'resolved_at': resolvedAt,
    };
  }

  bool hasLocation() => locationLat != null && locationLng != null;
  
  bool get isAssigned => responseTeamId != null;
  bool get isResolved => resolvedAt != null && resolvedAt! > 0;
  bool get isActive => isCurrent == true && !isResolved;
  
  /// Create a copy of this SosEvent with updated fields
  SosEvent copyWith({
    String? sosId,
    String? userId,
    double? locationLat,
    double? locationLng,
    String? responseTeamId,
    bool? isCurrent,
    double? pressedAt,
    double? assignedAt,
    double? resolvedAt,
  }) {
    return SosEvent(
      sosId: sosId ?? this.sosId,
      userId: userId ?? this.userId,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      responseTeamId: responseTeamId ?? this.responseTeamId,
      isCurrent: isCurrent ?? this.isCurrent,
      pressedAt: pressedAt ?? this.pressedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
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
    return {'disaster_id': disasterId, 'response_team_id': responseTeamId};
  }
}
