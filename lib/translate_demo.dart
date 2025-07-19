import 'package:flutter/material.dart';
import 'translate_service.dart';

class TranslateDemo extends StatefulWidget {
  const TranslateDemo({Key? key}) : super(key: key);

  @override
  State<TranslateDemo> createState() => _TranslateDemoState();
}

class _TranslateDemoState extends State<TranslateDemo> {
  String _translated = '';
  bool _loading = false;

  Future<void> _doTranslate() async {
    setState(() => _loading = true);
    try {
      final result = await translateText('How are you feeling today?', 'ms');
      setState(() => _translated = result);
    } catch (e) {
      setState(() => _translated = 'Translation failed');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _loading ? null : _doTranslate,
          child: const Text('Translate to Malay'),
        ),
        if (_loading) const CircularProgressIndicator(),
        if (_translated.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_translated, style: const TextStyle(fontSize: 18)),
          ),
      ],
    );
  }
}
