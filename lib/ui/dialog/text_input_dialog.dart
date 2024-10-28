import 'package:flutter/material.dart';
import 'package:r_backup_tool/styles.dart';

class TextInputDialog extends StatefulWidget {
  static const _keyboardLetterData = '1234567890abcdefghijklmnopqrstuvwxyz---^';
  static const _keyboardSymbolData = r'!@#$%^&*()`~-_=+[{]};:’”\|,<.>/?';

  final Future<bool> Function(String text) onConfirm;
  final String? title;
  final String? content;

  const TextInputDialog(
      {super.key, required this.onConfirm, this.title, this.content});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();

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
              ScaleTransition(
                scale: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextInputDialogState extends State<TextInputDialog> {
  final textEditController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      textEditController.text = widget.content ?? '';
      textEditController.selection = TextSelection(
          baseOffset: 0, extentOffset: textEditController.text.length);
    });
    super.initState();
  }

  @override
  void dispose() {
    textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
            onTap: Navigator.of(context).pop,
          )),
          Center(
            child: GestureDetector(
              child: Container(
                width: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.title != null && widget.title!.isNotEmpty)
                      Text(
                        widget.title!,
                        style: AppTextStyle.textPrimary,
                      ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: textEditController,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(context).pop();
                            },
                            child: const Text('关闭')),
                        OutlinedButton(
                            onPressed: () async {
                              if (_loading) return;
                              _loading = true;
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (await widget.onConfirm
                                      .call(textEditController.text) &&
                                  mounted) {
                                Navigator.of(context).pop();
                              }
                              _loading = false;
                            },
                            child: const Text('确定')),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
