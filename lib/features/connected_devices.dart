// lib/features/connected_devices_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_nsd/flutter_nsd.dart';
import 'dart:async';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  final FlutterNsd _flutterNsd = FlutterNsd();
  final List<NsdServiceInfo> _services = [];
  bool _isScanning = false;
  // A common service type for finding many network devices.
  static const String _serviceType = '_http._tcp';

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  void dispose() {
    if (_isScanning) {
      _flutterNsd.stopDiscovery();
    }
    super.dispose();
  }

  Future<void> _startDiscovery() async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _services.clear();
      _isScanning = true;
    });

    try {
      await _flutterNsd.discoverServices(_serviceType);
      _flutterNsd.stream.listen(
        (NsdServiceInfo service) {
          if (mounted && !_services.any((s) => s.name == service.name)) {
            setState(() {
              _services.add(service);
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() => _isScanning = false);
            print('Discovery error: $e');
          }
        },
        onDone: () {
          if (mounted) {
            setState(() => _isScanning = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        print('Error starting discovery: $e');
      }
    }
  }

  void _stopDiscovery() {
    if (_isScanning) {
      _flutterNsd.stopDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Devices'),
        actions: [
          TextButton(
            onPressed: _isScanning ? _stopDiscovery : _startDiscovery,
            child: Text(
              _isScanning ? 'STOP' : 'SCAN',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (_isScanning) const LinearProgressIndicator(),
          Expanded(
            child: _services.isEmpty && !_isScanning
                ? const Center(
                    child: Text('No devices found. Try starting a scan.'),
                  )
                : ListView.builder(
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return ListTile(
                        leading: const Icon(Icons.device_hub_rounded, size: 32),
                        title: Text(service.name ?? 'Unknown Device'),
                        // --- THIS IS THE CORRECTED PROPERTY NAME ---
                        subtitle: Text('${service.hostname}:${service.port}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}