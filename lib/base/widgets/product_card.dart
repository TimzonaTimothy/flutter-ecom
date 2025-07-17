import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

// class ProductCard extends StatefulWidget {
//   final int productId;
//   final String imagePath;
//   final String title;
//   final String price;
//   final double rating;
//   final String oldPrice;
//   final VoidCallback? onTap;
//   final VoidCallback? onTapWishlist;
//   final bool isFavorite;

//   const ProductCard(
//       {super.key,
//       required this.productId,
//       required this.imagePath,
//       required this.title,
//       required this.price,
//       required this.rating,
//       required this.oldPrice,
//       required this.onTap,
//       required this.onTapWishlist, 
//       required this.isFavorite,
//       });

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   // bool isFavorite = false; 
//   final bool isFavorite = WishlistController.isFavorite(productId);

//   void _toggleFavorite() {
//     setState(() {
//       isFavorite = !isFavorite;
//     });

//     if (widget.onTapWishlist != null) {
//       widget.onTapWishlist!();
//     }
//   } 
  

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               offset: const Offset(0, 0),
//               blurRadius: 10,
//               spreadRadius: 1,
//             ),
//           ],
//           color: AppStyles.whiteColor,
//           // color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(10)),
//       child: SizedBox(
//         width: 160,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
            
//             GestureDetector(
//               onTap: widget.onTap,
//               child: Stack(
//                 children: [
//                   Container(
//                     height: 150,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       image: DecorationImage(
//                         image: NetworkImage(widget.imagePath),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: GestureDetector(
//                       // onTap: _toggleFavorite,
//                       onTap: () {
//                             WishlistController.toggleWishlist(productId);
//                           },
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                             color: AppStyles.whiteColor.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(50)),
//                         child: Icon(
//                           isFavorite
//                               ? Icons.favorite
//                               : Icons.favorite_border_outlined,
//                           color: isFavorite
//                               ? AppStyles.primaryColor 
//                               : AppStyles.blackColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 5),
//             Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: widget.onTap,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Text(
//                           widget.title ?? "Untitled Product",
//                           style: AppStyles.headLineStyle4.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: AppStyles.greColor),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Icon(Icons.star, color: AppStyles.primaryColor, size: 20),
//                       const SizedBox(width: 4),
//                       Text(widget.rating.toStringAsFixed(1),
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             GestureDetector(
//               onTap: widget.onTap,
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     left: 8.0, bottom: 8, right: 8, top: 3),
//                 child: Row(
//                   children: [
//                     Text(
//                       "\$${widget.price ?? '0.00'}",
//                       style: AppStyles.headLineStyle2
//                           .copyWith(fontWeight: FontWeight.w900),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(
//                       width: 3,
//                     ),
//                     Flexible(
//                       child: Text(
//                         "\$${widget.oldPrice ?? '0.00'}",
//                         style: AppStyles.headLineStyle3.copyWith(
//                             fontWeight: FontWeight.w500,
//                             decoration: TextDecoration.lineThrough,
//                             color: AppStyles.whiteSmokeColor),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class ProductCard extends StatelessWidget {
  final int productId;
  final String imagePath;
  final String title;
  final String price;
  final double rating;
  final String oldPrice;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.productId,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.rating,
    required this.oldPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishlistController>(
      builder: (wishlistController) {
        final bool isFavorite = wishlistController.isFavorite(productId);
        
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 0),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            color: AppStyles.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Stack(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            // Use the controller instance, not static access
                            wishlistController.toggleWishlist(productId);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppStyles.whiteColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: isFavorite
                                  ? AppStyles.primaryColor
                                  : AppStyles.blackColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              title,
                              style: AppStyles.headLineStyle4.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppStyles.greColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppStyles.primaryColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      bottom: 8,
                      right: 8,
                      top: 3,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "\$price",
                          style: AppStyles.headLineStyle2.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            "\$oldPrice",
                            style: AppStyles.headLineStyle3.copyWith(
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              color: AppStyles.whiteSmokeColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}