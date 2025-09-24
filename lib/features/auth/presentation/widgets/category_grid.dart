import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/category_image_tile.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> items;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const CategoryGrid({
    super.key,
    required this.items,
    this.crossAxisSpacing = 4,
    this.mainAxisSpacing = 4,
  }) : assert(items.length == 4, 'CategoryGrid expects exactly 4 items');

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: crossAxisSpacing.w,
        mainAxisSpacing: mainAxisSpacing.h,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CategoryImageTile(
          title: item.title,
          imageAssetPath: item.imageAssetPath,
          onTap: item.onTap,
        );
      },
    );
  }
}

class CategoryItem {
  final String title;
  final String imageAssetPath;
  final VoidCallback? onTap;

  const CategoryItem({
    required this.title,
    required this.imageAssetPath,
    this.onTap,
  });
}
