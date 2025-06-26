import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import '../cart/views/cart_screen.dart';
import '../home/views/home_screen.dart';
import '../profile/views/profile_screen.dart';
import '../wishlist/views/wishlist.dart';
import 'res/styles/app_styles.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const HomeScreen(),
    const WishListScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  //change index
  int _selectedindex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedindex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppStyles.bgColor, // Forces background color
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // soft shadow
                offset: const Offset(0, -2), // shadow at the top
                blurRadius: 6,
              ),
            ],
          ),
          child: BottomNavigationBar(
              currentIndex: _selectedindex,
              onTap: _onItemTapped,
              selectedItemColor: AppStyles.primaryColor,
              unselectedItemColor: AppStyles.greColor,
              showSelectedLabels: true,
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
                    activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
                    label: "Home"),
                const BottomNavigationBarItem(
                    icon: Icon(FluentSystemIcons.ic_fluent_heart_regular),
                    activeIcon: Icon(FluentSystemIcons.ic_fluent_heart_filled),
                    label: "Wishlist"),
                BottomNavigationBarItem(
                    icon: Badge.count(
                        count: 10,
                        child: const Icon(Icons.shopping_cart_outlined)),
                    activeIcon: const Icon(Icons.shopping_cart),
                    label: "Carts"),
                const BottomNavigationBarItem(
                    icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
                    activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
                    label: "Profile"),
              ]),
        ),
      ),
    );
  }
}
