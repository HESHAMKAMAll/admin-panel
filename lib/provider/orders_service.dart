// order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled
}

// Add this enum for order filters
enum OrderTimeFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}

class OrderItem {
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final List<String> imageUrls;

  OrderItem({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
      'imageUrls': imageUrls,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      title: map['title'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      imageUrls: List<String>.from(map['imageUrls']),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? shippingAddress;
  final String? contactNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.shippingAddress,
    this.contactNumber,
  });

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    // تحويل قيمة status من string إلى OrderStatus
    OrderStatus parseStatus(String statusStr) {
      switch (statusStr.toLowerCase()) {
        case 'pending':
          return OrderStatus.pending;
        case 'processing':
          return OrderStatus.processing;
        case 'shipped':
          return OrderStatus.shipped;
        case 'delivered':
          return OrderStatus.delivered;
        case 'cancelled':
          return OrderStatus.cancelled;
        default:
          print('Unknown status string: $statusStr, defaulting to pending');
          return OrderStatus.pending;
      }
    }

    return Order(
      id: id,
      userId: map['userId'],
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: map['totalAmount'].toDouble(),
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      status: parseStatus(map['status']),
      shippingAddress: map['shippingAddress'],
      contactNumber: map['contactNumber'],
    );
  }

// نعدل أيضاً طريقة تحويل Enum إلى String في toMap

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'contactNumber': contactNumber,
    };
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'userId': userId,
  //     'items': items.map((item) => item.toMap()).toList(),
  //     'totalAmount': totalAmount,
  //     'orderDate': Timestamp.fromDate(orderDate),
  //     'status': status.toString().split('.').last,
  //     'shippingAddress': shippingAddress,
  //     'contactNumber': contactNumber,
  //   };
  // }
  //
  // factory Order.fromMap(String id, Map<String, dynamic> map) {
  //   return Order(
  //     id: id,
  //     userId: map['userId'],
  //     items: (map['items'] as List)
  //         .map((item) => OrderItem.fromMap(item))
  //         .toList(),
  //     totalAmount: map['totalAmount'].toDouble(),
  //     orderDate: (map['orderDate'] as Timestamp).toDate(),
  //     status: OrderStatus.values.firstWhere(
  //           (e) => e.toString().split('.').last == map['status'],
  //       orElse: () => OrderStatus.pending,
  //     ),
  //     shippingAddress: map['shippingAddress'],
  //     contactNumber: map['contactNumber'],
  //   );
  // }
}

// orders_service.dart


