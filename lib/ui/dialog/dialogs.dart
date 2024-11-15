import 'package:flutter/material.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/utils/native_tool.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';

import 'tips_dialog.dart';

showStoragePermissionDialog(BuildContext context) {
  showCenterDialog(context, builder: (_, __, ___, ____) {
    return TipsDialog(tips: '需要文件管理权限以创建导出文件，请先授予应用文件管理权限。', actions: [
      TextButton(
        child: const Text(
          '取消',
          style: AppTextStyle.textButtonBlue,
        ),
        onPressed: () {
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
          requestStoragePermission();
        },
      ),
    ]);
  });
}
