import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class AddCardScreen extends StatefulWidget {
  final Function(Map<String, String>) onCardAdded;

  const AddCardScreen({super.key, required this.onCardAdded});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  bool _saveCard = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Husnain arif Qazi'; // Pre-filled as in image
    _cardNumberController.addListener(_validateForm);
    _expiryController.addListener(_validateForm);
    _cvcController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _cardNumberController.text.length >= 16 &&
          _expiryController.text.length >= 5 &&
          _cvcController.text.length >= 3 &&
          _nameController.text.isNotEmpty;
    });
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
          'Add a credit or debit card',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.iconColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Number Field
              _buildTextField(
                controller: _cardNumberController,
                label: 'Card number',
                hintText: '',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberInputFormatter(),
                ],
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),

              // Expiry and CVC Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryController,
                      label: 'MM/YY',
                      hintText: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateInputFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _cvcController,
                      label: 'CVC',
                      hintText: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      keyboardType: TextInputType.number,
                      suffixIcon: Icon(
                        Icons.credit_card,
                        color: Colors.grey[400],
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Name of the card holder',
                hintText: '',
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 24.h),

              // Save Card Checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _saveCard = !_saveCard;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color:
                            _saveCard
                                ? const Color(0xFFE91E63)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              _saveCard ? const Color(0xFFE91E63) : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child:
                          _saveCard
                              ? Icon(
                                Icons.check,
                                size: 14.w,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Save this card for a faster checkout next time',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Privacy Policy Text
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'By saving your card you grant us your consent to store your payment method for future orders. You can withdraw consent at any time.\n\nFor more information, please visit the ',
                    ),
                    TextSpan(
                      text: 'Privacy policy',
                      style: TextStyle(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const Spacer(),

              // Done Button
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _saveCardData : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid
                              ? const Color(0xFFE91E63)
                              : Colors.grey[300],
                      foregroundColor:
                          _isFormValid ? Colors.white : Colors.grey[500],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF4A9B8E), // Teal color from image
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextFormField(
            controller: controller,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  void _saveCardData() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      final cardData = {
        'number': _cardNumberController.text.replaceAll(' ', ''),
        'expiry': _expiryController.text,
        'cvc': _cvcController.text,
        'name': _nameController.text,
        'type': _getCardType(_cardNumberController.text),
      };

      widget.onCardAdded(cardData);
      Navigator.of(context).pop();
    }
  }

  String _getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    }
    return 'Unknown';
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
