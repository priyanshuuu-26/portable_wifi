import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:portable_wifi/models/wifi_model.dart';
import 'package:portable_wifi/utils/global_variables.dart';
import 'package:portable_wifi/utils/utils.dart';

class LocationWiFiProvider extends ChangeNotifier {
  double _latitude = 0;
  double _longitude = 0;
  bool _isFetching = false;
  List<WiFiModel> _wifiList = [];
  Set<Marker> _markers = {};

  double get latitude => _latitude;

  double get longitude => _longitude;

  bool get isFetching => _isFetching;

  List<WiFiModel> get wifiList => _wifiList;

  Set<Marker> get markers => _markers;

  void setMarkers(Set<Marker> value) {
    _markers = value;
    notifyListeners();
  }

  void addMarker(Marker value) {
    _markers.add(value);
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void setWiFiList(List<WiFiModel> value) {
    _wifiList = value;
    notifyListeners();
  }

  void addWiFi(WiFiModel value) {
    _wifiList.add(value);
    notifyListeners();
  }

  void clearWiFiList() {
    _wifiList.clear();
    notifyListeners();
  }

  void setIsFetching(bool value) {
    _isFetching = value;
    notifyListeners();
  }

  void shuffleWiFiList() {
    wifiList.shuffle();
    notifyListeners();
  }

  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;

      fetchCityWiFis();

      notifyListeners();
    } catch (e) {
      print("Failed to fetch location: $e");
      rethrow;
    }
  }

  Future<bool> isPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  Future<String> getCityName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude,
        _longitude,
      );
      return placemarks[0].locality!;
    } catch (e) {
      print("Failed to fetch city name: $e");
      rethrow;
    }
  }

  Future<void> fetchCityWiFis() async {
    setIsFetching(true);
    try {
      final cityName = await getCityName();
      showLog("CITY NAME: $cityName");

      final citySlug = await fetchCityMapId(cityName);

      showLog("CITY SLUG: $citySlug");
      if (citySlug == '') {
        setIsFetching(false);
        return;
      }

      http.Response request = await http.get(Uri.parse(
          'https://www.wifimap.io/_next/data/${GlobalVariables.wifi_map_id}/en/map/$citySlug.json?citySlug=$citySlug'));

      if (request.statusCode == 200) {
        final body = jsonDecode(request.body);

        final hotspotList = body['pageProps']['hotspotsList'];

        showLog("HOTSPOT LIST LENGTH IS ${hotspotList.length}");

        clearWiFiList();
        for (var hotspot in hotspotList) {
          addWiFi(WiFiModel.fromJson(hotspot));
        }

        wifiList.shuffle();
        if (wifiList.isNotEmpty) {
          addWiFiMarkersToMap();
        }
        //showLog("City WiFis: $body");
        setIsFetching(false);
      } else {
        showLog("Failed to fetch city wifi: ${request.statusCode}");
        showLog("Failed to fetch city wifi: ${request.body}");
        setIsFetching(false);
      }
    } catch (e) {
      setIsFetching(false);
      showLog("Failed to fetch city wifi exp: $e");
    }
  }

  Future<String> fetchCityMapId(String cityName) async {
    var request = http.Request('GET', Uri.parse('https://api.wifimap.io/cities?query=Surat&per_page=1'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final body = jsonDecode(await response.stream.bytesToString());
      final id = body['data'][0]['slug'];
      return id;
    }
    else {
      print(response.reasonPhrase);
    }
    return '';
  }

  Future<void> addWiFiMarkersToMap() async {
    clearMarkers();
    Marker(markerId: const MarkerId("CURRENT"), position: LatLng(latitude, longitude));
    for (var wifi in wifiList) {
      addMarker(Marker(
        icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(20, 20)),
          '${defaultImagePath}wifi_map_marker.png',
        ),
        markerId: MarkerId(wifi.id.toString()),
        infoWindow: InfoWindow(title: wifi.name),
        position: LatLng(wifi.lat, wifi.lng),
      ));
    }
  }

  void clearLocation() {
    _latitude = 0;
    _longitude = 0;
    notifyListeners();
  }
}
