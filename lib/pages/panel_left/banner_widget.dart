// banner_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../provider/banner_images_provider.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerImagesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: 200,
          width: double.infinity,
          child: provider.bannerImages.isEmpty
              ? const Center(child: Text('No banner images'))
              : Swiper(
                  indicatorLayout: PageIndicatorLayout.SCALE,
                  autoplay: true,
                  itemBuilder: (BuildContext context, int index) {
                    return CachedNetworkImage(
                      imageUrl: provider.bannerImages[index],
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    );
                  },
                  itemCount: provider.bannerImages.length,
                  // pagination: SwiperPagination(
                  //   builder: DotSwiperPaginationBuilder(
                  //     color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
                  //     activeColor: ColorsConsts.mainColor,
                  //   ),
                  // ),
                  // control: const SwiperControl(),
                ),
        );

        // return Column(
        //   children: [
        //     // Banner Swiper
        //     SizedBox(
        //       height: MediaQuery.of(context).size.height * 0.266,
        //       width: double.infinity,
        //       child: provider.bannerImages.isEmpty
        //           ? const Center(child: Text('No banner images'))
        //           : Swiper(
        //         indicatorLayout: PageIndicatorLayout.SCALE,
        //         autoplay: true,
        //         itemBuilder: (BuildContext context, int index) {
        //           return Stack(
        //             children: [
        //               Positioned(
        //                 top: 0,
        //                 left: 0,
        //                 right: 0,
        //                 // bottom: 0,
        //                 child: CachedNetworkImage(
        //                   imageUrl: provider.bannerImages[index],
        //                   placeholder: (context, url) =>
        //                   const Center(child: CircularProgressIndicator()),
        //                   errorWidget: (context, url, error) =>
        //                   const Icon(Icons.error),
        //                   fit: BoxFit.fill,
        //                 ),
        //               ),
        //               // Delete button
        //               Positioned(
        //                 top: 8,
        //                 right: 8,
        //                 child: IconButton(
        //                   icon: const Icon(Icons.delete, color: Colors.white),
        //                   onPressed: () => provider
        //                       .deleteImage(provider.bannerImages[index]),
        //                 ),
        //               ),
        //             ],
        //           );
        //         },
        //         itemCount: provider.bannerImages.length,
        //         pagination: const SwiperPagination(),
        //         control: const SwiperControl(),
        //       ),
        //     ),
        //
        //     // Upload buttons
        //     // Padding(
        //     //   padding: const EdgeInsets.all(16.0),
        //     //   child: Row(
        //     //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     //     children: [
        //     //       ElevatedButton.icon(
        //     //         onPressed: () => provider.uploadImageFromDevice(),
        //     //         icon: const Icon(Icons.photo_library),
        //     //         label: const Text('Gallery'),
        //     //       ),
        //     //       if (!kIsWeb) // Camera button only for mobile
        //     //         ElevatedButton.icon(
        //     //           onPressed: () =>
        //     //               provider.uploadImageFromDevice(fromCamera: true),
        //     //           icon: const Icon(Icons.camera_alt),
        //     //           label: const Text('Camera'),
        //     //         ),
        //     //       ElevatedButton.icon(
        //     //         onPressed: () => _showUrlDialog(context, provider),
        //     //         icon: const Icon(Icons.link),
        //     //         label: const Text('URL'),
        //     //       ),
        //     //     ],
        //     //   ),
        //     // ),
        //   ],
        // );
      },
    );
  }

  Future<void> _showUrlDialog(BuildContext context, BannerImagesProvider provider) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add image from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter image URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.uploadImageFromUrl(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
