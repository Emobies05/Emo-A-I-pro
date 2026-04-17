import 'package:flutter/material.dart';

class ButterflyState extends ChangeNotifier {
  // 🌈 Visual state
  Color glowColor = Colors.blueAccent;
  double glowStrength = 0.6;
  double wingSpeed = 1.0;

  // 🧠 Activity state
  bool isSleeping = false;
  bool isListening = false;
  bool isAiTyping = false;
  bool isUserTyping = false;

  // 🌸 Landing / flower
  bool isLanding = false;
  bool isOnFlower = false;
  Offset flowerPosition = const Offset(150, 500);

  // ---------- BASIC CONTROLS ----------

  void setGlow(Color color) {
    glowColor = color;
    notifyListeners();
  }

  void setGlowStrength(double strength) {
    glowStrength = strength;
    notifyListeners();
  }

  // ---------- AI / USER INTERACTION ----------

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

  // ---------- VOICE LISTENING ----------

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

  // ---------- SLEEP / WAKE ----------

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

  // ---------- ✅ EMOTION ENGINE (IMPORTANT) ----------
  // Emotion comes from BACKEND, not text

  void applyEmotion(String emotion) {
    switch (emotion) {
      case "calm":
        glowColor = Colors.blueAccent;
        glowStrength = 0.6;
        wingSpeed = 1.0;
        break;

      case "curious":
        glowColor = Colors.cyanAccent;
        glowStrength = 1.0;
        wingSpeed = 1.4;
        break;

      case "concerned":
        glowColor = Colors.orangeAccent;
        glowStrength = 1.0;
        wingSpeed = 1.6;
        break;

      case "protective":
        glowColor = Colors.redAccent;
        glowStrength = 1.2;
        wingSpeed = 1.8;
        break;

      case "resting":
        glowColor = Colors.pinkAccent;
        glowStrength = 0.3;
        wingSpeed = 0.4;
        break;

      default:
        glowColor = Colors.blueAccent;
        glowStrength = 0.6;
        wingSpeed = 1.0;
    }

    notifyListeners();
  }

  // ---------- 🌸 LANDING / FLOWER ----------

  void startLanding() {
    isLanding = true;
    isOnFlower = false;
    glowColor = Colors.pinkAccent;
    glowStrength = 1.0;
    wingSpeed = 0.8;
    notifyListeners();
  }

  void landOnFlower() {
    isLanding = false;
    isOnFlower = true;
    wingSpeed = 0.3;
    glowStrength = 0.4;
    notifyListeners();
  }

  void takeOff() {
    isOnFlower = false;
    wingSpeed = 1.4;
    glowStrength = 1.0;
    notifyListeners();
  }
}
