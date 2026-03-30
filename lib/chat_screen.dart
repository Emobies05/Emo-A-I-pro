String reply = await EmoAIPro.sendMessage(userMessage);

setState(() {
  messages.add({
    "role": "assistant",
    "text": reply,
  });
});
