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
        ValueListenableBuilder(
            valueListenable: _tab,
            builder: (context, value, child) {
              return BottomNavigationBar(
                currentIndex: value,
                selectedItemColor: AppColors.text0,
                unselectedItemColor: AppColors.text1,
                onTap: (index) {
                  _tab.value = index;
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.key),
                    label: '信息管理',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.contact_page), label: '通讯录'),
                ],
              );
            }),
      ],
    );
  }
}
