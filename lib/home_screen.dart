import 'package:flutter/material.dart';
import 'package:portable_wifi/features/connected_devices.dart';
import 'package:portable_wifi/features/free_wifi.dart';
import 'package:portable_wifi/features/ip_geolocation.dart';
import 'package:portable_wifi/features/nearby_wifi.dart';
import 'package:portable_wifi/features/port_scanner.dart';
import 'package:portable_wifi/features/qr_code.dart';
import 'package:portable_wifi/features/speed_test.dart';
import 'package:portable_wifi/features/wifi_info.dart';
import 'package:portable_wifi/features/wifi_map.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Wifi Information',
        'icon': Icons.wifi,
        'screen': const WifiInfoScreen(),
      },
      {
        'title': 'Nearby Wifis',
        'icon': Icons.wifi_find_rounded,
        'screen': const NearbyWifisScreen(),
      },
      {
        'title': 'Connected Devices',
        'icon': Icons.devices_other_rounded,
        'screen': const ConnectedDevicesScreen(),
      },
      {
        'title': 'Speed Test',
        'icon': Icons.speed_rounded,
        'screen': const SpeedTestScreen(),
      },
      // {
      //   'title': 'System Settings',
      //   'icon': Icons.settings_applications_rounded,
      //   'screen': const HotspotControlScreen(),
      // },

      {
        'title': 'QR Codes',
        'icon': Icons.qr_code_scanner_rounded,
        'screen': const QrCodeScreen(),
      },
      {
        'title': 'Port Scanner',
        'icon': Icons.radar_rounded,
        'screen': const PortScannerScreen(),
      },
      {
        'title': 'IP Geolocation',
        'icon': Icons.travel_explore_rounded,
        'screen': const IpGeolocationScreen(),
      },
      {
        'title': 'Free Wifis',
        'icon': Icons.wifi_password_rounded,
        'screen': const FreeWifisScreen(),
      },
      {
        'title': 'Wifi Map',
        'icon': Icons.map_rounded,
        'screen': const WifiMapScreen(),
      },
      
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Wifi Analyser'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.1, 
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => feature['screen']),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature['icon'], size: 42, color: Colors.blueAccent),
                    const SizedBox(height: 14),
                    Text(
                      feature['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Feature coming soon!',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
