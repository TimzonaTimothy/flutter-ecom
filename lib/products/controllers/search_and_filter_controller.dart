import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_and_filter_model.dart';
import '../service/product_search_and_filter_service.dart';

// Search Controller
class SearchProductController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  
  // Observable variables
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxList<ProductSearchModel> searchResults = <ProductSearchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showSuggestions = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;
  
  Timer? _debounceTimer;
  
  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    _setupListeners();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
  
  void _setupListeners() {
    searchController.addListener(_onSearchChanged);
    searchFocusNode.addListener(_onFocusChanged);
  }
  
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty && searchController.text.length >= 2) {
        getSuggestions(searchController.text);
      } else {
        suggestions.clear();
        showSuggestions.value = false;
      }
    });
  }
  
  void _onFocusChanged() {
    if (searchFocusNode.hasFocus && searchController.text.isNotEmpty) {
      showSuggestions.value = true;
      hasSearched.value = false;
    }
  }
  
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [
        'Blue Shirt',
        'CosmicChic Jacket',
        'EnchantedElegance Dress',
        'WhimsyWhirl Top',
        'Fluffernova Coat',
        'MirageMelody Cape',
        'BlossomBreeze Overalls',
      ];
      recentSearches.assignAll(searches);
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }
  
  Future<void> _saveRecentSearch(String search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove if exists and add to top
      recentSearches.remove(search);
      recentSearches.insert(0, search);
      
      // Keep only last 10 searches
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }
      
      await prefs.setStringList('recent_searches', recentSearches);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }
  
  Future<void> getSuggestions(String query) async {
    try {
      final suggestionsData = await SearchAndFilterApiService.getSearchSuggestions(query);
      suggestions.assignAll(suggestionsData);
      showSuggestions.value = true;
    } catch (e) {
      print('Error getting suggestions: $e');
    }
  }
  
 Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    int attempt = 0;

    isLoading.value = true;
    showSuggestions.value = false;
    hasSearched.value = true;
    errorMessage.value = '';

    searchFocusNode.unfocus();

    while (attempt < maxRetries) {
      try {
        final response = await SearchAndFilterApiService.searchProducts(
          query: query,
          page: 1, // Start with page 1
          pageSize: 20,
        );
        final results = (response['results'] as List)
            .map((json) => ProductSearchModel.fromJson(json))
            .toList();

        searchResults.assignAll(results);
        await _saveRecentSearch(query);
        break; // Exit loop on success
      } catch (e) {
        attempt++;
        if (attempt == maxRetries) {
          errorMessage.value = 'Failed to search products after $maxRetries attempts';
          print('Search error after $maxRetries attempts: $e');
        }
        await Future.delayed(retryDelay);
      }
    }
    isLoading.value = false;
  }
  
  void clearSearches() {
    recentSearches.clear();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('recent_searches');
    });
  }
  
  void removeSearch(int index) {
    if (index >= 0 && index < recentSearches.length) {
      recentSearches.removeAt(index);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('recent_searches', recentSearches);
      });
    }
  }
  
  void selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    performSearch(suggestion);
  }
  
  void selectRecentSearch(String search) {
    searchController.text = search;
    performSearch(search);
  }
  
  void clearResults() {
    searchResults.clear();
    hasSearched.value = false;
    errorMessage.value = '';
  }
}

// Filter Controller
class FilterController extends GetxController {
  // Filter options
  final RxList<String> brands = ['All', 'Nike', 'Adidas', 'Puma', 'Reebok'].obs;
  final RxList<String> gender = ['All', 'Men', 'Women'].obs;
  final RxList<String> sortBy = ['Most Recent', 'Popular', 'Price High'].obs;
  final RxList<String> ratings = [
    '4.5 and above',
    '4.0 - 4.5',
    '3.5 - 4.0',
    '3.0 - 3.5',
    '2.5 - 3.0'
  ].obs;
  
  // Selected values
  final RxInt selectedBrand = 0.obs;
  final RxInt selectedGender = 0.obs;
  final RxInt selectedSort = 1.obs;
  final RxInt selectedRating = 0.obs;
  final Rx<RangeValues> priceRange = const RangeValues(1000, 1000).obs;
  
