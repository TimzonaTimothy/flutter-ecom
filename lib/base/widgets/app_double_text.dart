import 'package:flutter/material.dart';
import '../res/styles/app_styles.dart';

class AppDoubleText extends StatelessWidget {
  const AppDoubleText({
    Key? key,
    required this.bigText,
    this.smallText,
     this.func,
  }) : super(key: key);

  final String bigText;
  final String? smallText;
  final VoidCallback? func;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          bigText,
          style: AppStyles.headLineStyle2,
          overflow: TextOverflow.ellipsis,
        ),
        InkWell(
          onTap: func,
          child: Text(
            smallText ?? '',
            style: AppStyles.headLineStyle4.copyWith(
          
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
