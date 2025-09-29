import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/payment_option_card.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/small_action_card.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payment_details_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/statement_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/plot_installments_reference_screen.dart';
import 'package:flutter/services.dart';
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

    final String accountNumber = 'PK-0011-2233-4455';
    final double balance = 125430.75;

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
            _AccountSummaryCard(
              accountNumber: accountNumber,
              balance: balance,
              onViewStatement: () => _openStatement(context),
            ),
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
                // SizedBox(width: 12.w),
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
            Column(
              children:
                  paymentOptions
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
            ),
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
      MaterialPageRoute(builder: (_) => const PlotInstallmentReferenceScreen()),
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

  void _openStatement(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StatementScreen()));
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

class _AccountSummaryCard extends StatelessWidget {
  final String accountNumber;
  final double balance;
  final VoidCallback onViewStatement;

  const _AccountSummaryCard({
    required this.accountNumber,
    required this.balance,
    required this.onViewStatement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primaryRed),
              SizedBox(width: 8.w),
              Text(
                'Account Summary',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onViewStatement,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Statement'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Current Balance',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(balance),
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.iconColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Account Number',
                  value: accountNumber,
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: accountNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account number copied')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'PKR ${value.toStringAsFixed(2)}';
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoTile({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.fillColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(value, style: AppTextStyles.bodyMediumBold),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
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
