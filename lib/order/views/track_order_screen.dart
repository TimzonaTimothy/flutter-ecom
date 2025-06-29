import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Order"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Product Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/brown_suit.png', height: 100, width: 100),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Brown Suite", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Size: XL | Qty: 10pcs"),
                      SizedBox(height: 4),
                      Text("\$120", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Order Details
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

            SizedBox(height: 30),

            // Order Status
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
        color: isActive ? Colors.brown : Colors.grey.shade300,
        iconStyle: IconStyle(
          iconData: isActive ? Icons.check : Icons.circle_outlined,
          color: Colors.white,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: isActive ? Colors.brown : Colors.grey.shade300,
        thickness: 2,
      ),
      endChild: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Icon(icon, color: isActive ? Colors.brown : Colors.grey),
      ),
    );
  }
}
