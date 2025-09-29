// lib/features/free_wifis_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class FreeWifisScreen extends StatefulWidget {
  const FreeWifisScreen({super.key});

  @override
  State<FreeWifisScreen> createState() => _FreeWifisScreenState();
}

class _FreeWifisScreenState extends State<FreeWifisScreen> {
  List<WiFiAccessPoint> _openNetworks = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    // Check for location permissions, which are required for Wi-Fi scanning
    if (await Permission.location.request().isGranted) {
      setState(() {
        _isScanning = true;
        _openNetworks.clear();
      });

      try {
        // Start the scan and get the results
        await WiFiScan.instance.startScan();
        final List<WiFiAccessPoint> allNetworks = await WiFiScan.instance.getScannedResults();
        
        // --- THIS IS THE KEY FILTERING LOGIC ---
        // An open network's capabilities string usually lacks security protocols like WPA/WEP.
        final List<WiFiAccessPoint> filteredList = allNetworks.where((network) {
          final capabilities = network.capabilities;
          final bool isSecure = capabilities.contains('WPA') ||
                                capabilities.contains('WEP') ||
                                capabilities.contains('PSK');
          return !isSecure;
        }).toList();

        setState(() {
          _openNetworks = filteredList;
        });

      } catch (e) {
        print("Scan failed: $e");
      } finally {
        if (mounted) {
          setState(() => _isScanning = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required to scan for networks.")),
      );
    }
  }

  // Helper function to get an icon based on signal strength (dBm)
  Widget _getSignalIcon(int level) {
    if (level > -60) {
      return const Icon(Icons.wifi_rounded, color: Colors.green, size: 32);
    } else if (level > -80) {
      return const Icon(Icons.wifi_2_bar_rounded, color: Colors.orange, size: 32);
    } else {
      return const Icon(Icons.wifi_1_bar_rounded, color: Colors.red, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Free Wifi'),
        actions: [
          IconButton(
            icon: _isScanning ? const SizedBox.shrink() : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : _openNetworks.isEmpty
              ? const Center(
                  child: Text('No open (password-free) Wi-Fi networks found nearby.'),
                )
              : ListView.builder(
                  itemCount: _openNetworks.length,
                  itemBuilder: (context, index) {
                    final network = _openNetworks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        leading: _getSignalIcon(network.level),
                        title: Text(
                          network.ssid.isNotEmpty ? network.ssid : '(Hidden Network)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(network.bssid),
                        trailing: Text('${network.level} dBm'),
                      ),
                    );
                  },
                ),
    );
  }
}