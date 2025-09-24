import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              if (_imageUrls.isNotEmpty)
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => _imagePreview(_imageUrls[i], i),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _imageUrls.length,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Seller Info', style: AppTextStyles.bodyMediumBold),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sellerNameCtrl,
                decoration: const InputDecoration(labelText: 'Seller Name'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerIdCtrl,
                decoration: const InputDecoration(labelText: 'Seller ID'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 90,
            width: 120,
            color: Colors.grey.shade200,
            child: _previewImage(url),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: InkWell(
            onTap: () => setState(() => _imageUrls.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
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