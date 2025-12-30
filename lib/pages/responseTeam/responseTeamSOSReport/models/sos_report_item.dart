import 'package:resqapp/models/supabase_models.dart';

class SosReportItem {
  final SosEvent sosEvent;
  final ResqUser? user;
  final double? distanceKm;

  SosReportItem({
    required this.sosEvent,
    this.user,
    this.distanceKm,
  });

  String get username => user?.username ?? 'Unknown User';

  String get phoneNumber => user?.phoneNumber ?? 'No phone number';

  String get formattedTime {
    if (sosEvent.pressedAt == null) return '-';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(sosEvent.pressedAt!.toInt());
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String get formattedDistance {
    if (distanceKm == null) return '-';
    return distanceKm!.toStringAsFixed(1);
  }

  bool get isAssigned => sosEvent.isAssigned;
  String? get assignedTeamId => sosEvent.responseTeamId;
  bool get isActive => sosEvent.isActive;
  
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


