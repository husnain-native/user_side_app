import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/add_beneficiary_screen.dart';

class UtilityTypesScreen extends StatefulWidget {
  final String mode; // 'transfer' or 'request'
  const UtilityTypesScreen({super.key, this.mode = 'transfer'});
  @override
  State<UtilityTypesScreen> createState() => _UtilityTypesScreenState();
}

class _UtilityTypesScreenState extends State<UtilityTypesScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banks = <_UtilityOption>[
      _UtilityOption('Meezan Bank', 'assets/images/logo_meezan.png'),
      _UtilityOption('Jazz Cash Wallet', 'assets/images/logo_jazzcash.webp'),
      _UtilityOption('EasyPaisa-Telenor Bank', 'assets/images/logo_easy.jpg'),
      _UtilityOption('HBL KONNECT', 'assets/images/logo_hbl.png'),
      _UtilityOption('Bank Al-Habib', 'assets/images/logo_habib.webp'),
      _UtilityOption('UBL', 'assets/images/logo_ubl.png'),
      _UtilityOption('Bank Alfalah', 'assets/images/logo_alfala.png'),
      _UtilityOption('Allied Bank', 'assets/images/logo_allied.webp'),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Select Bank',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              itemCount: banks.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, i) {
                final q = _search.text.trim().toLowerCase();
                final option = banks[i];
                if (q.isNotEmpty && !option.title.toLowerCase().contains(q)) {
                  return const SizedBox.shrink();
                }
                return _OptionTile(
                  option: option,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => AddBeneficiaryScreen(
                              bankName: option.title,
                              bankAsset: option.asset,
                              mode: widget.mode,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _UtilityOption option;
  final VoidCallback onTap;
  const _OptionTile({required this.option, required this.onTap});
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
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.w,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: AssetImage(option.asset),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(option.title, style: AppTextStyles.bodyMediumBold),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _UtilityOption {
  final String title;
  final String asset;
  _UtilityOption(this.title, this.asset);
}
