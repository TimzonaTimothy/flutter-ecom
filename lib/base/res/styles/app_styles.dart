import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primary = const Color(0xFFFF8901);

class AppStyles {
  static Color primaryColor = primary;
  static Color bgColor = const Color(0xFFeeedf2);
  static Color textColor = const Color(0xFF757575);
  static Color greColor = const Color(0xFF555555);
  static Color whiteSmokeColor = const Color(0xFFB3B3B3);
  static Color whiteColor = const Color(0xFFFFFFFF);

  static TextStyle textStyle = GoogleFonts.poppins(
    fontSize: 12,
    color: textColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle headLineStyle1 = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle headLineStyle2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static TextStyle headLineStyle3 = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static TextStyle headLineStyle4 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: whiteSmokeColor,
  );
}
