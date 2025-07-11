import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/filter_card.dart';
import '../../base/widgets/product_card.dart';
import '../controllers/wishlist_controller.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  int selectedFilterIndex = 0;

  final List<String> filters = ['All', 'Newest', 'Popular', 'Man', 'Woman','unisex'];

  final List<Map<String, String>> allProducts = [
    {'title': 'Summer Jacket', 'price': '100'},
    {'title': 'Winter Hoodie', 'price': '120'},
    {'title': 'Sneakers', 'price': '90'},
    {'title': 'Raincoat', 'price': '80'},
    // Add category key if you want to filter by category
  ];

  List<Map<String, String>> get filteredProducts {
    // Replace with real filter logic
    if (selectedFilterIndex == 0) return allProducts; // "All"
    return allProducts.reversed.toList(); // For demo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("My Wishlist", style: AppStyles.headLineStyle2),
        centerTitle: true,
       
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 20, top: 20),
        children: [
          

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: FilterChipsRow(
              filters: filters,
              selectedIndex: selectedFilterIndex,
              onSelected: (index) {
                setState(() {
                  selectedFilterIndex = index;
                });
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
         

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProductGrid(filteredProducts), ),
            ]),
          );
     
  }

  Widget _buildProductGrid(List<Map<String, String>> products) {
    final products = [
      {'id':'1','title': 'Summer Jacket', 'price': '100'},
      {'id':'2','title': 'Winter Hoodie', 'price': '120'},
      {'id':'3','title': 'Sneakers', 'price': '90'},
      {'id':'4','title': 'Raincoat', 'price': '80'},
      {'id':'5','title': 'Summer Jacket', 'price': '100'},
      {'id':'6','title': 'Winter Hoodie', 'price': '120'},
      {'id':'7','title': 'Sneakers', 'price': '90'},
    ];

    return GridView.count(
      key: ValueKey<int>(selectedFilterIndex),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 20,
      childAspectRatio: 0.76,
      children: products.map((product) {
        return Container();
//         ProductCard(
//           productId: int.parse(product['id'].toString()),
//           imagePath:
//               "https://assets.ajio.com/medias/sys_master/root/20230720/dYSU/64b95b15a9b42d15c965a70b/-473Wx593H-469514310-blue-MODEL2.jpg",
//           title: product['title']!,
//           price: product['price']!,
//           rating: double.parse(product['rating'] ?? '4'),
//           oldPrice: product['price']!,
//           onTap: () {},
//          onTapWishlist: () {
//   Get.find<WishlistController>().toggleWishlist(product.id);
// },
// isFavorite: Get.find<WishlistController>().isFavorite(int.parse(product.id)),

//         );
      }).toList(),
    );
  }
}
