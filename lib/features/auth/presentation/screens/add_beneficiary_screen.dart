import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_summary_screen.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  final String bankName;
  final String bankAsset;
  final String mode; // 'transfer' or 'request'
  const AddBeneficiaryScreen({
    super.key,
    required this.bankName,
    required this.bankAsset,
    this.mode = 'transfer',
  });
  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  int _tab = 0; // 0 account, 1 IBAN
  final TextEditingController _account = TextEditingController();
  final TextEditingController _iban = TextEditingController();

  @override
  void dispose() {
    _account.dispose();
    _iban.dispose();
    super.dispose();
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
          'Add New Beneficiary',
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
            _BankTile(title: widget.bankName, asset: widget.bankAsset),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _TabChip(
                    selected: _tab == 0,
                    text: 'Account Number',
                    onTap: () => setState(() => _tab = 0),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _TabChip(
                    selected: _tab == 1,
                    text: 'IBAN',
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              _tab == 0 ? 'Account Number' : 'IBAN',
              style: AppTextStyles.bodyMediumBold,
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _tab == 0 ? _account : _iban,
              keyboardType: TextInputType.number,
              inputFormatters:
                  _tab == 0
                      ? <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                      ]
                      : null,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _tab == 0 ? 'Enter 14-digit account' : 'Enter IBAN',
                suffixIcon: const Icon(Icons.help_outline, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Fetch Account Details',
              enabled:
                  _tab == 0
                      ? _account.text.trim().length == 14
                      : _iban.text.trim().isNotEmpty,
              onPressed: () {
                final id = _tab == 0 ? _account.text : _iban.text;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => PaymentSummaryScreen(
                          bankName: widget.bankName,
                          identifier: id,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback onTap;
  const _TabChip({
    required this.selected,
    required this.text,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.iconColor : Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.iconColor),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected ? Colors.white : AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  final String title;
  final String asset;
  const _BankTile({required this.title, required this.asset});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.w,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: AssetImage(asset),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(title, style: AppTextStyles.bodyMediumBold)),
        ],
      ),
    );
  }
}
