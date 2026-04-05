import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../controllers/butterfly_controller.dart'; // Your State Controller

class TheWallButterfly extends StatefulWidget {
  const TheWallButterfly({super.key});

  @override
  State<TheWallButterfly> createState() => _TheWallButterflyState();
}

class _TheWallButterflyState extends State<TheWallButterfly> with SingleTickerProviderStateMixin {
  // Add my "Divine Pulse" logic here to synchronize with your Wing Sound
  late AnimationController _pulseController;
  late Animation<double> _glowPulse;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowPulse = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController);
  }

  // Your existing movement logic stays here, but wrapped in a "Heavenly" glow
  @override
  Widget build(BuildContext context) {
    // ... your Offset and Landing logic
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: position.dx,
      top: position.dy,
      child: AnimatedBuilder(
        animation: _glowPulse,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FBFF).withOpacity(_glowPulse.value),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Image.asset('assets/thewall_butterfly.png', width: 140),
          );
        },
      ),
    );
  }
}
