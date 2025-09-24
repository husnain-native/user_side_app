import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Card(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 6.h),
                  _buildLocation(),
                  SizedBox(height: 2.h),
                  _buildDetails(),
                  SizedBox(height: 2.h),
                  _buildLabel(),
                  SizedBox(height: 2.h),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
          child: Container(
            height: 80.h,
            width: double.infinity,
            color: Colors.grey.shade200,
            child:
                property.imageUrls.isNotEmpty
                    ? _buildImage(property.imageUrls.first)
                    : Icon(Icons.home, size: 48, color: Colors.grey),
          ),
        ),
        Positioned(
          bottom: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              property.typeLabel,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String path) {
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

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(property.title, style: AppTextStyles.bodyMediumBold, maxLines: 1,),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 14.r, color: Colors.grey),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            property.location, maxLines: 1,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        _buildDetailItem(Icons.bed, '${property.bedrooms}'),
        SizedBox(width: 16.w),
        _buildDetailItem(Icons.bathtub_outlined, '${property.bathrooms}'),
        SizedBox(width: 16.w),
        _buildDetailItem(Icons.square_foot, '${property.area.toInt()} sq ft'),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12.r, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
      ],
    );
  }

  //////////////////////////////////////////////// build label

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Time (left side)
          Text(
            property.timeAgo,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
          ),

          /// Status Label (right side)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _getStatusColor(property.status).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Text(
              property.statusLabel,
              style: TextStyle(
                color: Colors.black,
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////
  ///
  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Text(
            property.formattedPrice,
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.available:
        return Colors.green;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.blue;
      case PropertyStatus.underContract:
        return Colors.orange;
    }
  }
}
