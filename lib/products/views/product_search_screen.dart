import 'dart:async';

import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../base/res/styles/app_styles.dart';


import '../models/search_and_filter_model.dart';
import '../service/product_search_and_filter_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
    final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<String> _recentSearches = [];
  List<String> _suggestions = [];
  List<ProductSearchModel> _searchResults = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty && _searchController.text.length >= 2) {
        _getSuggestions(_searchController.text);
      } else {
        setState(() {
          _suggestions.clear();
          _showSuggestions = false;
        });
      }
    });
  }
  
  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      setState(() {
        _showSuggestions = true;
        _hasSearched = false;
      });
    }
  }
  
  Future<void> _loadRecentSearches() async {
    // Load from local storage (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [
        'Blue Shirt',
        'CosmicChic Jacket',
        'EnchantedElegance Dress',
        'WhimsyWhirl Top',
        'Fluffernova Coat',
        'MirageMelody Cape',
        'BlossomBreeze Overalls',
      ];
    });
  }
  
  Future<void> _saveRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove if exists and add to top
    _recentSearches.remove(search);
    _recentSearches.insert(0, search);
    
    // Keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }
    
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }
  
  Future<void> _getSuggestions(String query) async {
    try {
      final suggestions = await ApiService.getSearchSuggestions(query);
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = true;
      });
    } catch (e) {
      print('Error getting suggestions: $e');
    }
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _showSuggestions = false;
      _hasSearched = true;
      _errorMessage = '';
    });
    
    _searchFocusNode.unfocus();
    
    try {
      final response = await ApiService.searchProducts(query: query);
      setState(() {
        _searchResults = (response['results'] as List)
            .map((json) => ProductSearchModel.fromJson(json))
            .toList();
        _isLoading = false;
      });
      
      // Save to recent searches
      await _saveRecentSearch(query);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search products. Please try again.';
      });
    }
  }
  
  void _clearSearches() {
    setState(() {
      _recentSearches.clear();
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('recent_searches');
    });
  }
  
  void _removeSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('recent_searches', _recentSearches);
    });
  }
  
  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }
  
  void _selectRecentSearch(String search) {
    _searchController.text = search;
    _performSearch(search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Search", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 12),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(25),
            //     color: Colors.grey.shade100,
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(Icons.search, color: Colors.brown),
            //       SizedBox(width: 10),
            //       Expanded(
            //         child: TextField(
            //           controller: _searchController,
            //           decoration: InputDecoration(
            //             hintText: 'Search',
            //             border: InputBorder.none,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 20),

            // // Recent Label
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Recent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            //     GestureDetector(
            //       onTap: _clearSearches,
            //       child: Text('Clear All', style: TextStyle(color: Colors.brown)),
            //     ),
            //   ],
            // ),
             Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppStyles.primaryColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              validator: (value) =>
                  value == null ? 'please enter your query' : null,
              controller: _searchController,
              focusNode: _searchFocusNode,
              keyboardType: TextInputType.text,
              style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
              decoration: InputDecoration(
                hintText: "Search products, brands, categories...",
                alignLabelWithHint: true,
                hintTextDirection: TextDirection.ltr,
                hintStyle: AppStyles.textStyle.copyWith(
                  color: AppStyles.textColor.withOpacity(0.6),
                ),
                border: InputBorder.none,
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: AppStyles.primaryColor,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
           AppDoubleText(
            bigText: "Recent",
            smallText: "Clear All",
            func: _clearSearches,
          ),
            SizedBox(height: 10),

            // Search List
            Expanded(
              child: ListView.builder(
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_recentSearches[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: AppStyles.primaryColor),
                      onPressed: () => _removeSearch(index),
                    ),
                    onTap: () {
                      // Handle re-search
                      _searchController.text = _recentSearches[index];
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
