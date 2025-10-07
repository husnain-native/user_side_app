import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_receipt_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EducationFeeSummaryScreen extends StatelessWidget {
  final String institutionName;
  final String rollNo;
  final double amount;
  final String paymentMethodName;
  final String paymentMethodLogo;
  const EducationFeeSummaryScreen({
    super.key,
    required this.institutionName,
    required this.rollNo,
    required this.amount,
    required this.paymentMethodName,
    required this.paymentMethodLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Education Summary',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Institution', institutionName),
            _row('Roll No', rollNo),
            _row('Amount', 'PKR ${amount.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            _method(),
            const Spacer(),
            CustomButton(
              text: 'Proceed to Pay',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => Center(
                        child: SizedBox(
                          width: 80.w,
                          height: 60.w,
                          child: const SpinKitWave(
                            color: AppColors.iconColor,
                            size: 40,
                          ),
                        ),
                      ),
                );
                Future.delayed(const Duration(seconds: 2), () async {
                  final rootNav = Navigator.of(context, rootNavigator: true);
                  if (rootNav.canPop()) rootNav.pop();
                  await showPaymentReceiptDialog(
                    context,
                    title: 'Education Fee',
                    receiptId: 'RCPT-${DateTime.now().millisecondsSinceEpoch}',
                    dateTime: DateTime.now(),
                    amount: amount,
                    fromAccount: '584648495855',
                    fromTitle: 'HUSNAIN ARIF',
                    billingCompany: institutionName,
                    consumerNumber: rollNo,
                    stampAsset: 'assets/images/paid.webp',
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              k,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(child: Text(v, style: AppTextStyles.bodyMediumBold)),
        ],
      ),
    );
  }

  Widget _method() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.asset(paymentMethodLogo, fit: BoxFit.contain),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(paymentMethodName, style: AppTextStyles.bodyMediumBold),
          ),
          Text(
            'PKR ${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMediumBold,
          ),
        ],
      ),
    );
  }
}
