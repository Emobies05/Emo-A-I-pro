import 'package:flutter/material.dart';

class TheWallFlower extends StatelessWidget {
  final Offset position;

  const TheWallFlower({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.4),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Image.asset(
          'assets/thewall_flower.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
