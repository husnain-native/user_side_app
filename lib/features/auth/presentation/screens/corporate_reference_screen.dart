import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_method_selection_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/corporate_summary_screen.dart';

class CorporateReferenceScreen extends StatefulWidget {
  const CorporateReferenceScreen({super.key});
  @override
  State<CorporateReferenceScreen> createState() =>
      _CorporateReferenceScreenState();
}

class _CorporateReferenceScreenState extends State<CorporateReferenceScreen> {
  final TextEditingController _refController = TextEditingController();
  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = _refController.text.trim();
    final valid = ref.length >= 6;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Corporate Payment',
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
            Text('Enter Corporate Ref', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: TextField(
                controller: _refController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Reference (min 6 chars)',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
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

  void _proceed() {
    final ref = _refController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PaymentMethodSelectionScreen(
              billType: 'Corporate Payment',
              reference: ref,
              amount: 0,
              billingCompany: 'Park View City Corporate',
              onConfirmed: (method) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => CorporateSummaryScreen(
                          reference: ref,
                          amount: 100000,
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
