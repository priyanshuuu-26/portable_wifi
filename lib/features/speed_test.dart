import 'package:flutter/material.dart';
import 'package:speed_test_dart/speed_test_dart.dart';
import 'package:speed_test_dart/classes/classes.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final SpeedTestDart _speedTest = SpeedTestDart();

  bool _isTesting = false;
  String _status = 'Press Start to begin';
  double _downloadRate = 0;
  double _uploadRate = 0;
  final String _unit = 'Mb/s';

  // ✅ Custom servers for Jaipur (tested)
  final List<Server> _customServers = [
    Server(
      6893,
      'Jaipur',
      'India',
      'BSNL',
      'bsnlooklajpr.mywire.org:8080',
      'http://bsnlooklajpr.mywire.org:8080/speedtest/upload.php',
      26.9124,
      75.7873,
      0.0,
      0.0,
      Coordinate(26.9124, 75.7873),
    ),
    Server(
      71698,
      'Jaipur',
      'India',
      'Vi India',
      'speedtest.raj.vodafoneidea.com:8080',
      'http://speedtest.raj.vodafoneidea.com:8080/speedtest/upload.php',
      26.9124,
      75.7873,
      0.0,
      0.0,
      Coordinate(26.9124, 75.7873),
    ),
  ];

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _downloadRate = 0;
      _uploadRate = 0;
      _status = 'Selecting best server...';
    });

    try {
      // ✅ Pick the best server (lowest latency)
      final bestServers = await _speedTest
          .getBestServers(servers: _customServers)
          .timeout(const Duration(seconds: 10), onTimeout: () => _customServers);

      setState(() => _status = 'Testing download speed...');

      // ✅ Download test with 1 simultaneous download and 1 retry
      final download = await _speedTest
          .testDownloadSpeed(
            servers: bestServers,
            simultaneousDownloads: 1,
            retryCount: 1,
          )
          .timeout(const Duration(seconds: 15), onTimeout: () => 0);

      setState(() {
        _downloadRate = download;
        _status = 'Testing upload speed...';
      });

      // ✅ Upload test with 1 simultaneous upload and 1 retry
      final upload = await _speedTest
          .testUploadSpeed(
            servers: bestServers,
            simultaneousUploads: 1,
            retryCount: 1,
          )
          .timeout(const Duration(seconds: 15), onTimeout: () => 0);

      setState(() {
        _uploadRate = upload;
        _status = 'Test Complete';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Test Failed: $e';
        _isTesting = false;
      });
      print('Speed test error: $e');
    }
  }

  Widget _buildSpeedDisplay(String title, double rate) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Text('${rate.toStringAsFixed(2)} $_unit',
            style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Internet Speed Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            _buildSpeedDisplay('Download', _downloadRate),
            const SizedBox(height: 40),
            _buildSpeedDisplay('Upload', _uploadRate),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _isTesting ? null : _startTest,
              child: Text(_isTesting ? 'Testing...' : 'Start Test'),
            ),
          ],
        ),
      ),
    );
  }
}
