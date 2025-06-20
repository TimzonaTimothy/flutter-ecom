import 'package:flutter/material.dart';

import '../../base/res/styles/app_styles.dart';

class ProductCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;
  final VoidCallback? onTap;
  final VoidCallback? onTapWishlist;

  const ProductCard(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.price,
      required this.onTap,
      required this.onTapWishlist});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (widget.onTapWishlist != null) {
      widget.onTapWishlist!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 0),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ], color: AppStyles.whiteColor, borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _toggleFavorite,
              child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite ? AppStyles.textColor : Colors.black,
                    ),
                  )),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppStyles.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.title,
                  style: AppStyles.headLineStyle4.copyWith(
                      fontWeight: FontWeight.bold, color: AppStyles.greColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      "\$${widget.price}",
                      style: AppStyles.headLineStyle2
                          .copyWith(fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      "\$${widget.price}",
                      style: AppStyles.headLineStyle3.copyWith(
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.lineThrough,
                          color: AppStyles.whiteSmokeColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
