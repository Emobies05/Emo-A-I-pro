import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'package:emo_a_i_pro/emo_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isStreaming = false;

  // Personality mode
  String currentMode = "Default";
  final List<String> modes = [
    "Default",
    "Friendly",
    "Developer",
    "Motivational",
    "Romantic",
    "Therapist",
  ];

  // Voice
  late stt.SpeechToText speech;
  bool isListening = false;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _initTts();
    _loadHistory();
  }

  Future<void> _initTts() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final userMessage = controller.text.trim();
    if (userMessage.isEmpty || isStreaming) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": userMessage,
        "emoji": null,
      });
      isTyping = true;
    });

    controller.clear();
    _scrollToBottom();
    await _saveHistory();

    // Call backend
    final fullReply = await EmoAIPro.sendMessage(userMessage, currentMode);

    // Fake streaming: reveal text gradually
    setState(() {
      isTyping = false;
      isStreaming = true;
      messages.add({
        "role": "assistant",
        "text": "",
        "emoji": null,
      });
    });

    final int index = messages.length - 1;
    for (int i = 0; i < fullReply.length; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (!mounted) return;
      setState(() {
        messages[index]["text"] = fullReply.substring(0, i + 1);
      });
      _scrollToBottom();
    }

    setState(() {
      isStreaming = false;
    });
    await _saveHistory();
  }

  Future<void> _startListening() async {
    if (!isListening) {
      final available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  void _setEmoji(int index, String emoji) {
    setState(() {
      messages[index]["emoji"] = emoji;
    });
    _saveHistory();
  }

  Widget _buildMessageBubble(int index) {
    final msg = messages[index];
    final bool isUser = msg["role"] == "user";
    final String? emoji = msg["emoji"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blueAccent
                  : const Color(0xFF1E1E1E), // AI bubble
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg["text"] ?? "",
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.white,
                    fontSize: 15,
                  ),
                ),
                if (!isUser && (msg["text"] as String).isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up,
                            size: 18, color: Colors.white70),
                        onPressed: () => _speak(msg["text"]),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4),
              child: Row(
                children: [
                  for (final e in ["👍", "❤️", "😂", "🤯", "😢"])
                    GestureDetector(
                      onTap: () => _setEmoji(index, e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  if (emoji != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050509),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050509),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.bolt, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              "Emo‑AI Pro",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF1E1E1E),
              value: currentMode,
              items: modes
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => currentMode = v);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypingIndicator(),
                    ),
                  );
                }
                return _buildMessageBubble(index);
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              color: const Color(0xFF050509),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening ? Colors.redAccent : Colors.white70,
                    ),
                    onPressed: _startListening,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Message Emo‑AI Pro…",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dot1 = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );
    _dot2 = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8)),
    );
    _dot3 = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Padding(
          padding: EdgeInsets.only(bottom: animation.value),
          child: const CircleAvatar(
            radius: 3,
            backgroundColor: Colors.white70,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(_dot1),
          const SizedBox(width: 4),
          _buildDot(_dot2),
          const SizedBox(width: 4),
          _buildDot(_dot3),
        ],
      ),
    );
  }
}
