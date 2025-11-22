import 'package:resqapp/models/supabase_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResponseTeamRealtimeManager {
  RealtimeChannel? _evacuationPointsSubscription;
  RealtimeChannel? _disastersSubscription;
  RealtimeChannel? _sosEventsSubscription;

  final Function(EvacuationPoint) onEvacuationInsert;
  final Function(EvacuationPoint) onEvacuationUpdate;
  final Function(EvacuationPoint) onEvacuationDelete;

  final Function(Disaster) onDisasterInsert;
  final Function(Disaster) onDisasterUpdate;
  final Function(Disaster) onDisasterDelete;

  final Function(SosEvent) onSosInsert;
  final Function(SosEvent) onSosUpdate;
  final Function(SosEvent) onSosDelete;

  ResponseTeamRealtimeManager({
    required this.onEvacuationInsert,
    required this.onEvacuationUpdate,
    required this.onEvacuationDelete,
    required this.onDisasterInsert,
    required this.onDisasterUpdate,
    required this.onDisasterDelete,
    required this.onSosInsert,
    required this.onSosUpdate,
    required this.onSosDelete,
  });

  void initSubscriptions() {
    final client = Supabase.instance.client;

    _evacuationPointsSubscription = client
        .channel('evacuation_points_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'evacuation_points',
          callback: (payload) => _handleEvacuationChange(payload),
        )
        .subscribe();

    _disastersSubscription = client
        .channel('disasters_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'disasters',
          callback: (payload) => _handleDisasterChange(payload),
        )
        .subscribe();

    _sosEventsSubscription = client
        .channel('sos_events_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sos_events',
          callback: (payload) => _handleSosChange(payload),
        )
        .subscribe();
  }

  void dispose() {
    _evacuationPointsSubscription?.unsubscribe();
    _disastersSubscription?.unsubscribe();
    _sosEventsSubscription?.unsubscribe();
  }

  void _handleEvacuationChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          onEvacuationInsert(EvacuationPoint.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.update:
          onEvacuationUpdate(EvacuationPoint.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.delete:
          onEvacuationDelete(EvacuationPoint.fromJson(payload.oldRecord));
          break;
        default:
          break;
      }
    } catch (_) {}
  }

  void _handleDisasterChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          onDisasterInsert(Disaster.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.update:
          onDisasterUpdate(Disaster.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.delete:
          onDisasterDelete(Disaster.fromJson(payload.oldRecord));
          break;
        default:
          break;
      }
    } catch (_) {}
  }

  void _handleSosChange(PostgresChangePayload payload) {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
          onSosInsert(SosEvent.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.update:
          onSosUpdate(SosEvent.fromJson(payload.newRecord));
          break;
        case PostgresChangeEvent.delete:
          onSosDelete(SosEvent.fromJson(payload.oldRecord));
          break;
        default:
          break;
      }
    } catch (_) {}
  }
}