import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
// Removed legacy widgets/imports after grid redesign
import 'package:park_chatapp/features/auth/presentation/screens/statement_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/plot_installments_reference_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/utility_bill_types_screen.dart';
// import 'package:park_chatapp/features/auth/presentation/screens/possession_charges_reference_screen.dart';
import 'package:flutter/services.dart';
// import 'package:park_chatapp/features/payments/presentation/widgets/account_card.dart';
// import 'package:park_chatapp/features/payments/presentation/widgets/payment_option_card.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_GridOption> gridOptions = [
      _GridOption(
        title: 'Bill Payment',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => _handleUtilityBills(context),
      ),
      _GridOption(
        title: 'Education',
        icon: Icons.menu_book_outlined,
        onTap: () {},
      ),
      _GridOption(
        title: 'Possession Charges',
        icon: Icons.receipt_long_outlined,
        onTap: () {},
      ),
      _GridOption(
        title: 'Corporate',
        icon: Icons.home_work_rounded,
        onTap: () {},
      ),
      // _GridOption(
      //   title: 'Possession Charges',
      //   icon: Icons.smartphone_outlined,
      //   onTap: () {},
      // ),
      // _GridOption(
      //   title: 'Payments',
      //   icon: Icons.account_balance_wallet,
      //   onTap: () => _handlePlotInstallments(context),
      // ),
    ];

    // final String accountNumber = 'PK-0011-2233-4455';
    // final double balance = 125430.75;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Payments',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: AppColors.iconColor),
            onPressed: () => _openStatement(context),
            tooltip: 'View Statement',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _AccountSummaryCard(
            //   accountNumber: accountNumber,
            //   balance: balance,
            //   onViewStatement: () => _openStatement(context),
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: SmallActionCard(
            //         icon: Icons.send,
            //         title: 'Transfer Money',
            //         color: AppColors.primaryRed,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder:
            //                   (_) => const PaymentTypesScreen(mode: 'transfer'),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //     Expanded(
            //       child: SmallActionCard(
            //         icon: Icons.request_page,
            //         title: 'Request Money',
            //         color: Colors.green,
            //         onTap: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder:
            //                   (_) => const PaymentTypesScreen(mode: 'request'),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Options',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 24.w,
                    color: AppColors.primaryRed,
                  ),
                  onPressed: () {
                    // Show info dialog or navigate to help screen
                  },
                ),
              ],
            ),
            // SizedBox(height: 16.h),

            // SizedBox(height: 20.h),
            // SmallActionCard(
            //   icon: Icons.receipt_long,
            //   title: 'View Statement',
            //   color: Colors.indigo,
            //   onTap: () => _openStatement(context),
            // ),
            SizedBox(height: 12.h),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.35,
              ),
              itemCount: gridOptions.length,
              itemBuilder: (context, index) {
                final item = gridOptions[index];
                return _GridTile(option: item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUtilityBills(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UtilityBillTypesScreen()));
  }

  void _handlePlotInstallments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlotInstallmentReferenceScreen()),
    );
  }

  // Placeholder for future option

  void _openStatement(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StatementScreen()));
  }
}

class _GridOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _GridOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _GridTile extends StatelessWidget {
  final _GridOption option;
  const _GridTile({required this.option});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
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
                color: AppColors.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                option.icon,
                color: AppColors.iconColor,
                size: 28.w,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              option.title,
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

// Grid-only layout; legacy account summary widgets removed
