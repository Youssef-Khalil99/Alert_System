import 'package:flutter/material.dart';

class BackIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackIcon({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
      icon: Navigator.canPop(context) ? const Icon(Icons.arrow_back_ios) : Container(),
    );
  }
}
