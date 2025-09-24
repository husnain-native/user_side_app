import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class SocietyDetailsSection extends StatelessWidget {
  final String heading;
  final String description;
  final List<SocietyFeature> features;

  const SocietyDetailsSection({
    super.key,
    required this.heading,
    required this.description,
    required this.features,
  });

  factory SocietyDetailsSection.sample({Key? key}) {
    return SocietyDetailsSection(
      key: key,
      heading: 'Park View City',
      description:
          'Park View City offers a thoughtfully planned lifestyle with modern infrastructure, green spaces, and essential amenities for comfortable living. Explore some key facilities available to residents below.',
      features: const [
        SocietyFeature(
          icon: Icons.shield_outlined,
          title: 'Gated & Secure',
          description:
              '24/7 security with boundary walls, monitored entry, and CCTV surveillance for peace of mind.',
        ),
        SocietyFeature(
          icon: Icons.park_outlined,
          title: 'Parks & Green Belts',
          description:
              'Lush community parks, jog tracks, and landscaped green belts for a healthy lifestyle.',
        ),
        SocietyFeature(
          icon: Icons.account_balance,
          title: 'Central Mosque',
          description:
              'A centrally located mosque to cater to the spiritual needs of residents.',
        ),
        SocietyFeature(
          icon: Icons.school_outlined,
          title: 'Schools Nearby',
          description:
              'Access to quality education with reputed schools in and around the community.',
        ),
        SocietyFeature(
          icon: Icons.local_hospital_outlined,
          title: 'Healthcare Access',
          description:
              'Clinics and hospitals within easy reach for timely medical care.',
        ),
        SocietyFeature(
          icon: Icons.storefront_outlined,
          title: 'Commercial Areas',
          description:
              'Shopping areas and daily-need stores conveniently placed within the society.',
        ),
        SocietyFeature(
          icon: Icons.water_drop_outlined,
          title: 'Utilities & Infrastructure',
          description:
              'Reliable water, sewerage and power infrastructure for uninterrupted living.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8.h),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primaryRed, fontSize: 25.sp ),
        ),
        SizedBox(height: 5.h),
        Container(
          width: 70.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
          ),
        ),
        SizedBox(height: 28.h),
        ...features
            .map((f) => _FeatureBlock(feature: f))
            .expand((w) => [w, SizedBox(height: 24.h)])
            .toList()
          ..removeLast(),
      ],
    );
  }
}

class SocietyFeature {
  final IconData icon;
  final String title;
  final String description;

  const SocietyFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureBlock extends StatelessWidget {
  final SocietyFeature feature;

  const _FeatureBlock({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68.w,
          height: 68.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryRed, width: 2.5),
          ),
          child: Center(
            child: Icon(feature.icon, color: AppColors.primaryRed, size: 32.w),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          feature.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            feature.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
