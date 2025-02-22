import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/banner_images_provider.dart';
import '../../provider/products.dart';
import '../widgets/banner_widget.dart';
import 'filtered_products_page.dart';

class PanelLeftPage extends StatelessWidget {
  const PanelLeftPage({super.key});

  // تعريف الألوان الأساسية
  static const Color backgroundColor = Color(0xFF0D193E);
  static const Color cardColor = Color(0xFF1E224C);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB8C7E0);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar(
          //   backgroundColor: backgroundColor,
          //   floating: true,
          //   title: Text(
          //     'Our Products',
          //     style: TextStyle(color: textColor),
          //   ),
          // ),
          SliverToBoxAdapter(
            child: Consumer<Products>(
              builder: (context, productsData, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  Consumer<BannerImagesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // return SizedBox(
                      //   height: 200,
                      //   width: double.infinity,
                      //   child: provider.bannerImages.isEmpty
                      //       ? const Center(child: Text('No banner images'))
                      //       : Swiper(
                      //     indicatorLayout: PageIndicatorLayout.SCALE,
                      //     autoplay: true,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return CachedNetworkImage(
                      //         imageUrl: provider.bannerImages[index],
                      //         placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      //         errorWidget: (context, url, error) => const Icon(Icons.error),
                      //         fit: BoxFit.cover,
                      //       );
                      //     },
                      //     itemCount: provider.bannerImages.length,
                      //     // pagination: SwiperPagination(
                      //     //   builder: DotSwiperPaginationBuilder(
                      //     //     color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
                      //     //     activeColor: ColorsConsts.mainColor,
                      //     //   ),
                      //     // ),
                      //     // control: const SwiperControl(),
                      //   ),
                      // );

                      return Column(
                        children: [
                          // Banner Swiper
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.266,
                            width: double.infinity,
                            child: provider.bannerImages.isEmpty
                                ? const Center(child: Text('No banner images'))
                                : Swiper(
                              indicatorLayout: PageIndicatorLayout.SCALE,
                              autoplay: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      // bottom: 0,
                                      child: CachedNetworkImage(
                                        imageUrl: provider.bannerImages[index],
                                        placeholder: (context, url) =>
                                        const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    // Delete button
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        onPressed: () => provider
                                            .deleteImage(provider.bannerImages[index]),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: provider.bannerImages.length,
                              pagination: const SwiperPagination(),
                              control: const SwiperControl(),
                            ),
                          ),

                          // Upload buttons
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => provider.uploadImageFromDevice(),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                ),
                                if (!kIsWeb) // Camera button only for mobile
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        provider.uploadImageFromDevice(fromCamera: true),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Camera'),
                                  ),
                                ElevatedButton.icon(
                                  onPressed: () => _showUrlDialog(context, provider),
                                  icon: const Icon(Icons.link),
                                  label: const Text('URL'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildSectionHeader('Categories'),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: productsData.categories.length,
                      itemBuilder: (context, index) {
                        final category = productsData.categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FilteredProductsPage(
                                  filterType: 'category',
                                  filterValue: category.categoryName,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: cardColor,
                            elevation: 2,
                            margin: const EdgeInsets.only(right: 12, bottom: 4),
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      category.categoryImagesPath,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.categoryName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Brands Section
                  _buildSectionHeader('Popular Brands'),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: productsData.brands.length,
                      itemBuilder: (context, index) {
                        final brand = productsData.brands[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FilteredProductsPage(
                                  filterType: 'brand',
                                  filterValue: brand.brandName,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: cardColor,
                            elevation: 1,
                            margin: const EdgeInsets.only(right: 12, bottom: 4),
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    brand.brandImagesPath,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    brand.brandName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Products Grid
                  _buildSectionHeader('All Products'),
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productsData.products.length,
                    itemBuilder: (context, index) {
                      final product = productsData.products[index];
                      return Card(
                        color: cardColor,
                        elevation: 2,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(product.imageUrls[0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF64FFDA),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Delete Button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _showDeleteConfirmation(context, product.id);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // Previous code remains the same until _deleteProduct function...

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      // 1. Get the product document to retrieve image URLs
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      // 2. Get image URLs from the product document
      final data = productDoc.data()!;
      final List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);

      // 3. Delete each image from Storage
      for (String imageUrl in imageUrls) {
        try {
          // Convert URL to storage reference
          // Assuming the URL is a Firebase Storage URL
          // Example URL: https://firebasestorage.googleapis.com/v0/b/your-app.appspot.com/o/products%2Fimage.jpg
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $imageUrl');
          print('Error details: $e');
          // Continue with other images even if one fails
        }
      }

      // 4. Delete the product document from Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Delete Product',
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'Are you sure you want to delete this product? This will also delete all associated images.',
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _deleteProduct(context, productId);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Product and images deleted successfully',
                      style: TextStyle(color: textColor),
                    ),
                    backgroundColor: cardColor,
                  ),
                );
              } catch (error) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete product: $error',
                      style: TextStyle(color: textColor),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}