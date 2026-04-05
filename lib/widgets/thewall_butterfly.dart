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
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final Random _rand = Random();
  
  late AnimationController _floatController;
  late Animation<double> _floatY;

  // FIXED: Moved position into the State so it is defined
  Offset _position = const Offset(200, 200);
  Timer? _moveTimer;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startMovement();
  }

  void _startMovement() {
    _moveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final state = context.read<ButterflyState>();
      if (!state.isOnFlower) {
        _playWingSound();
        _moveRandomly();
      }
    });
  }

  void _moveRandomly() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _position = Offset(
        _rand.nextDouble() * (size.width - 100),
        _rand.nextDouble() * (size.height - 200),
      );
    });
  }

  Future<void> _playWingSound() async {
    await _player.play(AssetSource('wing.wav'));
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _floatController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Watch the state to react to changes
    final state = context.watch<ButterflyState>();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      left: _position.dx,
      top: _position.dy,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatY.value),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: state.glowColor.withOpacity(0.6),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/thewall_butterfly.png',
                width: 130,
              ),
            ),
          );
        },
      ),
    );
  }
}
