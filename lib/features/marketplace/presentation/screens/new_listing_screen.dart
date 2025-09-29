import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';

class NewListingScreen extends StatefulWidget {
  const NewListingScreen({super.key});

  @override
  State<NewListingScreen> createState() => _NewListingScreenState();
}

class _NewListingScreenState extends State<NewListingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _sellerNameCtrl = TextEditingController(
    text: 'You',
  );
  final TextEditingController _sellerIdCtrl = TextEditingController(
    text: 'current_user',
  );
  final TextEditingController _imageUrlCtrl = TextEditingController();

  final List<String> _imageUrls = <String>[];
  bool _negotiable = false;
  ListingCategory _selectedCategory = ListingCategory.other;
  ListingCondition _selectedCondition = ListingCondition.used;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _sellerNameCtrl.dispose();
    _sellerIdCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'New Listing',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (Rs)',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final double? p = double.tryParse(
                          v.replaceAll(',', ''),
                        );
                        if (p == null || p < 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Row(
                    children: [
                      const Text('Negotiable'),
                      Switch(
                        value: _negotiable,
                        activeColor: AppColors.primaryRed,
                        onChanged: (val) => setState(() => _negotiable = val),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                items:
                    ListingCategory.values
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.label)),
                        )
                        .toList(),
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged:
                    (v) => setState(
                      () => _selectedCategory = v ?? _selectedCategory,
                    ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<ListingCondition>(
                value: _selectedCondition,
                items:
                    ListingCondition.values
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.label)),
                        )
                        .toList(),
                decoration: const InputDecoration(labelText: 'Condition'),
                onChanged:
                    (v) => setState(
                      () => _selectedCondition = v ?? _selectedCondition,
                    ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _addImageUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (_imageUrls.isNotEmpty)
                SizedBox(
                  height: 90.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => _imagePreview(_imageUrls[i], i),
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemCount: _imageUrls.length,
                  ),
                ),
              SizedBox(height: 16.h),
              Text('Seller Info', style: AppTextStyles.bodyMediumBold),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _sellerNameCtrl,
                decoration: const InputDecoration(labelText: 'Seller Name'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _sellerIdCtrl,
                decoration: const InputDecoration(labelText: 'Seller ID'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePreview(String url, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 90.h,
            width: 120.w,
            color: Colors.grey.shade200,
            child: _previewImage(url),
          ),
        ),
        Positioned(
          right: 4.w,
          top: 4.h,
          child: InkWell(
            onTap: () => setState(() => _imageUrls.removeAt(index)),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16.r),
            ),
          ),
        ),
      ],
    );
  }

  void _addImageUrl() {
    final String url = _imageUrlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _imageUrls.add(url);
      _imageUrlCtrl.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final double price = double.parse(_priceCtrl.text.replaceAll(',', ''));
    final Listing listing = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      price: price,
      negotiable: _negotiable,
      category: _selectedCategory,
      condition: _selectedCondition,
      imageUrls: List<String>.from(_imageUrls),
      sellerName: _sellerNameCtrl.text.trim(),
      sellerId: _sellerIdCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      createdAt: DateTime.now(),
      status: ListingStatus.active,
    );
    Navigator.pop(context, listing);
  }

  Widget _previewImage(String path) {
    final bool isAsset = path.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
      );
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
    );
  }
}
