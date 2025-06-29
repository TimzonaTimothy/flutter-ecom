import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text("Help Center"),
        leading: BackButton(),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.brown),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.brown,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.grey,
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
                    selectedColor: Colors.brown,
                    backgroundColor: Colors.grey.shade200,
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
                        title: Text(item["question"]!, style: TextStyle(fontWeight: FontWeight.w600)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Text(item["answer"]!),
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
