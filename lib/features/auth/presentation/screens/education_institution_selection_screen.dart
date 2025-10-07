import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/education_reference_screen.dart';

class EducationInstitutionSelectionScreen extends StatelessWidget {
  const EducationInstitutionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final institutions = <_Institution>[
      _Institution('Park View City School (LHR)', 'assets/images/logo1.jpg'),
      _Institution('Park View City School (ISL)', 'assets/images/logoisl.jpg'),
      _Institution('Park View City College (LHR)', 'assets/images/logo1.jpg'),
      _Institution('Park View City College (ISL)', 'assets/images/logoisl.jpg'),
      // _Institution('University of Karachi', ''),
      // _Institution('NUST', ''),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Select Institution',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: institutions.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: const Color(0xFFE5E7EB)),
        itemBuilder: (context, index) {
          final inst = institutions[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) =>
                          EducationReferenceScreen(institutionName: inst.name),
                ),
              );
            },
            leading: _Logo(path: inst.logoPath),
            title: Text(inst.name, style: AppTextStyles.bodyMedium),
            // trailing removed per request
          );
        },
      ),
    );
  }
}

class _Institution {
  final String name;
  final String logoPath;
  _Institution(this.name, this.logoPath);
}

class _Logo extends StatelessWidget {
  final String path;
  const _Logo({required this.path});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey[100],
      ),
      clipBehavior: Clip.antiAlias,
      child:
          path.isNotEmpty
              ? Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
              : _fallback(),
    );
  }

  Widget _fallback() {
    return const Icon(Icons.school, color: Colors.grey);
  }
}
