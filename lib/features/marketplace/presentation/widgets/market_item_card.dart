import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/marketplace/domain/models/market_item.dart';

class MarketItemCard extends StatelessWidget {
  final MarketItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const MarketItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumb(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMediumBold,
                        ),

                         Spacer(),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 18),
                          onPressed: onFavorite,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Text(
                      item.formattedPrice,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                    SizedBox(height: 7,),
                    Row(
                      children: [
                        _chip(item.category),
                        if (item.subCategory != null) ...[
                          SizedBox(width: 6.w),
                          _chip(item.subCategory!),
                        ],
                      ],
                    ),

                    SizedBox(height: 7.h),
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
                        SizedBox(width: 8.w),
                        Text(
                          item.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb() {
    final String? url = item.imageUrls.isNotEmpty ? item.imageUrls.first : null;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.r),
        bottomLeft: Radius.circular(12.r),
      ),
      child: Container(
        width: 92.w,
        height: 102.h,
        color: Colors.grey.shade100,
        child:
            url == null
                ? Icon(Icons.image, color: Colors.grey, size: 28.r)
                : (url.startsWith('http')
                    ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _error(),
                    )
                    : Image.asset(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _error(),
                    )),
      ),
    );
  }

  Widget _error() => Icon(Icons.broken_image, color: Colors.grey, size: 24.r);

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4.r),
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
}
