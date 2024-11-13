import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/styles.dart';

class TextInputDialog extends StatefulWidget {
  final Future<bool> Function(String text) onConfirm;
  final String? title;
  final String? content;

  const TextInputDialog(
      {super.key, required this.onConfirm, this.title, this.content});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
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
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: AppColors.dialogContentBackground,
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
              TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '关闭',
                    style: AppTextStyle.textButtonBlue,
                  )),
              TextButton(
                  onPressed: () async {
                    if (_loading) return;
                    _loading = true;
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (await widget.onConfirm.call(textEditController.text) &&
                        mounted) {
                      Navigator.of(context).pop();
                    }
                    _loading = false;
                  },
                  child: const Text(
                    '确定',
                    style: AppTextStyle.textButtonBlue,
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
