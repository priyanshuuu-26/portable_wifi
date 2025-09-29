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
    // Ensure the provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch location and wiFis when the screen loads
      Provider.of<LocationWiFiProvider>(context, listen: false).fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationWiFiProvider>(
      builder: (context, locationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Free Wifi Map'),
            actions: [
              // Refresh button to fetch again
              if (!locationProvider.isFetching)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => locationProvider.fetchLocation(),
                ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    locationProvider.latitude,
                    locationProvider.longitude,
                  ),
                  zoom: 14,
                ),
                markers: locationProvider.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              // Show a loading indicator while fetching
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