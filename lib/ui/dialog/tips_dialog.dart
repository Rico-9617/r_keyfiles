import 'package:flutter/material.dart';
import 'package:r_backup_tool/styles.dart';

class TipsDialog extends StatelessWidget {
  final String tips;
  final List<Widget> actions;

  const TipsDialog({super.key, required this.tips, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tips,
            style: AppTextStyle.textPrimary.copyWith(fontSize: 18),
          ),
          const SizedBox(
            height: 8,
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
