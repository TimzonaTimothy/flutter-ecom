import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';

class ImageSliders extends StatefulWidget {
  const ImageSliders({super.key});

  @override
  State<ImageSliders> createState() => _ImageSlidersState();
}

class _ImageSlidersState extends State<ImageSliders> {
  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: AnotherCarousel(
              images: const [
                NetworkImage(
                    "https://img.freepik.com/free-psd/online-shopping-banner-template_23-2148900156.jpg?t=st=1750198514~exp=1750202114~hmac=48e2c50152b433931055750c0454482103868831444e13782f62a174b99734d6&w=1380"),
                NetworkImage(
                    'https://img.freepik.com/premium-photo/online-fashion-shopping-collage_23-2150535797.jpg'),
                NetworkImage(
                    "https://img.freepik.com/premium-photo/online-fashion-shopping-collage_23-2150535761.jpg"),
                NetworkImage(
                    "https://img.freepik.com/premium-photo/online-fashion-shopping-collage_23-2150535769.jpg"),
              ],
              dotSize: 4,
              indicatorBgPadding: 5.0,
              borderRadius: true,
            ),
          )
        ],
      ),
    );
  }
}
