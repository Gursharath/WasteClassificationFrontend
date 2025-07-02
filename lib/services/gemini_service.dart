// TODO Implement this library.
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiChatService {
  static const apiKey =
      'AIzaSyD_RXMvFPWt6OztLZDIBS9ClTZ0KqxUB8w'; // Replace with your real Gemini API key

  static const endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';

  static Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final reply = json['candidates'][0]['content']['parts'][0]['text'];
      return reply;
    } else {
      print("Gemini API error: ${response.body}");
      return 'Failed to get response';
    }
  }
}
