
import 'package:flutter/cupertino.dart';

class ContentScaffold extends StatelessWidget{
  final Widget Function(double statusBarHeight,double navigationBarHeight) child;
  const ContentScaffold({super.key, required this.child, });

  @override
  Widget build(BuildContext context) {
    return child.call(MediaQuery.of(context).padding.top, MediaQuery.of(context).padding.bottom);
  }

}