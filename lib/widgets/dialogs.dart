import 'package:flutter/material.dart';

void showDialog(
  BuildContext context, {
  required RoutePageBuilder builder,
  bool barrierDismiss = true,
  AlignmentGeometry alignment = Alignment.center,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder.call(context, animation, secondaryAnimation),
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
    ),
  );
}

void showCenterDialog(
  BuildContext context, {
  required RoutePageBuilder builder,
  bool barrierDismiss = true,
}) {
  showDialog(context, builder: (context, animation, secondaryAnimation) {
    return ScaleTransition(
      scale: animation,
      child: builder.call(context, animation, secondaryAnimation),
    );
  });
}
