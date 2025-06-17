
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import '../home/views/home_screen.dart';
import 'res/styles/app_styles.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const HomeScreen(),
    const Center(child: Text("Wishlist")),
    const Center(child: Text("Cart")),
    const Center(child: Text("Profile")),
  ];
  
  //change index 
  int _selectedindex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: appScreens[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        onTap: _onItemTapped,
          selectedItemColor: AppStyles.primaryColor,
          unselectedItemColor: AppStyles.greColor,
          showSelectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),

                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_heart_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_heart_filled),
                label: "Wishlist"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: "Carts"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
                label: "Profile"),
          ]),
    );
  }
}