// // lib/providers/hotspot_manager_provider.dart
// import 'dart:async';
// import 'package:data_usage/data_usage.dart';
// import 'package:flutter/material.dart';
// import 'package:portable_wifi/services/notification.dart';

// class HotspotManagerProvider extends ChangeNotifier {
//   // Timer State
//   Timer? _timer;
//   int _durationInSeconds = 0;
//   int _remainingSeconds = 0;
//   bool get isTimerRunning => _timer?.isActive ?? false;
//   int get remainingSeconds => _remainingSeconds;

//   Timer? _dataUsageTimer;
//   double _dataLimitMB = 0;
//   DataUsage? _initialDataUsage;
//   double _sessionUsageMB = 0;
//   bool get isDataLimitActive => _dataUsageTimer?.isActive ?? false;
//   double get sessionUsageMB => _sessionUsageMB;

//   void startTimer(int minutes) {
//     _stopTimer(notify: false); // Stop any existing timer first
//     _durationInSeconds = minutes * 60;
//     _remainingSeconds = _durationInSeconds;

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingSeconds > 0) {
//         _remainingSeconds--;
//       } else {
//         _stopTimer();
//         NotificationService().showNotification(
//           'Hotspot Timer Finished',
//           'Remember to turn off your portable hotspot!',
//         );
//       }
//       notifyListeners(); // Update listeners every second
//     });
//     notifyListeners();
//   }

//   void _stopTimer({bool notify = true}) {
//     _timer?.cancel();
//     _remainingSeconds = 0;
//     if (notify) {
//       notifyListeners();
//     }
//   }
// Future<void> startDataLimit(double limitMB) async {
//     try {
//       _stopDataLimit(notify: false); // Stop any existing monitor
//       _dataLimitMB = limitMB;
//        _initialDataUsage = await DataUsage.dataUsage();
//       _sessionUsageMB = 0;

//       // Check usage every 30 seconds
//       _dataUsageTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
//         final currentDataUsage = await DataUsage.dataUsage();
//         final mobileTX = (currentDataUsage.mobileTx! - _initialDataUsage!.mobileTx!);
//         final mobileRX = (currentDataUsage.mobileRx! - _initialDataUsage!.mobileRx!);
        
//         // Calculate session usage in MB
//         _sessionUsageMB = (mobileTX + mobileRX) / (1024 * 1024);

//         if (_sessionUsageMB >= _dataLimitMB) {
//           _stopDataLimit();
//           NotificationService().showNotification(
//             'Data Limit Reached',
//             'You have used over $_dataLimitMB MB of data.',
//           );
//         }
//         notifyListeners();
//       });
//       notifyListeners();
//     } catch(e) {
//       print("Failed to start data limit monitor: $e");
//     }
//   }

//   void _stopDataLimit({bool notify = true}) {
//     _dataUsageTimer?.cancel();
//     if (notify) {
//       notifyListeners();
//     }
//   }
// }
