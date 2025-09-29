import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiInfoScreen extends StatefulWidget {
  const WifiInfoScreen({super.key});

  @override
  State<WifiInfoScreen> createState() => _WifiInfoScreenState();
}

class _WifiInfoScreenState extends State<WifiInfoScreen> {
  String? _wifiName, _wifiBSSID, _wifiIPv4, _wifiIPv6, _wifiBroadcast;

  @override
  void initState() {
    super.initState();
    _fetchWifiInfo();
  }

  Future<void> _fetchWifiInfo() async {
    final NetworkInfo info = NetworkInfo();
    try {
      _wifiName = await info.getWifiName();
      _wifiBSSID = await info.getWifiBSSID();
      _wifiIPv4 = await info.getWifiIP();
      _wifiIPv6 = await info.getWifiIPv6();
      _wifiBroadcast = await info.getWifiBroadcast();
    } catch (e) {
      print("Failed to get Wifi info: $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wifi Information")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text("Name (SSID)"), subtitle: Text(_wifiName ?? "Not available")),
          ListTile(title: Text("BSSID"), subtitle: Text(_wifiBSSID ?? "Not available")),
          ListTile(title: Text("IPv4 Address"), subtitle: Text(_wifiIPv4 ?? "Not available")),
          ListTile(title: Text("IPv6 Address"), subtitle: Text(_wifiIPv6 ?? "Not available")),
          ListTile(title: Text("Broadcast Address"), subtitle: Text(_wifiBroadcast ?? "Not available")),
        ],
      ),
    );
  }
}