class OrdersService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Order> _orders = [];
  int _pendingOrdersCount = 0;

  List<Order> get orders => [..._orders];
  int get pendingOrdersCount => _pendingOrdersCount;

  // Add this method to get pending orders count
  Stream<int> streamPendingOrdersCount() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Add this method to get pending orders count for a specific user
  Stream<int> streamUserPendingOrdersCount(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: OrderStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<Order>> streamOrdersByStatus(OrderStatus status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return orders;
    });
  }

  // تعديل الدالة لجلب جميع الطلبات
  Stream<List<Order>> streamAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Order.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Helper method to find pending order
  Future<Order?> _findPendingOrder(String userId) async {
    try {
      final QuerySnapshot pendingOrders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: OrderStatus.pending.toString().split('.').last)
          .get();

      if (pendingOrders.docs.isEmpty) {
        return null;
      }

      return Order.fromMap(
          pendingOrders.docs.first.id,
          pendingOrders.docs.first.data() as Map<String, dynamic>
      );
    } catch (error) {
      print('Error finding pending order: $error');
      throw Exception('Failed to find pending order');
    }
  }

  // Fixed create order method
  Future<String> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String contactNumber,
  }) async
  {
    try {
      // Check for existing pending order
      final existingOrder = await _findPendingOrder(userId);

      if (existingOrder != null) {
        // Create a new list for updated items
        List<OrderItem> updatedItems = [...existingOrder.items];
        double updatedTotal = existingOrder.totalAmount;

        // Process each new item
        for (OrderItem newItem in items) {
          // Find if item already exists
          int existingItemIndex = updatedItems.indexWhere(
                  (item) => item.productId == newItem.productId
          );

          if (existingItemIndex != -1) {
            // Get existing item
            OrderItem existingItem = updatedItems[existingItemIndex];

            // Calculate the price for the additional quantity
            double additionalCost = newItem.price * newItem.quantity;
            updatedTotal += additionalCost;

            // Create updated item with new quantity
            updatedItems[existingItemIndex] = OrderItem(
              productId: existingItem.productId,
              title: existingItem.title,
              quantity: existingItem.quantity + newItem.quantity,
              price: existingItem.price,
              imageUrls: existingItem.imageUrls,
            );
          } else {
            // Add new item
            updatedItems.add(newItem);
            updatedTotal += newItem.price * newItem.quantity;
          }
        }

        // Create updated order
        final updatedOrder = Order(
          id: existingOrder.id,
          userId: userId,
          items: updatedItems,
          totalAmount: updatedTotal,
          orderDate: existingOrder.orderDate,
          status: OrderStatus.pending,
          shippingAddress: shippingAddress,
          contactNumber: contactNumber,
        );

        // Update in Firestore
        await _firestore
            .collection('orders')
            .doc(existingOrder.id)
            .update(updatedOrder.toMap());

        // Update local list
        final orderIndex = _orders.indexWhere((order) => order.id == existingOrder.id);
        if (orderIndex != -1) {
          _orders[orderIndex] = updatedOrder;
        } else {
          _orders.insert(0, updatedOrder);
        }
        notifyListeners();

        return existingOrder.id;
      } else {
        // Create new order
        final orderData = Order(
          id: '',
          userId: userId,
          items: items,
          totalAmount: items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
          orderDate: DateTime.now(),
          status: OrderStatus.pending,
          shippingAddress: shippingAddress,
          contactNumber: contactNumber,
        ).toMap();

        // Add to Firestore
        final DocumentReference docRef = await _firestore
            .collection('orders')
            .add(orderData);

        // Add to local list
        final newOrder = Order.fromMap(docRef.id, orderData);
        _orders.insert(0, newOrder);
        notifyListeners();

        return docRef.id;
      }
    } catch (error) {
      print('Error creating/updating order: $error');
      throw Exception('Failed to create/update order');
    }
  }


  // Get user's orders
  Future<List<Order>> fetchUserOrders(String userId) async {
    try {
      final QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      _orders = ordersSnapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      notifyListeners();
      return _orders;
    } catch (error) {
      print('Error fetching orders: $error');
      throw Exception('Failed to fetch orders');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // استخدام طريقة تحويل ثابتة ومتسقة
      String statusString = newStatus.toString().split('.').last;

      // طباعة القيمة للتأكد من صحتها (للتصحيح)
      print('Updating status to: $statusString');

      // تحديث القيمة في Firestore
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': statusString});

      // تحديث القائمة المحلية
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final updatedOrder = Order(
          id: _orders[orderIndex].id,
          userId: _orders[orderIndex].userId,
          items: _orders[orderIndex].items,
          totalAmount: _orders[orderIndex].totalAmount,
          orderDate: _orders[orderIndex].orderDate,
          status: newStatus,
          shippingAddress: _orders[orderIndex].shippingAddress,
          contactNumber: _orders[orderIndex].contactNumber,
        );
        _orders[orderIndex] = updatedOrder;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating order status: $error');
      throw Exception('Failed to update order status');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (error) {
      print('Error cancelling order: $error');
      throw Exception('Failed to cancel order');
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot orderDoc = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        return null;
      }

      return Order.fromMap(
          orderDoc.id, orderDoc.data() as Map<String, dynamic>);
    } catch (error) {
      print('Error getting order: $error');
      throw Exception('Failed to get order');
    }
  }

  // Stream of orders for real-time updates
  Stream<List<Order>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        Order.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }
}