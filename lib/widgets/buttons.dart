import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_backup_tool/main.dart';

import '../styles.dart';

Widget buildCopyButton(String data) => TextButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: data));
        Toast.show('已复制');
      },
      child: copyButton,
    );

const copyButton = Text(
  '复制',
  style: AppTextStyle.textButtonBlue,
);
