import 'package:flutter/widgets.dart';

PageRouteBuilder buildTransparentPageRoute(Widget widget,
        {bool barrierDismissible = false}) =>
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      opaque: false,
      barrierDismissible: barrierDismissible,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
