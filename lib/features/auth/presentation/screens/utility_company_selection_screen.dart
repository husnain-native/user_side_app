import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/utility_bills_reference_screen.dart';

class UtilityCompanySelectionScreen extends StatelessWidget {
  final String billType;
  final IconData? icon;
  final Color? color;

  const UtilityCompanySelectionScreen({
    super.key,
    required this.billType,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final companies = _getCompaniesForBillType(billType);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Select Biller',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_outlined),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frequently Used Section
          if (companies.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Frequently Used',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return _CompanyTile(
                    company: company,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => UtilityBillReferenceScreen(
                                billType: '${company.name} - $billType',
                                icon: icon,
                                color: color,
                                logoPath: company.logoPath,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Company> _getCompaniesForBillType(String billType) {
    switch (billType) {
      case 'Electricity Bill':
        return [
          Company('Park View City', 'assets/images/logo1.jpg'),
          // Company('SSGC', 'assets/images/ssgc.png'),
          Company('KE', 'assets/images/KE.png'),
          Company('LESCO', 'assets/images/lesco.png'),
          Company('GEPCO', 'assets/images/gepco.jpg'),
          Company('MEPCO', 'assets/images/mepco.png'),
          // Additional electricity companies
          Company('IESCO', 'assets/images/IESCO.jpeg'),
          Company('FESCO', 'assets/images/FESCO.jpeg'),
          Company('PESCO', 'assets/images/PESCO.png'),
          Company('HESCO', 'assets/images/HESCO.png'),
          Company('QESCO', 'assets/images/QESCO.png'),
          Company('SEPCO', 'assets/images/SEPCO.jpeg'),
          Company('HAZECO', 'assets/images/HAZECO.jpeg'),
        ];
      case 'Water Bill':
        return [
          Company('Park View City', 'assets/images/logo1.jpg'),
          Company('WASA Punjab', 'assets/images/WASA.jpg'),
          Company('KWSB', 'assets/images/KWSB.webp'),
          Company('LWASA', 'assets/images/LWASA.png'),
          Company('RWASA', 'assets/images/RWASA.png'),
          Company('MWASA', 'assets/images/MWASA.png'),
          Company('FWASA', 'assets/images/FWASA.jpg'),
          Company('GWASA', 'assets/images/GWASA.png'),
          Company('WSSCM', 'assets/images/WSSCM.jpeg'),
        ];
      case 'Gas Bill':
        return [
          Company('Park View City', 'assets/images/logo1.jpg'),
          Company('SNGPL', 'assets/images/sngpl.png'),
          Company('SSGC', 'assets/images/ssgc.png'),
        ];
      case 'Security Fee':
        return [
          Company('Park View City', 'assets/images/logo1.jpg'),
          Company('Building Security Fee', 'assets/images/logo2.png'),
          Company('Housing Society Security', 'assets/images/logo2.png'),
          Company('Commercial Area Security', 'assets/images/logo2.png'),
        ];
      default:
        return [];
    }
  }
}

class Company {
  final String name;
  final String logoPath;
  Company(this.name, this.logoPath);
}

class _CompanyTile extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const _CompanyTile({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Company Logo/Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child:
                  company.logoPath.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.asset(
                          company.logoPath,
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _getDefaultIcon();
                          },
                        ),
                      )
                      : _getDefaultIcon(),
            ),
            SizedBox(width: 16.w),
            // Company Name
            Expanded(
              child: Text(
                company.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDefaultIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: _getCompanyColor(),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          _getCompanyInitials(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getCompanyColor() {
    // Generate a color based on company name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.amber,
    ];
    final index = company.name.hashCode % colors.length;
    return colors[index.abs()];
  }

  String _getCompanyInitials() {
    final words = company.name.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    }
    return (words[0].isNotEmpty ? words[0][0] : '') +
        (words[1].isNotEmpty ? words[1][0] : '').toUpperCase();
  }
}
