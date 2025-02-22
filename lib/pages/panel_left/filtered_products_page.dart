import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../provider/products.dart';

class FilteredProductsPage extends StatelessWidget {
  final String filterType;
  final String filterValue;

  const FilteredProductsPage({
    Key? key,
    required this.filterType,
    required this.filterValue,
  }) : super(key: key);

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      // 1. Get product document for image URLs
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      // 2. Get image URLs
      final data = productDoc.data()!;
      final List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);

      // 3. Delete images from Storage
      for (String imageUrl in imageUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $imageUrl');
          print('Error details: $e');
        }
      }

      // 4. Delete product document
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
        backgroundColor: const Color(0xFF162952),
        title: const Text(
          'Delete Product',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this product? This will also delete all associated images.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _deleteProduct(context, productId);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Product and images deleted successfully',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color(0xFF162952),
                  ),
                );
              } catch (error) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete product: $error',
                      style: const TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D193E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D193E),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          filterValue,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Consumer<Products>(
        builder: (context, productsData, _) {
          final filteredProducts = productsData.products.where((product) {
            if (filterType == 'category') {
              return product.productCategoryName == filterValue;
            } else {
              return product.brand == filterValue;
            }
          }).toList();

          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found in this ${filterType}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Filter Info Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E224C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          filterType == 'category'
                              ? Icons.category_outlined
                              : Icons.branding_watermark_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filterType == 'category' ? 'Category' : 'Brand',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                filterValue,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${filteredProducts.length} Products',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        color: const Color(0xFF1E224C),
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
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF64FFDA),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Stock: ${product.quantity}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
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
                                onPressed: () => _showDeleteConfirmation(context, product.id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}