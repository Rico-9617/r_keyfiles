import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/styles.dart';

class TipsDialog extends StatelessWidget {
  final String tips;
  final List<Widget> actions;

  const TipsDialog({super.key, required this.tips, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.dialogContentBackground,
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tips,
            style: AppTextStyle.textPrimary
                .copyWith(fontSize: AppTextStyle.text_title),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions,
          )
        ],
      ),
    );
  }
}
