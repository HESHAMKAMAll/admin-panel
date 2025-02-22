import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/product_model.dart';

class Products with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Product> _products = [];

  final List<Category> _categories = [];

  final List<BrandModel> _brands = [];

  final List<CartItems> _cartItems = [];

  final List<Product> _wishlist = [];

  List<Product> get products {
    return [..._products];
  }

  List<Category> get categories {
    return [..._categories];
  }

  List<BrandModel> get brands {
    return [..._brands];
  }

  List<CartItems> get cartItems {
    return [..._cartItems];
  }

  List<Product> get wishlist {
    return [..._wishlist];
  }

  Products() {
    fetchProductsRealtime(); // استدعاء المراقبة فور إنشاء الكلاس
    fetchCategoriesRealtime();
    fetchBrandsRealtime();
  }

  void fetchProductsRealtime() {
    _firestore.collection('products').snapshots().listen((event) {
      _products.clear(); // تفريغ القائمة قبل تحديثها

      for (var doc in event.docs) {
        _products.add(Product(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          price: doc['price'].toDouble(),
          imageUrls: List<String>.from(doc['imageUrls']), // جلب قائمة الصور
          brand: doc['brand'],
          productCategoryName: doc['productCategoryName'],
          quantity: doc['quantity'],
          isPopular: doc['isPopular'],
          isFavorite: doc['isFavorite'],
        ));
      }
      notifyListeners(); // تحديث الواجهة
    });
  }

  Product? findById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null; // إرجاع null إذا لم يتم العثور على المنتج
    }
  }

