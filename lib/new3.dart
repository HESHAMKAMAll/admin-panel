// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../../models/product_model.dart';
// import '../../provider/products.dart';
//
// class UploadProductScreen extends StatefulWidget {
//   const UploadProductScreen({super.key});
//
//   @override
//   _UploadProductScreenState createState() => _UploadProductScreenState();
// }
//
// class _UploadProductScreenState extends State<UploadProductScreen> {
//   // ... existing variables ...
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _quantityController = TextEditingController();
//   String _selectedCategory = '';
//   String _selectedBrand = '';
//   bool _isPopular = false;
//   List<File> _selectedImages = [];
//   bool _isLoading = false;
//
//   // Define theme colors
//   final Color primaryColor = Color(0xFF0B1A40);
//   final Color accentColor = Colors.amber;
//   final Color textColor = Colors.white;
//   final Color subtleTextColor = Colors.white70;
//
//   final _imageUrlController = TextEditingController();
//   bool _isValidImageUrl = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final productsProvider = Provider.of<Products>(context);
//     final categories = productsProvider.categories;
//     final brands = productsProvider.brands;
//     // ... existing build method content until the Images Section ...
//
//     return Theme(
//       data: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: primaryColor,
//         appBarTheme: AppBarTheme(
//           backgroundColor: primaryColor,
//           elevation: 0,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white.withValues(alpha: 0.1),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.white24),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: accentColor),
//           ),
//           labelStyle: TextStyle(color: subtleTextColor),
//           hintStyle: TextStyle(color: subtleTextColor),
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               primaryColor,
//               primaryColor.withValues(alpha: 0.8),
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Images Section
//                 Card(
//                   color: Colors.white.withOpacity(0.1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Product Images',
//                           style: TextStyle(
//                             color: textColor,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//
//                         // Add URL Input Field
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _imageUrlController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Image URL',
//                                   hintText: 'Enter image URL',
//                                   prefixIcon: Icon(Icons.link, color: accentColor),
//                                 ),
//                                 style: TextStyle(color: textColor),
//                                 onChanged: (value) {
//                                   _validateImageUrl(value);
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             ElevatedButton(
//                               onPressed: _isValidImageUrl ? _addImageUrl : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: accentColor,
//                                 foregroundColor: primaryColor,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text('Add URL'),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//
//                         Row(
//                           children: [
//                             TextButton.icon(
//                               icon: Icon(Icons.photo_library, color: accentColor),
//                               label: Text(
//                                 'Upload from Gallery',
//                                 style: TextStyle(color: accentColor),
//                               ),
//                               onPressed: _pickImage,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//
//                         // Modified Image Preview Section
//                         SizedBox(
//                           height: 150,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _selectedImages.length + _imageUrls.length,
//                             itemBuilder: (context, index) {
//                               if (index < _selectedImages.length) {
//                                 // Local image preview
//                                 return _buildImagePreview(
//                                   isFile: true,
//                                   source: _selectedImages[index],
//                                   index: index,
//                                 );
//                               } else {
//                                 // URL image preview
//                                 final urlIndex = index - _selectedImages.length;
//                                 return _buildImagePreview(
//                                   isFile: false,
//                                   source: _imageUrls[urlIndex],
//                                   index: urlIndex,
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Product Details Section
//                 Card(
//                   color: Colors.white.withValues(alpha: 0.1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Product Details',
//                           style: TextStyle(
//                             color: textColor,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _titleController,
//                           decoration: InputDecoration(
//                             labelText: 'Product Title',
//                             prefixIcon: Icon(Icons.title, color: accentColor),
//                           ),
//                           style: TextStyle(color: textColor),
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'Please enter product title';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _descriptionController,
//                           decoration: InputDecoration(
//                             labelText: 'Product Description',
//                             prefixIcon: Icon(Icons.description, color: accentColor),
//                           ),
//                           style: TextStyle(color: textColor),
//                           maxLines: 3,
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'Please enter product description';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _priceController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Price',
//                                   prefixIcon: Icon(Icons.attach_money, color: accentColor),
//                                 ),
//                                 style: TextStyle(color: textColor),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value?.isEmpty ?? true) {
//                                     return 'Please enter price';
//                                   }
//                                   if (double.tryParse(value!) == null) {
//                                     return 'Please enter a valid number';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _quantityController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Quantity',
//                                   prefixIcon: Icon(Icons.inventory, color: accentColor),
//                                 ),
//                                 style: TextStyle(color: textColor),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value?.isEmpty ?? true) {
//                                     return 'Please enter quantity';
//                                   }
//                                   if (int.tryParse(value!) == null) {
//                                     return 'Please enter a valid number';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Optional Details Section
//                 Card(
//                   color: Colors.white.withValues(alpha: 0.1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Optional Details',
//                           style: TextStyle(
//                             color: textColor,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<String>(
//                           value: _selectedCategory.isEmpty ? null : _selectedCategory,
//                           hint: Text('Select Category', style: TextStyle(color: subtleTextColor)),
//                           dropdownColor: primaryColor,
//                           items: categories.map((category) {
//                             return DropdownMenuItem(
//                               value: category.categoryName,
//                               child: Text(category.categoryName, style: TextStyle(color: textColor)),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedCategory = value ?? '';
//                             });
//                           },
//                           decoration: InputDecoration(
//                             prefixIcon: Icon(Icons.category, color: accentColor),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonFormField<String>(
//                           value: _selectedBrand.isEmpty ? null : _selectedBrand,
//                           hint: Text('Select Brand (Optional)', style: TextStyle(color: subtleTextColor)),
//                           dropdownColor: primaryColor,
//                           items: brands.map((brand) {
//                             return DropdownMenuItem(
//                               value: brand.brandName,
//                               child: Text(brand.brandName, style: TextStyle(color: textColor)),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedBrand = value ?? '';
//                             });
//                           },
//                           decoration: InputDecoration(
//                             prefixIcon: Icon(Icons.branding_watermark, color: accentColor),
//                           ),
//                         ),
//                         SwitchListTile(
//                           title: Text('Featured Product', style: TextStyle(color: textColor)),
//                           value: _isPopular,
//                           activeColor: accentColor,
//                           onChanged: (value) {
//                             setState(() {
//                               _isPopular = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 if (_isLoading)
//                   Center(child: CircularProgressIndicator(color: accentColor))
//                 else
//                   ElevatedButton(
//                     onPressed: () => _submitForm(context),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: primaryColor,
//                       backgroundColor: accentColor,
//                       minimumSize: Size(double.infinity, 54),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Upload Product',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     // Modified Images Section
//
//     // ... rest of the existing build method ...
//   }
//
//   // Add new methods for URL handling
//   List<String> _imageUrls = [];
//
//
//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _quantityController.dispose();
//     _imageUrlController.dispose();
//     super.dispose();
//   }
//
//   void _validateImageUrl(String value) {
//     setState(() {
//       _isValidImageUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;
//     });
//   }
//
//   void _addImageUrl() {
//     if (_imageUrlController.text.isNotEmpty && _isValidImageUrl) {
//       setState(() {
//         _imageUrls.add(_imageUrlController.text);
//         _imageUrlController.clear();
//         _isValidImageUrl = false;
//       });
//     }
//   }
//
//   Widget _buildImagePreview({
//     required bool isFile,
//     required dynamic source,
//     required int index,
//   }) {
//     return Stack(
//       children: [
//         Container(
//           margin: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 offset: Offset(0, 2),
//                 blurRadius: 6.0,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: isFile
//                 ? Image.file(
//               source as File,
//               width: 100,
//               height: 150,
//               fit: BoxFit.cover,
//             )
//                 : Image.network(
//               source as String,
//               width: 100,
//               height: 150,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   width: 100,
//                   height: 150,
//                   color: Colors.grey.shade200,
//                   child: Icon(Icons.error, color: Colors.red),
//                 );
//               },
//             ),
//           ),
//         ),
//         Positioned(
//           top: 0,
//           right: 0,
//           child: Material(
//             color: Colors.black54,
//             borderRadius: BorderRadius.circular(20),
//             child: IconButton(
//               icon: Icon(Icons.close, color: Colors.white),
//               onPressed: () {
//                 setState(() {
//                   if (isFile) {
//                     _selectedImages.removeAt(index);
//                   } else {
//                     _imageUrls.removeAt(index);
//                   }
//                 });
//               },
//               constraints: BoxConstraints(
//                 minWidth: 32,
//                 minHeight: 32,
//               ),
//               padding: EdgeInsets.all(4),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _pickImage() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1200,
//         imageQuality: 80,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImages.add(File(pickedFile.path));
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick image: $e')),
//       );
//     }
//   }
//
//
//   Future<void> _submitForm(BuildContext context) async {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_selectedImages.isEmpty && _imageUrls.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add at least one image')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       // 1. إنشاء مرجع للوثيقة للحصول على ال ID
//       final docRef = FirebaseFirestore.instance.collection('products').doc();
//       final String productId = docRef.id;
//
//       // 2. رفع الصور المحلية إلى مجلد المنتج
//       List<String> storageUrls = await _uploadImages(productId);
//
//       // 3. دمج روابط الصور المحلية مع الروابط المباشرة
//       List<String> allImageUrls = [...storageUrls, ..._imageUrls];
//
//       // 4. إنشاء كائن Product
//       final Product newProduct = Product(
//         id: productId,
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim(),
//         price: double.parse(_priceController.text),
//         imageUrls: allImageUrls,
//         productCategoryName: _selectedCategory,
//         brand: _selectedBrand,
//         quantity: int.parse(_quantityController.text),
//         isFavorite: false,
//         isPopular: _isPopular,
//         ratings: {},
//         firebaseAverageRating: 0.0,
//       );
//
//       // 5. تحويل كائن Product إلى Map
//       final Map<String, dynamic> productData = {
//         'id' : productId,
//         'title': newProduct.title,
//         'description': newProduct.description,
//         'price': newProduct.price,
//         'imageUrls': newProduct.imageUrls,
//         'brand': newProduct.brand,
//         'productCategoryName': newProduct.productCategoryName,
//         'quantity': newProduct.quantity,
//         'isPopular': newProduct.isPopular,
//         'isFavorite': newProduct.isFavorite,
//         'ratings': newProduct.ratings,
//         'averageRating': newProduct.firebaseAverageRating,
//       };
//
//       // 6. رفع البيانات إلى Firestore
//       await docRef.set(productData);
//
//       // 7. إعادة تعيين النموذج
//       _formKey.currentState!.reset();
//       setState(() {
//         _selectedImages.clear();
//         _imageUrls.clear();
//         _isPopular = false;
//         _titleController.clear();
//         _descriptionController.clear();
//         _priceController.clear();
//         _quantityController.clear();
//         _selectedCategory = '';
//         _selectedBrand = '';
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product uploaded successfully')),
//       );
//     } catch (error) {
//       print("Error uploading product: $error");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to upload product: ${error.toString()}')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<List<String>> _uploadImages(String productId) async {
//     List<String> uploadedUrls = [];
//     final storage = FirebaseStorage.instance;
//
//     try {
//       for (int i = 0; i < _selectedImages.length; i++) {
//         final File imageFile = _selectedImages[i];
//         final String fileName = 'image_$i.jpg';
//
//         // إنشاء مرجع للصورة في مجلد المنتج
//         final Reference imageRef = storage
//             .ref()
//             .child('products')
//             .child(productId)
//             .child(fileName);
//
//         // رفع الصورة مع metadata
//         final metadata = SettableMetadata(
//           contentType: 'image/jpeg',
//           customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
//         );
//
//         // انتظار اكتمال رفع الصورة
//         await imageRef.putFile(imageFile, metadata);
//
//         // الحصول على رابط التحميل
//         String downloadUrl = await imageRef.getDownloadURL();
//         uploadedUrls.add(downloadUrl);
//       }
//
//       return uploadedUrls;
//     } catch (e) {
//       print("Error uploading images: $e");
//       throw Exception('Failed to upload images: $e');
//     }
//   }
//
// }
