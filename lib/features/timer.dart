import 'package:flutter/material.dart';
import 'package:portable_wifi/providers/hotspot_manager_provider.dart';
import 'package:provider/provider.dart';

class TimerSettingsScreen extends StatelessWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final minutesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Set Timer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: minutesController,
              decoration: const InputDecoration(labelText: 'Enter duration in minutes'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(minutesController.text);
                if (minutes != null && minutes > 0) {
                  Provider.of<HotspotManagerProvider>(context, listen: false).startTimer(minutes);
                  Navigator.pop(context);
                }
              },
              child: const Text('Set Timer'),
            ),
          ],
        ),
      ),
    );
  }
}