import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/emo_butterfly.dart';

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

    final butterfly = context.read<ButterflyState>();
    butterfly.userTyping();
    butterfly.wake();

    setState(() {
      messages.add({
        "role": "user",
        "text": userMessage,
      });
      isTyping = false;
    });

    controller.clear();
    _scrollToBottom();
    await _saveHistory();

    butterfly.aiTyping();

    final fullReply = await EmoAIPro.sendMessage(userMessage);

    setState(() {
      isStreaming = true;
      messages.add({
        "role": "assistant",
        "text": "",
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

    butterfly.aiStopTyping();
    butterfly.applyEmotion(fullReply);
    butterfly.wake();

    setState(() {
      isStreaming = false;
    });

    await _saveHistory();
  }

  Future<void> _startListening() async {
    final butterfly = context.read<ButterflyState>();

    if (!isListening) {
      final available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        butterfly.startListening();

        speech.listen(onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => isListening = false);
      butterfly.stopListening();
      speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Widget _buildMessageBubble(int index) {
    final msg = messages[index];
    final bool isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg["text"] ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            if (!isUser)
              IconButton(
                icon: const Icon(Icons.volume_up,
                    size: 18, color: Colors.white70),
                onPressed: () => _speak(msg["text"]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
          Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == messages.length) {
                      return const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Typing...",
                            style: TextStyle(color: Colors.white54),
                          ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  color: const Color(0xFF050509),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color:
                              isListening ? Colors.redAccent : Colors.white70,
                        ),
                        onPressed: _startListening,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Message TheWall AI…",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) {
                            butterfly.userTyping();
                            butterfly.wake();
                          },
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

          /// ⭐ TheWall Reactive Butterfly
          const TheWallButterfly(),
        ],
      ),
    );
  }
}
