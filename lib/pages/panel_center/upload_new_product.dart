import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../provider/products.dart';
import '../../provider/product_upload_provider.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  // Define theme colors
  final Color primaryColor = Color(0xFF0B1A40);
  final Color accentColor = Colors.amber;
  final Color textColor = Colors.white;
  final Color subtleTextColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    // Get the products provider for categories and brands
    final productsProvider = Provider.of<Products>(context);
    final categories = productsProvider.categories;
    final brands = productsProvider.brands;

    // Get the upload provider
    final uploadProvider = Provider.of<ProductUploadProvider>(context);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor),
          ),
          labelStyle: TextStyle(color: subtleTextColor),
          hintStyle: TextStyle(color: subtleTextColor),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: uploadProvider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images Section
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Images',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Add URL Input Field
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: uploadProvider.imageUrlController,
                                decoration: InputDecoration(
                                  labelText: 'Image URL',
                                  hintText: 'Enter image URL',
                                  prefixIcon: Icon(Icons.link, color: accentColor),
                                ),
                                style: TextStyle(color: textColor),
                                onChanged: (value) {
                                  uploadProvider.validateImageUrl(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: uploadProvider.isValidImageUrl ? uploadProvider.addImageUrl : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Add URL'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.photo_library, color: accentColor),
                              label: Text(
                                'Upload from Gallery',
                                style: TextStyle(color: accentColor),
                              ),
                              onPressed: () async {
                                try {
                                  await uploadProvider.pickImage();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to pick image: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Modified Image Preview Section
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: uploadProvider.selectedImages.length + uploadProvider.imageUrls.length,
                            itemBuilder: (context, index) {
                              if (index < uploadProvider.selectedImages.length) {
                                // Local image preview
                                return _buildImagePreview(
                                  isFile: true,
                                  source: uploadProvider.selectedImages[index],
                                  index: index,
                                  onRemove: () => uploadProvider.removeLocalImage(index),
                                  context: context,
                                );
                              } else {
                                // URL image preview
                                final urlIndex = index - uploadProvider.selectedImages.length;
                                return _buildImagePreview(
                                  context: context,
                                  isFile: false,
                                  source: uploadProvider.imageUrls[urlIndex],
                                  index: urlIndex,
                                  onRemove: () => uploadProvider.removeUrlImage(urlIndex),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Product Details Section
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: uploadProvider.titleController,
                          decoration: InputDecoration(
                            labelText: 'Product Title',
                            prefixIcon: Icon(Icons.title, color: accentColor),
                          ),
                          style: TextStyle(color: textColor),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter product title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: uploadProvider.descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Product Description',
                            prefixIcon: Icon(Icons.description, color: accentColor),
                          ),
                          style: TextStyle(color: textColor),
                          maxLines: 3,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter product description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: uploadProvider.priceController,
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  prefixIcon: Icon(Icons.attach_money, color: accentColor),
                                ),
                                style: TextStyle(color: textColor),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter price';
                                  }
                                  if (double.tryParse(value!) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: uploadProvider.quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  prefixIcon: Icon(Icons.inventory, color: accentColor),
                                ),
                                style: TextStyle(color: textColor),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter quantity';
                                  }
                                  if (int.tryParse(value!) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Optional Details Section
                Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optional Details',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: uploadProvider.selectedCategory.isEmpty ? null : uploadProvider.selectedCategory,
                          hint: Text('Select Category', style: TextStyle(color: subtleTextColor)),
                          dropdownColor: primaryColor,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.categoryName,
                              child: Text(category.categoryName, style: TextStyle(color: textColor)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            uploadProvider.selectedCategory = value ?? '';
                            uploadProvider.notifyListeners();
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.category, color: accentColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: uploadProvider.selectedBrand.isEmpty ? null : uploadProvider.selectedBrand,
                          hint: Text('Select Brand (Optional)', style: TextStyle(color: subtleTextColor)),
                          dropdownColor: primaryColor,
                          items: brands.map((brand) {
                            return DropdownMenuItem(
                              value: brand.brandName,
                              child: Text(brand.brandName, style: TextStyle(color: textColor)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            uploadProvider.selectedBrand = value ?? '';
                            uploadProvider.notifyListeners();
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.branding_watermark, color: accentColor),
                          ),
                        ),
                        SwitchListTile(
                          title: Text('Add to Featured Product', style: TextStyle(color: textColor)),
                          value: uploadProvider.isPopular,
                          activeColor: accentColor,
                          onChanged: (value) {
                            uploadProvider.isPopular = value;
                            uploadProvider.notifyListeners();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (uploadProvider.isLoading)
                  Center(child: CircularProgressIndicator(color: accentColor))
                else
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await uploadProvider.submitForm();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product uploaded successfully')));
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: accentColor,
                      minimumSize: Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Upload Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview({
    required BuildContext context,
    required bool isFile,
    required dynamic source,
    required int index,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isFile
                ? Image.file(
              source as File,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            )
                : Image.network(
              source as String,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: onRemove,
              constraints: BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.all(4),
            ),
          ),
        ),
      ],
    );
  }
}
