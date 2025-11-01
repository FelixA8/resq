import 'package:flutter/material.dart';

class SOSWaitingViewModel extends ChangeNotifier {
  Duration _elapsedTime = Duration.zero;
  late final Ticker _ticker;
  late DateTime _startTime;
  bool _isStopped = false;

  String get formattedTime => _formatDuration(_elapsedTime);

  SOSWaitingViewModel() {
    _startTime = DateTime.now();
    _ticker = Ticker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    // Check for stop condition (placeholder for now)
    if (_shouldStopStopwatch()) {
      _stopStopwatch();
      return;
    }

    // Update elapsed time
    _elapsedTime = DateTime.now().difference(_startTime);
    notifyListeners();
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
