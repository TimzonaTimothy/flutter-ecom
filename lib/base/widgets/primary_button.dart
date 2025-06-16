import 'package:flutter/material.dart';

import '../res/styles/app_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool hasBackground;
  final bool isLoading;
  final bool isBorder;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.horizontalPadding,
    this.verticalPadding,
    this.hasBackground = true,
    this.isLoading = false,
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine button background color based on hasBackground, enabled state, etc.
    Color backgroundColor;
    if (!hasBackground) {
      backgroundColor = Colors.transparent;
    } else if (onTap == null) {
      // Disabled state
      backgroundColor = AppStyles.primaryColor.withOpacity(0.5);
    } else {
      backgroundColor = AppStyles.primaryColor;
    }

    // Determine text color
    Color textColor =
        hasBackground ? AppStyles.whiteColor : AppStyles.primaryColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading || onTap == null ? null : onTap,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size.fromHeight(50),
          disabledBackgroundColor: AppStyles.primaryColor.withOpacity(0.5),
          disabledForegroundColor: AppStyles.primaryColor.withOpacity(0.5),

          backgroundColor: backgroundColor,
          side: isBorder
              ? BorderSide(color: AppStyles.primaryColor, width: 2)
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? screenWidth * 0.34,
            vertical: verticalPadding ?? screenHeight * 0.008,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Overlay color for pressed/highlighted states (optional)
          // You can customize this if needed
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AppStyles.headLineStyle2.copyWith(color: textColor),
              ),
      ),
    );
  }
}
