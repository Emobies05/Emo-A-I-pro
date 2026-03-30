import 'dart:convert';
import 'package:http/http.dart' as http;

class EmoAIPro {
  static const String baseUrl = "http://localhost:3000/chat";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
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
