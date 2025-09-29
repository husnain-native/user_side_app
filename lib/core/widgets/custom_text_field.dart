import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.grey, width: 0.1),
        ),
        filled: true,
        fillColor: AppColors.fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.grey, width: 0.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 0.1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        prefixIconColor: AppColors.primaryRed.withOpacity(0.6),
        suffixIconColor: AppColors.primaryRed.withOpacity(0.6),
      ),
    );
  }
}
