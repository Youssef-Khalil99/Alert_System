import 'package:flutter/material.dart';

import 'hover_button.dart';

class AppButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final double? height;
  final double? width;

  const AppButton(
      {super.key, required this.onTap, required this.color, required this.icon, this.width, this.height});

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        onTapDown: (e) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (e) {
          setState(() {
            isPressed = false;
          });
        },
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
              ),
            ],
          ),
          HoverButton(
            isPressed: isPressed,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                  color: widget.color, borderRadius: BorderRadius.circular(12)),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ]));
  }
}


