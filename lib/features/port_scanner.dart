// lib/features/port_scanner_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class PortScannerScreen extends StatefulWidget {
  const PortScannerScreen({super.key});

  @override
  State<PortScannerScreen> createState() => _PortScannerScreenState();
}

class _PortScannerScreenState extends State<PortScannerScreen> {
  final _ipController = TextEditingController();
  final _startPortController = TextEditingController(text: '1');
  final _endPortController = TextEditingController(text: '1024');
  
  bool _isScanning = false;
  final List<int> _openPorts = [];
  String _scanStatus = 'Ready to scan.';

  @override
  void initState() {
    super.initState();
    // Pre-fill the IP address field with the device's current IP for convenience
    _fetchCurrentIP();
  }

  Future<void> _fetchCurrentIP() async {
    try {
      final ip = await NetworkInfo().getWifiIP();
      if (ip != null) {
        _ipController.text = ip;
      }
    } catch (e) {
      print("Could not get IP address: $e");
    }
  }

  Future<void> _startScan() async {
    // Clear previous results
    setState(() {
      _isScanning = true;
      _openPorts.clear();
      _scanStatus = 'Starting scan...';
    });

    final String ip = _ipController.text;
    final int startPort = int.tryParse(_startPortController.text) ?? 1;
    final int endPort = int.tryParse(_endPortController.text) ?? 1024;

    if (ip.isEmpty) {
      setState(() {
        _scanStatus = 'Please enter a valid IP address.';
        _isScanning = false;
      });
      return;
    }

    // Loop through the port range
    for (int port = startPort; port <= endPort; port++) {
      if (!_isScanning) break; // Allow stopping the scan

      setState(() {
        _scanStatus = 'Scanning port $port...';
      });

      // Try to connect to the socket
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: 200),
        );
        // If the connection succeeds, the port is open
        setState(() {
          _openPorts.add(port);
        });
        // Important: close the socket after checking
        socket.destroy();
      } catch (e) {
        // If the connection fails, the port is likely closed. We do nothing.
      }
    }

    setState(() {
      _scanStatus = 'Scan complete. Found ${_openPorts.length} open ports.';
      _isScanning = false;
    });
  }
  
  void _stopScan() {
    setState(() {
      _isScanning = false;
      _scanStatus = 'Scan stopped by user.';
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Fields
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'IP Address to Scan'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startPortController,
                    decoration: const InputDecoration(labelText: 'Start Port'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endPortController,
                    decoration: const InputDecoration(labelText: 'End Port'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning ? Colors.red : Colors.blueAccent,
              ),
              child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
            ),
            const SizedBox(height: 16),
            // Status and Results
            Text(_scanStatus, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            Text(
              'Open Ports:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _openPorts.isEmpty
                  ? const Text('No open ports found in the scanned range.')
                  : ListView.builder(
                      itemCount: _openPorts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.lan_rounded, color: Colors.green),
                          title: Text('Port ${_openPorts[index]} is open'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}