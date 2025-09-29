import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/chat/presentation/screens/direct_chat_screen.dart';
import 'package:park_chatapp/features/marketplace/domain/models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Listing Details',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        // top: false,
        child: ListView(
          children: [
            _imageGallery(listing.imageUrls),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: AppTextStyles.headlineLarge),
                  SizedBox(height: 6.h),
                  Text(
                    listing.formattedPrice,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _pill(listing.category.label),
                      SizedBox(width: 8.w),
                      _pill(listing.condition.label),
                      const Spacer(),
                      Text(
                        listing.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text('Description', style: AppTextStyles.bodyMediumBold),
                  SizedBox(height: 6.h),
                  Text(listing.description, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 18.r,
                        color: AppColors.primaryRed,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(child: Text(listing.location)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18.r,
                        color: AppColors.primaryRed,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          listing.sellerName,
                          style: AppTextStyles.bodyMediumBold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 18.r,
                      ),
                      label: const Text('Chat with Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DirectChatScreen(
                                  sellerName: listing.sellerName,
                                  sellerId: listing.sellerId,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageGallery(List<String> urls) {
    if (urls.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        height: 220.h,
        alignment: Alignment.center,
        child: Icon(Icons.image, size: 48.r, color: Colors.grey),
      );
    }
    return SizedBox(
      height: 260.h,
      child: PageView.builder(
        itemCount: urls.length,
        controller: PageController(viewportFraction: 1),
        itemBuilder: (_, i) {
          final String path = urls[i];
          final bool isAsset = path.startsWith('assets/');
          return isAsset
              ? Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _errorImg(),
              )
              : Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _errorImg(),
              );
        },
      ),
    );
  }

  Widget _errorImg() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: AppTextStyles.bodySmall),
    );
  }
}
