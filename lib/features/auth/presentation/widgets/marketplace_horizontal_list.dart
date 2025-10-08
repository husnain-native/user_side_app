import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/store/marketplace_store.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';
import 'package:park_chatapp/features/marketplace/presentation/widgets/listing_card_vertical.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/listing_detail_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/marketplace_screen.dart';

/// Horizontal scroller of marketplace items for the home screen.
/// Uses the same ListingCard UI, constrained to a fixed width for horizontal paging.
class MarketplaceHorizontalList extends StatelessWidget {
  const MarketplaceHorizontalList({super.key});
  static bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Marketplace',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 6.h,
                ), // optional spacing inside container
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.rectangle, // makes it round
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Icon(Icons.arrow_forward, size: 18.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 190.h,
          child: ValueListenableBuilder(
            valueListenable: MarketplaceStore.instance.listingsNotifier,
            builder: (_, __, ___) {
              final items = MarketplaceStore.instance.allListings;
              if (items.isEmpty && !_seeded) {
                _seeded = true;
                // Seed a few sample listings so home has content before opening the marketplace screen.
                Future.microtask(() {
                  MarketplaceStore.instance.setAllListings(_sampleListings());
                });
              }
              if (items.isEmpty) {
                return const Center(child: Text('No items in marketplace yet'));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 12.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SizedBox(
                    width: 180.w,
                    child: ListingCardVertical(
                      listing: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: item),
                          ),
                        );
                      },
                      onFavorite:
                          () =>
                              MarketplaceStore.instance.toggleFavorite(item.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

List<Listing> _sampleListings() {
  return <Listing>[
    Listing(
      id: 'h1',
      title: 'Comfy Sofa Set',
      description: '3-seater with 2 chairs, gently used.',
      price: 45000,
      negotiable: true,
      category: ListingCategory.furniture,
      condition: ListingCondition.used,
      imageUrls: const ['assets/images/sofa.jpg'],
      sellerName: 'Ali',
      sellerId: 'u1',
      location: 'Park View',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: ListingStatus.active,
    ),
    Listing(
      id: 'h2',
      title: 'iPhone 12 128GB',
      description: 'Excellent condition, non-PTA.',
      price: 165000,
      negotiable: false,
      category: ListingCategory.electronics,
      condition: ListingCondition.likeNew,
      imageUrls: const ['assets/images/iphone.jpg'],
      sellerName: 'Hassan',
      sellerId: 'u2',
      location: 'Bahria Enclave',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: ListingStatus.active,
    ),
    Listing(
      id: 'h3',
      title: 'Yoga Mat',
      description: 'Non-slip, brand new.',
      price: 2500,
      negotiable: true,
      category: ListingCategory.sports,
      condition: ListingCondition.newItem,
      imageUrls: const ['assets/images/yogamat.jpg'],
      sellerName: 'Sara',
      sellerId: 'u3',
      location: 'PWD',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      status: ListingStatus.active,
    ),
  ];
}
