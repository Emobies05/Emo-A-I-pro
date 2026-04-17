import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import '../controllers/butterfly_controller.dart';

class TheWallButterfly extends StatefulWidget {
  const TheWallButterfly({super.key});

  @override
  State<TheWallButterfly> createState() => _TheWallButterflyState();
}

class _TheWallButterflyState extends State<TheWallButterfly>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final Random _rand = Random();

  late AnimationController _floatController;
  late Animation<double> _floatY;

  // ✨ Glow pulse
  late AnimationController _glowController;
  late Animation<double> _glowOpacity;

  Offset _position = const Offset(200, 200);
  Timer? _moveTimer;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowOpacity =
        Tween<double>(begin: 0.4, end: 0.85).animate(_glowController);

    _startAutoFlight();
  }

  // 🦋 Auto wandering
  void _startAutoFlight() {
    _moveTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      final state = context.read<ButterflyState>();
      if (!state.isOnFlower && !state.isLanding && !state.isSleeping) {
        _flyToNewSpot();
      }
    });
  }

  Future<void> _flyToNewSpot() async {
    final size = MediaQuery.of(context).size;

    try {
      await _player.stop();
      await _player.play(AssetSource('wing.wav'));
    } catch (_) {}

    setState(() {
      _position = Offset(
        _rand.nextDouble() * (size.width - 150),
        _rand.nextDouble() * (size.height - 250),
      );
    });
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _floatController.dispose();
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ButterflyState>();

    return AnimatedPositioned(
      duration: Duration(milliseconds: (1200 / state.wingSpeed).clamp(600, 1600).toInt()),
      curve: Curves.fastOutSlowIn,
      left: _position.dx,
      top: _position.dy,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _glowController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatY.value * state.wingSpeed),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: state.glowColor
                        .withOpacity(_glowOpacity.value * state.glowStrength),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/thewall_butterfly.png',
                width: 140,
                height: 140,
              ),
            ),
          );
        },
      ),
    );
  }
}
