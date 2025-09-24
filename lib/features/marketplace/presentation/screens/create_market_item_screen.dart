import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' as convert;
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/auth_service.dart';
import 'package:park_chatapp/core/services/market_item_service.dart';
import 'package:park_chatapp/features/marketplace/domain/models/market_item.dart';

class CreateMarketItemScreen extends StatefulWidget {
  const CreateMarketItemScreen({super.key});

  @override
  State<CreateMarketItemScreen> createState() => _CreateMarketItemScreenState();
}

class _CreateMarketItemScreenState extends State<CreateMarketItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _marlaCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _bedCtrl = TextEditingController();
  final _bathCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();

  final AuthService _auth = AuthService();

  String _selectedTopCategory = 'Properties';
  String? _subCategory;
  String _condition = 'used';
  bool _negotiable = false;
  bool _isSubmitting = false;

  final List<String> _images = <String>[]; // store URLs or asset paths (MVP)
  List<String> _allAssetImages = <String>[];
  bool _loadingAssets = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _marlaCtrl.dispose();
    _blockCtrl.dispose();
    _bedCtrl.dispose();
    _bathCtrl.dispose();
    _yearCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Create Listing',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _categorySection(),
              SizedBox(height: 12.h),
              _photosSection(),
              SizedBox(height: 12.h),
              _coreDetailsSection(),
              SizedBox(height: 12.h),
              _dynamicFields(),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Post Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categorySection() {
    final topCats = <String>[
      'Properties',
      'Vehicles',
      'Electronics',
      'Home & Furniture',
      'Services',
      'Books',
      'Sports',
      'Other',
    ];
    final subs = _subCategoriesFor(_selectedTopCategory);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: AppTextStyles.bodyMediumBold),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children:
                topCats
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c),
                        selected: _selectedTopCategory == c,
                        onSelected:
                            (_) => setState(() {
                              _selectedTopCategory = c;
                              _subCategory = null;
                            }),
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            value: _subCategory,
            decoration: InputDecoration(
              labelText: 'Subcategory',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            items:
                subs
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
            onChanged: (v) => setState(() => _subCategory = v),
          ),
        ],
      ),
    );
  }

  List<String> _subCategoriesFor(String top) {
    switch (top) {
      case 'Properties':
        return ['Residential', 'Commercial', 'Plot', 'Apartment'];
      case 'Vehicles':
        return ['Car', 'Bike', 'SUV', 'Truck'];
      case 'Electronics':
        return ['Phones', 'Laptops', 'Audio', 'TV'];
      case 'Home & Furniture':
        return ['Sofa', 'Table', 'Appliances', 'Decor'];
      case 'Sports':
        return ['Fitness', 'Outdoor', 'Indoor'];
      default:
        return ['General'];
    }
  }

  Widget _photosSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos', style: AppTextStyles.bodyMediumBold),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [..._images.map((p) => _thumb(p)), _addPhotoButton()],
          ),
        ],
      ),
    );
  }

  Widget _thumb(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 86.w,
        height: 86.w,
        color: Colors.grey.shade100,
        child:
            path.startsWith('http')
                ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _thumbError(),
                )
                : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _thumbError(),
                ),
      ),
    );
  }

  Widget _thumbError() =>
      Icon(Icons.broken_image, color: Colors.grey, size: 24.r);

  Widget _addPhotoButton() {
    return InkWell(
      onTap: () async {
        await _openAssetPicker();
      },
      child: Container(
        width: 86.w,
        height: 86.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  Future<void> _openAssetPicker() async {
    if (_allAssetImages.isEmpty && !_loadingAssets) {
      setState(() => _loadingAssets = true);
      try {
        final String manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifest =
            convert.jsonDecode(manifestContent) as Map<String, dynamic>;
        final List<String> assets =
            manifest.keys
                .where((k) => k.startsWith('assets/images/') && _isImagePath(k))
                .map((e) => e.toString())
                .toList();
        _allAssetImages = assets;
      } catch (_) {
        _allAssetImages = <String>[
          'assets/images/sofa.jpg',
          'assets/images/table.jpg',
          'assets/images/iphone.jpg',
          'assets/images/jacket.jpeg',
          'assets/images/civic.avif',
          'assets/images/apr1.jpg',
          'assets/images/apr2.jpg',
          'assets/images/apr3.jpg',
          'assets/images/plot.jpeg',
          'assets/images/retail1.jpg',
          'assets/images/house4.jpg',
          'assets/images/house3.webp',
          'assets/images/house5.jpeg',
        ];
      }
      if (mounted) setState(() => _loadingAssets = false);
    }

    if (!mounted) return;
    final Set<String> selected = Set<String>.from(_images);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final List<String> source = _allAssetImages;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            12.w,
            12.h,
            12.w,
            12.h + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Select Images', style: AppTextStyles.bodyMediumBold),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(
                        () =>
                            _images
                              ..clear()
                              ..addAll(selected),
                      );
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6.h,
                    crossAxisSpacing: 6.w,
                    childAspectRatio: 1,
                  ),
                  itemCount: source.length,
                  itemBuilder: (_, i) {
                    final path = source[i];
                    final isSel = selected.contains(path);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSel) {
                            selected.remove(path);
                          } else {
                            selected.add(path);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.asset(
                              path,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _thumbError(),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  isSel ? AppColors.primaryRed : Colors.white,
                              child: Icon(
                                isSel ? Icons.check : Icons.add,
                                size: 14,
                                color: isSel ? Colors.white : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isImagePath(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.webp') ||
        p.endsWith('.avif');
  }

  Widget _coreDetailsSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _textField('Title', _titleCtrl, 'Enter title'),
          SizedBox(height: 10.h),
          _textField(
            'Description',
            _descCtrl,
            'Enter description',
            maxLines: 3,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Price (PKR)',
                  _priceCtrl,
                  '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(child: _textField('Location', _locationCtrl, 'Block C')),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _textField('Brand', _brandCtrl, 'Apple / Honda / ...'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _textField('Model', _modelCtrl, 'iPhone 12 / Civic'),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _condition,
                  items: const [
                    DropdownMenuItem(value: 'new', child: Text('New')),
                    DropdownMenuItem(
                      value: 'like_new',
                      child: Text('Like New'),
                    ),
                    DropdownMenuItem(value: 'used', child: Text('Used')),
                  ],
                  onChanged: (v) => setState(() => _condition = v ?? 'used'),
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _negotiable,
                  onChanged: (v) => setState(() => _negotiable = v ?? false),
                  title: const Text('Negotiable'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dynamicFields() {
    switch (_selectedTopCategory) {
      case 'Properties':
        return _propertiesFields();
      case 'Vehicles':
        return _vehicleFields();
      default:
        return _generalFields();
    }
  }

  Widget _propertiesFields() {
    return _section(
      'Property Details',
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Bedrooms',
                  _bedCtrl,
                  '3',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _textField(
                  'Bathrooms',
                  _bathCtrl,
                  '2',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Marla',
                  _marlaCtrl,
                  '10',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(child: _textField('Block', _blockCtrl, 'Block C')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicleFields() {
    return _section(
      'Vehicle Details',
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  'Year',
                  _yearCtrl,
                  '2018',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _textField(
                  'Kilometers',
                  _kmCtrl,
                  '58000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _generalFields() {
    return _section('Additional Details', const SizedBox());
  }

  Widget _section(String title, Widget child) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMediumBold),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        return null;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to post')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final double price = double.tryParse(_priceCtrl.text) ?? 0;

      final Map<String, dynamic> attrs = <String, dynamic>{
        if (_selectedTopCategory == 'Properties') ...{
          'bedrooms': int.tryParse(_bedCtrl.text) ?? 0,
          'bathrooms': int.tryParse(_bathCtrl.text) ?? 0,
          'marla': double.tryParse(_marlaCtrl.text) ?? 0,
          'block': _blockCtrl.text.trim(),
        },
        if (_selectedTopCategory == 'Vehicles') ...{
          'year': int.tryParse(_yearCtrl.text) ?? 0,
          'kilometers': int.tryParse(_kmCtrl.text) ?? 0,
        },
        if (_brandCtrl.text.trim().isNotEmpty) 'brand': _brandCtrl.text.trim(),
        if (_modelCtrl.text.trim().isNotEmpty) 'model': _modelCtrl.text.trim(),
      };

      final item = MarketItem(
        id: id,
        type:
            _selectedTopCategory == 'Properties'
                ? 'property'
                : _selectedTopCategory == 'Vehicles'
                ? 'vehicle'
                : 'general',
        category: _selectedTopCategory,
        subCategory: _subCategory,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        currency: 'PKR',
        negotiable: _negotiable,
        condition: _condition,
        location: _locationCtrl.text.trim(),
        imageUrls: _images,
        sellerId: user.uid,
        sellerName: user.displayName ?? 'Seller',
        createdAt: DateTime.now(),
        status: MarketItemStatus.active,
        attributes: attrs,
      );

      await MarketItemService.addItem(item);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item posted')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
