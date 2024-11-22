import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:vibration/vibration.dart';

const double keyFontSize = 14;

class PasswordDialog extends StatefulWidget {
  static const _keyboardLetterData = '1234567890abcdefghijklmnopqrstuvwxyz---^';
  static const _keyboardSymbolData = r'!@#$%^&*()`~-_=+[{]};:’”\|,<.>/?';

  final Future<bool> Function(String password) onConfirm;
  final String? title;
  final bool requireConfirm;
  final bool useGenerator;

  const PasswordDialog(
      {super.key,
      required this.onConfirm,
      this.title,
      this.requireConfirm = false,
      this.useGenerator = false});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();

  show(BuildContext context) {
    showModalBottomSheet(
        context: context, builder: (_) => this, isScrollControlled: true);
  }
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _textNotifier = ValueNotifier('');
  final _textEncryptNotifier = ValueNotifier(true);
  final _keyboardIndex = ValueNotifier(0);
  final _letterUpperCase = ValueNotifier(0);
  late ValueNotifier<int> _generateScope;
  late ValueNotifier<bool> _generateAvailable;
  late ValueNotifier<int> _generateLength;

  bool _loading = false;

  final int _lower_case_letter = 0x1;
  final int _upper_case_letter = 0x2;
  final int _number = 0x4;
  final int _symbol = 0x8;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FlutterWindowManagerPlus.addFlags(
          FlutterWindowManagerPlus.FLAG_SECURE);
    });
    if (widget.useGenerator) {
      _generateScope = ValueNotifier(0);
      _generateLength = ValueNotifier(6);
      _generateScope.value |= _lower_case_letter;
      _generateScope.value |= _upper_case_letter;
      _generateScope.value |= _number;
      _generateAvailable = ValueNotifier(true);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.dialogContentBackground,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          Text(
            widget.title ?? '请输入密码',
            style: AppTextStyle.textPrimary,
          ),
          const SizedBox(
            height: 12,
          ),
          _buildTextArea(_textNotifier, _textEncryptNotifier),
          const SizedBox(
            height: 12,
          ),
          ValueListenableBuilder(
              valueListenable: _keyboardIndex,
              builder: (_, index, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTab(_keyboardIndex, index, '字母,数字', 0),
                          _buildTab(_keyboardIndex, index, '符号', 1),
                          if (widget.useGenerator)
                            _buildTab(_keyboardIndex, index, '生成器', 2),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        height: 250,
                        child: switch (index) {
                          0 => _buildLetterKeyboard(
                              _letterUpperCase, _textNotifier),
                          1 => _buildSymbolKeyboard(_textNotifier),
                          2 => _buildGeneratorKeyboard(),
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
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text(
                    '关闭',
                    style: AppTextStyle.textButtonBlue,
                  )),
              TextButton(
                  onPressed: () async {
                    if (_loading) return;
                    _loading = true;
                    callback() async {
                      if (await widget.onConfirm.call(_textNotifier.value) &&
                          mounted) {
                        Navigator.of(context).pop();
                      }
                      _loading = false;
                    }

                    if (widget.requireConfirm) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('确认使用该密码？'),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      '取消',
                                      style: AppTextStyle.textButtonBlue,
                                    ),
                                    onPressed: () {
                                      _loading = false;
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      '确定',
                                      style: AppTextStyle.textButtonBlue,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      callback();
                                    },
                                  ),
                                ],
                              ));
                    } else {
                      await callback();
                    }
                  },
                  child: const Text(
                    '确定',
                    style: AppTextStyle.textButtonBlue,
                  )),
            ],
          ),
          SizedBox(
            height: 12 + MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  Padding _buildGeneratorKeyboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            builder: (context, length, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '位数: $length',
                    style: AppTextStyle.textPrimary,
                  ),
                  Slider(
                    value: length.toDouble(),
                    min: 1,
                    max: 64,
                    divisions: 63,
                    label: length.toString(),
                    onChanged: (double value) {
                      _generateLength.value = value.toInt();
                    },
                  ),
                ],
              );
            },
            valueListenable: _generateLength,
          ),
          const SizedBox(
            height: 12,
          ),
          ValueListenableBuilder(
            builder: (_, scope, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGeneratorScopeSelector(
                      '小写字母', _lower_case_letter, scope),
                  _buildGeneratorScopeSelector(
                      '大写字母', _upper_case_letter, scope),
                  _buildGeneratorScopeSelector('数字', _number, scope),
                  _buildGeneratorScopeSelector('符号', _symbol, scope),
                ],
              );
            },
            valueListenable: _generateScope,
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
              child: ValueListenableBuilder(
            builder: (context, enabled, _) {
              return ElevatedButton(
                  onPressed: enabled
                      ? () {
                          _textNotifier.value = generate(
                              _generateLength.value, _generateScope.value);
                        }
                      : null,
                  child: const Text('生成'));
            },
            valueListenable: _generateAvailable,
          )),
        ],
      ),
    );
  }

  TextButton _buildGeneratorScopeSelector(String text, int value, int scope) {
    return TextButton(
      onPressed: () {
        if (scope & value == 0) {
          _generateScope.value |= value;
        } else {
          _generateScope.value &= ~value;
        }
        _generateAvailable.value = _generateScope.value != 0;
      },
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              color: scope & value == 0
                  ? AppColors.textDisable
                  : AppColors.text0)),
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
              onTap: () async {
                textNotifier.value += symbol;
              },
              onTapDown: (_) async => await vibrate(),
              child: Container(
                alignment: Alignment.center,
                color: AppColors.keyboardKey,
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
                      onTapDown: (_) async => await vibrate(),
                      child: Container(
                        color: AppColors.keyboardKey,
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
                                    .copyWith(fontSize: keyFontSize),
                              );
                            }),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        textNotifier.value += letterUpperCase.value > 0
                            ? symbol.toUpperCase()
                            : symbol;
                      },
                      onTapDown: (_) async => await vibrate(),
                      child: Container(
                        alignment: Alignment.center,
                        color: AppColors.keyboardKey,
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
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: index == value
                ? AppTextStyle.textPrimary
                : AppTextStyle.textDisable,
            child: Text(
              title,
            ),
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
                              color: AppColors.text0, fontSize: 20),
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
                      onTapDown: (_) async => await vibrate(),
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

  vibrate() async {
    if (await Vibration.hasCustomVibrationsSupport() == true) {
      Vibration.vibrate(duration: 70);
    } else {
      Vibration.vibrate();
      await Future.delayed(const Duration(milliseconds: 70));
      Vibration.cancel();
    }
  }

  String generate(int length, int scope) {
    final source = <List<String>>[];
    List<int> scopeIndexes = [];
    int scopeIndex = 0;
    if (scope & _lower_case_letter == _lower_case_letter) {
      source.add(List.generate(26, (i) => String.fromCharCode(i + 97)));
      scopeIndexes.add(scopeIndex++);
    }
    if (scope & _upper_case_letter == _upper_case_letter) {
      source.add(List.generate(26, (i) => String.fromCharCode(i + 65)));
      scopeIndexes.add(scopeIndex++);
    }
    if (scope & _number == _number) {
      source.add(List.generate(10, (i) => i.toString()));
      scopeIndexes.add(scopeIndex++);
    }
    if (scope & _symbol == _symbol) {
      source.add(PasswordDialog._keyboardSymbolData.split(''));
      scopeIndexes.add(scopeIndex++);
    }
    while (scopeIndexes.length < length) {
      scopeIndexes.add(Random().nextInt(scopeIndex));
    }
    scopeIndexes.shuffle(Random());
    final result = StringBuffer();
    while (result.length < length) {
      final src = source[scopeIndexes[result.length]];
      result.write(src[Random().nextInt(src.length)]);
    }
    return result.toString();
  }
}
