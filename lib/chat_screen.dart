void sendMessage() async {
  final userMessage = controller.text.trim();
  if (userMessage.isEmpty) return;

  setState(() {
    messages.add({
      "role": "user",
      "text": userMessage,
    });
  });

  controller.clear();

  // ⭐ CALL YOUR BACKEND HERE
  String reply = await EmoAIPro.sendMessage(userMessage);

  setState(() {
    messages.add({
      "role": "assistant",
      "text": reply,
    });
  });
}
