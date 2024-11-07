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
        Container(
          decoration: const BoxDecoration(
            color: Colors.greenAccent,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -1.0),
                  spreadRadius: 1,
                  blurRadius: 2)
            ],
          ),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  _tab.value = 0;
                },
                child: ValueListenableBuilder(
                    valueListenable: _tab,
                    builder: (_, index, __) {
                      final selected = index == 0;
                      return AnimatedScale(
                        scale: 1.2,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          '信息管理',
                          style: TextStyle(
                              color: selected
                                  ? AppColors.text0
                                  : AppColors.textDisable,
                              fontSize: 12),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.greenAccent,
          height: MediaQuery.of(context).padding.bottom,
        ),
      ],
    );
  }
}
