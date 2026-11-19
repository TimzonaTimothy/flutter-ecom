import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/utils/snackbar.dart';
import '../models/review_model.dart';
import '../service/review_service.dart';

class ReviewController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxDouble rating = 5.0.obs;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  final Rxn<ReviewModel> existingReview = Rxn<ReviewModel>();
  final RxBool hasExistingReview = false.obs;

  @override
  void onClose() {
    print('ReviewController onClose called');
    subjectController.dispose();
    reviewController.dispose();
    super.onClose();
  }

  void updateRating(double newRating) {
    rating.value = newRating;
  }

  Future<void> loadExistingReview(int productId) async {
    try {
      isLoading.value = true;
      final review = await ReviewService.getUserReviewForProduct(productId);
      if (isClosed) return;
      if (review != null) {
        existingReview.value = review;
        hasExistingReview.value = true;
        subjectController.text = review.subject;
        reviewController.text = review.review;
        rating.value = review.rating;
      } else {
        existingReview.value = null;
        hasExistingReview.value = false;
        subjectController.clear();
        reviewController.clear();
        rating.value = 5.0;
      }
    } catch (e) {
      print('Error loading existing review: $e');
      showFailureSnackbar('Error loading existing review');
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<bool> submitReview(int productId) async {
    if (isLoading.value || isClosed) return false;
    if (subjectController.text.trim().isEmpty) {
      showFailureSnackbar('Please enter a subject for your review');
      return false;
    }

    if (reviewController.text.trim().isEmpty) {
      showFailureSnackbar('Please enter your review');
      return false;
    }

    if (rating.value <= 0) {
      showFailureSnackbar('Please select a rating');
      return false;
    }

    try {
      isLoading.value = true;
      final result = await ReviewService.submitReview(
        productId: productId,
        subject: subjectController.text.trim(),
        review: reviewController.text.trim(),
        rating: rating.value,
        isUpdate: hasExistingReview.value,
      );

      if (isClosed) return false;
      if (result != null) {
        final message = hasExistingReview.value
            ? 'Review updated successfully!'
            : 'Review submitted successfully!';
        showSuccessSnackbar(message);
        clearForm();
        return true;
      } else {
        showFailureSnackbar('Failed to submit review. Please try again.');
        return false;
      }
    } catch (e) {
      print('Error submitting review: $e');
      showFailureSnackbar('Error submitting review: ${e.toString()}');
      return false;
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void clearForm() {
    subjectController.clear();
    reviewController.clear();
    rating.value = 5.0;
    existingReview.value = null;
    hasExistingReview.value = false;
  }
}
