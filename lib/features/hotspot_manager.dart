// // lib/features/hotspot_manager_screen.dart
// import 'package:flutter/material.dart';
// import 'package:portable_wifi/providers/hotspot_manager_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:app_settings/app_settings.dart'; // To open settings
// import 'package:data_usage/data_usage.dart';   // To check permission status

// class HotspotManagerScreen extends StatefulWidget {
//   const HotspotManagerScreen({super.key});

//   @override
//   State<HotspotManagerScreen> createState() => _HotspotManagerScreenState();
// }

// class _HotspotManagerScreenState extends State<HotspotManagerScreen> {
//   bool? _hasPermission;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermission();
//   }

//   // Check if the special "Usage Stats" permission has been granted
//   Future<void> _checkPermission() async {
//     bool hasPermission = await DataUsage.checkPermission();
//     setState(() {
//       _hasPermission = hasPermission;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final minutesController = TextEditingController();
//     final dataController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Hotspot Manager')),
//       body: Consumer<HotspotManagerProvider>(
//         builder: (context, provider, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Timer Section (no changes here)
//                 const Text('Timer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 // ... timer UI ...
//                 const Divider(height: 48),

//                 // Data Usage Limit Section
//                 const Text('Data Usage Limit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
                
//                 // --- PERMISSION HANDLING UI ---
//                 if (_hasPermission == false)
//                   Card(
//                     color: Colors.red.withOpacity(0.2),
//                     child: ListTile(
//                       title: const Text('Permission Required'),
//                       subtitle: const Text('Tap here to grant usage access permission.'),
//                       onTap: () async {
//                         await AppSettings.openAppSettings(type: AppSettingsType.usage);
//                         // Re-check permission after user returns from settings
//                         _checkPermission();
//                       },
//                     ),
//                   ),

//                 if (provider.isDataLimitActive)
//                   Text('Session Usage: ${provider.sessionUsageMB.toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 18)),
                
//                 TextField(
//                   controller: dataController,
//                   decoration: const InputDecoration(labelText: 'Set data limit in MB'),
//                   keyboardType: TextInputType.number,
//                   // Disable the field if permission is not granted
//                   enabled: _hasPermission ?? false,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   // Disable the button if permission is not granted
//                   onPressed: (_hasPermission ?? false) ? () {
//                     final limit = double.tryParse(dataController.text);
//                     if (limit != null && limit > 0) provider.startDataLimit(limit);
//                   } : null,
//                   child: const Text('Start Data Limit'),
//                 ),
//                 if(provider.isDataLimitActive)
//                   OutlinedButton(
//                     onPressed: () => provider.stopTimer(), // Assumes you want to stop the monitor
//                     child: const Text('Stop Data Limit'),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }