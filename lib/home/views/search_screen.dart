import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyles.bgColor,
//       appBar: AppBar(
//         backgroundColor: AppStyles.bgColor,
//         elevation: 0,
//         title: Text("Search", style: AppStyles.headLineStyle2),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//       ),
//       body: ListView(
//         shrinkWrap: true,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: AppStyles.primaryColor,
//                 width: 0.5,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: TextFormField(
//               textAlign: TextAlign.start,
//               textAlignVertical: TextAlignVertical.center,
//               validator: (value) =>
//                   value == null ? 'please enter your query' : null,
//               controller: searchController,
//               keyboardType: TextInputType.text,
//               style: AppStyles.textStyle.copyWith(color: AppStyles.textColor),
//               decoration: InputDecoration(
//                 hintText: "Search",
//                 alignLabelWithHint: true,
//                 hintTextDirection: TextDirection.ltr,
//                 hintStyle: AppStyles.textStyle.copyWith(
//                   color: AppStyles.textColor.withOpacity(0.6),
//                 ),
//                 border: InputBorder.none,
//                 prefixIcon: IconButton(
//                   icon: Icon(
//                     Icons.search,
//                     color: AppStyles.primaryColor,
//                   ),
//                   onPressed: () {},
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           const AppDoubleText(
//             bigText: "Recent",
//             smallText: "Clear All",
//           )
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _recentSearches = [
    'Blue Shirt',
    'CosmicChic Jacket',
    'EnchantedElegance Dress',
    'WhimsyWhirl Top',
    'Fluffernova Coat',
    'MirageMelody Cape',
    'BlossomBreeze Overalls',
    'EnchantedElegance Dress',
  ];

  void _clearSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _removeSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
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
