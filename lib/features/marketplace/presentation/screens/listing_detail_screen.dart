import 'package:flutter/material.dart';
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    listing.formattedPrice,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _pill(listing.category.label),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 16),
                  Text('Description', style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 6),
                  Text(listing.description, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 18, color: AppColors.primaryRed,),
                      const SizedBox(width: 6),
                      Expanded(child: Text(listing.location)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppColors.primaryRed, ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          listing.sellerName,
                          style: AppTextStyles.bodyMediumBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                      label: const Text('Chat with Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
        height: 220,
        alignment: Alignment.center,
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      );
    }
    return SizedBox(
      height: 260,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: AppTextStyles.bodySmall),
    );
  }
}