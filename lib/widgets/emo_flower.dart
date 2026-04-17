import 'package:flutter/material.dart';

class TheWallFlower extends StatelessWidget {
  final Offset position;

  const TheWallFlower({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.45),
                blurRadius: 60,
                spreadRadius: 12,
              ),
            ],
          ),
          child: Image.asset(
            'assets/thewall_flower.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
