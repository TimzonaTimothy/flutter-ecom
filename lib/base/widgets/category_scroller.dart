import 'package:flutter/material.dart';

class CategoryScroller extends StatelessWidget {
  final List<Map<String, String>> items;
  final double avatarRadius;
  final VoidCallback? onTap;

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
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: CircleAvatar(
                    backgroundImage: AssetImage(item['image']!),
                    radius: avatarRadius,
                  ),
                ),
                const SizedBox(height: 5),
                Text(item['label']!),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
