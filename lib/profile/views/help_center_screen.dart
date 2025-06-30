import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class HelpCenterScreen extends StatefulWidget {
  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'All';

  final List<String> filters = ['All', 'Services', 'General', 'Account'];

  final List<Map<String, String>> faqs = [
    {
      "question": "Can I track my order's delivery status?",
      "answer": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    },
    {"question": "Is there a return policy?", "answer": "Yes, within 30 days."},
    {"question": "Can I save my favorite items for later?", "answer": "Yes, use the wishlist feature."},
    {"question": "Can I share products with my friends?", "answer": "You can share via social or copy link."},
    {"question": "How do I contact customer support?", "answer": "Use the contact form or call us."},
    {"question": "What payment methods are accepted?", "answer": "Credit card, PayPal, and more."},
    {"question": "How to add review?", "answer": "Go to the product and click on 'Add Review'."},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // FAQ and Contact Us
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Help Center", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
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
                // controller: _searchController,
                keyboardType: TextInputType.text,
                style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
                decoration: InputDecoration(
                  hintText: "Search",
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
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppStyles.primaryColor,
            labelColor: AppStyles.primaryColor,
            unselectedLabelColor: AppStyles.greColor,
            tabs: [
              Tab(text: "FAQ"),
              Tab(text: "Contact Us"),
            ],
          ),

          // Filters
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: AppStyles.primaryColor,
                    backgroundColor: AppStyles.bgColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // FAQ Tab
                ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final item = faqs[index];
                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(item["question"]!, style: AppStyles.headLineStyle3),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Text(item["answer"]!,style: AppStyles.textStyle,),
                          )
                        ],
                      ),
                    );
                  },
                ),

                // Contact Us Tab (Placeholder)
                Center(child: Text("Contact Form Coming Soon")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
