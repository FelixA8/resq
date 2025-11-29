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

  String get formattedTime => _formatDuration(_elapsedTime);
  bool get isResponseTeamAssigned => _isResponseTeamAssigned;

  /// Set the callback for when SOS is cancelled (isCurrent becomes false)
  void setSOSCancelledCallback(void Function() callback) {
    onSOSCancelled = callback;
  }

  SOSWaitingViewModel({
    double? pressedAtMillis,
    this.onSOSCancelled,
  }) {
    if (pressedAtMillis != null && pressedAtMillis > 0) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(pressedAtMillis.toInt());
    } else {
      _startTime = DateTime.now();
    }
    
    _ticker = Ticker(_onTick);
    _ticker.start();
    
    // Start polling to check for response team assignment
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

  /// Start polling every 5 seconds to check if response team has been assigned
  void _startPolling() async {
    developer.log('🔄 Starting SOS status polling (every 5 seconds)');
    
    // Check immediately first
    await _checkResponseTeamStatus();
    
    // Then poll every 5 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkResponseTeamStatus();
    });
  }

  /// Check if response team has been assigned to this SOS event
  Future<void> _checkResponseTeamStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        developer.log('⚠️ Cannot check SOS status: userId not found');
        return;
      }
      
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('sos_events')
          .select()
          .eq('user_id', userId)
          .order('pressed_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        final isCurrent = response['is_current'] as bool?;
        final responseTeamId = response['response_team_id'] as String?;
        
        // Check if SOS was cancelled (isCurrent became false)
        if (isCurrent == false) {
          developer.log('⚠️ SOS cancelled - isCurrent is now false');
          if (onSOSCancelled != null) {
            developer.log('🔙 Triggering SOS cancellation callback');
            onSOSCancelled!();
          }
          return; // Stop checking, SOS is no longer active
        }
        
        // Check response team assignment status
        final hadResponseTeam = _isResponseTeamAssigned;
        final hasResponseTeam = responseTeamId != null;
        
        if (hasResponseTeam != hadResponseTeam) {
          _isResponseTeamAssigned = hasResponseTeam;
          developer.log('✅ Response team status changed: ${hasResponseTeam ? "ASSIGNED" : "UNASSIGNED"}');
          notifyListeners(); // Notify UI to rebuild
        }
      }
    } catch (e) {
      developer.log('⚠️ Error checking response team status: $e');
    }
  }

  /// Placeholder condition to stop the stopwatch
  /// TODO: Replace with actual condition (e.g., response received, user cancels, etc.)
  bool _shouldStopStopwatch() {
    // Placeholder: return false to run endlessly
    // Example conditions you might want to check:
    // - Response received from emergency services
    // - User manually cancels SOS
    // - Maximum time limit reached
    // - Connection established with responder
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
    _ticker.stop();
    _pollingTimer?.cancel();
    developer.log('🔕 Stopped SOS status polling');
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
      await Future.delayed(Duration(seconds: 1));
      _elapsed += Duration(seconds: 1);
      onTick(_elapsed);
    }
  }

  void stop() {
    _running = false;
  }
}
