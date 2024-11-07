import 'package:flutter/material.dart';

Future showDialog(
  BuildContext context, {
  required DialogRoutePageBuilder builder,
  bool barrierDismiss = true,
  AlignmentGeometry alignment = Alignment.center,
}) {
  late Route route;
  route = PageRouteBuilder(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) =>
        builder.call(context, animation, secondaryAnimation, route),
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Stack(
        children: [
          FadeTransition(
            opacity: animation,
            child: GestureDetector(
              onTap: barrierDismiss ? Navigator.of(context).pop : null,
              child: Container(
                color: Colors.black54, // Translucent background
              ),
            ),
          ),
          Align(alignment: alignment, child: GestureDetector(child: child)),
        ],
      );
    },
  );
  return Navigator.of(context).push(
    route,
  );
}

Future showCenterDialog(
  BuildContext context, {
  required DialogRoutePageBuilder builder,
  bool barrierDismiss = true,
}) {
  return showDialog(context,
      builder: (context, animation, secondaryAnimation, route) {
    return ScaleTransition(
      scale: animation,
      child: builder.call(context, animation, secondaryAnimation, route),
    );
  });
}

typedef DialogRoutePageBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Route route);
