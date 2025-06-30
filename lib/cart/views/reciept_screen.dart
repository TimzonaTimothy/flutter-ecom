import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/primary_button.dart';

class EReceiptScreen extends StatelessWidget {
  const EReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("E-Receipt", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            BarcodeWidget(
              
              data: 'TR2565HGJD',
              barcode: Barcode.code128(),
              width: double.infinity,
              height: 100,
            ),
                     Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    AppMedia.onborading3,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Brown Jacket',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Size : XL  |  Qty : 10pcs',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text('\$83.97',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
            buildAmountRow("Amount", "\$120.00"),
            buildAmountRow("Delivery Charge", "\$00.00"),
            buildAmountRow("Promo", "-\$31.50"),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
            buildAmountRow("Total", "-\$88.50", isBold: true),
            const SizedBox(height: 20),
            buildAmountRow("Payment Methods", "Cash"),
            buildAmountRow("Date", "23 Aug 2023, 04:25 PM"),
            buildAmountRow("Transaction ID", "TR2565HGJD", withCopy: true),
            const Spacer(),
            PrimaryButton(
              verticalPadding: 10,
              horizontalPadding: 10,
              text: 'Download E-Receipt',
              onTap: () {
                // Get.to(
                //   const PaymentMethodsScreen(),
                //   transition: Transition.rightToLeftWithFade,
                //   duration: const Duration(milliseconds: 500),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAmountRow(String title, String value,
      {bool isBold = false, bool withCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppStyles.headLineStyle4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppStyles.blackColor.withOpacity(0.5))),
          Row(
            children: [
              Text(value,
                  style: AppStyles.headLineStyle4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.blackColor)),
              if (withCopy)
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: AppStyles.primaryColor,
                  ),
                  onPressed: () {
                    // copy to clipboard logic
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
