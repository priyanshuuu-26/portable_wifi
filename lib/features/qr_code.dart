import 'package:flutter/material.dart';
import 'package:portable_wifi/features/qr_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _qrDataString;

  void _generateQrCode() {
    final ssid = _ssidController.text;
    final password = _passwordController.text;

    if (ssid.isNotEmpty) { // Password can be empty for open networks
      setState(() {
        final securityType = password.isEmpty ? 'NOPASS' : 'WPA';
        _qrDataString = 'WIFI:T:$securityType;S:$ssid;P:$password;;';
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Wifi Name (SSID)')),
      );
    }
  }

  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator & Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SCANNER BUTTON ADDED AT THE TOP ---
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan Wi-Fi QR Code'),
              onPressed: _navigateToScanner,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // --- GENERATOR UI ---
            const Text(
              'Share a Wifi Network',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Wifi Name (SSID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password (optional for open networks)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQrCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 30),

            if (_qrDataString != null)
              Center(
                child: QrImageView(
                  data: _qrDataString!,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}