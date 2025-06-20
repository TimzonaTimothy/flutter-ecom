import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: const Text("Product Details", style: TextStyle(color: Colors.black)),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {},
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.favorite_border, color: Colors.black),
        onPressed: () {},
      )
    ],
  ));

  }
}