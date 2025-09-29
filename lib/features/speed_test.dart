// lib/features/speed_test_screen.dart
import 'package:flutter/material.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final _speedTest = SpeedTestDart();

  bool _isTesting = false;
  String _status = 'Press Start to begin';
  double _downloadRate = 0;
  double _uploadRate = 0;
  final String _unit = 'Mb/s';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _downloadRate = 0;
      _uploadRate = 0;
    });

    try {
      // 1. Get server settings
      setState(() => _status = 'Getting server list...');
      final settings = await _speedTest.getSettings();
      final servers = settings.servers;

      // 2. Find the best servers by testing latency
      setState(() => _status = 'Finding optimal server...');
      final bestServers = await _speedTest.getBestServers(
        servers: servers,
      );

      // 3. Test download speed
      setState(() => _status = 'Testing Download...');
      final double downloadSpeed = await _speedTest.testDownloadSpeed(
        servers: bestServers,
      );
      setState(() {
        _downloadRate = downloadSpeed;
      });

      // 4. Test upload speed
      setState(() => _status = 'Testing Upload...');
      final double uploadSpeed = await _speedTest.testUploadSpeed(
        servers: bestServers,
      );
      setState(() {
        _uploadRate = uploadSpeed;
      });

      // 5. Test is complete
      setState(() {
        _status = 'Test Complete';
        _isTesting = false;
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Test Failed: Please try again.';
          _isTesting = false;
        });
        print("Speed test failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Speed Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _status,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            _buildSpeedDisplay(
              title: 'Download',
              rate: _downloadRate,
              unit: _unit,
            ),
            const SizedBox(height: 40),
            
            _buildSpeedDisplay(
              title: 'Upload',
              rate: _uploadRate,
              unit: _unit,
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: _isTesting ? null : _startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Start Test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedDisplay({
    required String title,
    required double rate,
    required String unit,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Text(
          '${rate.toStringAsFixed(2)} $unit',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ],
    );
  }
}