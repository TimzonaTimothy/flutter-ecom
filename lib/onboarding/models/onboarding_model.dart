import '../../base/res/media.dart';

class UnbordingContent {
  final String image;
  final String title;
  final String discription;

  UnbordingContent({
    this.image = '',
    this.title = '',
    this.discription = '',
  });
}


List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Welcome to ShopEase',
    image: AppMedia.onborading1,
    discription: "Sign up and discover a world of exclusive products."
    // "industry's standard dummy text ever since the 1500s, "
  ),
  UnbordingContent(
    title: 'Follow Other Users',
    image: AppMedia.onborading2,
    discription: "Stay updated on deals from your favorite brands."
    // "industry's standard dummy text ever since the 1500s, "
  ),
  UnbordingContent(
    title: 'Easy Shopping',
    image: AppMedia.onborading3,
    discription: "Add items to your cart and check out in seconds."
    // "industry's standard dummy text ever since the 1500s, "
    // "when an unknown printer took a galley of type and scrambled it "
  ),
  // UnbordingContent(
  //   title: 'Browse the platform',
  //   image: 'assets/onboarding/browse.svg',
  //   discription: "From mobile apps to web solutions, DeGoodDev is committed to delivering exceptional outcomes that propel your business forward."
  //   // "industry's standard dummy text ever since the 1500s, "
  //   // "when an unknown printer took a galley of type and scrambled it "
  // ),
];