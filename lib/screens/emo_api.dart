import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmoAIPro {
  // ðŸ”‘ Environment variables â€” set via --dart-define
  static const String _geminiKey =
      String.fromEnvironment('GEMINI_API_KEY');
  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnon =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _emoKeyBase = 'https://emo-key.vercel.app';
  static const String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Cache emo key locally
  static String? _cachedEmoKey;

  // â”€â”€â”€ Step 1: Get or generate Emo-Key â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<String?> getEmoKey(String userName) async {
    if (_cachedEmoKey != null) return _cachedEmoKey;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('emo_key');
    if (saved != null) {
      _cachedEmoKey = saved;
      return saved;
    }

    try {
      final res = await http.get(
        Uri.parse('$_emoKeyBase/api/generate?name=$userName'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final key = data['key'] as String;
          await prefs.setString('emo_key', key);
          _cachedEmoKey = key;
          return key;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // â”€â”€â”€ Step 2: Validate key against Supabase â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<bool> validateKey(String emoKey) async {
    try {
      final res = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/emo_keys?key=eq.$emoKey&select=key'),
        headers: {
          'apikey': _supabaseAnon,
          'Authorization': 'Bearer $_supabaseAnon',
        },
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.isNotEmpty;
      }
    } catch (_) {}
    return false;
  }

  // â”€â”€â”€ Step 3: Send message to Gemini â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<String> sendMessage(
    String message, {
    String userName = 'User',
    String language = 'en',
  }) async {
    try {
      // Get and validate Emo-Key
      final emoKey = await getEmoKey(userName);
      if (emoKey == null) {
        return 'Could not generate access key. Please try again.';
      }

      final isValid = await validateKey(emoKey);
      if (!isValid) {
        return 'Access key invalid. Please contact support.';
      }

      // Send to Gemini with language instruction
      final systemPrompt = language == 'en'
          ? 'You are Emo AI Pro, a compassionate emotional intelligence assistant. Respond in English.'
          : 'You are Emo AI Pro, a compassionate emotional intelligence assistant. Respond in the same language as the user.';

      final res = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': '$systemPrompt\n\nUser: $message'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'No response';
      } else {
        return 'Error: ${res.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // â”€â”€â”€ Translation via Gemini â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<String> translate(String text, String targetLanguage) async {
    try {
      final res = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Translate the following text to $targetLanguage. Return only the translated text, nothing else:\n\n$text'
                }
              ]
            }
          ],
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? text;
      }
    } catch (_) {}
    return text;
  }
}
