import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';

class TransferAmountScreen extends StatefulWidget {
  final String fromName;
  final String fromAccount;
  final double balance;
  final String toName;
  final String toAccount;
  final String lastSummary; // e.g., "Last: PKR 1,330 | 26 Sep 2025"
  final double transferLimit;

  const TransferAmountScreen({
    super.key,
    required this.fromName,
    required this.fromAccount,
    required this.balance,
    required this.toName,
    required this.toAccount,
    required this.lastSummary,
    required this.transferLimit,
  });

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _purpose = 'Others';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isValidAmount {
    final value = double.tryParse(_amountController.text.trim());
    return value != null && value > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A), // purple like screenshot
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Amount',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.home_outlined, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FromAccountCard(
              name: widget.fromName,
              account: widget.fromAccount,
              balance: widget.balance,
            ),
            SizedBox(height: 16.h),
            Text(
              'Transfer to',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            _ToAccountCard(
              name: widget.toName,
              account: widget.toAccount,
              lastSummary: widget.lastSummary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Enter Amount',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            _AmountField(controller: _amountController),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Acc Bal: PKR ${widget.balance.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ),
                Text(
                  'Transfer Limit:PKR ${_format(widget.transferLimit)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              'Purpose of Transfer',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            _PurposeDropdown(
              value: _purpose,
              onChanged: (v) => setState(() => _purpose = v ?? 'Others'),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        child: CustomButton(
          text: 'Next',
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim()) ?? 0;
            if (amount <= 0) return;
            Navigator.of(context).pop({'amount': amount, 'purpose': _purpose});
          },
          enabled: _isValidAmount,
        ),
      ),
    );
  }

  String _format(double v) {
    return v.toStringAsFixed(0);
  }
}

class _FromAccountCard extends StatelessWidget {
  final String name;
  final String account;
  final double balance;
  const _FromAccountCard({
    required this.name,
    required this.account,
    required this.balance,
  });
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
          CircleAvatar(
            radius: 22.w / 2,
            backgroundColor: const Color(0xFFEDE7F6),
            child: const Icon(Icons.account_balance, color: Color(0xFF6A1B9A)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  account,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Balance: ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'PKR ${balance.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: Colors.purple),
        ],
      ),
    );
  }
}

class _ToAccountCard extends StatelessWidget {
  final String name;
  final String account;
  final String lastSummary;
  const _ToAccountCard({
    required this.name,
    required this.account,
    required this.lastSummary,
  });
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
          CircleAvatar(
            radius: 22.w / 2,
            backgroundColor: const Color(0xFFE0F2F1),
            child: const Icon(
              Icons.currency_exchange,
              color: Color(0xFF26A69A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  account,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  lastSummary,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more, color: Colors.grey),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFB39DDB)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Text(
            'PKR',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[800]),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurposeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _PurposeDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.white,
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Others', child: Text('Others')),
            DropdownMenuItem(value: 'Monthly Installment', child: Text('Monthly Installment')),
            DropdownMenuItem(value: 'Yearly Installment', child: Text('Yearly Installment')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
