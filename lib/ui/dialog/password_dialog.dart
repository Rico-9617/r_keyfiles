import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/styles.dart';

class PasswordDialog extends StatelessWidget {
  const PasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    final textNotifier = ValueNotifier('test');
    final textEncryptNotifier = ValueNotifier(true);
    final keyboardIndex = ValueNotifier(0);
    final letterUpperCase = ValueNotifier(false);
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: Navigator.of(context).pop,
          )),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  '请输入密码',
                  style: AppTextStyle.textPrimary,
                ),
                const SizedBox(
                  height: 12,
                ),
                _buildTextArea(textNotifier, textEncryptNotifier),
                const SizedBox(
                  height: 12,
                ),
                ValueListenableBuilder(
                    valueListenable: keyboardIndex,
                    builder: (_, index, __) => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTab(keyboardIndex, index, '字母', 0),
                                _buildTab(keyboardIndex, index, '数字', 1),
                                _buildTab(keyboardIndex, index, '符号', 2),
                              ],
                            ),
                            // switch(index){
                            // 0=>
                            // _=>const SizedBox.shrink()
                            // },
                          ],
                        )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('关闭')),
                    ElevatedButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('确定')),
                  ],
                ),
                SizedBox(
                  height: 12 + MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTab(
      ValueNotifier<int> keyboardIndex, int index, String title, int value) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          keyboardIndex.value = value;
        },
        child: Container(
          height: 35,
          alignment: Alignment.center,
          child: Text(
            title,
            style: index == value
                ? AppTextStyle.textPrimary
                : AppTextStyle.textDisable,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea(ValueNotifier<String> textNotifier,
      ValueNotifier<bool> textEncryptNotifier) {
    return Stack(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GestureDetector(
              onTap: () {
                if (textNotifier.value.isNotEmpty) {
                  textEncryptNotifier.value = !textEncryptNotifier.value;
                }
              },
              child: ValueListenableBuilder(
                  valueListenable: textNotifier,
                  builder: (_, text, __) => ValueListenableBuilder(
                      valueListenable: textEncryptNotifier,
                      builder: (_, encrypt, __) => Text(
                            encrypt ? text.replaceAll(RegExp(r'.'), '*') : text,
                            style: const TextStyle(
                                color: AppColors.text0, fontSize: 18),
                            textAlign: TextAlign.center,
                          ))),
            ),
          ),
        ),
        Positioned(
          right: 16,
          child: ValueListenableBuilder(
              valueListenable: textNotifier,
              builder: (_, text, __) => text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        textNotifier.value = text.substring(0, text.length - 1);
                      },
                      onLongPress: () {
                        textNotifier.value = '';
                      },
                      child: const Icon(CupertinoIcons.delete_left),
                    )
                  : const SizedBox.shrink()),
        ),
      ],
    );
  }

  show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => this,
        transitionsBuilder: (_, animation, __, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.black54, // Translucent background
                ),
              ),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}

class SlideFromBottomRoute extends PageRouteBuilder {
  SlideFromBottomRoute()
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasswordDialog(),
          transitionDuration: const Duration(milliseconds: 300),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        FadeTransition(
          opacity: animation,
          child: Container(
            color: Colors.black54, // Translucent background
          ),
        ),
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        ),
      ],
    );
  }
}
