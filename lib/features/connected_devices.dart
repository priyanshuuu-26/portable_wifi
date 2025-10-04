import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class WifiDevicesScreen extends StatefulWidget {
  const WifiDevicesScreen({super.key});

  @override
  State<WifiDevicesScreen> createState() => _WifiDevicesScreenState();
}

class _WifiDevicesScreenState extends State<WifiDevicesScreen> {
  List<String> devices = [];
  bool isScanning = false;

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    final info = NetworkInfo();
    final String? ip = await info.getWifiIP();

    if (ip == null) {
      setState(() => isScanning = false);
      return;
    }

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final stream = NetworkAnalyzer.discover2(subnet, 80, timeout: const Duration(milliseconds: 400));

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        setState(() {
          devices.add(addr.ip);
        });
      }
    }, onError: (e) {
      debugPrint('Scan error: $e'); // Ignore timeouts
    }, onDone: () {
      setState(() {
        isScanning = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    scanNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isScanning ? null : scanNetwork,
          )
        ],
      ),
      body: isScanning
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? const Center(child: Text('No devices found'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.devices),
                      title: Text(devices[index]),
                    );
                  },
                ),
    );
  }
}
