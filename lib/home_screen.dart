// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:portable_wifi/features/connected_devices.dart';
import 'package:portable_wifi/features/free_wifi.dart';
import 'package:portable_wifi/features/ip_geolocation.dart';
import 'package:portable_wifi/features/nearby_wifi.dart';
import 'package:portable_wifi/features/port_scanner.dart';
import 'package:portable_wifi/features/qr_code.dart';
import 'package:portable_wifi/features/speed_test.dart';
import 'package:portable_wifi/features/timer.dart';
import 'package:portable_wifi/features/wifi_info.dart';
import 'package:portable_wifi/features/wifi_map.dart';

// --- IMPORTS CORRECTED TO USE 'wifi_analyser' AND MATCH OUR FILE NAMES ---


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We define a map of actions for our buttons
    final Map<String, Map<String, dynamic>> features = {
      'Wifi Info': {'icon': Icons.wifi, 'action': const WifiInfoScreen()},
      'Nearby Wifis': {'icon': Icons.wifi_find_rounded, 'action': const NearbyWifisScreen()},
      'Connected Devices': {'icon': Icons.devices_other_rounded, 'action': const ConnectedDevicesScreen()},
      'Speed Test': {'icon': Icons.speed_rounded, 'action': const SpeedTestScreen()},
      'QR Codes': {'icon': Icons.qr_code_scanner_rounded, 'action': const QrCodeScreen()},
      'Wifi Map': {'icon': Icons.map_rounded, 'action': const WifiMapScreen()},
      'Port Scanner': {'icon': Icons.radar_rounded, 'action': const PortScannerScreen()},
      'IP Geolocation': {'icon': Icons.travel_explore_rounded, 'action': const IpGeolocationScreen()},
      'Free Wifis': {'icon': Icons.wifi_password_rounded, 'action': const FreeWifisScreen()},
      // The class name here is correct, and the import now points to the right file
      'Timer': {'icon': Icons.timer_outlined, 'action': const TimerSettingsScreen()},
      'Data Usage': {
        'icon': Icons.data_usage_rounded,
        'action': () => AppSettings.openAppSettings(type: AppSettingsType.dataRoaming)
      },
      'Hotspot Settings': {
        'icon': Icons.wifi_tethering_rounded,
        'action': () => AppSettings.openAppSettings(type: AppSettingsType.hotspot)
      },
      'Airplane Mode': {
        'icon': Icons.airplanemode_active_rounded,
        'action': () => AppSettings.openAppSettings(type: AppSettingsType.wireless)
      },
    };

    final featureKeys = features.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Wifi Analyser')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        itemCount: featureKeys.length,
        itemBuilder: (context, index) {
          final key = featureKeys[index];
          final feature = features[key]!;
          return Card(
            child: InkWell(
              onTap: () {
                final action = feature['action'];
                if (action is Widget) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => action));
                } else if (action is Function) {
                  // Show a SnackBar for redirects
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirecting to system settings...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    action();
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(feature['icon'], size: 36),
                  const SizedBox(height: 8),
                  Text(key, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}