import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';
import 'package:park_chatapp/features/marketplace/domain/store/marketplace_store.dart';

/// Vertical marketplace card (image on top, details below), visually aligned
/// with property cards used elsewhere in the app.
class ListingCardVertical extends StatelessWidget {
  const ListingCardVertical({
    super.key,
    required this.listing,
    this.onTap,
    this.onFavorite,
  });

  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.r),
      child: Card(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMediumBold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    listing.formattedPrice,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _pill(listing.category.label),
                      SizedBox(width: 6.w),
                      _pill(listing.condition.label),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        listing.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final String? url =
        listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
          child: Container(
            height: 80.h,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: _buildImage(url),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: MarketplaceStore.instance.favoriteIdsNotifier,
            builder: (_, favs, __) {
              final bool isFav = favs.contains(listing.id);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onFavorite,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFav ? AppColors.primaryRed : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _pill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey);
    }
    final bool isAsset = path.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }
}