  // Filter results
  final RxList<ProductSearchModel> filteredProducts = <ProductSearchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<FilterOptions?> filterOptions = Rx<FilterOptions?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();
  }
  
 Future<void> loadFilterOptions() async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    int attempt = 0;

    // Check for cached options
    final cachedOptions = await _getCachedFilterOptions();
    if (cachedOptions != null) {
      filterOptions.value = cachedOptions;
      return;
    }

    while (attempt < maxRetries) {
      try {
        isLoading.value = true;
        final options = await SearchAndFilterApiService.getFilterOptions();
        filterOptions.value = FilterOptions.fromJson(options);

        if (filterOptions.value != null) {
          final dynamicBrands = ['All'] + filterOptions.value!.brands.map((b) => b.title).toList();
          brands.assignAll(dynamicBrands);
          priceRange.value = RangeValues(
            filterOptions.value!.priceRange['min'] ?? 0.0,
            filterOptions.value!.priceRange['max'] ?? 1000.0,
          );
          // Cache the options
          await _cacheFilterOptions(filterOptions.value!);
        }
        break;
      } catch (e) {
        attempt++;
        print('Filter options attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          errorMessage.value = 'Failed to load filter options after $maxRetries attempts';
        }
        await Future.delayed(retryDelay);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> _cacheFilterOptions(FilterOptions options) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filter_options', jsonEncode(options.toJson()));
  }

  Future<FilterOptions?> _getCachedFilterOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('filter_options');
    if (cached != null) {
      return FilterOptions.fromJson(jsonDecode(cached));
    }
    return null;
  }
  
 Future<void> applyFilters({int page = 1, int pageSize = 20}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final selectedBrandName = selectedBrand.value == 0 ? null : brands[selectedBrand.value];
      final selectedGenderName = selectedGender.value == 0 ? null : gender[selectedGender.value];
      final selectedSortName = sortBy[selectedSort.value];

      double? minRating;
      if (selectedRating.value < ratings.length) {
        final ratingText = ratings[selectedRating.value];
        if (ratingText.contains('4.5')) minRating = 4.5;
        else if (ratingText.contains('4.0')) minRating = 4.0;
        else if (ratingText.contains('3.5')) minRating = 3.5;
        else if (ratingText.contains('3.0')) minRating = 3.0;
        else if (ratingText.contains('2.5')) minRating = 2.5;
      }

      final response = await SearchAndFilterApiService.advancedSearch(
        query: null, // No search query for filters
        brands: selectedBrandName != null ? [selectedBrandName] : null,
        gender: selectedGenderName,
        minPrice: priceRange.value.start,
        maxPrice: priceRange.value.end,
        minRating: minRating,
        sortBy: selectedSortName,
        page: page,
        pageSize: pageSize,
      );

      final results = (response['results'] as List)
          .map((json) => ProductSearchModel.fromJson(json))
          .toList();

      filteredProducts.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Failed to apply filters. Please try again.';
      print('Filter error: $e');
     } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> advancedSearch({
    String? query,
    List<String>? categories,
    List<String>? colors,
    List<String>? sizes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final selectedBrandName = selectedBrand.value == 0 
          ? null 
          : brands[selectedBrand.value];
      
      final selectedGenderName = selectedGender.value == 0 
          ? null 
          : gender[selectedGender.value];
      
      final selectedSortName = sortBy[selectedSort.value];
      
      double? minRating;
      if (selectedRating.value < ratings.length) {
        final ratingText = ratings[selectedRating.value];
        if (ratingText.contains('4.5')) {
          minRating = 4.5;
        } else if (ratingText.contains('4.0')) {
          minRating = 4.0;
        } else if (ratingText.contains('3.5')) {
          minRating = 3.5;
        } else if (ratingText.contains('3.0')) {
          minRating = 3.0;
        } else if (ratingText.contains('2.5')) {
          minRating = 2.5;
        }
      }
      
      final response = await SearchAndFilterApiService.advancedSearch(
        query: query,
        brands: selectedBrandName != null ? [selectedBrandName] : null,
        categories: categories,
        gender: selectedGenderName,
        minPrice: priceRange.value.start,
        maxPrice: priceRange.value.end,
        minRating: minRating,
        colors: colors,
        sizes: sizes,
        sortBy: selectedSortName,
      );
      
      final results = (response['results'] as List)
          .map((json) => ProductSearchModel.fromJson(json))
          .toList();
      
      filteredProducts.assignAll(results);
      
    } catch (e) {
      errorMessage.value = 'Failed to perform advanced search. Please try again.';
      print('Advanced search error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void resetFilters() {
    selectedBrand.value = 0;
    selectedGender.value = 0;
    selectedSort.value = 1;
    selectedRating.value = 0;
    priceRange.value = const RangeValues(10, 1000);
    filteredProducts.clear();
    errorMessage.value = '';
  }
  
  void updateBrand(int index) {
    selectedBrand.value = index;
  }
  
  void updateGender(int index) {
    selectedGender.value = index;
  }
  
  void updateSort(int index) {
    selectedSort.value = index;
  }
  
  void updateRating(int index) {
    selectedRating.value = index;
  }
  
  void updatePriceRange(RangeValues values) {
    priceRange.value = values;
  }
  
  String getFilterDescription() {
    List<String> filters = [];
    
    if (selectedBrand.value != 0) {
      filters.add('Brand: ${brands[selectedBrand.value]}');
    }
    
    if (selectedGender.value != 0) {
      filters.add('Gender: ${gender[selectedGender.value]}');
    }
    
    filters.add('Price: \$${priceRange.value.start.round()} - \$${priceRange.value.end.round()}');
    
    if (selectedRating.value < ratings.length) {
      filters.add('Rating: ${ratings[selectedRating.value]}');
    }
    
    filters.add('Sort: ${sortBy[selectedSort.value]}');
    
    return filters.join(' • ');
  }
  
  bool get hasActiveFilters {
    return selectedBrand.value != 0 ||
           selectedGender.value != 0 ||
           selectedSort.value != 1 ||
           selectedRating.value != 0 ||
           priceRange.value != const RangeValues(100, 1000);
  }
}