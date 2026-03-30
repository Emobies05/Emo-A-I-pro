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

  Offset _position = const Offset(200, 200);
  Timer? _moveTimer;
  Timer? _sleepTimer;
  Timer? _landingTimer;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startMoveTimer();
    _startSleepTimer();
    _startLandingTimer();
  }

  void _startMoveTimer() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final state = context.read<ButterflyState>();
      if (!state.isOnFlower && !state.isLanding) {
        _playWingSound();
        _moveToRandomPosition();
      }
    });
  }

  void _startSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      final controller = context.read<ButterflyState>();
      if (!controller.isAiTyping &&
          !controller.isUserTyping &&
          !controller.isListening &&
          !controller.isOnFlower &&
          !controller.isLanding) {
        controller.sleep();
      }
    });
  }

  void _startLandingTimer() {
    _landingTimer?.cancel();
    _landingTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      final state = context.read<ButterflyState>();
      if (!state.isOnFlower && !state.isLanding) {
        state.startLanding();
      }
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
    _sleepTimer?.cancel();
    _landingTimer?.cancel();
    _floatController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ButterflyState>();

    if (_screenSize == Size.zero) {
      _screenSize = MediaQuery.of(context).size;
    }

    // If landing, move toward flower
    if (state.isLanding) {
      final target = Offset(
        state.flowerPosition.dx,
        state.flowerPosition.dy - 80,
      );
      final diff = target - _position;
      if (diff.distance > 5) {
        _position = _position + diff * 0.08;
      } else {
        state.landOnFlower();
        Future.delayed(const Duration(seconds: 6), () {
          state.takeOff();
          _startMoveTimer();
        });
      }
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          context.read<ButterflyState>().wake();
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
              offset: Offset(0, _floatY.value * state.wingSpeed),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    // OUTER GLOW
                    BoxShadow(
                      color: state.glowColor.withOpacity(state.glowStrength),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                    // INNER GLOW
                    BoxShadow(
                      color: state.glowColor.withOpacity(state.glowStrength),
                      blurRadius: 10,
                      spreadRadius: -5,
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
