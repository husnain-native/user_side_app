import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/possession_charges_summary_screen.dart';

class PossessionChargesReferenceScreen extends StatefulWidget {
  const PossessionChargesReferenceScreen({super.key});

  @override
  State<PossessionChargesReferenceScreen> createState() =>
      _PossessionChargesReferenceScreenState();
}

class _PossessionChargesReferenceScreenState
    extends State<PossessionChargesReferenceScreen> {
  final TextEditingController _refController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String ref = _refController.text.trim();
    final bool valid = RegExp(r'^\d{13}$').hasMatch(ref);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Possession Charges',
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
            _TopInfoCard(),
            SizedBox(height: 16.h),
            Text('Enter Reference Number', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              child: TextField(
                controller: _refController,
                keyboardType: TextInputType.number,
                maxLength: 13,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Possession Ref (13 digits)',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Reference must be 13 digits',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          valid
              ? SafeArea(
                minimum: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                child: CustomButton(
                  text: 'Next',
                  onPressed: _proceed,
                  isLoading: false,
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  void _proceed() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PossessionChargesSummaryScreen(
              reference: _refController.text.trim(),
            ),
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.assignment_turned_in_outlined,
              color: AppColors.iconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HUSNAIN ARIF', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  'Plot: 23-A Sector B',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
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
