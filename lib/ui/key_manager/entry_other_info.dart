import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/utils/tools.dart';
import 'package:r_backup_tool/widgets/buttons.dart';

class EntryOtherInfo extends StatelessWidget {
  final KeyEntryDetailController controller;

  const EntryOtherInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            const Text(
              '标签',
              style: AppTextStyle.textEntityItemTitle,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: controller.tagsEditController.text));
                Toast.show('已复制');
              },
              child: const SizedBox(
                width: 50,
                height: 40,
                child: Center(
                  child: copyButton,
                ),
              ),
            )
          ],
        ),
        TextField(
          controller: controller.tagsEditController,
          enabled: hasExternalStoragePermission.value ||
              !controller.keyFile.externalStore.value,
          onTapOutside: (_) => hideKeyboard(context),
          style: AppTextStyle.textPrimary,
          maxLines: 5,
          minLines: 1,
          expands: false,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const Text(
              '备注',
              style: AppTextStyle.textEntityItemTitle,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: controller.noteEditController.text));
                Toast.show('已复制');
              },
              child: const SizedBox(
                width: 50,
                height: 40,
                child: Center(
                  child: copyButton,
                ),
              ),
            )
          ],
        ),
        TextField(
          controller: controller.noteEditController,
          enabled: hasExternalStoragePermission.value ||
              !controller.keyFile.externalStore.value,
          onTapOutside: (_) => hideKeyboard(context),
          style: AppTextStyle.textPrimary,
          maxLines: null,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
