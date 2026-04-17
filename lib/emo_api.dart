import 'dart:convert';
import 'package:http/http.dart' as http;

class EmoAIPro {
  /// 🔗 Replace with your deployed backend URL
  /// Example:
  /// https://emo-ai-pro.vercel.app/api/chat
  /// http://192.168.1.5:3000/chat
  static const String baseUrl = "http://YOUR_SERVER_IP:3000/chat";

  /// ✅ Sends message to backend
  /// ✅ Receives text + emotion
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "message": message,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "text": data["reply"] ?? "I’m here with you.",
          "emotion": data["emotion"] ?? "calm",
        };
      } else {
        return {
          "text": "Server error (${response.statusCode}). Please try again.",
          "emotion": "concerned",
        };
      }
    } catch (e) {
      return {
        "text": "Connection issue. Please check your network.",
        "emotion": "protective",
      };
    }
  }
}
