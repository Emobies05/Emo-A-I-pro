import 'package:flutter/material.dart';

class EmoFlower extends StatefulWidget {
  final Offset position;
  final bool isActive;
  final Color color;

  const EmoFlower({
    super.key,
    required this.position,
    this.isActive = false,
    this.color = Colors.pinkAccent,
  });

  @override
  State<EmoFlower> createState() => _EmoFlowerState();
}

class _EmoFlowerState extends State<EmoFlower>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(
                      widget.isActive ? 0.75 : _pulseOpacity.value,
                    ),
                    blurRadius: widget.isActive ? 80 : 50,
                    spreadRadius: widget.isActive ? 18 : 8,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: widget.isActive ? 1.08 : 1.0,
                child: Image.asset(
                  'assets/emo_flower.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
