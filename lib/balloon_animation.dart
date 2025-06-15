import 'dart:math';
import 'package:flutter/material.dart';

class BalloonAnimation extends StatefulWidget {
  const BalloonAnimation({super.key});

  @override
  State<BalloonAnimation> createState() => _BalloonAnimationState();
}

class _BalloonAnimationState extends State<BalloonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Balloon> _balloons = [];
  final Random _random = Random();

  String _getRandomBalloonSprite() {
    final spriteNumber =
        _random.nextInt(5) + 1; // Random number between 1 and 5
    return 'assets/images/balloon-$spriteNumber.png';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Create 10 balloons with random properties
    for (int i = 0; i < 10; i++) {
      _balloons.add(
        Balloon(
          spritePath: _getRandomBalloonSprite(),
          size: 50.0 + _random.nextDouble() * 30.0,
          startX: _random.nextDouble() * 300.0,
          startY: 600.0,
          endX: _random.nextDouble() * 300.0,
          endY: -100.0,
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _balloons.map((balloon) {
            final progress = _controller.value;
            final x =
                balloon.startX + (balloon.endX - balloon.startX) * progress;
            final y =
                balloon.startY + (balloon.endY - balloon.startY) * progress;

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: sin(progress * 10) * 0.2,
                child: Image.asset(
                  balloon.spritePath,
                  width: balloon.size,
                  height: balloon.size,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Balloon {
  final String spritePath;
  final double size;
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  Balloon({
    required this.spritePath,
    required this.size,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}
