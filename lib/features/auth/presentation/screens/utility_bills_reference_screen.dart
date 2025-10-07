import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/utility_bills_summary_screen.dart';

class UtilityBillReferenceScreen extends StatefulWidget {
  final String billType;
  final IconData? icon;
  final Color? color;
  final String? logoPath;
  const UtilityBillReferenceScreen({
    super.key,
    this.billType = 'Utility Bills',
    this.icon,
    this.color,
    this.logoPath,
  });

  @override
  State<UtilityBillReferenceScreen> createState() =>
      _UtilityBillReferenceScreenState();
}

class _UtilityBillReferenceScreenState
    extends State<UtilityBillReferenceScreen> {
  final TextEditingController _refController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String ref = _refController.text.trim();

    // Extract company name from billType (format: "Company Name - Bill Type")
    final String companyName =
        widget.billType.contains(' - ')
            ? widget.billType.split(' - ')[0]
            : widget.billType;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.billType,
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
            _TopInfoCard(
              title: companyName,
              icon: widget.icon,
              color: widget.color,
              logoPath: widget.logoPath,
            ),
            SizedBox(height: 16.h),
            Text(companyName, style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
                border: Border.all(
                  color: const Color.fromARGB(255, 238, 239, 240),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              child: TextField(
                controller: _refController,
                keyboardType: TextInputType.number,
                maxLength: 13,
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Enter Consumer ID',
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
          RegExp(r'^\d{13}$').hasMatch(ref)
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
            (_) => UtilityBillSummaryScreen(
              reference: _refController.text.trim(),
              billType: widget.billType,
            ),
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? color;
  final String? logoPath;
  const _TopInfoCard({this.title, this.icon, this.color, this.logoPath});
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
              color: (color ?? AppColors.iconColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                (logoPath != null && (logoPath ?? '').isNotEmpty)
                    ? ClipOval(
                      child: Image.asset(
                        logoPath!,
                        width: 44.w,
                        height: 44.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon ?? Icons.receipt_long,
                            color: color ?? AppColors.iconColor,
                          );
                        },
                      ),
                    )
                    : Icon(
                      icon ?? Icons.receipt_long,
                      color: color ?? AppColors.iconColor,
                    ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'HUSNAIN ARIF',
                  style: AppTextStyles.bodyMediumBold,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Account: 584648495855',
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
