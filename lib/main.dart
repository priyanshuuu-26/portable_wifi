import 'package:flutter/material.dart';
import 'package:portable_wifi/home_screen.dart';
import 'package:portable_wifi/providers/hotspot_manager_provider.dart';
import 'package:portable_wifi/providers/location_wifi_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
     MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationWiFiProvider()),
     //   ChangeNotifierProvider(create: (context) => HotspotManagerProvider()), // Add the new one
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wifi Analyser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomeScreen(),
    );
  }
}
