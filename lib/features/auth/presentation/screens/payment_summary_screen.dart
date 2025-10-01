import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/transfer_amount_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_receipt_screen.dart';

class PaymentSummaryScreen extends StatelessWidget {
  final String bankName;
  final String identifier; // account or IBAN
  final String mode; // 'transfer' or 'request'
  const PaymentSummaryScreen({
    super.key,
    required this.bankName,
    required this.identifier,
    this.mode = 'transfer',
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
          'Payment Summary',
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
            _SummaryRow(label: 'Bank', value: bankName),
            _SummaryRow(label: 'Beneficiary', value: 'John Doe'),
            _SummaryRow(label: 'Account/IBAN', value: identifier),
            _SummaryRow(label: 'Amount', value: 'PKR 0.00 (enter next)'),
            const Spacer(),
            CustomButton(
              text:
                  mode == 'request'
                      ? 'Proceed to Request'
                      : 'Proceed to Amount',
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).push<Map<String, dynamic>>(
                  MaterialPageRoute(
                    builder:
                        (_) => TransferAmountScreen(
                          fromName: 'HUSNAIN ARIF',
                          fromAccount: '584648495855',
                          balance: 234796.61,
                          toName: 'John Doe',
                          toAccount: identifier,
                          lastSummary: '—',
                          transferLimit: 3000000,
                          flow: mode,
                        ),
                  ),
                );
                final amount = (result ?? const {})['amount'] as double?;
                if (amount != null && amount > 0) {
                  // show receipt modal
                  await showPaymentReceiptDialog(
                    context,
                    title:
                        mode == 'request'
                            ? 'Money Received'
                            : 'Payment Receipt',
                    receiptId: DateTime.now().millisecondsSinceEpoch.toString(),
                    dateTime: DateTime.now(),
                    amount: amount,
                    fromAccount: '584648495855',
                    fromTitle: 'HUSNAIN ARIF',
                    billingCompany: bankName,
                    consumerNumber: identifier,
                    stampAsset: 'assets/images/paid.webp',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 160.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMediumBold)),
        ],
      ),
    );
  }
}
