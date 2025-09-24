import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class CategoryImageTile extends StatelessWidget {
  final String title;
  final String imageAssetPath;
  final VoidCallback? onTap;

  const CategoryImageTile({
    super.key,
    required this.title,
    required this.imageAssetPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Ink.image(
            image: AssetImage(imageAssetPath),
            fit: BoxFit.cover,
            child: InkWell(onTap: onTap),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Center(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
