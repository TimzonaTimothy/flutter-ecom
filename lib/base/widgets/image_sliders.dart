import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:ecom_app/base/res/media.dart';
import 'package:flutter/material.dart';

class ImageSliders extends StatefulWidget {
  const ImageSliders({super.key});

  @override
  State<ImageSliders> createState() => _ImageSlidersState();
}

class _ImageSlidersState extends State<ImageSliders> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: double.infinity,
          child: AnotherCarousel(
            images: const [
              AssetImage(AppMedia.onborading1),
              AssetImage(AppMedia.onborading1),
              AssetImage(AppMedia.onborading1),
            ],
            dotSize: 4, 
            indicatorBgPadding: 5.0,
          ),
        )
      ],
    );
  }
}
