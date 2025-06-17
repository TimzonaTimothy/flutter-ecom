import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import '../../base/res/media.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/app_double_text.dart';
import '../../base/widgets/category_scroller.dart';
import '../../base/widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Men', 'image': AppMedia.welcomeImage},
      {'label': 'Women', 'image': AppMedia.logo},
      {'label': 'Kids', 'image': AppMedia.welcomeImage},
      {'label': 'Men', 'image': AppMedia.logo},
      {'label': 'Women', 'image': AppMedia.welcomeImage},
      {'label': 'Kids', 'image': AppMedia.welcomeImage},
      {'label': 'Men', 'image': AppMedia.welcomeImage},
      {'label': 'Women', 'image': AppMedia.welcomeImage},
      {'label': 'Kids', 'image': AppMedia.welcomeImage},
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        title: Container(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Location", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppStyles.primaryColor,
                  ),
                  Text(
                    "Please select a location",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppStyles.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppStyles.whiteSmokeColor),
              child: Icon(
                Icons.notifications,
                color: AppStyles.textColor,
              )),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      backgroundColor: AppStyles.bgColor,
      body: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppStyles.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(width: 1, color: AppStyles.whiteColor)),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.search,
                          color: AppStyles.whiteSmokeColor,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Search',
                          style: AppStyles.textStyle
                              .copyWith(color: AppStyles.whiteSmokeColor),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppStyles.textColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    FluentSystemIcons.ic_fluent_filter_filled,
                    color: AppStyles.whiteColor,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppDoubleText(
              bigText: 'Categories',
              smallText: 'View all',
              func: () {},
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: CategoryScroller(
              items: categories,
              onTap: () {},
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: GridView.count(
    physics: const NeverScrollableScrollPhysics(), // disables GridView scrolling
    shrinkWrap: true, // makes GridView fit in ListView
    crossAxisCount: 2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 20,
    childAspectRatio: 0.78, // adjust based on your card height/width
    children:  [
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Summer Jacket Summer Jacket',
        price: '100',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Winter Hoodie Winter Hoodie',
        price: '120',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Sneakers Sneakers Sneakers',
        price: '90',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Raincoat Raincoat Raincoat',
        price: '80',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Winter Hoodie Winter Hoodie',
        price: '120',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Sneakers Sneakers Sneakers',
        price: '90',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Raincoat Raincoat Raincoat',
        price: '80',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Winter Hoodie Winter Hoodie',
        price: '120',
        onTap: () {},
      ),
      ProductCard(
        imagePath: AppMedia.welcomeImage,
        title: 'Sneakers Sneakers Sneakers',
        price: '90',
        onTap: () {},
      ),
      
    ],
  ),
),

        ],
      ),
    );
  }
}
