// lib/widgets/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import '../models/onboarding_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback? onNextPressed;
  final VoidCallback? onSkipPressed;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    Key? key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
    this.onNextPressed,
    this.onSkipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Top spacing + Logo
              SizedBox(height: 15.h),
              _buildLogo(),
              SizedBox(height:5.h),
              // Main content area (expandable)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImage(),
                    SizedBox(height: 10.h),
                    _buildSubHeading(),
                    SizedBox(height: 2.h),
                    _buildMainHeading(),
                    // SizedBox(height: 16.h),
                    _buildDescription(),
                    SizedBox(height: 30.h),
                    _buildPageIndicator(),
                  ],
                ),
              ),

              // Bottom section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 60.h,
      child: Image.asset(data.logoAssetPath, fit: BoxFit.contain),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 210.h,
      width: double.infinity,
      child: Image.asset(data.imageAssetPath, fit: BoxFit.contain),
    );
  }

  Widget _buildSubHeading() {
    return Text(
      data.subHeading,
      style: TextStyle(
        fontSize: 19.sp,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildMainHeading() {
    return Text(
      data.mainHeading,
      style: TextStyle(
        fontSize: 24.sp,
        color: AppColors.black,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Text(
        data.description,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildPageIndicator() {
    return PageIndicator(currentPage: currentPage, totalPages: totalPages);
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        SizedBox(height: 10.h),

        // Primary Button
        SizedBox(
          width: double.infinity,
          height: 37.h,
          child: ElevatedButton(
            onPressed: onNextPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              data.buttonText,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // Skip Button
        TextButton(
          onPressed: onSkipPressed,
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // const SizedBox(height: 5),
      ],
    );
  }
}
