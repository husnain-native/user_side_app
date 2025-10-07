import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_method_selection_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/transfer_amount_screen.dart';

class UtilityBillSummaryScreen extends StatefulWidget {
  final String reference;
  final String? billType;
  const UtilityBillSummaryScreen({
    super.key,
    required this.reference,
    this.billType,
  });

  @override
  State<UtilityBillSummaryScreen> createState() =>
      _UtilityBillSummaryScreenState();
}

class _UtilityBillSummaryScreenState extends State<UtilityBillSummaryScreen> {
  late List<_Bill> history;
  late _Bill due;

  @override
  void initState() {
    super.initState();
    history = [
      _Bill(
        provider: 'KE',
        account: '0400006584203',
        date: '05 Sep 2025',
        amount: 5400,
        status: 'Paid',
      ),
      _Bill(
        provider: 'PTCL',
        account: '2100384711',
        date: '05 Aug 2025',
        amount: 5200,
        status: 'Paid',
      ),
    ];
    due = _Bill(
      provider: 'PARK',
      account: '0400006584197',
      date: '05 Oct 2025',
      amount: 5600,
      status: 'Due',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalPaid = history.fold(0.0, (s, b) => s + b.amount);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Utility Bill Details',
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
            _ReferenceCard(
              reference: widget.reference,
              billType: widget.billType,
            ),
            SizedBox(height: 16.h),
            _DueCard(bill: due),
            SizedBox(height: 12.h),
            _BillDetailsCard(
              bill: due,
              reference: widget.reference,
              billType: widget.billType ?? 'Utility Bill',
              onViewBill: () => _showBillImage(context, widget.billType),
              onPay: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => PaymentMethodSelectionScreen(
                          billType: widget.billType ?? 'Utility Bill',
                          reference: widget.reference,
                          amount: due.amount,
                          billingCompany: due.provider,
                          onConfirmed: (method) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => TransferAmountScreen(
                                      fromName: 'HUSNAIN ARIF',
                                      fromAccount: '584648495855',
                                      balance: 234796.61,
                                      toName: due.provider,
                                      toAccount: due.account,
                                      lastSummary: '—',
                                      transferLimit: 3000000,
                                      flow: 'utility',
                                      billType:
                                          widget.billType ?? 'Utility Bill',
                                      billReference: widget.reference,
                                      billDate: due.date,
                                      billAmount: due.amount,
                                      paymentMethodName: method.name,
                                      paymentMethodLogoAsset: method.icon,
                                    ),
                              ),
                            );
                          },
                        ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            Text('Previous Bills', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            ...history.map((b) => _HistoryTile(bill: b)).toList(),
            SizedBox(height: 32.h),
            Text(
              'Total Paid: PKR ${totalPaid.toStringAsFixed(0)}',
              style: AppTextStyles.bodyMediumBold,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final String reference;
  final String? billType;
  const _ReferenceCard({required this.reference, this.billType});
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
            child: Icon(Icons.receipt, color: AppColors.primaryRed),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billType ?? 'Reference Number',
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
  final _Bill bill;
  const _DueCard({required this.bill});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.indigo.shade400],
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
                  'PKR ${bill.amount.toStringAsFixed(0)} due on ${bill.date}',
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

class _BillDetailsCard extends StatelessWidget {
  final _Bill bill;
  final String reference;
  final String billType;
  final VoidCallback onViewBill;
  final VoidCallback? onPay;
  const _BillDetailsCard({
    required this.bill,
    required this.reference,
    required this.billType,
    required this.onViewBill,
    this.onPay,
  });
  @override
  Widget build(BuildContext context) {
    final double beforeDue = bill.amount;
    final double afterDue = bill.amount * 1.05; // mock late fee 5%
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.iconColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Bill Details',
                  style: AppTextStyles.bodyMediumBold,
                ),
              ),
              TextButton.icon(
                onPressed: onViewBill,
                icon: const Icon(Icons.image_outlined),
                label: const Text('View Bill'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _row('Bill Type', billType),
          _row('Reference Number', reference),
          _row('Billing Date', bill.date),
          _row('Before Due Date', 'PKR ${beforeDue.toStringAsFixed(0)}'),
          _row('After Due Date', 'PKR ${afterDue.toStringAsFixed(0)}'),
          _row('Status', bill.status),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 26.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(255, 14, 92, 4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                onPressed: onPay,
                icon: Icon(Icons.payments_outlined, size: 16.sp),
                label: const Text('Pay Bill'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w,
            child: Text(
              k,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
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

void _showBillImage(BuildContext context, String? billType) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Bill Image',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, __) {
      return Opacity(
        opacity: anim.value,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 100.h),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 29, 27, 27),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color.fromARGB(255, 15, 16, 17),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/electricity_bill.png', // placeholder for electricity bill image
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 4.w,
                    top: 4.h,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _HistoryTile extends StatelessWidget {
  final _Bill bill;
  const _HistoryTile({required this.bill});
  @override
  Widget build(BuildContext context) {
    final String asset = _providerLogo(bill.provider);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12.r),
      //   border: Border.all(color:  Color(0xFFE5E7EB)),
      // ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: Image.asset(
              asset,
              width: 42.w,
              height: 52.h,
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
                        bill.title,
                        style: AppTextStyles.bodyMediumBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${bill.provider} - ${bill.account}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bill.status == 'Paid'
                            ? 'Last Paid Rs ${bill.amount.toStringAsFixed(0)} ${bill.date}'
                            : 'Last Paid —',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      bill.status == 'Paid'
                          ? 'PAID'
                          : 'Due Rs ${bill.amount.toStringAsFixed(0)} ${bill.date}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color:
                            bill.status == 'Paid'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Divider(color: AppColors.grey, height: 5.h, thickness: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _providerLogo(String provider) {
    final Map<String, String> candidates = {
      'KE': 'assets/images/KE.png',
      'PTCL': 'assets/images/ptcl.jpeg',
      'PARK': 'assets/images/logo2.png',
      'PWASA': 'assets/images/logo2.png',
    };
    return candidates[provider] ?? 'assets/images/logo2.png';
  }
}

class _Bill {
  final String provider;
  final String account;
  final String date;
  final double amount;
  final String status;
  final String title;
  _Bill({
    required this.provider,
    required this.account,
    required this.date,
    required this.amount,
    required this.status,
    String? title,
  }) : title = title ?? provider;
}
