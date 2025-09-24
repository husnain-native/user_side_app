import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';

class SignUpCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const SignUpCheckBox({Key? key, required this.value, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryRed,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
          // removes extra "touch padding"
          visualDensity: VisualDensity.compact, 
          // makes it smaller/tighter
        ),
        const SizedBox(width: 6), // 👈 control space between checkbox & text
        Expanded(
          child: Text(
            "Send me emails about new arrivals, hot deals, daily savings, and more",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
