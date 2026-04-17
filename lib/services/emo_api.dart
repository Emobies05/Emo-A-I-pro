import 'dart:convert';
import 'package:http/http.dart' as http;

class EmoAIPro {
  static const String baseUrl = "https://emo-a-i-pro.vercel.app/api/chat";

  static Future<String> sendMessage(String message, {List<Map<String, dynamic>>? history}) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "history": history ?? []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No reply from server.";
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }
}
