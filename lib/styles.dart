import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle textWhite =
      TextStyle(color: AppColors.textTitle, fontSize: text_normal);
  static const TextStyle textButtonBlue =
      TextStyle(color: AppColors.textClick, fontSize: text_operation);
  static const TextStyle textItemTitle = TextStyle(
      color: AppColors.textTitle,
      fontSize: text_title,
      fontWeight: FontWeight.w500);
  static const TextStyle textEntityItemTitle = TextStyle(
      color: AppColors.text0,
      fontSize: text_list_title,
      fontWeight: FontWeight.w500);
  static const TextStyle textPrimary =
      TextStyle(color: AppColors.text0, fontSize: text_normal);
  static const TextStyle textDisable =
      TextStyle(color: AppColors.textDisable, fontSize: text_operation);

  static const double text_title = 20;
  static const double text_operation = 14;
  static const double text_tab = 16;
  static const double text_tab_selected = 18;
  static const double text_normal = 16;
  static const double text_list_title = 18;
}
