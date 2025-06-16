import 'package:flutter/material.dart';
import '../res/styles/app_styles.dart';

class PrimaryInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool hasBackground;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator; // correct type for validator

  const PrimaryInput({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.horizontalPadding,
    this.verticalPadding,
    this.hasBackground = true,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    

    return Container(
      decoration: BoxDecoration(
        // color: hasBackground ? AppStyles.primaryColor.withOpacity(0.05) : Colors.transparent,
        border: Border.all(
          color: AppStyles.primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12,),
      child: TextFormField(
        validator: validator, // moved to TextFormField
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: AppStyles.textStyle.copyWith(
            color: AppStyles.textColor.withOpacity(0.6),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
