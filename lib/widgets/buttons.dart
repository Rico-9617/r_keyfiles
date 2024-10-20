
import 'package:flutter/material.dart';

class ClickableWidget extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Widget? child;

  const ClickableWidget(
      {super.key,
      this.enabled = true,
      this.onTap,
      this.padding,
      this.width,
      this.height,
      this.child});

  @override
  Widget build(BuildContext context) {
    final contentWidget = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: padding,
      child: child,
    );

    return ClipRRect(
        child: Material(
          elevation: 10,
          child: enabled
              ? InkWell(
                  onTap: onTap,
                  child: contentWidget,
                )
              : contentWidget,
        ));
  }
}
