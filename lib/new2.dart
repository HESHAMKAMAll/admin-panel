// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
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
//   @override
//   Widget build(BuildContext context) {
//     final productsProvider = Provider.of<Products>(context);
//     final categories = productsProvider.categories;
//     final brands = productsProvider.brands;
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
//                   color: Colors.white.withValues(alpha: 0.1),
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
//                         SizedBox(
//                           height: 150,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _selectedImages.length + 1,
//                             itemBuilder: (context, index) {
//                               if (index == _selectedImages.length) {
//                                 return Padding(
//                                   padding: EdgeInsets.all(8),
//                                   child: InkWell(
//                                     onTap: _pickImage,
//                                     child: Container(
//                                       width: 100,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(color: accentColor),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Icon(
//                                         Icons.add_photo_alternate,
//                                         size: 40,
//                                         color: accentColor,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return Stack(
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.all(8),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.file(
//                                         _selectedImages[index],
//                                         width: 100,
//                                         height: 150,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 0,
//                                     right: 0,
//                                     child: Material(
//                                       color: Colors.black54,
//                                       borderRadius: BorderRadius.circular(20),
//                                       child: IconButton(
//                                         icon: Icon(Icons.close, color: Colors.white),
//                                         onPressed: () => _removeImage(index),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
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
//                           hint: Text('Select Category (Optional)', style: TextStyle(color: subtleTextColor)),
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
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImages.add(File(pickedFile.path));
//       });
//     }
//   }
//
//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }
//
//   Future<List<String>> _uploadImages() async {
//     List<String> imageUrls = [];
//
//     for (var imageFile in _selectedImages) {
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference storageRef = FirebaseStorage.instance.ref().child('products/$fileName');
//
//       await storageRef.putFile(imageFile);
//       String downloadUrl = await storageRef.getDownloadURL();
//       imageUrls.add(downloadUrl);
//     }
//
//     return imageUrls;
//   }
//
//   Future<void> _submitForm(BuildContext context) async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select at least one image')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final imageUrls = await _uploadImages();
//
//       await Provider.of<Products>(context, listen: false).uploadProduct(
//         title: _titleController.text,
//         description: _descriptionController.text,
//         price: double.parse(_priceController.text),
//         imageUrls: imageUrls,
//         brand: _selectedBrand,
//         category: _selectedCategory,
//         quantity: int.parse(_quantityController.text),
//         isPopular: _isPopular,
//       );
//
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Product uploaded successfully')),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(error.toString())),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }
// }
