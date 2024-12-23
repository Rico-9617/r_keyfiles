import 'package:flutter/widgets.dart';

PageRouteBuilder createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var slideTransition =
          SlideTransition(position: animation.drive(tween), child: child);

      var reverseTween = Tween(begin: Offset.zero, end: Offset(1.0, 0.0))
          .chain(CurveTween(curve: curve));
      var reverseSlideTransition = SlideTransition(
          position: secondaryAnimation.drive(reverseTween),
          child: slideTransition);

      return reverseSlideTransition;
    },
  );
}
