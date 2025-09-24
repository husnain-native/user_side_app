import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/market_item_service.dart';
import 'package:park_chatapp/features/marketplace/domain/models/market_item.dart';
import 'package:park_chatapp/features/marketplace/presentation/widgets/market_item_card.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/create_market_item_screen.dart';

class UnifiedMarketplaceScreen extends StatefulWidget {
  const UnifiedMarketplaceScreen({super.key});

  @override
  State<UnifiedMarketplaceScreen> createState() =>
      _UnifiedMarketplaceScreenState();
}

class _UnifiedMarketplaceScreenState extends State<UnifiedMarketplaceScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 100000000);
  String _sortBy = 'Newest';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Search Result',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<MarketItem>>(
          stream: MarketItemService.streamAllItems(),
          builder: (context, snapshot) {
            final List<MarketItem> items = _applyFilters(
              snapshot.data ?? const <MarketItem>[],
            );
            return ListView(
              children: [
                _searchBar(),
                _categoryChips(),
                _banner(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Results', style: AppTextStyles.bodyMediumBold),
                      IconButton(
                        icon: const Icon(Icons.view_stream_outlined, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 105.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return SizedBox(
                        width: 280.w,
                        child: MarketItemCard(item: e, onTap: () {}),
                      );
                    },
                  ),
                ),
                _relatedCategories(),
                _exclusiveOffers(items),
                SizedBox(height: 20.h),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateMarketItemScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<MarketItem> _applyFilters(List<MarketItem> items) {
    Iterable<MarketItem> out = items;
    if (_selectedCategory != 'All') {
      out = out.where(
        (i) => i.category.toLowerCase() == _selectedCategory.toLowerCase(),
      );
    }
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      out = out.where(
        (i) =>
            i.title.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q),
      );
    }
    out = out.where(
      (i) => i.price >= _priceRange.start && i.price <= _priceRange.end,
    );
    switch (_sortBy) {
      case 'Price Low to High':
        out = out.toList()..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price High to Low':
        out = out.toList()..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Newest':
      default:
        out = out.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return out.toList();
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search items, properties...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color.fromARGB(38, 175, 153, 131),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.h),
        ),
        onChanged: (v) => setState(() => _searchText = v.trim()),
      ),
    );
  }

  Widget _categoryChips() {
    final cats = [
      'All',
      'Properties',
      'Vehicles',
      'Electronics',
      'Home & Furniture',
      'Services',
      'Books',
      'Sports',
      'Other',
    ];
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final c = cats[i];
          final selected = _selectedCategory == c;
          return ChoiceChip(
            label: Text(c),
            color: MaterialStateProperty.resolveWith((states) {
              return states.contains(MaterialState.selected)
                  ? AppColors.primaryRed.withOpacity(0.1)
                  : Colors.white; // unselected
            }),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = c),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: cats.length,
      ),
    );
  }

  Widget _banner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 90.h,
          color: Colors.grey.shade200,
          alignment: Alignment.centerLeft,
          // padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Image.asset(
            'assets/images/banner.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _relatedCategories() {
    final chips = ['Accessories', 'Audio', 'Appliances'];
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Related Categories', style: AppTextStyles.bodyMediumBold),
          SizedBox(height: 8.h),
          Row(
            children:
                chips
                    .map(
                      (e) => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _miniCategory(e),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _miniCategory(String label) {
    return Container(
      width: 92.w,
      height: 76.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  Widget _exclusiveOffers(List<MarketItem> items) {
    final grid = items.take(6).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exclusive offer', style: AppTextStyles.bodyMediumBold),
          SizedBox(height: 8.h),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
            ),
            itemCount: grid.length,
            itemBuilder: (_, i) {
              final item = grid[i];
              return _offerCardVertical(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _offerCardVertical(MarketItem item) {
    final String? url = item.imageUrls.isNotEmpty ? item.imageUrls.first : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.7,
            child:
                url == null
                    ? Container(
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, color: Colors.grey),
                    )
                    : (url.startsWith('http')
                        ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        )
                        : Image.asset(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        )),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 6.h, 10.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMediumBold,
                ),
                Row(
                  children: [
                    _badge(item.category),
                    if (item.subCategory != null) ...[
                      SizedBox(width: 6.w),
                      _badge(item.subCategory!),
                    ],
                  ],
                ),
                // SizedBox(height: 6.h),
               
                SizedBox(height: 6.h),
                Text(
                  item.formattedPrice,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.place, size: 14.r, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.06),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primaryRed,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => _FilterSheet(initialSort: _sortBy, initialPrice: _priceRange),
    );
    if (result != null) {
      setState(() {
        _sortBy = result.sortBy;
        _priceRange = result.price;
      });
    }
  }
}

class _FilterResult {
  final String sortBy;
  final RangeValues price;
  const _FilterResult(this.sortBy, this.price);
}

class _FilterSheet extends StatefulWidget {
  final String initialSort;
  final RangeValues initialPrice;
  const _FilterSheet({required this.initialSort, required this.initialPrice});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _sortBy;
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.initialSort;
    _price = widget.initialPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filter', style: AppTextStyles.headlineMedium),
              const Spacer(),
              TextButton(
                onPressed:
                    () => setState(() {
                      _sortBy = 'Newest';
                      _price = const RangeValues(0, 1000000);
                    }),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _section('Sort by', _sortChips()),
          const SizedBox(height: 12),
          _section('Price Range', _priceSlider()),
          const SizedBox(height: 12),
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
              onPressed:
                  () => Navigator.pop(context, _FilterResult(_sortBy, _price)),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
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

  Widget _sortChips() {
    final sorts = ['Newest', 'Price Low to High', 'Price High to Low'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children:
          sorts
              .map(
                (s) => ChoiceChip(
                  label: Text(s),
                  selected: _sortBy == s,
                  onSelected: (_) => setState(() => _sortBy = s),
                ),
              )
              .toList(),
    );
  }

  Widget _priceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RangeSlider(
          values: _price,
          min: 0,
          max: 2000000,
          divisions: 100,
          labels: RangeLabels(
            _price.start.toStringAsFixed(0),
            _price.end.toStringAsFixed(0),
          ),
          onChanged: (v) => setState(() => _price = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PKR ${_price.start.toStringAsFixed(0)}'),
            Text('PKR ${_price.end.toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }
}
