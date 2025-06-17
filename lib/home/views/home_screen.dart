import 'package:flutter/material.dart';

import '../../base/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: Container(
        child: const Center(
          child: Text('Hello Home'),
        ),
      ),
    );
  }
}
