import 'dart:async';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  _ConnectedDevicesScreenState createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  List<String> _foundDevices = [];
  bool _isScanning = false;

  Future<void> _scanNetwork() async {
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
    });

    final ip = await NetworkInfo().getWifiIP();
    if (ip == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not connected to Wi-Fi")));
      setState(() => _isScanning = false);
      return;
    }

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    const port = 80; // Common port to check

    final stream = NetworkAnalyzer.discover(subnet, port);

    stream
        .listen((NetworkAddress addr) {
          if (addr.exists) {
            setState(() {
              _foundDevices.add(addr.ip);
            });
          }
        })
        .onDone(() {
          setState(() => _isScanning = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Devices"),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.search),
            onPressed: _isScanning ? null : _scanNetwork,
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _foundDevices.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_foundDevices[index]));
              },
            ),
    );
  }
}
