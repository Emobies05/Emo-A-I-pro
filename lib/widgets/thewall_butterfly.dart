import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  Offset _position = const Offset(200, 200);
  Timer? _moveTimer;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startMoveTimer();
  }

  void _startMoveTimer() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _playWingSound();
      _moveToRandomPosition();
    });
  }

  Future<void> _playWingSound() async {
    await _player.play(AssetSource('wing.wav'));
  }

  void _moveToRandomPosition() {
    if (_screenSize == Size.zero) return;

    final double maxX = _screenSize.width - 140;
    final double maxY = _screenSize.height - 220;

    final double newX = _rand.nextDouble() * maxX;
    final double newY = _rand.nextDouble() * maxY;

    setState(() {
      _position = Offset(newX, newY);
    });
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
    if (_screenSize == Size.zero) {
      _screenSize = MediaQuery.of(context).size;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (_) {
          _startMoveTimer();
        },
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, child) {
            return Transform.translate(
              offset: Offset(0, _floatY.value),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
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
      ),
    );
  }
}
