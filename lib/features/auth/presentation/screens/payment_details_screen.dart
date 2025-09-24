import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/widgets/custom_button.dart';
import 'package:park_chatapp/core/widgets/custom_text_field.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String title;
  final String? subtitle;

  const PaymentDetailsScreen({super.key, required this.title, this.subtitle});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  final TextEditingController _walletProviderController =
      TextEditingController();
  final TextEditingController _walletNumberController = TextEditingController();

  bool _saveAsBeneficiary = false;

  PaymentMethod _selectedMethod = PaymentMethod.card;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();

    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();

    _bankNameController.dispose();
    _accountNumberController.dispose();

    _walletProviderController.dispose();
    _walletNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          widget.title,
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              SizedBox(height: 16.h),
              _buildAmountCard(),
              SizedBox(height: 16.h),
              _buildMethodSelector(),
              SizedBox(height: 12.h),
              _buildMethodDetailsCard(),
              SizedBox(height: 16.h),
              _buildReferenceNotesCard(),
              SizedBox(height: 12.h),
              _buildSaveToggleCard(),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        child: CustomButton(text: 'Review & Pay', onPressed: _submit),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payments,
                color: AppColors.primaryRed,
                size: 24.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTextStyles.bodyMediumBold),
                  if (widget.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        widget.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(62, 248, 230, 203),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Text(
                    'PKR',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 24.sp,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Please enter amount';
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0)
                          return 'Enter a valid amount';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildMethodChip('Card', PaymentMethod.card, Icons.credit_card),
            _buildMethodChip(
              'Bank Transfer',
              PaymentMethod.bankTransfer,
              Icons.account_balance,
            ),
            _buildMethodChip(
              'Mobile Wallet',
              PaymentMethod.mobileWallet,
              Icons.phone_iphone,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodChip(String label, PaymentMethod method, IconData icon) {
    final bool selected = _selectedMethod == method;
    return ChoiceChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.w,
            color: selected ? Colors.white : AppColors.primaryRed,
          ),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: selected ? Colors.white : AppColors.primaryRed,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: AppColors.primaryRed,
      backgroundColor: AppColors.primaryRed.withOpacity(0.08),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primaryRed.withOpacity(0.6)),
      ),
      onSelected: (_) => setState(() => _selectedMethod = method),
    );
  }

  Widget _buildMethodDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryRed,
                  size: 18.w,
                ),
                SizedBox(width: 6.w),
                Text('Details', style: AppTextStyles.bodyMediumBold),
              ],
            ),
            SizedBox(height: 12.h),
            ..._buildMethodFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMethodFields() {
    switch (_selectedMethod) {
      case PaymentMethod.card:
        return [
          CustomTextField(
            label: 'Card Number',
            keyboardType: TextInputType.number,
            controller: _cardNumberController,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter card number';
              if (value.replaceAll(' ', '').length < 12)
                return 'Card number looks short';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Expiry (MM/YY)',
                  keyboardType: TextInputType.datetime,
                  controller: _expiryController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter expiry';
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  label: 'CVV',
                  keyboardType: TextInputType.number,
                  controller: _cvvController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter CVV';
                    if (value.trim().length < 3) return 'CVV must be 3+ digits';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ];
      case PaymentMethod.bankTransfer:
        return [
          CustomTextField(
            label: 'Bank Name',
            controller: _bankNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter bank name';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Account Number',
            keyboardType: TextInputType.number,
            controller: _accountNumberController,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter account number';
              return null;
            },
          ),
        ];
      case PaymentMethod.mobileWallet:
        return [
          CustomTextField(
            label: 'Wallet Provider (e.g., JazzCash, Easypaisa)',
            controller: _walletProviderController,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter provider';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Wallet Number',
            keyboardType: TextInputType.phone,
            controller: _walletNumberController,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter wallet number';
              return null;
            },
          ),
        ];
    }
  }

  Widget _buildReferenceNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryRed,
                  size: 18.w,
                ),
                SizedBox(width: 6.w),
                Text('Additional Info', style: AppTextStyles.bodyMediumBold),
              ],
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              label: 'Reference / Account No.',
              controller: _referenceController,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              label: 'Notes (optional)',
              controller: _notesController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveToggleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text('Save as beneficiary', style: AppTextStyles.bodyMedium),
        subtitle: Text(
          'Quickly pay next time',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
        ),
        value: _saveAsBeneficiary,
        activeColor: AppColors.primaryRed,
        onChanged: (value) => setState(() => _saveAsBeneficiary = value),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (!_validateMethodSpecific()) return;

    final snackText =
        'Payment details submitted for '
        '${widget.title} via ${_selectedMethod.label}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(snackText)));
    Navigator.of(context).pop();
  }

  bool _validateMethodSpecific() {
    switch (_selectedMethod) {
      case PaymentMethod.card:
        if (_cardNumberController.text.trim().replaceAll(' ', '').length < 12) {
          _showError('Enter a valid card number');
          return false;
        }
        if (_cvvController.text.trim().length < 3) {
          _showError('CVV must be 3+ digits');
          return false;
        }
        return true;
      case PaymentMethod.bankTransfer:
        if (_bankNameController.text.trim().isEmpty ||
            _accountNumberController.text.trim().isEmpty) {
          _showError('Enter bank name and account number');
          return false;
        }
        return true;
      case PaymentMethod.mobileWallet:
        if (_walletProviderController.text.trim().isEmpty ||
            _walletNumberController.text.trim().isEmpty) {
          _showError('Enter wallet provider and number');
          return false;
        }
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum PaymentMethod { card, bankTransfer, mobileWallet }

extension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet';
    }
  }
}
