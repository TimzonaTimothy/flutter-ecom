import 'package:flutter/material.dart';

import '../res/styles/app_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool hasBackground;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.horizontalPadding,
    this.verticalPadding,
    this.hasBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? screenWidth * 0.34,
          vertical: verticalPadding ?? screenHeight * 0.008, 
        ),
        decoration: BoxDecoration(
          color: hasBackground ? AppStyles.primaryColor : Colors.transparent,
          border: Border.all(
            color: AppStyles.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: AppStyles.headLineStyle2.copyWith(color: AppStyles.whiteColor),
        ),
      ),
    );
  }
}
