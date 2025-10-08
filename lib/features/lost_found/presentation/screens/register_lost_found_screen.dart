import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:park_chatapp/features/lost_found/presentation/screens/lost_found_screen.dart';

class RegisterLostFoundScreen extends StatefulWidget {
  const RegisterLostFoundScreen({super.key});

  @override
  State<RegisterLostFoundScreen> createState() =>
      _RegisterLostFoundScreenState();
}

class _RegisterLostFoundScreenState extends State<RegisterLostFoundScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  LostFoundType _selectedType = LostFoundType.lost;
  String _selectedCategory = 'Other';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Documents',
    'Jewelry',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
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
          'Report Item',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.iconColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report a Lost or Found Item',
                  style: AppTextStyles.headlineMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Help others by reporting lost or found items in your community.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 24.h),

                // Type Selection
                Text('Type', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        'Lost',
                        LostFoundType.lost,
                        Icons.search_off,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTypeOption(
                        'Found',
                        LostFoundType.found,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Title
                Text('Title *', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Brief description of the item',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Description
                Text('Description', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Detailed description of the item',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Location
                Text('Location', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Where was it lost/found?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Category
                Text('Category', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items:
                      _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'Other';
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // Contact Information
                Text(
                  'Contact Information',
                  style: AppTextStyles.bodyMediumBold,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Optional - for others to contact you',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _contactNameController,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              'Submit Report',
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    LostFoundType type,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 32.r),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitItem() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit an item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final itemId = DateTime.now().millisecondsSinceEpoch.toString();
      final itemData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _selectedType == LostFoundType.lost ? 'Lost' : 'Found',
        'category': _selectedCategory,
        'contactName': _contactNameController.text.trim(),
        'contactPhone': _contactPhoneController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'userId': user.uid,
      };

      await FirebaseDatabase.instance
          .ref('lost_found/${user.uid}/$itemId')
          .set(itemData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item reported successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting item: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
