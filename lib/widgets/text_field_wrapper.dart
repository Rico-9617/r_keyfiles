import 'package:flutter/widgets.dart';

class TextHeadTailWrapper extends StatelessWidget {
  final Widget textField;
  final Widget? head;
  final Widget? tail;

  const TextHeadTailWrapper(
      {super.key, required this.textField, this.head, this.tail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        textField,
        if (head != null) Positioned(left: 0, child: head!),
        if (tail != null) Positioned(right: 0, child: tail!),
      ],
    );
  }
}
