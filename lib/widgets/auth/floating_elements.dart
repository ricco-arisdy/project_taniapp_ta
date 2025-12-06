import 'package:flutter/material.dart';

class FloatingElements extends StatelessWidget {
  final Animation<double> animation;

  const FloatingElements({
    Key? key,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 100 + (animation.value * 20),
                  left: 30,
                  child: Transform.rotate(
                    angle: animation.value * 0.3,
                    child: Icon(
                      Icons.eco,
                      size: 25,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 200 + (animation.value * -15),
                  right: 50,
                  child: Transform.rotate(
                    angle: -animation.value * 0.2,
                    child: Icon(
                      Icons.local_florist,
                      size: 20,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 150 + (animation.value * 25),
                  left: 60,
                  child: Transform.rotate(
                    angle: animation.value * 0.4,
                    child: Icon(
                      Icons.grass,
                      size: 30,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
