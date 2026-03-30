import 'package:flutter/material.dart';

class ButterflyState extends ChangeNotifier {
  Color glowColor = Colors.blueAccent;
  double glowStrength = 0.6;
  double wingSpeed = 1.0;

  bool isSleeping = false;
  bool isListening = false;
  bool isAiTyping = false;
  bool isUserTyping = false;

  // Flower / landing
  bool isLanding = false;
  bool isOnFlower = false;
  Offset flowerPosition = const Offset(150, 500);

  void setGlow(Color color) {
    glowColor = color;
    notifyListeners();
  }

  void setGlowStrength(double strength) {
    glowStrength = strength;
    notifyListeners();
  }

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

  // Landing on flower
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
