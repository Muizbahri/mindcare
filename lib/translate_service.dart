import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> translateText(String text, String targetLang) async {
  final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'];
  final url = Uri.parse(
    'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'q': text,
      'target': targetLang,
      'format': 'text',
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['translations'][0]['translatedText'];
  } else {
    throw Exception('Failed to translate text');
  }
}
