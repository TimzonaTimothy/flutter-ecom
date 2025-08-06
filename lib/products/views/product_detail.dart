import 'dart:convert';

import 'package:ecom_app/base/res/media.dart';
import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/my_request.dart';
import '../../base/widgets/product_card.dart';
import '../../base/widgets/product_shimmer.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/create_cart_model.dart';
import '../../order/controllers/review_controller.dart';
import '../../order/models/review_model.dart';
import '../../order/service/review_service.dart';
import '../../order/views/review_screen.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class ProductDetail extends StatefulWidget {
  final int productId;

  const ProductDetail({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late List<String> imageList;
  ProductModel? currentProduct;
  List<ReviewModel> reviews = [];
  int selectedImageIndex = 0;
  String isSelectedSize = "";
  String isSelectedColor = "";
  bool isLoading = true;
  bool isLoadingProduct = false;
  bool isLoadingReviews = false;

  final ReviewController reviewController = Get.put(ReviewController());

  @override
  void initState() {
    super.initState();
    Get.put(CartController());
    _fetchProductById(widget.productId);
    _fetchReviews(widget.productId);
  }

  void _initializeWithProduct() {
    // Fetch similar products
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

  Future<void> _fetchProductById(int productId) async {
    setState(() {
      isLoadingProduct = true;
    });

    try {
      // First check if product exists in ProductsController
      final productsController = Get.find<ProductsController>();
      final existingProduct = productsController.products.firstWhereOrNull(
        (p) => p.id == productId,
      );

      if (existingProduct != null) {
        // Product found in existing products
        currentProduct = existingProduct;
        imageList = currentProduct?.imageUrls ?? [];
        _initializeWithProduct();
      } else {
        // Fetch from API
        final data = await MyRequest('products/$productId/', {}, true).getApi();

        if (data != null) {
          final Map<String, dynamic> productData = jsonDecode(data);
          // Convert the API response to ProductModel
          currentProduct = ProductModel.fromJson(productData);
          imageList = currentProduct?.imageUrls ?? [];
          _initializeWithProduct();
        }
      }
    } catch (e) {
      print("Error fetching product: $e");
      // Handle error - maybe show error message or go back
    } finally {
      setState(() {
        isLoadingProduct = false;
      });
    }
  }

  Future<void> _fetchReviews(int productId) async {
    setState(() {
      isLoadingReviews = true;
    });

    try {
      final fetchedReviews = await ReviewService.getProductReviews(productId);

      setState(() {
        reviews = fetchedReviews ?? [];
      });
      await reviewController.loadExistingReview(productId);
    } catch (e) {
      showFailureSnackbar('Failed to load reviews');
    } finally {
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  bool _isInCart() {
    final cartItems = CartController.to.cartItems;

    return cartItems.any((item) =>
        item.product?.id == currentProduct?.id &&
        (item.size ?? '') == isSelectedSize &&
        (item.color ?? '') == isSelectedColor);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingProduct) {
      return Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Product Details", style: AppStyles.headLineStyle2),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentProduct == null) {
      return Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Product Details", style: AppStyles.headLineStyle2),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

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
          GetBuilder<WishlistController>(
            builder: (wishlistController) {
              final isFavorite =
                  wishlistController.isFavorite(currentProduct!.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppStyles.primaryColor : Colors.black,
                ),
                onPressed: () {
                  wishlistController.toggleWishlist(currentProduct!.id);
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.productId,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageList.isNotEmpty
                          ? imageList[selectedImageIndex]
                          : 'https://via.placeholder.com/300',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
                    '${currentProduct?.category.title ?? 'Category'} / ${currentProduct?.brand.title ?? 'Brand'}',
                    style: TextStyle(color: AppStyles.greColor)),
                const Spacer(),
                Icon(Icons.star, color: AppStyles.primaryColor, size: 20),
                const SizedBox(width: 4),
                Text(currentProduct?.rating.toStringAsFixed(1) ?? '0.0',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(currentProduct?.title ?? 'Product Title',
                style: AppStyles.headLineStyle2
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Product Details",
                style: AppStyles.headLineStyle2
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: currentProduct?.description ?? "No description available",
                style: AppStyles.textStyle,
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
              children: (currentProduct?.sizes ?? []).map((size) {
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
              children: (currentProduct?.colors ?? []).map((color) {
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

            // Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => AppDoubleText(
                    bigText: "Customer Reviews (${reviews.length})",
                    smallText: reviewController.hasExistingReview.value
                        ? "Update Your Review"
                        : "Write a Review",
                    func: () {
                      Get.to(
                        () => LeaveReviewPage(
                          productId: currentProduct!.id,
                          onReviewSubmitted: () =>
                              _fetchReviews(widget.productId),
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            isLoadingReviews
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "No reviews yet. Be the first to write one!",
                          style:
                              AppStyles.textStyle.copyWith(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: reviews
                            .map((review) => _buildReviewCard(review))
                            .toList(),
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
                Text('\$${currentProduct?.originalPrice ?? '0'}',
                    style: AppStyles.headLineStyle3.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                if (currentProduct == null) return;

                if ((currentProduct!.sizes?.isNotEmpty ?? false) &&
                    isSelectedSize.isEmpty) {
                  showFailureSnackbar("Please select a size");
                  return;
                }

                if ((currentProduct!.colors?.isNotEmpty ?? false) &&
                    isSelectedColor.isEmpty) {
                  showFailureSnackbar("Please select a color");
                  return;
                }

                final cartItem = CreateCartModel(
                  product: currentProduct!.id,
                  size: isSelectedSize.isNotEmpty ? isSelectedSize : null,
                  color: isSelectedColor.isNotEmpty ? isSelectedColor : null,
                  quantity: 1,
                );

                setState(() => isLoading = true);
                bool success = false;

                if (_isInCart()) {
                  final existing = CartController.to.cartItems.firstWhere(
                      (item) =>
                          item.product?.id == currentProduct?.id &&
                          (item.size ?? '') == isSelectedSize &&
                          (item.color ?? '') == isSelectedColor);

                  success =
                      await CartController.to.removeFromCart(existing.id!);
                  if (success) {
                    showSuccessSnackbar("Removed from cart!");
                    await CartController.to
                        .fetchCartItems(); // 👈 reload updated cart
                  }
                } else {
                  success = await CartController.to.addToCart(cartItem);
                  if (success) {
                    showSuccessSnackbar("Added to cart!");
                    await CartController.to
                        .fetchCartItems(); // 👈 reload updated cart
                  }
                }

                setState(() => isLoading = false);
              },
              icon: Icon(
                Icons.shopping_bag_outlined,
                color: AppStyles.whiteColor,
              ),
              label: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isInCart() ? "Remove from Cart" : "Add to Cart",
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.subject, style: AppStyles.textStyle),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                unratedColor: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.review,
            style: AppStyles.textStyle.copyWith(color: Colors.grey[600]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Reviewed on ${review.createdAt.toString().substring(0, 10)}',
            style: AppStyles.textStyle.copyWith(
              color: AppStyles.greColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GetBuilder<ProductsController>(
      builder: (productsController) {
        final similarProducts = productsController.products
            .where((p) =>
                p.id != currentProduct!.id &&
                p.productType == currentProduct!.productType)
            .toList();

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
              productId: product.id,
              imagePath: imageUrl,
              title: product.title ?? '',
              price: product.originalPrice ?? '0',
              rating: product.rating ?? 0,
              oldPrice: product.discountPrice ?? '0',
              onTap: () {
                Get.to(() => ProductDetail(productId: product.id),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500));
              },
            );
          }).toList(),
        );
      },
    );
  }
}
