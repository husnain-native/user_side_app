import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class StatementScreen extends StatelessWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Tx> transactions = [
      _Tx(
        date: DateTime.now().subtract(const Duration(days: 0)),
        title: 'Utility Bill',
        amount: -4500.00,
        ref: 'UB-982134',
      ),
      _Tx(
        date: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Salary Credit',
        amount: 120000.00,
        ref: 'SAL-2025-09',
      ),
      _Tx(
        date: DateTime.now().subtract(const Duration(days: 3)),
        title: 'Plot Installment',
        amount: -25000.00,
        ref: 'PLT-009',
      ),
      _Tx(
        date: DateTime.now().subtract(const Duration(days: 7)),
        title: 'POS Purchase',
        amount: -3200.50,
        ref: 'POS-7HF12',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Statement',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.iconColor),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final bool isCredit = tx.amount >= 0;
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: (isCredit ? Colors.green : AppColors.primaryRed)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.south_west : Icons.north_east,
                    color: isCredit ? Colors.green : AppColors.primaryRed,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title, style: AppTextStyles.bodyMediumBold),
                      SizedBox(height: 4.h),
                      Text(
                        _formatDate(tx.date),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Ref: ${tx.ref}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatAmount(tx.amount),
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: isCredit ? Colors.green[700] : AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(double a) {
    final sign = a >= 0 ? '+' : '-';
    final v = a.abs().toStringAsFixed(2);
    return '$sign PKR $v';
  }
}

class _Tx {
  final DateTime date;
  final String title;
  final double amount;
  final String ref;

  _Tx({
    required this.date,
    required this.title,
    required this.amount,
    required this.ref,
  });
}
