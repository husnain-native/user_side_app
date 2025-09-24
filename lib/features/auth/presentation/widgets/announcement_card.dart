import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String date;
  
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyLarge),
            SizedBox(height: 8.h),
            Text(date, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}