import 'package:ecom_app/base/res/media.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../base/res/styles/app_styles.dart';

class TrackOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Track Order", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        
      ),
      backgroundColor: AppStyles.bgColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Product Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(AppMedia.welcomeImage, height: 100, width: 100, fit: BoxFit.cover,),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Brown Suite", style: AppStyles.headLineStyle3.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text("Size: XL | Qty: 10pcs", style: AppStyles.textStyle
                                .copyWith(color: AppStyles.greColor),),
                      SizedBox(height: 4),
                      Text("\$120",style: AppStyles.headLineStyle4.copyWith(color: AppStyles.blackColor,fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),

  Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
            SizedBox(height: 20),

            // Order Details
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Order Details", style: AppStyles.headLineStyle3,)),
              SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Expected Delivery Date"),
                Text("03 Sep 2023", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tracking ID"),
                Text("TRK452126542", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 15,),

 Divider(
              color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
      

            // Order Status
             Align(
              alignment: Alignment.centerLeft,
              child: Text("Order Status", style: AppStyles.headLineStyle3,)),
              SizedBox(height: 15,),
            Column(
              children: [
                _buildTimelineTile(
                  isFirst: true,
                  isLast: false,
                  title: "Order Placed",
                  date: "23 Aug 2023, 04:25 PM",
                  isActive: true,
                  icon: Icons.receipt_long,
                ),
                _buildTimelineTile(
                  isFirst: false,
                  isLast: false,
                  title: "In Progress",
                  date: "23 Aug 2023, 03:54 PM",
                  isActive: true,
                  icon: Icons.local_shipping_outlined,
                ),
                _buildTimelineTile(
                  isFirst: false,
                  isLast: false,
                  title: "Shipped",
                  date: "Expected 02 Sep 2023",
                  isActive: false,
                  icon: Icons.local_shipping,
                ),
                _buildTimelineTile(
                  isFirst: false,
                  isLast: true,
                  title: "Delivered",
                  date: "23 Aug 2023, 2023",
                  isActive: false,
                  icon: Icons.inventory,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required bool isFirst,
    required bool isLast,
    required String title,
    required String date,
    required bool isActive,
    required IconData icon,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
        iconStyle: IconStyle(
          iconData: isActive ? Icons.check : Icons.circle_outlined,
          color: Colors.white,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: isActive ? AppStyles.primaryColor : Colors.grey.shade300,
        thickness: 2,
      ),
      endChild: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Icon(icon, color: isActive ? AppStyles.primaryColor : Colors.grey),
      ),
    );
  }
}
