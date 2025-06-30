import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> cancelledOrders = [
    {
      "title": "Brown Jacket",
      "image": "assets/jacket1.png",
      "size": "XL",
      "qty": 10,
      "price": 83.97,
    },
    {
      "title": "Brown Suite",
      "image": "assets/man1.png",
      "size": "XL",
      "qty": 10,
      "price": 120,
    },
    // Add more items here
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 2; // default to "Cancelled"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.brown,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.brown,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('Active Orders')),
          Center(child: Text('Completed Orders')),
          CancelledOrdersList(cancelledOrders: cancelledOrders),
        ],
      ),
    );
  }
}




class CancelledOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> cancelledOrders;

  const CancelledOrdersList({required this.cancelledOrders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cancelledOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = cancelledOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  order['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['title'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("Size: ${order['size']}  |  Qty : ${order['qty']}pcs", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("\$${order['price']}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {},
                child: Text('Re-Order', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
