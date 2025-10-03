import 'package:flutter/material.dart';
import 'package:portable_wifi/home_screen.dart';
import 'package:portable_wifi/providers/hotspot_manager_provider.dart';
import 'package:portable_wifi/providers/location_wifi_provider.dart';
import 'package:portable_wifi/services/notification.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  // The MultiProvider must be here, at the top level, before runApp.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationWiFiProvider()),
        ChangeNotifierProvider(create: (context) => HotspotManagerProvider()),
      ],
      child: const WifiAnalyserApp(),
    ),
  );
}

class WifiAnalyserApp extends StatelessWidget {
  const WifiAnalyserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wifi Analyser',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}