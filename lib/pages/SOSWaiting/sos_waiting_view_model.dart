import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;

class SOSWaitingViewModel extends ChangeNotifier {
  Duration _elapsedTime = Duration.zero;
  late final Ticker _ticker;
  late DateTime _startTime;
  bool _isStopped = false;
  bool _isResponseTeamAssigned = false;
  Timer? _pollingTimer;
  void Function()? onSOSCancelled;
  bool _disposed = false;

  String get formattedTime => _formatDuration(_elapsedTime);
  bool get isResponseTeamAssigned => _isResponseTeamAssigned;

  void setSOSCancelledCallback(void Function() callback) {
    onSOSCancelled = callback;
  }

  SOSWaitingViewModel({double? pressedAtMillis, this.onSOSCancelled}) {
    if (pressedAtMillis != null && pressedAtMillis > 0) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(pressedAtMillis.toInt());
    } else {
      _startTime = DateTime.now();
    }

    _ticker = Ticker(_onTick);
    _ticker.start();

    _startPolling();
  }

  void _onTick(Duration elapsed) {
    if (_shouldStopStopwatch()) {
      _stopStopwatch();
      return;
    }
    _elapsedTime = DateTime.now().difference(_startTime);
    notifyListeners();
  }

  void _startPolling() {
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    if (_disposed) return;

    _pollingTimer = Timer(const Duration(seconds: 5), () async {
      if (_disposed) return;

      await _checkResponseTeamStatus();

      if (!_disposed) {
        _scheduleNextPoll();
      }
    });
  }

  Future<void> _checkResponseTeamStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        developer.log('Cannot check SOS status: userId not found');
        return;
      }

      final supabase = Supabase.instance.client;
      final response =
          await supabase
              .from('sos_events')
              .select()
              .eq('user_id', userId)
              .order('pressed_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response != null) {
        final isCurrent = response['is_current'] as bool?;
        final responseTeamId = response['response_team_id'] as String?;

        if (isCurrent == false) {
          developer.log('SOS cancelled → stopping polling');

          stopPolling();

          onSOSCancelled?.call();
          return;
        }

        final hadResponseTeam = _isResponseTeamAssigned;
        final hasResponseTeam = responseTeamId != null;

        if (hasResponseTeam != hadResponseTeam) {
          _isResponseTeamAssigned = hasResponseTeam;
          developer.log(
            'Response team status changed: ${hasResponseTeam ? "ASSIGNED" : "UNASSIGNED"}',
          );
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log('Error checking response team status: $e');
    }
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  bool _shouldStopStopwatch() {
    return false;
  }

  void _stopStopwatch() {
    if (!_isStopped) {
      _isStopped = true;
      _ticker.stop();
      notifyListeners();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  void dispose() {
    _disposed = true;

    _pollingTimer?.cancel();
    _pollingTimer = null;

    _ticker.stop();

    super.dispose();
  }
}

class Ticker {
  final void Function(Duration) onTick;
  bool _running = false;
  Duration _elapsed = Duration.zero;
  Ticker(this.onTick);

  void start() {
    _running = true;
    _tick();
  }

  void _tick() async {
    while (_running) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_running) return;
      _elapsed += const Duration(seconds: 1);
      onTick(_elapsed);
    }
  }

  void stop() {
    _running = false;
  }
}
