import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/emo_butterfly.dart';
import '../controllers/butterfly_controller.dart';
import '../services/emo_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> messages = [];
  bool isStreaming = false;
  bool isListening = false;
  String _selectedLanguage = 'en';
  String _userName = 'User';

  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();

  // Supported languages
  final Map<String, String> _languages = {
    'en': 'ðŸ‡¬ðŸ‡§ English',
    'ml': 'ðŸ‡®ðŸ‡³ Malayalam',
    'hi': 'ðŸ‡®ðŸ‡³ Hindi',
    'ar': 'ðŸ‡¦ðŸ‡ª Arabic',
    'fr': 'ðŸ‡«ðŸ‡· French',
    'de': 'ðŸ‡©ðŸ‡ª German',
    'es': 'ðŸ‡ªðŸ‡¸ Spanish',
    'zh': 'ðŸ‡¨ðŸ‡³ Chinese',
    'ja': 'ðŸ‡¯ðŸ‡µ Japanese',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _loadPrefs();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _userName = prefs.getString('user_name') ?? 'User';
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_history');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        messages.clear();
        messages.addAll(decoded.cast<Map<String, dynamic>>());
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(messages));
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || isStreaming) return;

    final butterfly = context.read<ButterflyState>();
    butterfly.userTyping();
    butterfly.wake();

    setState(() {
      messages.add({'role': 'user', 'text': text});
      isStreaming = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    butterfly.aiTyping();

    final reply = await EmoAIPro.sendMessage(
      text,
      userName: _userName,
      language: _selectedLanguage,
    );

    setState(() {
      messages.add({'role': 'assistant', 'text': ''});
    });

    final int idx = messages.length - 1;
    for (int i = 0; i < reply.length; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (!mounted) return;
      setState(() {
        messages[idx]['text'] = reply.substring(0, i + 1);
      });
      _scrollToBottom();
    }

    butterfly.aiStopTyping();
    butterfly.applyEmotion(reply);

    setState(() => isStreaming = false);
    await _saveHistory();
  }

  Future<void> _toggleListening() async {
    final butterfly = context.read<ButterflyState>();

    if (!isListening) {
      final available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        butterfly.startListening();
        _speech.listen(onResult: (result) {
          setState(() => _inputCtrl.text = result.recognizedWords);
        });
      }
    } else {
      setState(() => isListening = false);
      butterfly.stopListening();
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0d1f2d),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Language',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._languages.entries.map((e) => ListTile(
                title: Text(e.value,
                    style: const TextStyle(color: Colors.white)),
                trailing: _selectedLanguage == e.key
                    ? const Icon(Icons.check, color: Colors.cyanAccent)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = e.key);
                  _saveLanguage(e.key);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildBubble(int index) {
    final msg = messages[index];
    final isUser = msg['role'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF6C3AED)
              : const Color(0xFF0d1f2d),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? Colors.purpleAccent.withOpacity(0.3)
                  : Colors.cyanAccent.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            if (!isUser && (msg['text'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => _speak(msg['text']),
                  child: const Icon(Icons.volume_up,
                      size: 16, color: Colors.cyanAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final butterfly = context.watch<ButterflyState>();

    return Scaffold(
      backgroundColor: const Color(0xFF050509),
      body: Stack(
        children: [
          // ðŸŒ… Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF07080B),
                  Color(0xFF0a1628),
                  Color(0xFF050509),
                ],
              ),
            ),
          ),

          Column(
            children: [
              // Header
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.cyanAccent.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            color: Colors.cyanAccent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purpleAccent.withOpacity(0.3),
                          border: Border.all(color: Colors.purpleAccent),
                        ),
                        child: const Icon(Icons.psychology,
                            color: Colors.purpleAccent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emo AI Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'EMO AI PRO Â· Active',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Language picker
                      GestureDetector(
                        onTap: _showLanguagePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _languages[_selectedLanguage]?.split(' ').first ??
                                'ðŸŒ',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length + (isStreaming ? 0 : 0),
                  itemBuilder: (_, i) => _buildBubble(i),
                ),
              ),

              // Divider
              Divider(
                  height: 1, color: Colors.cyanAccent.withOpacity(0.15)),

              // Input bar
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  color: const Color(0xFF07080B),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening
                              ? Colors.redAccent
                              : Colors.white54,
                        ),
                        onPressed: _toggleListening,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0d1f2d),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.cyanAccent.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _inputCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Ask Emo AI Pro...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) {
                              butterfly.userTyping();
                            },
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isStreaming
                                ? Colors.grey
                                : Colors.purpleAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ðŸ¦‹ Reactive Butterfly
          const TheWallButterfly(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _tts.stop();
    super.dispose();
  }
}
