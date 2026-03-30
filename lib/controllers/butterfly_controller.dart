import 'package:flutter/material.dart';

class ButterflyState extends ChangeNotifier {
  // Glow color
  Color glowColor = Colors.blueAccent;

  // Glow intensity (0.0 to 1.0)
  double glowStrength = 0.6;

  // Wing speed multiplier
  double wingSpeed = 1.0;

  // Sleep mode
  bool isSleeping = false;

  // Voice mode
  bool isListening = false;

  // AI typing mode
  bool isAiTyping = false;

  // User typing mode
  bool isUserTyping = false;

  // Update glow color
  void setGlow(Color color) {
    glowColor = color;
    notifyListeners();
  }

  // Update glow strength
  void setGlowStrength(double strength) {
    glowStrength = strength;
    notifyListeners();
  }

  // Set AI typing reaction
  void aiTyping() {
    isAiTyping = true;
    glowColor = Colors.blueAccent;
    glowStrength = 1.0;
    wingSpeed = 1.6;
    notifyListeners();
  }

  void aiStopTyping() {
    isAiTyping = false;
    wingSpeed = 1.0;
    glowStrength = 0.6;
    notifyListeners();
  }

  // User typing reaction
  void userTyping() {
    isUserTyping = true;
    glowColor = Colors.cyanAccent;
    glowStrength = 1.0;
    wingSpeed = 1.4;
    notifyListeners();
  }

  void userStopTyping() {
    isUserTyping = false;
    wingSpeed = 1.0;
    glowStrength = 0.6;
    notifyListeners();
  }

  // Voice reaction
  void startListening() {
    isListening = true;
    glowColor = Colors.purpleAccent;
    glowStrength = 1.0;
    wingSpeed = 1.8;
    notifyListeners();
  }

  void stopListening() {
    isListening = false;
    wingSpeed = 1.0;
    glowStrength = 0.6;
    notifyListeners();
  }

  // Sleep mode
  void sleep() {
    isSleeping = true;
    glowStrength = 0.2;
    wingSpeed = 0.4;
    notifyListeners();
  }

  void wake() {
    isSleeping = false;
    glowStrength = 1.0;
    wingSpeed = 1.2;
    notifyListeners();
  }

  // Emotion detection
  void applyEmotion(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("error") || lower.contains("failed")) {
      glowColor = Colors.redAccent;
    } else if (lower.contains("warning") || lower.contains("careful")) {
      glowColor = Colors.yellowAccent;
    } else if (lower.contains("love") || lower.contains("❤️")) {
      glowColor = Colors.pinkAccent;
    } else if (lower.contains("info") || lower.contains("note")) {
      glowColor = Colors.cyanAccent;
    } else {
      glowColor = Colors.blueAccent;
    }

    glowStrength = 1.0;
    wingSpeed = 1.4;
    notifyListeners();
  }
}
