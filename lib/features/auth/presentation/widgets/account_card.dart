import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class AccountCard extends StatelessWidget {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String branch;
  final String balance;

  const AccountCard({
    super.key,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.branch,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank Name
            Text(
              bankName,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            SizedBox(height: 8.h),

            // Account Holder
            Text(
              accountHolder,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),

            // Balance
            Text(
              balance,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 12.h),

            // Account Number
            Text(
              'CURRENT - $accountNumber',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),

            // Branch
            Text(
              branch,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}