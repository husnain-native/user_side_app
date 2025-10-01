import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/transfer_amount_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_receipt_screen.dart';

class PossessionChargesSummaryScreen extends StatefulWidget {
  final String reference;
  const PossessionChargesSummaryScreen({super.key, required this.reference});

  @override
  State<PossessionChargesSummaryScreen> createState() =>
      _PossessionChargesSummaryScreenState();
}

class _PossessionChargesSummaryScreenState
    extends State<PossessionChargesSummaryScreen> {
  late _Charge due;
  late List<_Charge> history;

  @override
  void initState() {
    super.initState();
    history = [
      _Charge(
        title: 'Possession Booking',
        date: '10 Aug 2025',
        amount: 75000,
        status: 'Paid',
      ),
    ];
    due = _Charge(
      title: 'Final Possession Charges',
      date: '10 Oct 2025',
      amount: 125000,
      status: 'Due',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Possession Details',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.iconColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReferenceCard(reference: widget.reference),
            SizedBox(height: 16.h),
            _DueCard(charge: due),
            SizedBox(height: 12.h),
            _PayAction(
              charge: due,
              onPaid: (double amount) {
                setState(() {
                  history.add(
                    _Charge(
                      title: due.title,
                      date: due.date,
                      amount: amount,
                      status: 'Paid',
                    ),
                  );
                  due = _Charge(
                    title: 'Documentation Charges',
                    date: '10 Nov 2025',
                    amount: 50000,
                    status: 'Due',
                  );
                });
                showPaymentReceiptDialog(
                  context,
                  title: 'Possession Payment Receipt',
                  receiptId: DateTime.now().millisecondsSinceEpoch.toString(),
                  dateTime: DateTime.now(),
                  amount: amount,
                  fromAccount: '584648495855',
                  fromTitle: 'HUSNAIN ARIF',
                  billingCompany: 'Park View City',
                  consumerNumber: widget.reference,
                  stampAsset: 'assets/images/paid.webp',
                );
              },
            ),
            SizedBox(height: 16.h),
            Text('Previous Charges', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            ...history.map((c) => _HistoryTile(charge: c)).toList(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final String reference;
  const _ReferenceCard({required this.reference});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.badge_outlined, color: AppColors.primaryRed),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reference Number',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(reference, style: AppTextStyles.bodyMediumBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DueCard extends StatelessWidget {
  final _Charge charge;
  const _DueCard({required this.charge});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.white),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Due',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
                SizedBox(height: 2.h),
                Text(
                  'PKR ${charge.amount.toStringAsFixed(0)} • ${charge.title} • ${charge.date}',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayAction extends StatelessWidget {
  final _Charge charge;
  final ValueChanged<double> onPaid;
  const _PayAction({required this.charge, required this.onPaid});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Charge', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  'PKR ${charge.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
                side: BorderSide(color: AppColors.iconColor, width: 1),
              ),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.iconColor,
            ),
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
                        toName: 'Park Vire City',
                        toAccount: '8975219217',
                        lastSummary: 'Last: PKR 75,000 | 10 Aug 2025',
                        transferLimit: 3000000,
                        flow: 'possession',
                      ),
                ),
              );
              final amount = (result ?? const {})['amount'] as double?;
              if (amount != null && amount > 0) {
                onPaid(amount);
              }
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _Charge charge;
  const _HistoryTile({required this.charge});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              'assets/images/logo2.png',
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        charge.title,
                        style: AppTextStyles.bodyMediumBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Park View City',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        charge.status == 'Paid'
                            ? 'PAID'
                            : 'Due Rs ${charge.amount.toStringAsFixed(0)} ${charge.date}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              charge.status == 'Paid'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      charge.status == 'Paid'
                          ? 'Last Paid Rs ${charge.amount.toStringAsFixed(0)} ${charge.date}'
                          : 'Last Paid —',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Charge {
  final String title;
  final String date;
  final double amount;
  final String status;
  _Charge({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}
