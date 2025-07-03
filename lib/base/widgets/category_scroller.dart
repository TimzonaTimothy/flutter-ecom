// import 'package:flutter/material.dart';

// class CategoryScroller extends StatelessWidget {
//   final List<Map<String, String>> items;
//   final double avatarRadius;
//   final VoidCallback? onTap;

//   const CategoryScroller({
//     super.key,
//     required this.items,
//     this.avatarRadius = 26,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: items.map((item) {
//           final imageUrl = item['image']!;
//           return Padding(
//             padding: const EdgeInsets.only(right: 20),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: onTap,
//                   child: CircleAvatar(
//                     backgroundImage: NetworkImage(imageUrl),
//                     radius: avatarRadius,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(item['label']!),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class CategoryScroller extends StatelessWidget {
  final List<Map<String, String>> items;
  final double avatarRadius;
  final void Function(String label)? onTap; 

  const CategoryScroller({
    super.key,
    required this.items,
    this.avatarRadius = 26,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final imageUrl = item['image']!;
          final label = item['label']!;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap!(label); // <-- Pass the label on tap
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: avatarRadius,
                  ),
                ),
                const SizedBox(height: 5),
                Text(label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
