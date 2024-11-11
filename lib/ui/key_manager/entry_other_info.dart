import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/utils/tools.dart';

class EntryOtherInfo extends StatelessWidget {
  final KeyEntryDetailController controller;

  const EntryOtherInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
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
                    Clipboard.setData(ClipboardData(
                        text: controller.tagsEditController.text));
                    Toast.show('已复制');
                  },
                  child: const SizedBox(
                    width: 50,
                    height: 40,
                    child: Center(
                      child: Text(
                        '复制',
                        style: AppTextStyle.textButtonBlue,
                      ),
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
                    Clipboard.setData(ClipboardData(
                        text: controller.noteEditController.text));
                    Toast.show('已复制');
                  },
                  child: const SizedBox(
                    width: 50,
                    height: 40,
                    child: Center(
                      child: Text(
                        '复制',
                        style: AppTextStyle.textButtonBlue,
                      ),
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
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 20, // Adjust height as needed
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.entryBackground,
                  AppColors.entryBackground.withAlpha(0)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 20, // Adjust height as needed
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.entryBackground,
                  AppColors.entryBackground.withAlpha(0)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
