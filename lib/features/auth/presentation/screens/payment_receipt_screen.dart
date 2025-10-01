import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

// Public API: show the receipt as a modal dialog
Future<void> showPaymentReceiptDialog(
  BuildContext context, {
  required String title,
  required String receiptId,
  required DateTime dateTime,
  required double amount,
  required String fromAccount,
  required String fromTitle,
  required String billingCompany,
  required String consumerNumber,
  String? stampAsset,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Payment Receipt',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: curved.value,
        child: Opacity(
          opacity: anim.value,
          child: Center(
            child: PaymentReceiptCard(
              title: title,
              receiptId: receiptId,
              dateTime: dateTime,
              amount: amount,
              fromAccount: fromAccount,
              fromTitle: fromTitle,
              billingCompany: billingCompany,
              consumerNumber: consumerNumber,
              stampAsset: stampAsset,
            ),
          ),
        ),
      );
    },
  );
}

class PaymentReceiptCard extends StatelessWidget {
  final String title; // e.g., Utility Bill, Possession, Installment
  final String receiptId;
  final DateTime dateTime;
  final double amount;
  final String fromAccount;
  final String fromTitle;
  final String billingCompany;
  final String consumerNumber; // or reference
  final String? stampAsset; // optional override

  const PaymentReceiptCard({
    super.key,
    required this.title,
    required this.receiptId,
    required this.dateTime,
    required this.amount,
    required this.fromAccount,
    required this.fromTitle,
    required this.billingCompany,
    required this.consumerNumber,
    this.stampAsset,
  });

  String _formatCurrency(double v) {
    final format = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
    return format.format(v);
  }

  @override
  Widget build(BuildContext context) {
    final String stamp = stampAsset ?? 'assets/images/paid.webp';
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 150.h),
        constraints: BoxConstraints(maxWidth: 520.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            // Centered PAID stamp
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Image.asset(
                        stamp,
                        width: 220.w,
                        height: 220.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content in one column; actions pinned to the bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(title, style: AppTextStyles.bodyMediumBold),
                    ),
                                Positioned(
              left: 4.w,
              top: 4.h,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
                  ],
                ),
                SizedBox(height: 70.h),
                _kv('Receipt ID', receiptId),

                _kv(
                  'Transaction Date & Time',
                  DateFormat('M/d/yyyy hh:mm a').format(dateTime),
                ),
                _kv('Transaction Amount', _formatCurrency(amount)),
                _kv('From', fromAccount),
                _kv('Account Title', fromTitle),
                _kv('Billing Company Name', billingCompany),
                _kv('Consumer Number', consumerNumber),
                SizedBox(height: 28.h),
                const Divider(height: 1),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.iconColor,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadiusGeometry.circular(5.r),
                          //   side: const BorderSide(color: AppColors.iconColor),
                          // ),
                         
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share receipt coming soon'),
                            ),
                          );
                        },
                        icon:  Icon(Icons.share, size: 18.sp,),
                        label:  Text('Share',style: TextStyle(fontSize: 14.sp),),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.iconColor,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadiusGeometry.circular(5.r),
                          
                          //   side: const BorderSide(color: AppColors.iconColor),
                          // ),
                         
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt saved to device (mock)'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.save_alt,
                          size: 18,
                          color: AppColors.iconColor,
                        ),
                        label: Text(
                          'Save Receipt',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Close button (top-left X)

          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.w,
            child: Text(
              k,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[800], fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
