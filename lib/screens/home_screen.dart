import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../controllers/butterfly_controller.dart';
import '../widgets/emo_butterfly.dart';
import '../widgets/emo_flower.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final Random _rand = Random();
  final AudioPlayer _player = AudioPlayer();

  // Flower positions (bottom area of screen)
  late List<Offset> flowerPositions;

  // Butterfly state
  int currentFlowerIndex = 0;
  int? landedFlowerIndex;
  bool _isLanded = false;
  bool _isTakingOff = false;
  Offset _butterflyPos = const Offset(180, 300);

  // Animations
  late AnimationController _floatCtrl;
  late Animation<double> _floatY;
  late AnimationController _flapCtrl;
  late Animation<double> _flapScale;
  late AnimationController _glowCtrl;
  late Animation<double> _glowOpacity;
  late AnimationController _spinCtrl;
  late Animation<double> _spinAngle;
  late AnimationController _swayCtrl;
  late Animation<double> _swayAngle;

  // Particle sparkles
  List<_Sparkle> _sparkles = [];
  Timer? _sparkleTimer;
  Timer? _flightTimer;
  Timer? _landTimer;

  @override
  void initState() {
    super.initState();

    // Float
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Flap
    _flapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..repeat(reverse: true);
    _flapScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _flapCtrl, curve: Curves.easeInOut),
    );

    // Glow
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(begin: 0.3, end: 0.9).animate(_glowCtrl);

    // Spin on takeoff
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _spinAngle = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.easeInOut),
    );

    // Sway while landed
    _swayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _swayAngle = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOut),
    );

    // Sparkles
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) _addSparkle();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFlowers();
      _scheduleNextMove();
    });
  }

  void _initFlowers() {
    final size = MediaQuery.of(context).size;
    setState(() {
      flowerPositions = [
        Offset(size.width * 0.08, size.height * 0.65),
        Offset(size.width * 0.42, size.height * 0.72),
        Offset(size.width * 0.72, size.height * 0.60),
      ];
      _butterflyPos = Offset(size.width * 0.4, size.height * 0.35);
    });
  }

  void _addSparkle() {
    if (flowerPositions.isEmpty) return;
    final flower = flowerPositions[_rand.nextInt(flowerPositions.length)];
    setState(() {
      _sparkles.add(_Sparkle(
        x: flower.dx + _rand.nextDouble() * 60 - 30,
        y: flower.dy + _rand.nextDouble() * 60 - 30,
        life: 1.0,
      ));
      _sparkles.removeWhere((s) => s.life <= 0);
      for (var s in _sparkles) {
        s.life -= 0.15;
      }
    });
  }

  void _scheduleNextMove() {
    final delay = 4000 + _rand.nextInt(4000);
    _flightTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (_isLanded) {
        _takeOff();
      } else {
        _flyToFlower();
      }
    });
  }

  void _flyToFlower() async {
    if (!mounted || flowerPositions.isEmpty) return;
    final next = (currentFlowerIndex + 1) % flowerPositions.length;

    _floatCtrl.repeat(reverse: true);
    _flapCtrl.repeat(reverse: true);
    _playWing();

    setState(() {
      currentFlowerIndex = next;
      _isLanded = false;
      _isTakingOff = false;
      _butterflyPos = Offset(
        flowerPositions[next].dx + 5,
        flowerPositions[next].dy - 55,
      );
    });

    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    _land(next);
  }

  void _land(int index) {
    setState(() {
      _isLanded = true;
      landedFlowerIndex = index;
    });
    _floatCtrl.stop();
    _flapCtrl.stop();
    context.read<ButterflyState>().landOnFlower();

    final sitTime = 3000 + _rand.nextInt(3000);
    _landTimer = Timer(Duration(milliseconds: sitTime), () {
      if (mounted) _takeOff();
    });
  }

  void _takeOff() async {
    if (!mounted) return;
    setState(() {
      _isTakingOff = true;
      _isLanded = false;
      landedFlowerIndex = null;
    });
    context.read<ButterflyState>().takeOff();

    await _spinCtrl.forward(from: 0);
    if (!mounted) return;

    setState(() => _isTakingOff = false);
    _floatCtrl.repeat(reverse: true);
    _flapCtrl.repeat(reverse: true);
    _playWing();
    _scheduleNextMove();
  }

  void _playWing() async {
    try {
      await _player.play(AssetSource('sounds/wing.wav'));
    } catch (_) {}
  }

  void _openChat() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _flightTimer?.cancel();
    _landTimer?.cancel();
    _sparkleTimer?.cancel();
    _floatCtrl.dispose();
    _flapCtrl.dispose();
    _glowCtrl.dispose();
    _spinCtrl.dispose();
    _swayCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Color get _glowColor {
    if (_isLanded && flowerPositions.isNotEmpty) {
      final colors = [Colors.pinkAccent, Colors.cyanAccent, Colors.purpleAccent];
      return colors[currentFlowerIndex % colors.length];
    }
    return Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ButterflyState>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: _openChat,
        child: Stack(
          children: [
            // ðŸŒ… Background gradient â€” deep garden sky
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0a1628), // deep night blue
                    Color(0xFF0d2137), // dark teal
                    Color(0xFF1a3a2a), // deep forest green
                    Color(0xFF0d1f1a), // dark ground
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),

            // ðŸŒŸ Stars / constellation dots
            CustomPaint(
              size: size,
              painter: _StarPainter(),
            ),

            // ðŸŒ¿ Ground layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.25,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF0a1a0f),
                    ],
                  ),
                ),
              ),
            ),

            // ðŸŒ¸ Flowers
            if (flowerPositions.isNotEmpty)
              ...List.generate(flowerPositions.length, (i) {
                return EmoFlower(
                  position: flowerPositions[i],
                  isActive: landedFlowerIndex == i,
                  color: [
                    Colors.pinkAccent,
                    Colors.cyanAccent,
                    Colors.purpleAccent,
                  ][i % 3],
                );
              }),

            // âœ¨ Sparkles
            ..._sparkles.map((s) => Positioned(
                  left: s.x,
                  top: s.y,
                  child: Opacity(
                    opacity: s.life.clamp(0.0, 1.0),
                    child: const Icon(
                      Icons.star,
                      size: 8,
                      color: Colors.cyanAccent,
                    ),
                  ),
                )),

            // ðŸ¦‹ Butterfly
            AnimatedPositioned(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.easeInOutCubic,
              left: _butterflyPos.dx,
              top: _butterflyPos.dy,
              child: GestureDetector(
                onTap: _openChat,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _floatCtrl,
                    _flapCtrl,
                    _glowCtrl,
                    _spinCtrl,
                    _swayCtrl,
                  ]),
                  builder: (context, _) {
                    double rotation = 0;
                    if (_isLanded) rotation = _swayAngle.value;
                    if (_isTakingOff) rotation = _spinAngle.value;

                    final floatOffset = _isLanded ? 0.0 : _floatY.value;
                    final wingScale = _isLanded ? 1.0 : _flapScale.value;

                    return Transform.translate(
                      offset: Offset(0, floatOffset),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _glowColor.withOpacity(
                                  _glowOpacity.value * state.glowStrength,
                                ),
                                blurRadius: _isLanded ? 60 : 35,
                                spreadRadius: _isLanded ? 14 : 5,
                              ),
                            ],
                          ),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(wingScale, 1.0),
                            child: Image.asset(
                              'assets/emo_butterfly.png',
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ðŸ·ï¸ Emo AI Pro title
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'EMO AI Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pro Emotional Intelligence Layer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // ðŸ‘† Tap hint at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Tap anywhere to chat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SECURE  âœ¦  PRIVATE  âœ¦  CONNECTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sparkle data
class _Sparkle {
  double x, y, life;
  _Sparkle({required this.x, required this.y, required this.life});
}

// Star background painter
class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    final rand = Random(42);
    for (int i = 0; i < 80; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height * 0.6;
      final r = rand.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
