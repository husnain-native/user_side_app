import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_method_selection_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/education_fee_summary_screen.dart';

class EducationReferenceScreen extends StatefulWidget {
  final String institutionName;
  const EducationReferenceScreen({super.key, required this.institutionName});

  @override
  State<EducationReferenceScreen> createState() =>
      _EducationReferenceScreenState();
}

class _EducationReferenceScreenState extends State<EducationReferenceScreen> {
  final TextEditingController _rollController = TextEditingController();
  // amount will be decided later; only roll no here

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String roll = _rollController.text.trim();
    final bool valid = roll.length >= 6; // amount removed per new flow
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Education Fee',
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
            Text(widget.institutionName, style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 12.h),
            Text(
              'Student Roll No',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
            ),
            SizedBox(height: 6.h),
            _input(_rollController, hint: 'Enter Roll No'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: valid ? _proceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c, {
    String hint = '',
    bool number = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  void _proceed() {
    final roll = _rollController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PaymentMethodSelectionScreen(
              billType: 'Education Fee',
              reference: roll,
              amount: 0, // amount determined later on summary
              billingCompany: widget.institutionName,
              onConfirmed: (method) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => EducationFeeSummaryScreen(
                          institutionName: widget.institutionName,
                          rollNo: roll,
                          amount:
                              45000, // example amount; replace with API if available
                          paymentMethodName: method.name,
                          paymentMethodLogo: method.icon,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
