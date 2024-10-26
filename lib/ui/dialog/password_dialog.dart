import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/styles.dart';

class PasswordDialog extends StatefulWidget {
  static const _keyboardLetterData = '1234567890abcdefghijklmnopqrstuvwxyz---^';
  static const _keyboardSymbolData = r'!@#$%^&*()`~-_=+[{]};:’”\|,<.>/?';

  final Future<bool> Function(String password) onConfirm;

  const PasswordDialog({super.key, required this.onConfirm});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();

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

class _PasswordDialogState extends State<PasswordDialog> {
  final textNotifier = ValueNotifier('');
  final textEncryptNotifier = ValueNotifier(true);
  final keyboardIndex = ValueNotifier(0);
  final letterUpperCase = ValueNotifier(0);
  bool _loading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FlutterWindowManagerPlus.addFlags(
          FlutterWindowManagerPlus.FLAG_SECURE);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                _buildTab(keyboardIndex, index, '字母,数字', 0),
                                _buildTab(keyboardIndex, index, '符号', 1),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            SizedBox(
                              height: 250,
                              child: switch (index) {
                                0 => _buildLetterKeyboard(
                                    letterUpperCase, textNotifier),
                                1 => _buildSymbolKeyboard(textNotifier),
                                _ => const SizedBox.shrink()
                              },
                            ),
                          ],
                        )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('关闭')),
                    OutlinedButton(
                        onPressed: () async {
                          if (_loading) return;
                          _loading = true;
                          if (await widget.onConfirm.call(textNotifier.value) &&
                              mounted) {
                            Navigator.of(context).pop();
                          }
                          _loading = false;
                        },
                        child: const Text('确定')),
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

  Widget _buildSymbolKeyboard(ValueNotifier<String> textNotifier) {
    return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: PasswordDialog._keyboardSymbolData.length,
        itemBuilder: (_, index) {
          final symbol = PasswordDialog._keyboardSymbolData[index];
          return GestureDetector(
              onTap: () {
                textNotifier.value += symbol;
              },
              child: Container(
                alignment: Alignment.center,
                color: Colors.blue.withAlpha(10),
                child: Text(
                  symbol,
                  style: AppTextStyle.textPrimary
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ));
        });
  }

  Widget _buildLetterKeyboard(
      ValueNotifier<int> letterUpperCase, ValueNotifier<String> textNotifier) {
    return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: PasswordDialog._keyboardLetterData.length,
        itemBuilder: (_, index) {
          final symbol = PasswordDialog._keyboardLetterData[index];
          return symbol == '-'
              ? const SizedBox.shrink()
              : symbol == '^'
                  ? GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        letterUpperCase.value = letterUpperCase.value == 1
                            ? 0
                            : letterUpperCase.value + 1;
                      },
                      child: Container(
                        color: Colors.blue.withAlpha(10),
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                            valueListenable: letterUpperCase,
                            builder: (_, upperCase, __) {
                              return Text(
                                switch (upperCase) {
                                  0 => '小写',
                                  1 => '大写',
                                  _ => '',
                                },
                                style: AppTextStyle.textPrimary
                                    .copyWith(fontSize: 12),
                              );
                            }),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        textNotifier.value += letterUpperCase.value > 0
                            ? symbol.toUpperCase()
                            : symbol;
                      },
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.blue.withAlpha(10),
                        child: ValueListenableBuilder(
                            valueListenable: letterUpperCase,
                            builder: (_, upperCase, __) {
                              return Text(
                                upperCase > 0 ? symbol.toUpperCase() : symbol,
                                style: AppTextStyle.textPrimary
                                    .copyWith(fontWeight: FontWeight.w600),
                              );
                            }),
                      ));
        });
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
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 46),
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
}
