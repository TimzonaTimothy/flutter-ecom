import 'package:flutter/material.dart';
import 'track_order_screen.dart';

class EReceiptScreen extends StatelessWidget {
  final int orderId;
  const EReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) =>
      TrackOrderPage(orderId: orderId, isReceipt: true);
}
