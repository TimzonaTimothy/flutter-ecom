import 'package:ecom_app/base/res/media.dart';
import 'package:ecom_app/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/styles/app_styles.dart';

class LeaveReviewPage extends StatelessWidget {
  final int? orderId;

  const LeaveReviewPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Leave Review", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                  backgroundColor: WidgetStateProperty.all(
                      AppStyles.primaryColor.withOpacity(0.1)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // ✅ Rounded corners
                    ),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: AppStyles.primaryColor, // ✅ Border color
                      width: 0.5,
                    ),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Cancel',
                  style: AppStyles.headLineStyle3
                      .copyWith(color: AppStyles.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                label: Text(
                  "Submit",
                  style: AppStyles.headLineStyle3
                      .copyWith(color: AppStyles.whiteColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product Info

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Get.to(
                      const HomeScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: Text('Re-Order',
                      style: AppStyles.textStyle
                          .copyWith(color: AppStyles.whiteColor)),
                ),
              ],
            ),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),

            // const SizedBox(height: ),
            Text("How is your order?", style: AppStyles.headLineStyle1),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
            const SizedBox(height: 8),
            Text("Your overall rating",
                style: AppStyles.headLineStyle4.copyWith(
                  fontWeight: FontWeight.w500,
                )),

            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              unratedColor: Colors.grey.shade300,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {},
            ),
            Divider(
                color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),

            // const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Add detailed review',
                  style: AppStyles.headLineStyle4.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter here',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor),
                const SizedBox(width: 6),
                Text('add photo',
                    style: GoogleFonts.poppins(color: AppStyles.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
