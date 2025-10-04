// lib/features/password_generator_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final _secureRandom = Random.secure();

  // Settings
  int _length = 16;
  bool _useLower = true;
  bool _useUpper = true;
  bool _useNumbers = true;
  bool _useSymbols = false;
  bool _avoidAmbiguous = true;
  int _count = 1; // generate X passwords at once

  List<String> _generated = [];

  static const String _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{};:,.<>?/~`|';

  static const String _ambiguous = 'Il1O0`\'"l|,;:.';


  String _charset() {
    final buffer = StringBuffer();
    if (_useLower) buffer.write(_lower);
    if (_useUpper) buffer.write(_upper);
    if (_useNumbers) buffer.write(_numbers);
    if (_useSymbols) buffer.write(_symbols);
    var chars = buffer.toString();
    if (_avoidAmbiguous) {
      for (final ch in _ambiguous.split('')) {
        chars = chars.replaceAll(ch, '');
      }
    }
    return chars;
  }

  String _generateOne(int length) {
    final chars = _charset();
    if (chars.isEmpty) return '';
    final bytes = List<int>.generate(length, (_) => _secureRandom.nextInt(chars.length));
    final sb = StringBuffer();
    for (final i in bytes) {
      sb.write(chars[i]);
    }
    return sb.toString();
  }

  void _generatePasswords() {
    final list = <String>[];
    for (var i = 0; i < _count; i++) {
      list.add(_generateOne(_length));
    }
    setState(() {
      _generated = list;
    });
  }

  double _estimateEntropy(String password) {
    // Entropy ~ length * log2(charset_size). Estimate charset size from toggles.
    final chars = _charset();
    final setSize = chars.length;
    if (setSize <= 1) return 0;
    final entropy = password.length * (log(setSize) / log(2));
    return entropy;
  }

  String _strengthLabel(double entropy) {
    if (entropy < 28) return 'Very Weak';
    if (entropy < 36) return 'Weak';
    if (entropy < 60) return 'Reasonable';
    if (entropy < 128) return 'Strong';
    return 'Very Strong';
  }

  Color _strengthColor(double entropy) {
    if (entropy < 28) return Colors.red.shade400;
    if (entropy < 36) return Colors.orange.shade400;
    if (entropy < 60) return Colors.amber.shade700;
    if (entropy < 128) return Colors.green.shade600;
    return Colors.green.shade900;
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final currentCharset = _charset();
    final sampleEntropy = (_generated.isNotEmpty) ? _estimateEntropy(_generated.first) : _length * (log((currentCharset.isEmpty ? 1 : currentCharset.length)) / log(2));
    final strengthLabel = _strengthLabel(sampleEntropy);
    final strengthColor = _strengthColor(sampleEntropy);

    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          // Length selector
          Row(
            children: [
              const Text('Length', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _length.toDouble(),
                  min: 8,
                  max: 64,
                  divisions: 56,
                  label: '$_length',
                  onChanged: (v) => setState(() => _length = v.round()),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 48, child: Text('$_length', textAlign: TextAlign.right)),
            ],
          ),

          // Character toggles
          Column(
            children: [
              SwitchListTile(
                value: _useLower,
                onChanged: (v) => setState(() => _useLower = v),
                title: const Text('Lowercase (a-z)'),
              ),
              SwitchListTile(
                value: _useUpper,
                onChanged: (v) => setState(() => _useUpper = v),
                title: const Text('Uppercase (A-Z)'),
              ),
              SwitchListTile(
                value: _useNumbers,
                onChanged: (v) => setState(() => _useNumbers = v),
                title: const Text('Numbers (0-9)'),
              ),
              SwitchListTile(
                value: _useSymbols,
                onChanged: (v) => setState(() => _useSymbols = v),
                title: const Text('Symbols (e.g. !@#\$%^&)'),
              ),
              SwitchListTile(
                value: _avoidAmbiguous,
                onChanged: (v) => setState(() => _avoidAmbiguous = v),
                title: const Text('Avoid ambiguous chars (0,O,1,I,l)'),
              ),
            ],
          ),

          // Count & generate
          Row(
            children: [
              const Text('Count:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _count,
                items: [1, 2, 5, 10].map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
                onChanged: (v) => setState(() => _count = v ?? 1),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: currentCharset.isEmpty ? null : _generatePasswords,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Entropy / strength
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (sampleEntropy / 128).clamp(0.0, 1.0),
                  color: strengthColor,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(strengthLabel, style: TextStyle(color: strengthColor, fontWeight: FontWeight.w700)),
                  Text('${sampleEntropy.toStringAsFixed(1)} bits', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Generated list
          Expanded(
            child: _generated.isEmpty
                ? Center(child: Text('No password generated yet', style: TextStyle(color: Colors.grey.shade700)))
                : ListView.separated(
                    itemCount: _generated.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final pw = _generated[i];
                      return ListTile(
                        title: SelectableText(pw, style: const TextStyle(fontFamily: 'monospace')),
                        subtitle: Text('Entropy: ${_estimateEntropy(pw).toStringAsFixed(1)} bits'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyToClipboard(pw),
                            tooltip: 'Copy',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () async {
                              // optional: share via platform share plugin if you add it
                              await Clipboard.setData(ClipboardData(text: pw));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied (share not implemented)')));
                            },
                            tooltip: 'Copy & share',
                          ),
                        ]),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
