import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';
import 'package:park_chatapp/features/marketplace/domain/store/marketplace_store.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [_buildThumbnail(), Expanded(child: _buildInfo())],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final String? url =
        listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ClipRRect(
        // padding: REdgeInsets.only(left: 12),
        // margin:  EdgeInsets.only(right: 12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          bottomLeft: Radius.circular(7),
        ),
        child: Container(
          color: Colors.grey.shade200,
          height: 90,
          width: 110,
          child: _buildImage(url),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  style: AppTextStyles.bodyMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ValueListenableBuilder<Set<String>>(
                valueListenable: MarketplaceStore.instance.favoriteIdsNotifier,
                builder: (_, favs, __) {
                  final bool isFav = favs.contains(listing.id);
                  return IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.primaryRed : null,
                    ),
                    splashRadius: 18,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            listing.formattedPrice,
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip(listing.category.label),
              const SizedBox(width: 6),
              _chip(listing.condition.label),
              const Spacer(),
              Text(
                listing.timeAgo,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
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