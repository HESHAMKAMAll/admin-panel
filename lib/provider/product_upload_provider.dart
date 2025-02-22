import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';

class ProductUploadProvider with ChangeNotifier {
  // Form state
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final imageUrlController = TextEditingController();

  String selectedCategory = '';
  String selectedBrand = '';
  bool isPopular = false;
  List<File> selectedImages = [];
  List<String> imageUrls = [];
  bool isValidImageUrl = false;
  bool isLoading = false;

  // Validate image URL
  void validateImageUrl(String value) {
    isValidImageUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;
    notifyListeners();
  }

  // Add image URL
  void addImageUrl() {
    if (imageUrlController.text.isNotEmpty && isValidImageUrl) {
      imageUrls.add(imageUrlController.text);
      imageUrlController.clear();
      isValidImageUrl = false;
      notifyListeners();
    }
  }

  // Remove local image
  void removeLocalImage(int index) {
    selectedImages.removeAt(index);
    notifyListeners();
  }

  // Remove URL image
  void removeUrlImage(int index) {
    imageUrls.removeAt(index);
    notifyListeners();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImages.add(File(pickedFile.path));
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> uploadImages(String productId) async {
    List<String> uploadedUrls = [];
    final storage = FirebaseStorage.instance;

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        final File imageFile = selectedImages[i];
        final String fileName = 'image_$i.jpg';

        // Create reference to the image in the product folder
        final Reference imageRef = storage
            .ref()
            .child('products')
            .child(productId)
            .child(fileName);

        // Upload image with metadata
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
        );

        // Wait for the upload to complete
        await imageRef.putFile(imageFile, metadata);

        // Get download URL
        String downloadUrl = await imageRef.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Submit the form and upload product to Firestore
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty && imageUrls.isEmpty) {
      throw Exception('Please add at least one image');
    }

    isLoading = true;
    notifyListeners();

    try {
      // 1. Create a reference to get the ID
      final docRef = FirebaseFirestore.instance.collection('products').doc();
      final String productId = docRef.id;

      // 2. Upload local images to the product folder
      List<String> storageUrls = await uploadImages(productId);

      // 3. Merge local image links with direct links
      List<String> allImageUrls = [...storageUrls, ...imageUrls];

      // 4. Create Product object
      final Product newProduct = Product(
        id: productId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        imageUrls: allImageUrls,
        productCategoryName: selectedCategory,
        brand: selectedBrand,
        quantity: int.parse(quantityController.text),
        isFavorite: false,
        isPopular: isPopular,
        ratings: {},
        firebaseAverageRating: 0.0,
      );

      // 5. Convert Product object to Map
      final Map<String, dynamic> productData = {
        'id': productId,
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrls': newProduct.imageUrls,
        'brand': newProduct.brand,
        'productCategoryName': newProduct.productCategoryName,
        'quantity': newProduct.quantity,
        'isPopular': newProduct.isPopular,
        'isFavorite': newProduct.isFavorite,
        'ratings': newProduct.ratings,
        'averageRating': newProduct.firebaseAverageRating,
      };

      // 6. Upload data to Firestore
      await docRef.set(productData);

      // 7. Reset the form
      resetForm();

    } catch (error) {
      throw Exception('Failed to upload product: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset the form
  void resetForm() {
    formKey.currentState?.reset();
    selectedImages.clear();
    imageUrls.clear();
    isPopular = false;
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    selectedCategory = '';
    selectedBrand = '';
    notifyListeners();
  }

  // Clean up controllers when no longer needed
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
}