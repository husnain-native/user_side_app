import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double _overallRating = 3.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Submit Feedback',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.iconColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(
                    color: AppColors.primaryRed.withOpacity(0.2),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Experience',
                        style: AppTextStyles.bodyMediumBold,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Poor', style: AppTextStyles.bodySmall),
                          Expanded(
                            child: Slider(
                              value: _overallRating,
                              min: 1.0,
                              max: 5.0,
                              divisions: 4,
                              activeColor: AppColors.primaryRed,
                              onChanged:
                                  (v) => setState(() => _overallRating = v),
                            ),
                          ),
                          Text('Excellent', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${_overallRating.toInt()}/5',
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Additional Comments', style: AppTextStyles.bodyMediumBold),
              SizedBox(height: 8.h),
              Card(
                color: AppColors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(
                    color: AppColors.primaryRed.withOpacity(0.2),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: TextField(
                    controller: _feedbackController,
                    minLines: 5,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Share your suggestions or additional feedback',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  icon:
                      _isSubmitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed old multi-section rating builder; keeping only overall rating

  void _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit feedback')),
      );
      return;
    }

    final Map<String, dynamic> feedbackData = {
      'overallRating': _overallRating,
      // Include legacy fields to satisfy current DB rules validation
      'maintenanceRating': _overallRating,
      'securityRating': _overallRating,
      'cleanlinessRating': _overallRating,
      'comments': _feedbackController.text.trim(),
      'userId': user.uid,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final feedbackRef =
          FirebaseDatabase.instance.ref('feedback/${user.uid}').push();
      await feedbackRef.set(feedbackData);

      if (!mounted) return;
      _feedbackController.clear();
      setState(() {
        _overallRating = 3.0;
      });
      Navigator.pop(context, feedbackData);
      _showSuccessModal(
        context,
        'Feedback Submitted Successfully',
        'Thank you for your valuable feedback. We appreciate your input to improve our services.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit feedback: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessModal(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, AppColors.primaryRed.withOpacity(0.05)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review,
                    size: 35.r,
                    color: AppColors.primaryRed,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                    height: 1.3,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
