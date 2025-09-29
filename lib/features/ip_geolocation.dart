// lib/features/ip_geolocation_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class IpGeolocationScreen extends StatefulWidget {
  const IpGeolocationScreen({super.key});

  @override
  State<IpGeolocationScreen> createState() => _IpGeolocationScreenState();
}

class _IpGeolocationScreenState extends State<IpGeolocationScreen> {
  bool _isLoading = false;
  String? _publicIp;
  Map<String, dynamic>? _locationData;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Start the process as soon as the screen loads
    _fetchIpAndLocation();
  }

  /// Fetches the public IP and then its geolocation data.
  Future<void> _fetchIpAndLocation() async {
    setState(() {
      _isLoading = true;
      _locationData = null;
    });

    try {
      // Step 1: Get the public IP address from ipify API
      final ipResponse = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (ipResponse.statusCode != 200) throw Exception('Failed to get IP');
      _publicIp = jsonDecode(ipResponse.body)['ip'];

      if (_publicIp == null) throw Exception('IP address was null');
      
      // Step 2: Use the IP to get geolocation data from ip-api.com
      final locationResponse = await http.get(Uri.parse('http://ip-api.com/json/$_publicIp'));
      if (locationResponse.statusCode != 200) throw Exception('Failed to get location');
      
      _locationData = jsonDecode(locationResponse.body);

      // Step 3: Create a marker for the map
      final double lat = _locationData?['lat'] ?? 0.0;
      final double lon = _locationData?['lon'] ?? 0.0;
      
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(_publicIp!),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: _locationData?['city'] ?? 'Location'),
        ),
      );

    } catch (e) {
      print('Error fetching IP Geolocation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch location data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Geolocation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchIpAndLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locationData == null
              ? const Center(child: Text('Could not fetch location data.'))
              : Column(
                  children: [
                    // Display Location Details
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('Public IP Address'),
                      subtitle: Text(_publicIp ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('City'),
                      subtitle: Text(_locationData?['city'] ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: const Text('Country'),
                      subtitle: Text(_locationData?['country'] ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('ISP'),
                      subtitle: Text(_locationData?['isp'] ?? 'N/A'),
                    ),
                    const Divider(),
                    // Display Map
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _locationData?['lat'] ?? 0.0,
                            _locationData?['lon'] ?? 0.0,
                          ),
                          zoom: 12,
                        ),
                        markers: _markers,
                      ),
                    ),
                  ],
                ),
    );
  }
}