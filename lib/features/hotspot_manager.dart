// lib/features/hotspot_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:portable_wifi/providers/hotspot_manager_provider.dart';
import 'package:provider/provider.dart';

class HotspotManagerScreen extends StatelessWidget {
  const HotspotManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final minutesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Hotspot Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Set a timer to get a notification reminding you to turn off your hotspot.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: minutesController,
              decoration: const InputDecoration(
                labelText: 'Enter duration in minutes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Consumer<HotspotManagerProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final minutes = int.tryParse(minutesController.text);
                        if (minutes != null && minutes > 0) {
                          provider.startTimer(minutes);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Start Timer'),
                    ),
                    if (provider.isTimerRunning)
                      OutlinedButton(
                        onPressed: () {
                          provider.stopTimer();
                        },
                        child: const Text('Stop Current Timer'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}