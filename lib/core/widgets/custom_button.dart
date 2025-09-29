import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? AppColors.primaryRed : Colors.grey.shade400,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        elevation: 0,
      ),
      child:
          isLoading
              ? const CircularProgressIndicator(color: AppColors.white)
              : Text(text, style: AppTextStyles.button),
    );
  }
}
