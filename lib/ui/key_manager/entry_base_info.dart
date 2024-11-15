import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/utils/tools.dart';
import 'package:r_backup_tool/widgets/buttons.dart';
import 'package:r_backup_tool/widgets/text_field_wrapper.dart';

class EntryBaseInfo extends StatelessWidget {
  final KeyEntryDetailController controller;

  const EntryBaseInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const Text(
          '用户名',
          style: AppTextStyle.textEntityItemTitle,
        ),
        TextHeadTailWrapper(
          textField: TextField(
            controller: controller.userNameEditController,
            onTapOutside: (_) => hideKeyboard(context),
            enabled: hasExternalStoragePermission.value ||
                !controller.keyFile.externalStore.value,
            style: AppTextStyle.textPrimary,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(right: 50),
            ),
          ),
          tail: buildCopyButton(controller.userNameEditController.text),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          '密码',
          style: AppTextStyle.textEntityItemTitle,
        ),
        TextHeadTailWrapper(
          textField: GestureDetector(
            onTap: () {
              if (hasExternalStoragePermission.value ||
                  !controller.keyFile.externalStore.value) {
                hideKeyboard(context);
                PasswordDialog(
                  onConfirm: (p) async {
                    controller.modifyPsw(p);
                    return true;
                  },
                  title: '设置新密码',
                  useGenerator: true,
                ).show(context);
              }
            },
            child: TextField(
              maxLines: null,
              controller: controller.pswEditController,
              enabled: false,
              style: AppTextStyle.textPrimary,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(right: 100),
              ),
            ),
          ),
          tail: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (_) {
                  controller.switchPswDisplay(false);
                },
                onTapUp: (_) {
                  controller.switchPswDisplay(true);
                },
                onTapCancel: () {
                  controller.switchPswDisplay(true);
                },
                onDoubleTap: () async {
                  controller.switchPswDisplay(false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  height: 40,
                  child: const Center(
                    child: Text(
                      '查看',
                      style: AppTextStyle.textButtonBlue,
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    Clipboard.setData(ClipboardData(
                        text: controller.curPsw?.getText() ?? ''));
                    Toast.show('已复制，10秒内有效！');
                    await Future.delayed(const Duration(seconds: 10));
                    Clipboard.setData(const ClipboardData(text: ''));
                  },
                  child: copyButton),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          '地址',
          style: AppTextStyle.textEntityItemTitle,
        ),
        TextHeadTailWrapper(
          textField: TextField(
            controller: controller.urlEditController,
            enabled: hasExternalStoragePermission.value ||
                !controller.keyFile.externalStore.value,
            onTapOutside: (_) => hideKeyboard(context),
            style: AppTextStyle.textPrimary,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(right: 50),
            ),
          ),
          tail: buildCopyButton(controller.urlEditController.text),
        ),
      ],
    );
  }
}
