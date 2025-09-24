import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/payment_option_card.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/small_action_card.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_details_screen.dart';
// import 'package:park_chatapp/features/payments/presentation/widgets/account_card.dart';
// import 'package:park_chatapp/features/payments/presentation/widgets/payment_option_card.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_PaymentOption> paymentOptions = [
      _PaymentOption(
        icon: Icons.lightbulb_outline,
        title: 'Pay Utility Bills',
        subtitle: 'Electricity, Water, Gas',
        onTap: () => _handleUtilityBills(context),
      ),
      _PaymentOption(
        icon: Icons.account_balance,
        title: 'Pay Plot Installments',
        subtitle: 'Monthly installment payments',
        onTap: () => _handlePlotInstallments(context),
      ),
      _PaymentOption(
        icon: Icons.key,
        title: 'Pay Possession Charges',
        subtitle: 'Final possession fees',
        onTap: () => _handlePossessionCharges(context),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Payments',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/atm_card.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 14.h),
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
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SmallActionCard(
                    icon: Icons.send,
                    title: 'Transfer Money',
                    color: AppColors.primaryRed,
                    onTap: () => _handleTransferMoney(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SmallActionCard(
                    icon: Icons.request_page,
                    title: 'Request Money',
                    color: Colors.green,
                    onTap: () => _handleRequestMoney(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...paymentOptions
                .map(
                  (option) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: PaymentOptionCard(
                      icon: option.icon,
                      title: option.title,
                      subtitle: option.subtitle,
                      onTap: option.onTap,
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void _handleUtilityBills(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => const PaymentDetailsScreen(
              title: 'Pay Utility Bills',
              subtitle: 'Electricity, Water, Gas',
            ),
      ),
    );
  }

  void _handlePlotInstallments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => const PaymentDetailsScreen(
              title: 'Pay Plot Installments',
              subtitle: 'Monthly installment payments',
            ),
      ),
    );
  }

  void _handlePossessionCharges(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => const PaymentDetailsScreen(
              title: 'Pay Possession Charges',
              subtitle: 'Final possession fees',
            ),
      ),
    );
  }
}

class _PaymentOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

///////////////////////////////////////////////////////////////
void _handleTransferMoney(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PaymentDetailsScreen(title: 'Transfer Money'),
    ),
  );
}

void _handleRequestMoney(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PaymentDetailsScreen(title: 'Request Money'),
    ),
  );
}
