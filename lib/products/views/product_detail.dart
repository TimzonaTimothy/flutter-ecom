import 'package:ecom_app/base/res/media.dart';
import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/widgets/product_card.dart';
import '../../base/widgets/product_shimmer.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel product;
  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  // final List<String> imageList = [
  //   AppMedia.onborading1,
  //   AppMedia.onborading2,
  //   AppMedia.onborading3,
  //   AppMedia.welcomeImage,
  //   AppMedia.onborading1,
  //   AppMedia.onborading2,
  // ];

  late List<String> imageList;

  int selectedImageIndex = 0;
  String isSelectedSize = "S";
  String isSelectedColor = "Black";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a delay like fetching from API

    imageList = widget.product.imageUrls ?? [];

    // Register controller if not already
    if (!Get.isRegistered<ProductsController>()) {
      Get.put(ProductsController());
    }

    // Fetch similar products here, safely outside GetBuilder
    Future.delayed(Duration.zero, () {
      ProductsController.instance.getProduct();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Product Details", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    // AppMedia.onborading2,
                    imageList[selectedImageIndex],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    height: 70,
                    decoration: BoxDecoration(
                        color: AppStyles.whiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImageIndex = index;
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              imageList[index],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    '${widget.product.category.title} / ${widget.product.brand.title}',
                    style: TextStyle(color: AppStyles.greColor)),
                const Spacer(),
                Icon(Icons.star, color: AppStyles.primaryColor, size: 20),
                const SizedBox(width: 4),
                Text(widget.product.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.product.title,
                style: AppStyles.headLineStyle2
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Product Details",
                style: AppStyles.headLineStyle2
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: widget.product.description ?? "No description available",
                style: AppStyles.textStyle,
                // style: AppStyles.textStyle.copyWith(fontSize: 14),
                children: [
                  TextSpan(
                    text: "Read more",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppStyles.primaryColor),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            const Text("Select Size",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10.0,
              children: (widget.product.sizes ?? []).map((size) {
                final isSelected = size == isSelectedSize;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelectedSize = size;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppStyles.primaryColor : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Select Color",
                style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 10,
              runSpacing: 10.0,
              children: (widget.product.colors ?? []).map((color) {
                final isSelected = color == isSelectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelectedColor = color;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppStyles.primaryColor : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const AppDoubleText(bigText: 'Similar Products'),
            const SizedBox(height: 10),
            isLoading ? const ProductCardShimmer() : _buildProductGrid(),
          ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppStyles.bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          children: [
            Row(
              children: [
                Text(
                  "Total ",
                  style: AppStyles.headLineStyle3.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppStyles.whiteSmokeColor),
                ),
                Text('\$${widget.product.originalPrice}',
                    style: AppStyles.headLineStyle3.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.shopping_bag_outlined,
                color: AppStyles.whiteColor,
              ),
              label: Text(
                "Add to Cart",
                style: AppStyles.headLineStyle3
                    .copyWith(color: AppStyles.whiteColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GetBuilder<ProductsController>(
      builder: (productsController) {
        final currentProduct = widget.product;
        final similarProducts = productsController.products
            .where((p) =>
                p.id != currentProduct.id &&
                p.productType == currentProduct.productType)
            .toList();

        // final products = productsController.products
        //     .where((p) => p.id != widget.product.id)
        //     .toList();

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
          childAspectRatio: 0.76,
          children: similarProducts.map((product) {
            final imageUrl =
                (product.imageUrls != null && product.imageUrls!.isNotEmpty)
                    ? product.imageUrls!.first
                    : AppMedia.welcomeImage;
            return ProductCard(
              imagePath: imageUrl,
              title: product.title ?? '',
              price: product.originalPrice ?? '0',
              rating: product.rating ?? 0,
              oldPrice: product.discountPrice ?? '0',
              onTap: () {
                Get.to(() => ProductDetail(product: product),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500));
              },
              onTapWishlist: () {},
            );
          }).toList(),
        );
      },
    );
  }
}
