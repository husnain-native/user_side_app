import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/utility_bills_reference_screen.dart';

class UtilityBillTypesScreen extends StatelessWidget {
  const UtilityBillTypesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final types = <_BillType>[
      _BillType('Electricity Bill', Icons.bolt_outlined, Colors.amber.shade600),
      _BillType('Water Bill', Icons.water_drop_outlined, Colors.blue.shade600),
      _BillType(
        'Gas Bill',
        Icons.local_gas_station_outlined,
        Colors.orange.shade700,
      ),
      _BillType('Security Fee', Icons.security_outlined, Colors.teal.shade600),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Pay Utility Bills',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: GridView.builder(
          itemCount: types.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, i) {
            final t = types[i];
            return _GridTile(
              icon: t.icon,
              color: t.color,
              title: t.title,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => UtilityBillReferenceScreen(
                          billType: t.title,
                          icon: t.icon,
                          color: t.color,
                        ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BillType {
  final String title;
  final IconData icon;
  final Color color;
  _BillType(this.title, this.icon, this.color);
}

class _GridTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _GridTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.w),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
