import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  State<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Maintenance';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Maintenance',
    'Cleanliness',
    'Security',
    'Noise',
    'Parking',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
          'Register Complaint',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.iconColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              SizedBox(height: 12.h),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labeledField(
                        label: 'Title',
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.title_outlined),
                            hintText: 'Brief description of the issue',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 12.h),
                      // _labeledField(
                      //   label: 'Category',
                      //   child: Wrap(
                      //     spacing: 8.w,
                      //     runSpacing: 6.h,
                      //     children:
                      //         _categories
                      //             .map(
                      //               (c) => ChoiceChip(
                      //                 label: Text(c),
                      //                 selected: _selectedCategory == c,
                      //                 onSelected:
                      //                     (_) => setState(
                      //                       () => _selectedCategory = c,
                      //                     ),
                      //               ),
                      //             )
                      //             .toList(),
                      //   ),
                      // ),
                      // SizedBox(height: 12.h),
                      // _labeledField(
                      //   label: 'Priority',
                        
                      //   child: Wrap(
                          
                      //     spacing: 8.w,
                      //     runSpacing: 6.h,
                      //     children:
                      //         _priorities
                      //             .map(
                      //               (p) => ChoiceChip(
                      //                 label: Text(p),
                      //                 selected: _selectedPriority == p,
                      //                 onSelected:
                      //                     (_) => setState(
                      //                       () => _selectedPriority = p,
                      //                     ),
                      //               ),
                      //             )
                      //             .toList(),
                      //   ),
                      // ),
                      SizedBox(height: 12.h),
                      _labeledField(
                        label: 'Description',
                        helper:
                            'Please provide detailed information so we can resolve it faster.',
                        child: TextField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 8,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(Icons.description_outlined),
                            hintText: 'Describe the problem clearly',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    _isSubmitting ? 'Submitting...' : 'Submit Complaint',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: AppColors.primaryRed),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Please ensure the details are accurate. Our team will review and update the status.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledField({
    required String label,
    String? helper,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMediumBold),
        if (helper != null) ...[
          SizedBox(height: 2.h),
          Text(
            helper,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
          ),
        ],
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  void _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a complaint')),
      );
      return;
    }

    final complaintData = {
      'title': _titleController.text.trim(),
      'category': _selectedCategory,
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority,
      'userId': user.uid,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'Pending',
    };

    try {
      final complaintRef =
          FirebaseDatabase.instance.ref('complaints/${user.uid}').push();
      await complaintRef.set(complaintData);

      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = 'Maintenance';
        _selectedPriority = 'Medium';
      });
      Navigator.pop(context, complaintData);
      _showSuccessModal(
        context,
        'Complaint Registered Successfully',
        'Your complaint has been submitted and is now under review.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit complaint: $e')));
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
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 25.r,
                    color: AppColors.primaryRed,
                  ),
                ),
                SizedBox(height: 13.h),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
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
