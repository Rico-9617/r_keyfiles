import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle textWhite =
      TextStyle(color: AppColors.textTitle, fontSize: 14);
  static const TextStyle textButtonBlue =
      TextStyle(color: AppColors.textClick, fontSize: 12);
  static const TextStyle textEntityTitle = TextStyle(
      color: AppColors.text0, fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle textEntityItemTitle = TextStyle(
      color: AppColors.text0, fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle textPrimary =
      TextStyle(color: AppColors.text0, fontSize: 14);
  static const TextStyle textDisable =
      TextStyle(color: AppColors.textDisable, fontSize: 12);
}
