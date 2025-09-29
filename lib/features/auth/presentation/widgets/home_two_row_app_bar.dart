import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/language_toggle.dart';

class HomeTwoRowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTwoRowAppBar({
    super.key,
    required this.onMenuTap,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.onCartTap,
    required this.onFilterTap,
    this.location = 'Lahore',
  });

  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;
  final VoidCallback onFilterTap;
  final String location;

  @override
  Size get preferredSize => Size.fromHeight(110.h);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 250, 249, 248),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopRow(context),
              SizedBox(height: 5.h),
              _buildSearchRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 5.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Current location',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18.r,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
              // SizedBox(height: 5.w),
              Padding(
                padding: EdgeInsets.only(left: 14.w),
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // SizedBox(width: 17,),
              Padding(
                padding: EdgeInsets.only(left: 11.w),
                child: LanguageToggleButton(),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _circleIconButton(Icons.person_outline, onProfileTap),
        SizedBox(width: 8.w),
        _badgeIconButton(
          Icons.notifications_none_rounded,
          onNotificationsTap,
          badgeCount: 2,
        ),
        // SizedBox(width: 8.w),
        // _badgeIconButton(Icons.shopping_bag_outlined, onCartTap, badgeCount: 2),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: onMenuTap,
            child: Container(
              
              width: 40.h,
              height: 31.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // elevation: 2,
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                  )
                ]
                // border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              child: const Icon(Icons.menu_sharp, color: Color(0xFF2A2A2A)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 31.h,
            decoration: BoxDecoration(
              color: AppColors.fillColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                 Icon(Icons.search, color: AppColors.iconColor, size: 18.sp,),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                 Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.iconColor,
                  weight: 1,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 40.h,
            height: 31.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF2A2A2A)),
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6E6E6)),
          color: AppColors.white,
        ),
        child: Icon(icon, color: const Color(0xFF2A2A2A)),
      ),
    );
  }

  Widget _badgeIconButton(
    IconData icon,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _circleIconButton(icon, onTap),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$badgeCount',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
