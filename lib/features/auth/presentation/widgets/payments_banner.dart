import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payments_screen.dart';
import 'package:park_chatapp/core/widgets/sign_in_prompt.dart';

/// A professional payments banner for the home screen.
/// Communicates: "Pay your utility bills, plot installments and possession charges here".
class PaymentsBanner extends StatelessWidget {
  const PaymentsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!await ensureSignedIn(context)) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaymentsScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.primaryRed, width: 0.3)
          // gradient: const LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Color(0xFF1E3C72), // deep blue
          //     Color(0xFF2A5298),
          //   ],
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.12),
          //     blurRadius: 16,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryRed,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payments',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      // SizedBox(height: 2.h),
                      Text(
                        'Pay your utility bills, plot installments and possession charges here.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.black.withOpacity(0.9),
                          fontSize: 11.sp
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: const [
                _Chip(label: 'Utility Bills', icon: Icons.lightbulb_outline),
                _Chip(label: 'Plot Installments', icon: Icons.account_balance),
                _Chip(label: 'Possession Charges', icon: Icons.key_outlined),
              ],
            ),
            SizedBox(height: 14.h),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.primaryRed, width: 1)
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primaryRed,
                        size: 14.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Go to payments',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                          fontSize: 12.sp
                          
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.iconColor, size: 16.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
