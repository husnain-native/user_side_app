import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/add_card_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/transfer_amount_screen.dart';

class PaymentMethodSelectionScreen extends StatefulWidget {
  final String billType;
  final String reference;
  final double amount;
  final String billingCompany;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.billType,
    required this.reference,
    required this.amount,
    required this.billingCompany,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> {
  String selectedPaymentMethod = 'mastercard'; // Default selection
  List<PaymentMethod> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _initializePaymentMethods();
  }

  void _initializePaymentMethods() {
    paymentMethods = [
      PaymentMethod(
        id: 'mastercard',
        name: 'Mastercard',
        subtitle: '•••• 7578',
        icon: 'assets/images/mastercard.jpg',
        isPrimary: true,
        isCard: true,
      ),
      PaymentMethod(
        id: 'cash',
        name: 'Cash',
        subtitle: '',
        icon: 'assets/images/cash.png',
        isPrimary: false,
        isCard: false,
      ),
      PaymentMethod(
        id: 'credit_debit',
        name: 'Credit or Debit Card',
        subtitle: '',
        icon: 'assets/images/multiple.jpg',
        isPrimary: false,
        isCard: true,
        isAddNew: true,
      ),
      PaymentMethod(
        id: 'jazzcash',
        name: 'JazzCash',
        subtitle: '',
        icon: 'assets/images/logo_jazzcash.webp',
        isPrimary: false,
        isCard: false,
      ),
      PaymentMethod(
        id: 'easypaisa',
        name: 'easypaisa',
        subtitle: '',
        icon: 'assets/images/logo_easy.jpg',
        isPrimary: false,
        isCard: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Select a payment method',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return _PaymentMethodTile(
                  method: method,
                  isSelected: selectedPaymentMethod == method.id,
                  onTap: () {
                    if (method.isAddNew) {
                      _navigateToAddCard();
                    } else {
                      setState(() {
                        selectedPaymentMethod = method.id;
                      });
                    }
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFE91E63,
                    ), // Pink color from image
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => AddCardScreen(
              onCardAdded: (cardData) {
                // Add new card to the list
                setState(() {
                  paymentMethods.insert(
                    1, // Insert after Mastercard
                    PaymentMethod(
                      id: 'new_card_${DateTime.now().millisecondsSinceEpoch}',
                      name: cardData['type'] ?? 'Card',
                      subtitle:
                          '•••• ${cardData['number']?.substring((cardData['number']?.length ?? 4) - 4) ?? '0000'}',
                      icon: _getCardIcon(cardData['type']),
                      isPrimary: false,
                      isCard: true,
                    ),
                  );
                  selectedPaymentMethod = paymentMethods[1].id;
                });
              },
            ),
      ),
    );
  }

  String _getCardIcon(String? cardType) {
    switch (cardType?.toLowerCase()) {
      case 'mastercard':
        return 'assets/images/mastercard.jpg';
      case 'visa':
        return 'assets/images/visa.jpg';
      default:
        return 'assets/images/mastercard.jpg';
    }
  }

  void _confirmPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => TransferAmountScreen(
              fromName: 'HUSNAIN ARIF',
              fromAccount: '584648495855',
              balance: 234796.61,
              toName: widget.billingCompany,
              toAccount: '8975219217',
              lastSummary: 'Last: PKR 5,400 | 05 Sep 2025',
              transferLimit: 3000000,
              flow: 'utility',
              billType: widget.billType,
              billReference: widget.reference,
              billDate: '05 Oct 2025',
              billAmount: widget.amount,
            ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final bool isPrimary;
  final bool isCard;
  final bool isAddNew;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.isCard,
    this.isAddNew = false,
  });
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Payment method icon/logo
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                // color: Colors.grey[100],
              ),
              child:
                  method.isAddNew
                      ? _buildAddNewIcon()
                      : method.icon.isNotEmpty
                      ? _buildIcon()
                      : _buildDefaultIcon(),
            ),
            SizedBox(width: 16.w),
            // Payment method details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      if (method.isPrimary) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Primary',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (method.subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Selection indicator or arrow
            if (method.isAddNew)
              Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey[400])
            else if (method.isCard && !method.isAddNew)
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, size: 12.w, color: Colors.white)
                        : null,
              )
            else
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Container(
                          margin: EdgeInsets.all(3.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        )
                        : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        method.icon,
        width: 40.w,
        height: 40.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      ),
    );
  }

  Widget _buildAddNewIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        method.icon,
        width: 40.w,
        height: 40.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 16.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 8.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultIcon() {
    IconData iconData;
    Color iconColor;

    switch (method.name.toLowerCase()) {
      case 'cash':
        iconData = Icons.money;
        iconColor = Colors.green;
        break;
      case 'jazzcash':
        iconData = Icons.phone_android;
        iconColor = Colors.orange;
        break;
      case 'easypaisa':
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.credit_card;
        iconColor = Colors.blue;
    }

    return Icon(iconData, size: 24.w, color: iconColor);
  }
}
