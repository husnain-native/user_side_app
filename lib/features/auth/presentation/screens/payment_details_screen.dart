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
  bool _isPaying = false;

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
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          widget.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.iconColor),
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
        child: CustomButton(
          text: _isPaying ? 'Processing...' : 'Review & Pay',
          onPressed: () {
            if (!_isPaying) {
              _onPayPressed();
            }
          },
          isLoading: _isPaying,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRed.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 26.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      widget.subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _quickAmountChip(1000),
                _quickAmountChip(5000),
                _quickAmountChip(10000),
              ],
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
            size: 18.w,
            color: selected ? Colors.white : AppColors.primaryRed,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primaryRed,
            ),
          ),
        ],
      ),
      selectedColor: AppColors.primaryRed,
      backgroundColor: AppColors.primaryRed.withOpacity(0.08),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primaryRed.withOpacity(0.6)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _selectedMethod == PaymentMethod.card
                        ? Icons.credit_card
                        : _selectedMethod == PaymentMethod.bankTransfer
                        ? Icons.account_balance
                        : Icons.phone_iphone,
                    color: AppColors.primaryRed,
                    size: 18.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('Details', style: AppTextStyles.bodyMediumBold),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primaryRed.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _selectedMethod.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ..._buildMethodFields(),
          ],
        ),
      ),
    );
  }

  Widget _quickAmountChip(double value) {
    final String label = value.toStringAsFixed(0);
    return ActionChip(
      label: Text('PKR $label'),
      onPressed: () {
        _setAmount(value);
      },
      avatar: Icon(Icons.add, size: 16.w, color: AppColors.primaryRed),
      backgroundColor: AppColors.primaryRed.withOpacity(0.06),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primaryRed.withOpacity(0.35)),
      ),
    );
  }

  void _setAmount(double value) {
    _amountController.text = value.toStringAsFixed(0);
    setState(() {});
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

  // Legacy _submit removed in favor of review flow

  Future<void> _onPayPressed() async {
    if (_formKey.currentState?.validate() != true) return;
    if (!_validateMethodSpecific()) return;

    await _showReviewSheet();
  }

  Future<void> _showReviewSheet() async {
    final String amountText =
        _amountController.text.trim().isEmpty
            ? '—'
            : 'PKR ${_amountController.text.trim()}';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.receipt_long,
                      color: AppColors.primaryRed,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Payment',
                          style: AppTextStyles.bodyMediumBold,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _ReviewRow(label: 'Amount', value: amountText),
              SizedBox(height: 8.h),
              _ReviewRow(label: 'Method', value: _selectedMethod.label),
              if (_referenceController.text.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                _ReviewRow(
                  label: 'Reference',
                  value: _referenceController.text.trim(),
                ),
              ],
              if (_notesController.text.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                _ReviewRow(label: 'Notes', value: _notesController.text.trim()),
              ],
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Edit'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        setState(() => _isPaying = true);
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (!mounted) return;
                        setState(() => _isPaying = false);
                        await _showSuccessDialog();
                      },
                      child: const Text('Confirm & Pay'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Payment Successful',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim, _, __) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: anim.value,
            child: Center(
              child: Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(16.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 280.w, maxWidth: 340.w),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: const Color(0xFF16A34A),
                            size: 40.w,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Payment Successful',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Your payment has been processed successfully.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMediumBold,
          ),
        ),
      ],
    );
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
