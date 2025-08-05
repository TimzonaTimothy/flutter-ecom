import 'package:ecom_app/base/res/media.dart';
import 'package:ecom_app/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../base/bottom_nav_bar.dart';
import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../controllers/order_controller.dart';
import '../controllers/review_controller.dart';
import '../models/order_model.dart';

// class LeaveReviewPage extends StatelessWidget {
//   final int? orderId;

//   const LeaveReviewPage({super.key, required this.orderId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Leave Review", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//       ),
//       backgroundColor: AppStyles.bgColor,
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 style: ButtonStyle(
//                   padding: WidgetStateProperty.all(
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
//                   backgroundColor: WidgetStateProperty.all(
//                       AppStyles.primaryColor.withOpacity(0.1)),
//                   shape: WidgetStateProperty.all(
//                     RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(20), // ✅ Rounded corners
//                     ),
//                   ),
//                   side: WidgetStateProperty.all(
//                     BorderSide(
//                       color: AppStyles.primaryColor, // ✅ Border color
//                       width: 0.5,
//                     ),
//                   ),
//                 ),
//                 onPressed: () {},
//                 child: Text(
//                   'Cancel',
//                   style: AppStyles.headLineStyle3
//                       .copyWith(color: AppStyles.primaryColor),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 label: Text(
//                   "Submit",
//                   style: AppStyles.headLineStyle3
//                       .copyWith(color: AppStyles.whiteColor),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppStyles.primaryColor,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Product Info

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset(
//                     AppMedia.onborading3,
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('Brown Jacket',
//                           style: GoogleFonts.poppins(
//                               fontSize: 16, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 4),
//                       Text('Size : XL  |  Qty : 10pcs',
//                           style: TextStyle(color: Colors.grey[600])),
//                       const SizedBox(height: 4),
//                       Text('\$83.97',
//                           style: GoogleFonts.poppins(
//                               fontSize: 15, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppStyles.primaryColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   ),
//                   onPressed: () {
//                     Get.to(
//                       const HomeScreen(),
//                       transition: Transition.rightToLeftWithFade,
//                       duration: const Duration(milliseconds: 500),
//                     );
//                   },
//                   child: Text('Re-Order',
//                       style: AppStyles.textStyle
//                           .copyWith(color: AppStyles.whiteColor)),
//                 ),
//               ],
//             ),
//             Divider(
//                 color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),

//             // const SizedBox(height: ),
//             Text("How is your order?", style: AppStyles.headLineStyle1),
//             Divider(
//                 color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),
//             const SizedBox(height: 8),
//             Text("Your overall rating",
//                 style: AppStyles.headLineStyle4.copyWith(
//                   fontWeight: FontWeight.w500,
//                 )),

//             const SizedBox(height: 16),
//             RatingBar.builder(
//               initialRating: 5,
//               minRating: 1,
//               direction: Axis.horizontal,
//               allowHalfRating: false,
//               itemCount: 5,
//               unratedColor: Colors.grey.shade300,
//               itemBuilder: (context, _) =>
//                   const Icon(Icons.star, color: Colors.amber),
//               onRatingUpdate: (rating) {},
//             ),
//             Divider(
//                 color: AppStyles.whiteSmokeColor.withOpacity(0.2), height: 32),

//             // const SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Add detailed review',
//                   style: AppStyles.headLineStyle4.copyWith(
//                     fontWeight: FontWeight.w500,
//                   )),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Enter here',
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor),
//                 const SizedBox(width: 6),
//                 Text('add photo',
//                     style: GoogleFonts.poppins(color: AppStyles.primaryColor)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





class LeaveReviewPage extends StatefulWidget {
  final int? orderId;
  final int? productId;
  final OrderProduct? product;

  const LeaveReviewPage({
    super.key, 
    this.orderId,
    this.productId,
    this.product,
  });

  @override
  State<LeaveReviewPage> createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends State<LeaveReviewPage> {
  final ReviewController reviewController = Get.put(ReviewController());
  final OrderController orderController = Get.find<OrderController>();
  
  OrderProduct? currentProduct;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeProduct();
  }

  void _initializeProduct() {
    if (widget.product != null) {
      currentProduct = widget.product;
      _loadExistingReview();
    } else if (widget.orderId != null) {
      _loadProductFromOrder();
    } else if (widget.productId != null) {
      _loadExistingReview();
    }
  }

  void _loadProductFromOrder() {
    if (widget.orderId != null) {
      final order = orderController.getOrderById(widget.orderId!);
      if (order != null && order.orderProducts.isNotEmpty) {
        setState(() {
          currentProduct = order.orderProducts.first;
        });
        _loadExistingReview();
      }
    }
  }

  void _loadExistingReview() {
    if (currentProduct?.id != null) {
      reviewController.loadExistingReview(currentProduct!.id!);
    } else if (widget.productId != null) {
      reviewController.loadExistingReview(widget.productId!);
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final productId = currentProduct?.id ?? widget.productId;
    if (productId == null) {
      showFailureSnackbar('Product information not available');
      return;
    }

    final success = await reviewController.submitReview(productId);
    if (success) {
      // Go back after successful submission
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Obx(() => Text(
          reviewController.hasExistingReview.value 
              ? "Update Review" 
              : "Leave Review", 
          style: AppStyles.headLineStyle2
        )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                  backgroundColor: WidgetStateProperty.all(
                      AppStyles.primaryColor.withOpacity(0.1)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: AppStyles.primaryColor,
                      width: 0.5,
                    ),
                  ),
                ),
                onPressed: reviewController.isLoading.value 
                    ? null 
                    : () => Get.back(),
                child: Text(
                  'Cancel',
                  style: AppStyles.headLineStyle3
                      .copyWith(color: AppStyles.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: reviewController.isLoading.value 
                    ? null 
                    : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: reviewController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        reviewController.hasExistingReview.value 
                            ? "Update" 
                            : "Submit",
                        style: AppStyles.headLineStyle3
                            .copyWith(color: AppStyles.whiteColor),
                      ),
              ),
            ),
          ],
        )),
      ),
      body: Obx(() {
        if (reviewController.isLoading.value && !reviewController.hasExistingReview.value) {
          return Center(
            child: CircularProgressIndicator(color: AppStyles.primaryColor),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info
                if (currentProduct != null) _buildProductInfo(),
                
                if (currentProduct == null && widget.productId != null)
                  _buildGenericProductInfo(),

                Divider(
                    color: AppStyles.whiteSmokeColor.withOpacity(0.2), 
                    height: 32),

                Center(
                  child: Text(
                    reviewController.hasExistingReview.value 
                        ? "Update your review" 
                        : "How is your order?", 
                    style: AppStyles.headLineStyle1
                  ),
                ),
                
                Divider(
                    color: AppStyles.whiteSmokeColor.withOpacity(0.2), 
                    height: 32),

                const SizedBox(height: 8),
                Text("Your overall rating",
                    style: AppStyles.headLineStyle4.copyWith(
                      fontWeight: FontWeight.w500,
                    )),

                const SizedBox(height: 16),
                Center(
                  child: RatingBar.builder(
                    initialRating: reviewController.rating.value,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    unratedColor: Colors.grey.shade300,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      reviewController.updateRating(rating);
                    },
                  ),
                ),

                Divider(
                    color: AppStyles.whiteSmokeColor.withOpacity(0.2), 
                    height: 32),

                Text('Review Subject',
                    style: AppStyles.headLineStyle4.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reviewController.subjectController,
                  decoration: InputDecoration(
                    hintText: 'Enter review subject (e.g., "Great product!")',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject for your review';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                Text('Detailed Review',
                    style: AppStyles.headLineStyle4.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reviewController.reviewController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tell others about your experience with this product...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your detailed review';
                    }
                    if (value.trim().length < 10) {
                      return 'Review must be at least 10 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                // Optional: Add photo functionality
                GestureDetector(
                  onTap: () {
                    // Implement photo upload functionality
                    showFailureSnackbar('Photo upload coming soon!');
                  },
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor),
                      const SizedBox(width: 6),
                      Text('Add photo (optional)',
                          style: GoogleFonts.poppins(color: AppStyles.primaryColor)),
                    ],
                  ),
                ),

                if (reviewController.hasExistingReview.value)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You have already reviewed this product. Your changes will update your existing review.',
                            style: AppStyles.textStyle.copyWith(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: currentProduct!.imageUrls.isNotEmpty
              ? Image.network(
                  currentProduct!.imageUrls.first,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                )
              : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image, color: Colors.grey),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(currentProduct!.title ?? 'Unknown Product',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (currentProduct!.sizes.isNotEmpty || currentProduct!.quantity != null)
                Text(
                  'Size: ${currentProduct!.sizes.isNotEmpty ? currentProduct!.sizes.first : 'N/A'} | Qty: ${currentProduct!.quantity ?? 0}pcs',
                  style: TextStyle(color: Colors.grey[600])
                ),
              const SizedBox(height: 4),
              Text(
                '\$${currentProduct!.discountPrice ?? currentProduct!.originalPrice ?? '0.00'}',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenericProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shopping_bag, color: Colors.grey, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Review',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Share your experience with this product',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}