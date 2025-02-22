// firebase_image_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class BannerImagesProvider extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  List<String> bannerImages = [];
  bool isLoading = false;

  BannerImagesProvider() {
    loadBannerImages();
  }

  Future<void> loadBannerImages() async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('banners').doc('images').get();
      if (snapshot.exists) {
        final data = snapshot.data();
        bannerImages = List<String>.from(data?['urls'] ?? []);
      }
    } catch (e) {
      print('Error loading banner images: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadImageFromUrl(String imageUrl) async {
    try {
      isLoading = true;
      notifyListeners();

      // Check if the URL is a direct image URL (e.g., from Firebase Storage or other hosting)
      if (imageUrl.startsWith('https://') &&
          (imageUrl.contains('firebasestorage.googleapis.com') ||
              _isImageUrl(imageUrl))) {
        // If it's already a hosted image, add it directly to Firestore
        bannerImages.add(imageUrl);
        await _updateFirestore();
      } else {
        // If it's not a direct image URL, download and upload to Storage
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final fileName = '${Uuid().v4()}.jpg';
          final ref = _storage.ref().child('banners/$fileName');
          await ref.putData(bytes);

          final downloadUrl = await ref.getDownloadURL();
          bannerImages.add(downloadUrl);
          await _updateFirestore();
        } else {
          throw Exception('Failed to load image');
        }
      }
    } catch (e) {
      print('Error uploading image from URL: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Helper method to check if URL is an image
  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext)) ||
        url.contains('images') ||  // Common in image hosting URLs
        url.contains('img') ||     // Common in image hosting URLs
        url.contains('photos');    // Common in image hosting URLs
  }

  Future<void> uploadImageFromDevice({bool fromCamera = false}) async {
    try {
      isLoading = true;
      notifyListeners();

      // Pick image
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image != null) {
        // Upload to Firebase Storage
        final fileName = path.basename(image.path);
        final ref = _storage.ref().child('banners/$fileName');
        await ref.putFile(File(image.path));

        // Get download URL
        final downloadUrl = await ref.getDownloadURL();

        // Add to Firestore
        bannerImages.add(downloadUrl);
        await _updateFirestore();
      }
    } catch (e) {
      print('Error uploading image from device: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      isLoading = true;
      notifyListeners();

      // Check if the image is stored in Firebase Storage
      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        // Delete from Storage only if it's a Firebase Storage URL
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }

      // Remove from list and update Firestore regardless of image source
      bannerImages.remove(imageUrl);
      await _updateFirestore();

    } catch (e) {
      print('Error deleting image: $e');
      // If deletion from Storage fails, still remove from Firestore
      bannerImages.remove(imageUrl);
      await _updateFirestore();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Helper method to check if URL is from Firebase Storage
  bool _isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  Future<void> _updateFirestore() async {
    await _firestore.collection('banners').doc('images').set({
      'urls': bannerImages,
    });
  }
}