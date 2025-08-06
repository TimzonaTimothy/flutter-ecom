import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/snackbar.dart';
import '../controllers/order_controller.dart';
import '../controllers/review_controller.dart';
import '../models/order_model.dart';

class LeaveReviewPage extends StatefulWidget {
  final int? orderId;
  final int? productId;
  final OrderProduct? product;
  final VoidCallback? onReviewSubmitted;

  const LeaveReviewPage({
    super.key,
    this.orderId,
    this.productId,
    this.product,
    this.onReviewSubmitted,
  });

  @override
  State<LeaveReviewPage> createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends State<LeaveReviewPage> {
  late final ReviewController reviewController;
  OrderController? orderController;
  OrderProduct? currentProduct;
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;
  bool _isDisposed = false; // New flag to track disposal

  void _initializeDependencies() {
    if (widget.orderId != null) {
      try {
        orderController = Get.find<OrderController>();
      } catch (e) {
        // If controller doesn't exist, create a new one
        orderController = Get.put(OrderController());
      }
    }
  }

  void _initializeProduct() {
    if (widget.product != null) {
      currentProduct = widget.product;
      _loadExistingReview();
    } else if (widget.orderId != null) {
      _loadProductFromOrder();
    } else if (widget.productId != null) {
      _loadExistingReview();
    } else {
      showFailureSnackbar('Product information not available');
    }
  }

  void _loadProductFromOrder() {
    if (widget.orderId != null && orderController != null) {
      final order = orderController!.getOrderById(widget.orderId!);
      if (order != null && order.orderProducts.isNotEmpty) {
        setState(() {
          currentProduct = order.orderProducts.first;
        });
        _loadExistingReview();
      } else {
        showFailureSnackbar('Order or product not found');
      }
    }
  }

  void _loadExistingReview() {
    final productId = currentProduct?.id ?? widget.productId;
    if (productId != null) {
      reviewController.loadExistingReview(productId);
    } else {
      showFailureSnackbar('Product ID not available');
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
      widget.onReviewSubmitted?.call(); // Trigger refresh in ProductDetail
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProduct();
  }

  void _initializeControllers() {
    try {
      reviewController = Get.put(ReviewController(), permanent: false);
      if (widget.orderId != null) {
        try {
          orderController = Get.find<OrderController>();
          print('Found existing OrderController');
        } catch (e) {
          print('OrderController not found, creating new one: $e');
          orderController = Get.put(OrderController(), permanent: false);
        }
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing controllers: $e');
      _isInitialized = false;
    }
  }

  void _safeNavigateBack() {
    try {
      // Do not delete ReviewController here; let dispose handle it
      Get.back();
    } catch (e) {
      print('Error navigating back: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  

  @override
  void dispose() {
    try {
      // Only delete if no other widgets depend on it
      if (Get.isRegistered<ReviewController>()) {
        Get.delete<ReviewController>(force: true);
      }
    } catch (e) {
      print('Error disposing controllers: $e');
    }
    _isDisposed = true; // Mark as disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Leave Review", style: AppStyles.headLineStyle2),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _safeNavigateBack,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppStyles.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Initializing...',
                style: AppStyles.textStyle,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: GetX<ReviewController>(
          init: reviewController,
          builder: (controller) => Text(
            controller.hasExistingReview.value
                ? "Update Review"
                : "Leave Review",
            style: AppStyles.headLineStyle2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _safeNavigateBack,
        ),
      ),
      backgroundColor: AppStyles.bgColor,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GetX<ReviewController>(
          init: reviewController,
          builder: (controller) {
            if (_isDisposed)
              return const SizedBox
                  .shrink(); // Prevent UI updates after disposal
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14)),
                      backgroundColor: WidgetStateProperty.all(
                          AppStyles.primaryColor.withOpacity(0.1)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: AppStyles.primaryColor, width: 0.5),
                      ),
                    ),
                    onPressed:
                        controller.isLoading.value ? null : _safeNavigateBack,
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
                    onPressed:
                        controller.isLoading.value ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            controller.hasExistingReview.value
                                ? "Update"
                                : "Submit",
                            style: AppStyles.headLineStyle3
                                .copyWith(color: AppStyles.whiteColor),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: GetX<ReviewController>(
        init: reviewController,
        builder: (controller) {
          if (_isDisposed)
            return const SizedBox.shrink(); // Prevent UI updates after disposal
          if (controller.isLoading.value &&
              !controller.hasExistingReview.value) {
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
                  if (currentProduct != null) _buildProductInfo(),
                  if (currentProduct == null && widget.productId != null)
                    _buildGenericProductInfo(),
                  if (currentProduct == null && widget.productId == null)
                    _buildErrorState(),
                  if (currentProduct != null || widget.productId != null) ...[
                    Divider(
                        color: AppStyles.whiteSmokeColor.withOpacity(0.2),
                        height: 32),
                    Center(
                      child: Text(
                        controller.hasExistingReview.value
                            ? "Update your review"
                            : "How is your order?",
                        style: AppStyles.headLineStyle1,
                      ),
                    ),
                    Divider(
                        color: AppStyles.whiteSmokeColor.withOpacity(0.2),
                        height: 32),
                    const SizedBox(height: 8),
                    Text(
                      "Your overall rating",
                      style: AppStyles.headLineStyle4
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: controller.rating.value,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        unratedColor: Colors.grey.shade300,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          controller.updateRating(rating);
                        },
                      ),
                    ),
                    Divider(
                        color: AppStyles.whiteSmokeColor.withOpacity(0.2),
                        height: 32),
                    _buildReviewForm(controller),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewForm(ReviewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Subject',
          style: AppStyles.headLineStyle4.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.subjectController,
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
        Text(
          'Detailed Review',
          style: AppStyles.headLineStyle4.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.reviewController,
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
        GestureDetector(
          onTap: () {
            showFailureSnackbar('Photo upload coming soon!');
          },
          child: Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Add photo (optional)',
                style: GoogleFonts.poppins(color: AppStyles.primaryColor),
              ),
            ],
          ),
        ),
        if (controller.hasExistingReview.value)
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
                const Icon(Icons.info_outline, color: Colors.blue),
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
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    );
                  },
                )
              : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentProduct!.title ?? 'Unknown Product',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Size: ${currentProduct!.sizes.isNotEmpty ? currentProduct!.sizes.first : 'N/A'} | Qty: ${currentProduct!.quantity ?? 0}pcs',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${currentProduct!.discountPrice ?? '0.00'}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
            child: const Icon(Icons.shopping_bag, color: Colors.grey, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Review',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your experience with this product',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Product Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn’t load the product details needed to leave a review. Please try again or go back.',
            style: AppStyles.textStyle.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _safeNavigateBack,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    AppStyles.whiteSmokeColor.withOpacity(0.1),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: AppStyles.primaryColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: AppStyles.headLineStyle3.copyWith(
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitialized = false; // Reset initialization state
                  });
                  _initializeControllers(); // Reinitialize controllers
                  _initializeProduct(); // Retry product initialization
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: AppStyles.headLineStyle3.copyWith(
                    color: AppStyles.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
