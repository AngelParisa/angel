import 'dart:math';
import 'package:flutter/material.dart';

class BalloonAnimation extends StatefulWidget {
  const BalloonAnimation({super.key});

  @override
  State<BalloonAnimation> createState() => _BalloonAnimationState();
}

class _BalloonAnimationState extends State<BalloonAnimation>
    with TickerProviderStateMixin {
  final List<Balloon> _balloons = [];
  final Random _random = Random();

  String _getRandomBalloonSprite() {
    final spriteNumber = _random.nextInt(5) + 1;
    return 'assets/images/balloon-$spriteNumber.png';
  }

  void _popBalloon(Balloon balloon) {
    if (!balloon.isPopped) {
      setState(() {
        balloon.isPopped = true;
        balloon.popController.forward();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Create 10 balloons with random properties
    for (int i = 0; i < _random.nextInt(10) + 5; i++) {
      final popTime =
          _random.nextDouble() * 4.5 +
          0.5; // Random pop time between 0.5-5 seconds
      print('Balloon $i will pop after ${popTime.toStringAsFixed(2)} seconds');
      final popController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200), // Pop animation duration
      );

      final floatController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );

      final balloon = Balloon(
        spritePath: _getRandomBalloonSprite(),
        size: 50.0 + _random.nextDouble() * 30.0,
        startX: _random.nextDouble() * 300.0,
        startY: 600.0,
        endX: _random.nextDouble() * 300.0,
        endY: -100.0,
        popTime: popTime,
        popController: popController,
        floatController: floatController,
      );

      _balloons.add(balloon);

      // Start floating animation
      floatController.forward();

      // Schedule the pop animation
      Future.delayed(Duration(milliseconds: (popTime * 1000).round()), () {
        if (mounted) {
          _popBalloon(balloon);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var balloon in _balloons) {
      balloon.popController.dispose();
      balloon.floatController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _balloons.map((balloon) {
        return AnimatedBuilder(
          animation: balloon.floatController,
          builder: (context, child) {
            final progress = balloon.floatController.value;
            final x =
                balloon.startX + (balloon.endX - balloon.startX) * progress;
            final y =
                balloon.startY + (balloon.endY - balloon.startY) * progress;

            return AnimatedBuilder(
              animation: balloon.popController,
              builder: (context, child) {
                if (balloon.isPopped && balloon.popController.value >= 1.0) {
                  return const SizedBox.shrink(); // Hide popped balloon
                }

                final scale =
                    1.0 +
                    balloon.popController.value *
                        0.3; // Balloon expands slightly before popping
                final opacity = 1.0 - balloon.popController.value;

                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.rotate(
                    angle: sin(progress * 10) * 0.2,
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Image.asset(
                          balloon.spritePath,
                          width: balloon.size,
                          height: balloon.size,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }).toList(),
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
  final double popTime;
  final AnimationController popController;
  final AnimationController floatController;
  bool isPopped = false;

  Balloon({
    required this.spritePath,
    required this.size,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.popTime,
    required this.popController,
    required this.floatController,
  });
}
