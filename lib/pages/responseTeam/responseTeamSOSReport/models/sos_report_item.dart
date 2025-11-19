import 'package:resqapp/models/supabase_models.dart';

/// Model that combines SOS event data with user information
/// Used for displaying SOS reports in the list
class SosReportItem {
  final SosEvent sosEvent;
  final ResqUser? user;
  final double? distanceKm;

  SosReportItem({
    required this.sosEvent,
    this.user,
    this.distanceKm,
  });

  /// Get the username or a default value
  String get username => user?.username ?? 'Unknown User';

  /// Get the phone number or a default value
  String get phoneNumber => user?.phoneNumber ?? 'No phone number';

  /// Get the formatted timestamp
  String get formattedTime {
    if (sosEvent.pressedAt == null) return '-';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(sosEvent.pressedAt!.toInt());
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Get the formatted distance
  String get formattedDistance {
    if (distanceKm == null) return '-';
    return distanceKm!.toStringAsFixed(1);
  }

  /// Check if this SOS is assigned to a team
  bool get isAssigned => sosEvent.isAssigned;

  /// Get the response team ID if assigned
  String? get assignedTeamId => sosEvent.responseTeamId;

  /// Check if this SOS is active
  bool get isActive => sosEvent.isActive;

  /// Create a copy with updated fields
  SosReportItem copyWith({
    SosEvent? sosEvent,
    ResqUser? user,
    double? distanceKm,
  }) {
    return SosReportItem(
      sosEvent: sosEvent ?? this.sosEvent,
      user: user ?? this.user,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}



