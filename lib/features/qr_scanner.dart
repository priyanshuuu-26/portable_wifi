// lib/features/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool isScanCompleted = false;

  void _closeScreen() {
    // Check if the widget is still in the tree before popping
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _handleQrCode(BarcodeCapture capture) {
    if (isScanCompleted) return;

    final String code = capture.barcodes.first.rawValue ?? "---";
    isScanCompleted = true; // Prevents multiple triggers

    // Check if it's a Wi-Fi QR code
    if (code.startsWith('WIFI:')) {
      // Extract SSID and Password from the QR code string
      final parts = code.split(';');
      String? ssid;
      String? password;
      for (var part in parts) {
        if (part.startsWith('S:')) {
          ssid = part.substring(2);
        } else if (part.startsWith('P:')) {
          password = part.substring(2);
        }
      }

      if (ssid != null && password != null) {
        _connectToWifi(ssid, password);
      } else {
        _showErrorAndGoBack('Invalid Wi-Fi QR Code format.');
      }
    } else {
      _showErrorAndGoBack('This is not a Wi-Fi QR Code.');
    }
  }

  Future<void> _connectToWifi(String ssid, String password) async {
  // Disconnect from the current network first (optional but good practice)
  WiFiForIoTPlugin.disconnect();

  // Attempt to connect to the new network
  final bool? isConnected = await WiFiForIoTPlugin.connect(
    ssid,
    password: password,
    security: NetworkSecurity.WPA, // Most common security type
  );

  if (isConnected == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully connected to $ssid')),
    );
    _closeScreen();
  } else {
    _showErrorAndGoBack('Failed to connect to $ssid. Check password.');
  }
}
  void _showErrorAndGoBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _closeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleQrCode,
          ),
          // Simple overlay for better UX
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}