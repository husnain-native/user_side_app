import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/transfer_amount_screen.dart';

class PlotInstallmentSummaryScreen extends StatefulWidget {
  final String reference;

  const PlotInstallmentSummaryScreen({super.key, required this.reference});

  @override
  State<PlotInstallmentSummaryScreen> createState() =>
      _PlotInstallmentSummaryScreenState();
}

class _PlotInstallmentSummaryScreenState
    extends State<PlotInstallmentSummaryScreen> {
  late List<_Installment> history;
  late _Installment due;

  @override
  void initState() {
    super.initState();
    history = [
      _Installment(
        number: 1,
        date: '12 Jun 2025',
        amount: 120000,
        status: 'Paid',
      ),
      _Installment(
        number: 2,
        date: '12 Sep 2025',
        amount: 120000,
        status: 'Paid',
      ),
    ];
    due = _Installment(
      number: 3,
      date: '12 Dec 2025',
      amount: 120000,
      status: 'Due',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Plan summary (mock). Replace with API values when available
    final int totalInstallments = 6;
    final double perInstallmentAmount = 120000;
    final double totalPayable = totalInstallments * perInstallmentAmount;
    final double totalPaid = history.fold(0.0, (sum, i) => sum + i.amount);
    final double remaining = (totalPayable - totalPaid).clamp(
      0.0,
      double.infinity,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Installment Details',
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
            _TotalsRow(
              totalPayable: totalPayable,
              totalPaid: totalPaid,
              remaining: remaining,
            ),
            SizedBox(height: 16.h),
            _DueCard(inst: due),
            SizedBox(height: 12.h),
            _NextInstallmentActions(
              nextInst: due,
              onPaid: (double paidAmount) {
                setState(() {
                  history.add(
                    _Installment(
                      number: due.number,
                      date: due.date,
                      amount: paidAmount,
                      status: 'Paid',
                    ),
                  );
                  due = _Installment(
                    number: due.number + 1,
                    date: '12 Mar 2026',
                    amount: due.amount,
                    status: 'Due',
                  );
                });
              },
            ),
            SizedBox(height: 16.h),
            Text('Previous Installments', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            ...history.map((i) => _HistoryTile(inst: i)).toList(),
            SizedBox(height: 32.h),
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
            child: Icon(Icons.tag, color: AppColors.primaryRed),
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
  final _Installment inst;
  const _DueCard({required this.inst});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
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
                  'PKR ${inst.amount.toStringAsFixed(0)} due on ${inst.date}',
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

class _TotalsRow extends StatelessWidget {
  final double totalPayable;
  final double totalPaid;
  final double remaining;
  const _TotalsRow({
    required this.totalPayable,
    required this.totalPaid,
    required this.remaining,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(label: 'Total Payable', value: totalPayable),
        ),
        SizedBox(width: 10.w),
        Expanded(child: _MetricCard(label: 'Total Paid', value: totalPaid)),
        SizedBox(width: 10.w),
        Expanded(child: _MetricCard(label: 'Remaining', value: remaining)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  const _MetricCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
          ),
          SizedBox(height: 4.h),
          Text(
            'PKR ${value.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMediumBold,
          ),
        ],
      ),
    );
  }
}

class _NextInstallmentActions extends StatelessWidget {
  final _Installment nextInst;
  final ValueChanged<double> onPaid;
  const _NextInstallmentActions({required this.nextInst, required this.onPaid});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Installment', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  'PKR ${nextInst.amount.toStringAsFixed(0)} • Due ${nextInst.date}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
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
                        lastSummary: 'Last: PKR 12,000 | 12 Sep 2025',
                        transferLimit: 3000000,
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
  final _Installment inst;
  const _HistoryTile({required this.inst});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF22C55E)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Installment ${inst.number}',
                  style: AppTextStyles.bodyMediumBold,
                ),
                SizedBox(height: 2.h),
                Text(
                  inst.date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'PKR ${inst.amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMediumBold,
          ),
        ],
      ),
    );
  }
}

class _Installment {
  final int number;
  final String date;
  final double amount;
  final String status;
  _Installment({
    required this.number,
    required this.date,
    required this.amount,
    required this.status,
  });
}
