import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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

  Balloon _createBalloon(int index, double screenWidth) {
    final popTime =
        _random.nextDouble() * 4.5 +
        0.5; // Random pop time between 0.5-5 seconds
    final willPop = _random.nextDouble() < 0.3; // 30% chance to pop
    developer.log(
      'Balloon $index will ${willPop ? "pop" : "float"} after ${popTime.toStringAsFixed(2)} seconds',
    );

    final popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Pop animation duration
    );

    final floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Calculate x positions to spread across screen width
    final startX = _random.nextDouble() * screenWidth;
    final endX = _random.nextDouble() * screenWidth;

    final balloon = Balloon(
      spritePath: _getRandomBalloonSprite(),
      size: 50.0 + _random.nextDouble() * 30.0,
      startX: startX,
      startY: 600.0,
      endX: endX,
      endY: -100.0,
      popTime: popTime,
      popController: popController,
      floatController: floatController,
    );

    // Start floating animation
    floatController.forward();

    // Schedule the pop animation only if the balloon should pop
    if (willPop) {
      Future.delayed(Duration(milliseconds: (popTime * 1000).round()), () {
        if (mounted) {
          _popBalloon(balloon);
        }
      });
    }

    return balloon;
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

    // Create random number of balloons (5-14)
    for (int i = 0; i < _random.nextInt(10) + 5; i++) {
      _balloons.add(
        _createBalloon(i, 300.0),
      ); // Default width until we get actual screen width
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
    // Get screen width and update balloon positions if needed
    final screenWidth = MediaQuery.of(context).size.width;
    if (_balloons.isNotEmpty && _balloons[0].startX > screenWidth) {
      // Recreate balloons with new screen width
      _balloons.clear();
      for (int i = 0; i < _random.nextInt(10) + 5; i++) {
        _balloons.add(_createBalloon(i, screenWidth));
      }
    }

    return Stack(
      children: _balloons.map((balloon) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            balloon.floatController,
            balloon.popController,
          ]),
          builder: (context, child) {
            final progress = balloon.floatController.value;
            final x =
                balloon.startX + (balloon.endX - balloon.startX) * progress;
            final y =
                balloon.startY + (balloon.endY - balloon.startY) * progress;

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
