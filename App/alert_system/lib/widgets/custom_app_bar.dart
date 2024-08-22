import 'package:flutter/material.dart';

import 'back_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarAttributes? cardBackViewAppBar;

  const CustomAppBar(this.cardBackViewAppBar, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // expandedHeight: 250.0,
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
        null,
        0,
      ),

      backgroundColor: cardBackViewAppBar?.color != null ? cardBackViewAppBar!.color!: Colors.teal,
      centerTitle: true,
      title: cardBackViewAppBar?.title != null ? Text(cardBackViewAppBar!.title!) : null,
      leading: cardBackViewAppBar?.leading ?? const BackIcon(),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: cardBackViewAppBar?.trailing ?? const SizedBox(),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarAttributes {
  String? title;
  final Widget? trailing;
  final Widget? leading;
  final Color? color;

  CustomAppBarAttributes({this.title, this.trailing, this.leading, this.color});
}
