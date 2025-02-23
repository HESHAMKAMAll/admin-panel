import 'package:flutter/cupertino.dart';

// تأكد من أن فئة Product لديها حقل للتقييمات بشكل صحيح
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String productCategoryName;
  final String brand;
  final int quantity;
  final bool isFavorite;
  final bool isPopular;
  final Map<String, double> ratings;
  final double? firebaseAverageRating;
  final DateTime createdAt; // New field

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.productCategoryName,
    required this.brand,
    required this.quantity,
    required this.isFavorite,
    required this.isPopular,
    this.ratings = const {},
    this.firebaseAverageRating,
    DateTime? createdAt, // Optional parameter
  }): this.createdAt = createdAt ?? DateTime.now(); // Default to current time if not provided

  bool get isNew {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays <= 7; // Consider product new if less than 7 days old
  }

  double get averageRating {
    if (firebaseAverageRating != null) return firebaseAverageRating!;
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.values.fold(0.0, (prev, rating) => prev + rating);
    return sum / ratings.length;
  }
}


class Category with ChangeNotifier {
  final String categoryName;
  final String categoryImagesPath;

  Category({
    required this.categoryName,
    required this.categoryImagesPath,
  });
}


class BrandModel with ChangeNotifier {
  final String brandName;
  final String brandImagesPath;

  BrandModel({
    required this.brandName,
    required this.brandImagesPath,
  });
}


class CartItems with ChangeNotifier {
  final String id;
  final String title;
  int quantity;
  final double price;
  final List<String> imageUrls; // تعديل لتكون قائمة صور بدلاً من صورة واحدة

  CartItems({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrls,
  });
}


