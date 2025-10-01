// lib/providers/location_wifi_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationWiFiProvider extends ChangeNotifier {
  // --- IMPORTANT: PASTE YOUR GOOGLE API KEY HERE ---
  // For a real app, you should protect this key using a tool like flutter_dotenv.
  final String _apiKey = "AIzaSyCjj3eD4pB-MjaBEAi-16giQ6Q-zxmPkow";

  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isFetching = false;
  final Set<Marker> _markers = {};

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get isFetching => _isFetching;
  Set<Marker> get markers => _markers;

  /// Main function to start the process.
  Future<void> fetchLocationAndPlaces() async {
    _isFetching = true;
    notifyListeners();

    try {
      // Get the user's current location first.
      Position position = await _determinePosition();
      _latitude = position.latitude;
      _longitude = position.longitude;

      // Now, use that location to find nearby places.
      await _fetchNearbyPlaces();
      
    } catch (e) {
      print("Error fetching location or places: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  /// Fetches nearby places (e.g., cafes) using the Google Places API.
  Future<void> _fetchNearbyPlaces() async {
    _markers.clear();
    // Add a special marker for the user's own location.
    _markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(_latitude, _longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
    ));

    // Construct the URL for the Google Places API "Nearby Search".
    // We're searching for cafes within a 1500-meter radius.
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$_latitude,$_longitude&radius=1500&type=cafe&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];

      // Create a marker for each cafe found.
      for (var place in results) {
        final double lat = place['geometry']['location']['lat'];
        final double lng = place['geometry']['location']['lng'];
        final String name = place['name'];

        _markers.add(
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
          ),
        );
      }
    } else {
      // If the API call fails, print the error. This is often due to the Places API not being enabled.
      print('Failed to load places: ${response.body}');
    }
  }

  /// Determines the current position of the device, handling permissions.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}