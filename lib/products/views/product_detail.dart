import 'package:ecom_app/base/res/media.dart';
import 'package:ecom_app/base/widgets/app_double_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final List<String> imageList = [
    AppMedia.onborading1,
    AppMedia.onborading2,
    AppMedia.onborading3,
    AppMedia.welcomeImage,
    AppMedia.onborading1,
    AppMedia.onborading2,
  ];
  int selectedImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppStyles.bgColor,
        appBar: AppBar(
          backgroundColor: AppStyles.bgColor,
          elevation: 0,
          title: Text("Product Details", style: AppStyles.headLineStyle2),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(20),
              //   child: Image.asset(AppMedia.onborading2,
              //       height: 300, fit: BoxFit.cover),
              // ),
              // const SizedBox(height: 12),
              // SizedBox(
              //   height: 70,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: imageList.length,
              //     itemBuilder: (context, index) => ClipRRect(
              //       borderRadius: BorderRadius.circular(10),
              //       child: Image.asset(
              //         imageList[index],
              //         width: 60,
              //         height: 60,
              //         fit: BoxFit.cover,
              //       ),
              //     ),
              //     separatorBuilder: (context, index) =>
              //         const SizedBox(width: 10),
              //   ),
              // ),

              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      // AppMedia.onborading2,
                      imageList[selectedImageIndex],
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      height: 70,
                      decoration: BoxDecoration(
                          color: AppStyles.whiteColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: imageList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImageIndex =
                                    index; // update displayed image
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                imageList[index],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("Female’s Style",
                      style: TextStyle(color: AppStyles.greColor)),
                  const Spacer(),
                  Icon(Icons.star, color: AppStyles.primaryColor, size: 20),
                  const SizedBox(width: 4),
                  const Text("4.5",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text("Light Brown Jacket",
                  style: AppStyles.headLineStyle2
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Product Details",
                  style: AppStyles.headLineStyle2
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text.rich(
                TextSpan(
                  text:
                      "Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit ametLorem ipsum dolor sit amet Lorem ipsum dolor sit amet ... ",
                  children: [
                    TextSpan(
                      text: "Read more",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.brown),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              const Text("Select Size",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ["S", "M", "L", "XL", "XXL", "XXXL"].map((size) {
                  final isSelected = size == "S"; // Example
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppStyles.primaryColor : Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Select Color : Brown",
                  style: TextStyle(fontWeight: FontWeight.w600)),

              const SizedBox(height: 20),
              const AppDoubleText(bigText: 'Similar Products'),
              const SizedBox(height: 10),
            ]),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyles.bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 6,
              )
            ],
          ),
          child: Row(
            children: [
              Row(
                children: [
                  Text(
                    "Total ",
                    style: AppStyles.headLineStyle3.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppStyles.whiteSmokeColor),
                  ),
                  Text("\$83.97",
                      style: AppStyles.headLineStyle3.copyWith(
                        fontWeight: FontWeight.w900,
                      )),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppStyles.whiteColor,
                ),
                label: Text(
                  "Add to Cart",
                  style:
                      AppStyles.textStyle.copyWith(color: AppStyles.whiteColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
