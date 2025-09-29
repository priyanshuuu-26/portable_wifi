import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class NearbyWifisScreen extends StatefulWidget {
  const NearbyWifisScreen({super.key});

  @override
  State<NearbyWifisScreen> createState() => _NearbyWifisScreenState();
}

class _NearbyWifisScreenState extends State<NearbyWifisScreen> {
  List<WiFiAccessPoint> _accessPoints = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    // Check for location permissions
    if (await Permission.location.request().isGranted) {
      setState(() => _isScanning = true);
      try {
        await WiFiScan.instance.startScan();
        final result = await WiFiScan.instance.getScannedResults();
        setState(() {
          _accessPoints = result;
          _isScanning = false;
        });
      } catch(e) {
         print("Scan failed: $e");
         setState(() => _isScanning = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required to scan for networks.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Wifi Networks"),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.hourglass_top : Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _accessPoints.length,
              itemBuilder: (context, index) {
                final ap = _accessPoints[index];
                return ListTile(
                  title: Text(ap.ssid.isNotEmpty ? ap.ssid : "(Hidden Network)"),
                  subtitle: Text(ap.bssid),
                  trailing: Text("${ap.level} dBm"), // Signal strength
                );
              },
            ),
    );
  }
}