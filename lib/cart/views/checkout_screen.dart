import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        centerTitle: true,
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // Navigate to payment
          },
          child: const Text(
            "Continue to Payment",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Shipping Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.brown),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Home", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text("1901 Thornridge Cir. Shiloh, Hawaii 81063"),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("CHANGE"),
              )
            ],
          ),
          const Divider(height: 32),
          const Text("Choose Shipping Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Colors.brown),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Economy", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text("Estimated Arrival  25 August 2023"),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("CHANGE"),
              )
            ],
          ),
          const Divider(height: 32),
          const Text("Order List", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._buildOrderItems(),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems() {
    final orders = [
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image": "https://via.placeholder.com/80x80.png?text=1",
      },
      {
        "title": "Brown Suite",
        "size": "XL",
        "price": "\$120",
        "image": "https://via.placeholder.com/80x80.png?text=2",
      },
      {
        "title": "Brown Jacket",
        "size": "XL",
        "price": "\$83.97",
        "image": "https://via.placeholder.com/80x80.png?text=3",
      },
    ];

    return orders
        .map(
          (item) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['image']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("Size: ${item['size']}"),
                      const SizedBox(height: 4),
                      Text(item['price']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
