import 'package:flutter/material.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  int selectedAddressIndex = 0;

  final List<Map<String, String>> addresses = [
    {
      "label": "Home",
      "address": "1901 Thornridge Cir. Shiloh, Hawaii 81063",
    },
    {
      "label": "Office",
      "address": "4517 Washington Ave. Manchester, Kentucky 39495",
    },
    {
      "label": "Parent’s House",
      "address": "8502 Preston Rd. Inglewood, Maine 98380",
    },
    {
      "label": "Friend’s House",
      "address": "2464 Royal Ln. Mesa, New Jersey 45463",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Shipping Address", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return AddressCard(
                  label: addresses[index]['label']!,
                  address: addresses[index]['address']!,
                  isSelected: selectedAddressIndex == index,
                  onTap: () {
                    setState(() {
                      selectedAddressIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Add new address logic
              },
              icon: const Icon(Icons.add, color: Colors.brown),
              label: const Text("Add New Shipping Address",
                  style: TextStyle(color: Colors.brown)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.brown),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Apply selected address
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Apply",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String label;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.label,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.location_pin, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Radio(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
            activeColor: Colors.brown,
          ),
        ],
      ),
    );
  }
}
