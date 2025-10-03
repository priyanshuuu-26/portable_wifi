import 'package:flutter/material.dart';
import 'package:flutter_nsd/flutter_nsd.dart';
import 'package:dart_ping/dart_ping.dart'; // ✅ Add this package in pubspec.yaml

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  final FlutterNsd _flutterNsd = FlutterNsd();
  final List<String> _connectedIps = [];
  final List<NsdServiceInfo> _services = [];
  bool _isScanning = false;

  static const String _serviceType = '_http._tcp';
  final String _baseIp = '192.168.43.'; // typical hotspot subnet

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_isScanning) {
      _flutterNsd.stopDiscovery();
    }
    super.dispose();
  }

  // ✅ Define pingDevice inside the State class
  Future<bool> pingDevice(String ip) async {
    try {
      final ping = Ping(ip, count: 1, timeout: 1);
      final result = await ping.stream.first;
      return result.response != null; // true if device responded
    } catch (_) {
      return false;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    setState(() {
      _connectedIps.clear();
      _services.clear();
      _isScanning = true;
    });

    // 1️⃣ Start mDNS discovery
    _flutterNsd.discoverServices(_serviceType);
    _flutterNsd.stream.listen(
      (NsdServiceInfo service) {
        if (!_services.any((s) => s.name == service.name)) {
          setState(() {
            _services.add(service);
          });
        }
      },
      onError: (e) => print('mDNS error: $e'),
      onDone: () {},
    );

    // 2️⃣ Scan hotspot subnet
    for (int i = 1; i <= 20; i++) { // scan first 20 IPs
      final ip = '$_baseIp$i';
      if (await pingDevice(ip)) {
        setState(() {
          _connectedIps.add(ip);
        });
      }
    }

    setState(() {
      _isScanning = false;
    });
  }

  void _stopScan() {
    if (_isScanning) {
      _flutterNsd.stopDiscovery();
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final combinedList = [
      ..._connectedIps.map((ip) => {'name': 'IP Device', 'info': ip}),
      ..._services.map((s) => {'name': s.name ?? 'Unknown', 'info': '${s.hostname}:${s.port}'}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Devices'),
        actions: [
          TextButton(
            onPressed: _isScanning ? _stopScan : _startScan,
            child: Text(
              _isScanning ? 'STOP' : 'SCAN',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning) const LinearProgressIndicator(),
          Expanded(
            child: combinedList.isEmpty
                ? const Center(child: Text('No devices found. Start a scan.'))
                : ListView.builder(
                    itemCount: combinedList.length,
                    itemBuilder: (context, index) {
                      final device = combinedList[index];
                      return ListTile(
                        leading: const Icon(Icons.device_hub_rounded, size: 32),
                        title: Text(device['name']!),
                        subtitle: Text(device['info']!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
