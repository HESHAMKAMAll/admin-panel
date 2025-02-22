import 'package:flutter/cupertino.dart';

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
  });

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


