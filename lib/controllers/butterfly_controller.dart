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
    glowColor = Colors.c
