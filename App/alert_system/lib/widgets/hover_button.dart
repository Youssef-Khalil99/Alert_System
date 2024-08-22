import 'package:flutter/material.dart';

class HoverButton extends StatelessWidget {
  final Widget child;
  final bool isPressed;

  const HoverButton(
      {super.key,
      required this.child,
      required this.isPressed});

  @override
  Widget build(BuildContext context) {
    final pressedTransform = Matrix4.identity()..translate(0.0, 8.0, 0.0);
    final transform = isPressed
            ? pressedTransform
            : Matrix4.identity();
    return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: transform,
        child: child);
  }
}
