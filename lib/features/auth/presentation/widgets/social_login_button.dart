import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String logoPath;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.logoPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppColors.grey),
      ),
      child: Row(
        children: [
          // Logo stays left-aligned
          Image.asset(
            logoPath,
            width: 24.w,
            height: 24.w,
          ), // Added .w for responsiveness
          // Takes all remaining space and centers text
          Expanded(
            child: Center(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.black, // Your red color
              fontWeight: FontWeight.w600
            ))),
          ),

          // Invisible spacer matching logo width + original gap (now responsive)
          SizedBox(width: 32.w), // 24.w (logo) + 8.w (gap)
        ],
      ),
    );
  }
}