// تعديل وظيفة تحديث تقييم المنتج لضمان الحفاظ على جميع التقييمات السابقة
  Future<void> updateProductRating(String productId, String userId, double rating) async {
    try {
      // الحصول على وثيقة المنتج من Firestore أولاً
      final DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        print('Product document not found');
        return;
      }

      // الحصول على التقييمات الحالية من Firestore
      Map<String, double> currentRatings = {};
      final data = productDoc.data() as Map<String, dynamic>;

      if (data.containsKey('ratings') && data['ratings'] != null) {
        final firebaseRatings = data['ratings'] as Map<String, dynamic>;
        firebaseRatings.forEach((key, value) {
          if (value is num) {
            currentRatings[key] = value.toDouble();
          }
        });
      }

      // إضافة أو تحديث تقييم المستخدم الحالي
      currentRatings[userId] = rating;

      // حساب متوسط التقييم الجديد
      double sum = currentRatings.values.fold(0.0, (prev, r) => prev + r);
      double newAverageRating = currentRatings.isEmpty ? 0.0 : sum / currentRatings.length;

      // تحديث Firebase أولاً
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'ratings': currentRatings,
        'averageRating': newAverageRating,
      });

      // ثم تحديث حالة التطبيق المحلية
      final productIndex = products.indexWhere((prod) => prod.id == productId);
      if (productIndex != -1) {
        products[productIndex] = Product(
          id: products[productIndex].id,
          title: products[productIndex].title,
          description: products[productIndex].description,
          price: products[productIndex].price,
          imageUrls: products[productIndex].imageUrls,
          brand: products[productIndex].brand,
          productCategoryName: products[productIndex].productCategoryName,
          quantity: products[productIndex].quantity,
          isFavorite: products[productIndex].isFavorite,
          isPopular: products[productIndex].isPopular,
          ratings: currentRatings,
          firebaseAverageRating: newAverageRating,
        );

        notifyListeners();
      }
    } catch (error) {
      print('Error updating product rating: $error');
    }
  }

  // طريقة لجلب متوسط التقييم وعدد التقييمات من Firebase
  Future<Map<String, dynamic>> getProductRatings(String productId) async {
    try {
      final docSnapshot = await _firestore.collection('products').doc(productId).get();
      if (!docSnapshot.exists) {
        return {'averageRating': 0.0, 'ratingsCount': 0};
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final averageRating = data['averageRating'] ?? 0.0;
      final ratings = data['ratings'] as Map<String, dynamic>? ?? {};

      return {
        'averageRating': averageRating is double ? averageRating : (averageRating as num).toDouble(),
        'ratingsCount': ratings.length,
        'ratings': ratings
      };
    } catch (e) {
      print('Error getting product ratings: $e');
      return {'averageRating': 0.0, 'ratingsCount': 0, 'ratings': {}};
    }
  }

  void fetchCategoriesRealtime() {
    _firestore.collection('categories').snapshots().listen((event) {
      _categories.clear();

      for (var doc in event.docs) {
        _categories.add(Category(
          categoryName: doc['categoryName'],
          categoryImagesPath: doc['categoryImagesPath'],
        ));
      }
      notifyListeners();
    });
  }

  void fetchBrandsRealtime() {
    _firestore.collection('brands').snapshots().listen((event) {
      _brands.clear();

      for (var doc in event.docs) {
        _brands.add(BrandModel(
          brandName: doc['brandName'],
          brandImagesPath: doc['brandImagesPath'],
        ));
      }
      notifyListeners();
    });
  }




  // _____________________________________
  void addProductToCart(String productId, double price, String title, List<String> imageUrls) {
    int index = _cartItems.indexWhere((item) => item.id == productId);

    if (index != -1) {
      // المنتج موجود بالفعل، قم بتحديث الكمية
      _cartItems[index] = CartItems(
        id: _cartItems[index].id,
        title: _cartItems[index].title,
        quantity: _cartItems[index].quantity + 1,
        price: _cartItems[index].price,
        imageUrls: _cartItems[index].imageUrls, // استخدم نفس قائمة الصور
      );
    } else {
      // المنتج غير موجود، قم بإضافته للقائمة
      _cartItems.add(CartItems(
        id: productId,
        title: title,
        quantity: 1,
        price: price,
        imageUrls: imageUrls, // قائمة الصور
      ));
    }
    notifyListeners();
  }


  void reduceItemByOne(String productId) {
    int index = _cartItems.indexWhere((item) => item.id == productId);

    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        // تقليل الكمية إذا كانت أكبر من 1
        _cartItems[index] = CartItems(
          id: _cartItems[index].id,
          title: _cartItems[index].title,
          quantity: _cartItems[index].quantity - 1,
          price: _cartItems[index].price,
          imageUrls: _cartItems[index].imageUrls, // الاحتفاظ بنفس الصور
        );
      } else {
        // إزالة العنصر إذا وصلت الكمية إلى 1
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }


  void removeItem(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void addProductToWishlist({
    required String productId,
    required double price,
    required String title,
    required List<String> imageUrls,
    required bool isFavorite,
    required bool isPopular,
    required String productCategoryName,
    required String brand,
    required String description,
  })
  {
    int index = _wishlist.indexWhere((item) => item.id == productId);
    if (index == -1) {
      _wishlist.add(Product(
        id: productId,
        title: title,
        quantity: 1,
        price: price,
        imageUrls: imageUrls,
        brand: brand,
        description: description,
        isFavorite: isFavorite,
        isPopular: isPopular,
        productCategoryName: productCategoryName,
      ));
      notifyListeners();
    }
  }


  void removeItemWishList(String productId) {
    _wishlist.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  List<Product> searchProducts(String query) {
    return _products
        .where((product) => product.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  }

  Future<void> uploadProduct({
    required String title,
    required String description,
    required double price,
    required List<String> imageUrls,
    String brand = '',
    required String category,
    required int quantity,
    bool isPopular = false,
  }) async
  {
    try {
      // التحقق من أن الفئة موجودة في _categories
      if (!_categories.any((cat) => cat.categoryName == category)) {
        throw Exception('⚠ الفئة غير موجودة في النظام.');
      }

      // إنشاء كائن المنتج بدون ID مؤقت
      final productData = {
        'title': title,
        'description': description,
        'price': price,
        'imageUrls': imageUrls,
        'brand': brand,
        'productCategoryName': category,
        'quantity': quantity,
        'isPopular': isPopular,
        'isFavorite': false,
      };

      // رفع المنتج إلى Firestore داخل مجموعة 'products'
      final docRef = await _firestore.collection('products').add(productData);

      // إنشاء كائن المنتج محليًا مع ID الحقيقي من Firestore
      final newProduct = Product(
        id: docRef.id, // استخدم ID الذي أنشأه Firestore
        title: title,
        description: description,
        price: price,
        imageUrls: imageUrls,
        brand: brand,
        productCategoryName: category,
        quantity: quantity,
        isPopular: isPopular,
        isFavorite: false,
      );

      // إضافة المنتج إلى القائمة المحلية
      _products.add(newProduct);
      notifyListeners(); // تحديث الواجهة بعد الإضافة
    } catch (error) {
      print("❌ حدث خطأ أثناء رفع المنتج: $error");
      throw Exception("❌ لم يتم رفع المنتج، حاول مرة أخرى.");
    }
  }

}
