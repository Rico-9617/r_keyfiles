import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';

import 'contacts/contacts_tab_page.dart';
import 'key_manager/key_manager_tab_page.dart';

class MainPage extends StatelessWidget {
  final ValueNotifier<int> _tab = ValueNotifier<int>(0);

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            flex: 1,
            child: ValueListenableBuilder(
                valueListenable: _tab,
                builder: (context, value, child) {
                  return switch (value) {
                    0 => const KeyManagerTabPage(),
                    1 => const ContactsTabPage(),
                    _ => const SizedBox.shrink(),
                  };
                })),
        // Container(
        //   decoration: const BoxDecoration(
        //     color: Colors.greenAccent,
        //     boxShadow: [
        //       BoxShadow(
        //           color: Colors.black12,
        //           offset: Offset(0.0, -1.0),
        //           spreadRadius: 1,
        //           blurRadius: 2)
        //     ],
        //   ),
        //   height: 70,
        //   child: Row(
        //     children: [
        //       _buildMenuItem('信息管理', 0),
        //     ],
        //   ),
        // ),
        Container(
          color: Colors.greenAccent,
          height: MediaQuery.of(context).padding.bottom,
        ),
      ],
    );
  }

  Expanded _buildMenuItem(String title, int index) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _tab.value = index;
        },
        child: Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder(
              valueListenable: _tab,
              builder: (_, i, __) {
                final selected = i == index;
                return AnimatedContainer(
                  transform: Matrix4.identity()..scale(selected ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    title,
                    style: TextStyle(
                        color:
                            selected ? AppColors.text0 : AppColors.textDisable,
                        fontSize: selected ? 14 : 12),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
