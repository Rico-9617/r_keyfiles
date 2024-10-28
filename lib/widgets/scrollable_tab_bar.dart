import 'package:flutter/material.dart';

class ScrollableTabBar extends StatefulWidget {
  final List<Widget> children;
  final Function(int index)? onTap;

  const ScrollableTabBar({super.key, required this.children, this.onTap});

  @override
  State createState() => _ScrollableTabBarState();
}

class _ScrollableTabBarState extends State<ScrollableTabBar> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToItem(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero,
        ancestor: context.findRenderObject());
    final offset = _scrollController.offset;
    final screenWidth = MediaQuery.of(context).size.width;

    if (position.dx + renderBox.size.width > screenWidth) {
      // Scroll right to show the hidden part
      _scrollController.animateTo(
        offset + position.dx + renderBox.size.width - screenWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (position.dx < 0) {
      // Scroll left to show the hidden part
      _scrollController.animateTo(
        offset + position.dx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GlobalKey> itemKeys =
        List.generate(widget.children.length, (_) => GlobalKey());

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int index = 0; index < widget.children.length; index++) ...[
            GestureDetector(
              key: itemKeys[index],
              onTap: () {
                widget.onTap?.call(index);
                _scrollToItem(itemKeys[index]);
              },
              child: widget.children[index],
            )
          ],
        ],
      ),
    );
  }
}
