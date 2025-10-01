// lib/providers/hotspot_manager_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:portable_wifi/services/notification.dart';

class HotspotManagerProvider extends ChangeNotifier {
  // Timer State
  Timer? _timer;
  int _remainingSeconds = 0;
  bool get isTimerRunning => _timer?.isActive ?? false;
  int get remainingSeconds => _remainingSeconds;

  void startTimer(int minutes) {
    stopTimer(notify: false);
    _remainingSeconds = minutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        stopTimer();
        NotificationService().showNotification(
          'Hotspot Timer Finished',
          'Remember to turn off your portable hotspot!',
        );
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer({bool notify = true}) {
    _timer?.cancel();
    _remainingSeconds = 0;
    if (notify) {
      notifyListeners();
    }
  }
}