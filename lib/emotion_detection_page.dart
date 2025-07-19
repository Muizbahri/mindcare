import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmotionDetectionPage extends StatefulWidget {
  const EmotionDetectionPage({Key? key}) : super(key: key);

  @override
  State<EmotionDetectionPage> createState() => _EmotionDetectionPageState();
}

class _EmotionDetectionPageState extends State<EmotionDetectionPage> {
  Uint8List? _imageBytes;
  bool _loading = false;
  Map<String, dynamic>? _emotionResult;

  Future<void> _pickImageAndDetectEmotion() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _loading = true;
      _emotionResult = null;
    });

    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/api/emotions/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imageBase64': base64Image}),
    );

    setState(() {
      _loading = false;
      if (response.statusCode == 200) {
        _emotionResult = jsonDecode(response.body);
      } else {
        _emotionResult = {'error': 'Failed to detect emotion'};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Detection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageBytes != null) Image.memory(_imageBytes!, height: 200),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _pickImageAndDetectEmotion,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image & Analyze Emotion'),
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_emotionResult != null) ...[
              const SizedBox(height: 16),
              Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_getSimpleEmotion(_emotionResult)),
            ],
          ],
        ),
      ),
    );
  }

  String _getSimpleEmotion(Map<String, dynamic>? result) {
    if (result == null ||
        result['success'] != true ||
        result['emotions'] == null) {
      return 'No emotion detected.';
    }
    final emotions = result['emotions'];
    final joy = emotions['joy']?.toString() ?? '';
    final sorrow = emotions['sorrow']?.toString() ?? '';
    // If joy is VERY_LIKELY or LIKELY, show Happy. If sorrow is VERY_LIKELY or LIKELY, show Sad. Otherwise, show Neutral.
    if (joy == 'VERY_LIKELY' || joy == 'LIKELY') {
      return 'Happy';
    } else if (sorrow == 'VERY_LIKELY' || sorrow == 'LIKELY') {
      return 'Sad';
    } else {
      return 'Neutral';
    }
  }
}
