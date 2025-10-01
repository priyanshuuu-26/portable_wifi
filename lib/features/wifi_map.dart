// lib/features/wifi_map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portable_wifi/providers/location_wifi_provider.dart';
import 'package:provider/provider.dart';

class WifiMapScreen extends StatefulWidget {
  const WifiMapScreen({super.key});

  @override
  State<WifiMapScreen> createState() => _WifiMapScreenState();
}

class _WifiMapScreenState extends State<WifiMapScreen> {
  @override
  void initState() {
    super.initState();
    // This tells the provider to start its process as soon as the screen loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationWiFiProvider>(context, listen: false).fetchLocationAndPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This Consumer widget listens for changes in the provider and rebuilds the UI.
    return Consumer<LocationWiFiProvider>(
      builder: (context, locationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nearby Wi-Fi Hotspots'),
            actions: [
              // Show a refresh button only when not actively loading.
              if (!locationProvider.isFetching)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => locationProvider.fetchLocationAndPlaces(),
                ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    // Use the user's location if available, otherwise a default location.
                    locationProvider.latitude == 0.0 ? 20.5937 : locationProvider.latitude,
                    locationProvider.longitude == 0.0 ? 78.9629 : locationProvider.longitude,
                  ),
                  zoom: 14,
                ),
                // Display all the markers (user location + cafes) from the provider.
                markers: locationProvider.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              // Show a loading spinner in the center while data is being fetched.
              if (locationProvider.isFetching)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}