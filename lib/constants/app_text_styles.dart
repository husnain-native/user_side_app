import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static TextStyle headlineSmall = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w100,
  );
  static TextStyle headlineMedium = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w300,
  );
  static TextStyle headlineLarge = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
  );
  static TextStyle bodyMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold, // Boldness
    color: AppColors.black, // Default color
  );
  static TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle linkText = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryRed,
  );
  static TextStyle bodyMediumBold = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold, // Boldness
    color: AppColors.black, // Default color
  );
}
