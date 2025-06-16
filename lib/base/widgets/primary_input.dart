import 'package:flutter/material.dart';

import '../res/styles/app_styles.dart';

class PrimaryInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool hasBackground;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const PrimaryInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.horizontalPadding,
    this.verticalPadding,
    this.hasBackground = true,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.validator,
  });

  @override
  State<PrimaryInput> createState() => _PrimaryInputState();
}

class _PrimaryInputState extends State<PrimaryInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: widget.hasBackground ? AppStyles.primaryColor.withOpacity(0.05) : Colors.transparent,
        border: Border.all(
          color: AppStyles.primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
        decoration: InputDecoration(
          counterText: '',
          hintText: widget.hintText,
          hintStyle: AppStyles.textStyle.copyWith(
            color: AppStyles.textColor.withOpacity(0.6),
          ),
          border: InputBorder.none,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppStyles.primaryColor,
                  ),
                  onPressed: _toggleObscure,
                )
              : null,
        ),
      ),
    );
  }
}
