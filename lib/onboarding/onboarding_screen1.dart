import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnBoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              // Logo section
              Padding(
                padding: EdgeInsets.only(top: 40.r, bottom: 60.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'TC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'BALADI ',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'EXPRESS',
                            style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Device illustration
              Expanded(
                child: Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background decorative elements
                      Positioned(
                        top: 50.r,
                        left: 20.r,
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey[400],
                            size: 30.sp,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80.r,
                        right: 30.r,
                        child: Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.percent,
                            color: Colors.grey[400],
                            size: 25.sp,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 120.r,
                        left: 30.r,
                        child: Container(
                          width: 45.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.local_offer_outlined,
                            color: Colors.grey[400],
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 100.r,
                        right: 25.r,
                        child: Container(
                          width: 55.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.discount_outlined,
                            color: Colors.grey[400],
                            size: 28.sp,
                          ),
                        ),
                      ),

                      // Main device stack
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Laptop
                          Container(
                            width: 280.w,
                            height: 180.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20.r,
                                  offset: Offset(0, 10.r),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Color(0xFF87CEEB),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Stack(
                                children: [
                                  // App icons grid
                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.r),
                                      child: GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 6,
                                              mainAxisSpacing: 8,
                                              crossAxisSpacing: 8,
                                            ),
                                        itemCount: 18,
                                        itemBuilder: (context, index) {
                                          final colors = [
                                            Colors.red,
                                            Colors.blue,
                                            Colors.green,
                                            Colors.orange,
                                            Colors.purple,
                                            Colors.pink,
                                          ];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  colors[index % colors.length],
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Devices stack
                          Transform.translate(
                            offset: Offset(0, -40.r),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Tablet
                                Transform.rotate(
                                  angle: -0.1,
                                  child: Container(
                                    width: 140.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 5.r),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(4.r),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1976D2),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              mainAxisSpacing: 2.r,
                                              crossAxisSpacing: 2.r,
                                            ),
                                        itemCount: 12,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.all(1.r),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2.r),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 20.w),

                                // Phone
                                Transform.rotate(
                                  angle: 0.1,
                                  child: Container(
                                    width: 70.w,
                                    height: 120.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 5.r),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(4.r),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisSpacing: 2.r,
                                              crossAxisSpacing: 2.r,
                                            ),
                                        itemCount: 12,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.all(1.r),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2.r),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Text content
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    Text(
                      "It's all about your need",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Amazing Deals & Offers",
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        "Find deals that are cheaper than local supermarket, great discount, and cash backs.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // Buttons
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
