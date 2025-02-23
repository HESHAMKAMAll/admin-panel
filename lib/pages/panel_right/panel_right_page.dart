import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../provider/orders_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderTimeFilter _timeFilter = OrderTimeFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D193E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF162952),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E3164),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF64B5F6), width: 3),
            ),
          ),
        ),
      ),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Orders Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF243772),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search orders...',
                          hintStyle: const TextStyle(color: Colors.white60),
                          prefixIcon: const Icon(Icons.search, color: Colors.white60),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white60),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    tabs: OrderStatus.values.map((status) {
                      return Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _getStatusText(status),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: OrderStatus.values.map((status) {
              return OrdersListView(
                status: status,
                timeFilter: _timeFilter,
                searchQuery: _searchQuery,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3164),
        title: const Text(
          'Filter Orders',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderTimeFilter.values.map((filter) {
            return RadioListTile<OrderTimeFilter>(
              title: Text(
                _getFilterText(filter),
                style: const TextStyle(color: Colors.white),
              ),
              value: filter,
              groupValue: _timeFilter,
              activeColor: const Color(0xFF64B5F6),
              onChanged: (value) {
                setState(() {
                  _timeFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterText(OrderTimeFilter filter) {
    switch (filter) {
      case OrderTimeFilter.all:
        return 'All Time';
      case OrderTimeFilter.today:
        return 'Today';
      case OrderTimeFilter.thisWeek:
        return 'This Week';
      case OrderTimeFilter.thisMonth:
        return 'This Month';
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

class OrdersListView extends StatelessWidget {
  final OrderStatus status;
  final OrderTimeFilter timeFilter;
  final String searchQuery;

  const OrdersListView({
    Key? key,
    required this.status,
    required this.timeFilter,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersService>(
      builder: (context, ordersService, _) {
        return StreamBuilder<List<Order>>(
          stream: ordersService.streamOrdersByStatus(status),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF64B5F6),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            var orders = snapshot.data ?? [];
            orders = orders.where((order) =>
            _matchesTimeFilter(order.orderDate) &&
                _matchesSearchQuery(order, searchQuery)).toList();

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ${status.toString().split('.').last.toLowerCase()} orders found',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162952),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${orders.length} Orders',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: \$${_calculateTotal(orders)}',
                        style: const TextStyle(
                          color: Color(0xFF64B5F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        onCopy: () => _copyOrderDetails(context, orders[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _matchesTimeFilter(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);

    switch (timeFilter) {
      case OrderTimeFilter.all:
        return true;
      case OrderTimeFilter.today:
        return orderDay == today;
      case OrderTimeFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return orderDay.isAfter(weekStart.subtract(const Duration(days: 1)));
      case OrderTimeFilter.thisMonth:
        return orderDate.year == now.year && orderDate.month == now.month;
    }
  }

  bool _matchesSearchQuery(Order order, String query) {
    if (query.isEmpty) return true;

    final searchLower = query.toLowerCase();
    return order.id.toLowerCase().contains(searchLower) ||
        order.shippingAddress?.toLowerCase().contains(searchLower) == true ||
        order.contactNumber?.toLowerCase().contains(searchLower) == true ||
        order.items.any((item) => item.title.toLowerCase().contains(searchLower));
  }

  String _calculateTotal(List<Order> orders) {
    return orders
        .fold(0.0, (sum, order) => sum + order.totalAmount)
        .toStringAsFixed(2);
  }

  void _copyOrderDetails(BuildContext context, Order order) {
    final details = '''
Order #${order.id}
Status: ${order.status.toString().split('.').last}
Date: ${DateFormat('MMM dd, yyyy HH:mm').format(order.orderDate)}
Items:
${order.items.map((item) => '- ${item.quantity}x ${item.title} (\$${item.price})').join('\n')}
Total: \$${order.totalAmount}
Shipping Address: ${order.shippingAddress}
Contact: ${order.contactNumber}
''';

    Clipboard.setData(ClipboardData(text: details));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order details copied to clipboard'),
        backgroundColor: Color(0xFF1E3164),
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onCopy;

  const OrderCard({
    Key? key,
    required this.order,
    this.onCopy,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.order.status.toString().split('.').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(  // Added Expanded
                      child: Text(
                        'Order #${widget.order.id.substring(0, 8)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,  // Added overflow handling
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(widget.order.orderDate),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            trailing: IntrinsicWidth(  // Changed to IntrinsicWidth
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF64B5F6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),  // Reduced spacing
                  IconButton(
                    constraints: const BoxConstraints(),  // Minimize padding
                    padding: EdgeInsets.zero,  // Remove padding
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // ListTile(
          //   contentPadding: const EdgeInsets.all(16),
          //   title: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Container(
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 12,
          //               vertical: 6,
          //             ),
          //             decoration: BoxDecoration(
          //               color: _getStatusColor(widget.order.status),
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             child: Text(
          //               widget.order.status.toString().split('.').last,
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'Order #${widget.order.id.substring(0, 8)}',
          //             style: const TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         DateFormat('MMM dd, yyyy HH:mm').format(widget.order.orderDate),
          //         style: const TextStyle(
          //           color: Colors.white60,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ],
          //   ),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         '\$${widget.order.totalAmount.toStringAsFixed(2)}',
          //         style: const TextStyle(
          //           color: Color(0xFF64B5F6),
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16,
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       IconButton(
          //         icon: Icon(
          //           _isExpanded ? Icons.expand_less : Icons.expand_more,
          //           color: Colors.white70,
          //         ),
          //         onPressed: () {
          //           setState(() {
          //             _isExpanded = !_isExpanded;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF243772),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Items'),
          const SizedBox(height: 12),
          ...widget.order.items.map((item) => _buildOrderItem(item)),
          const Divider(
            height: 32,
            color: Color(0xFF243772),
          ),
          _buildSectionHeader('Delivery Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Address', widget.order.shippingAddress ?? 'N/A'),
          _buildInfoRow('Contact', widget.order.contactNumber ?? 'N/A'),
          const SizedBox(height: 24),
          LayoutBuilder(  // Added LayoutBuilder
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.onCopy != null && constraints.maxWidth > 400)  // Conditional rendering
                    TextButton.icon(
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFF64B5F6),
                        size: 20,  // Reduced size
                      ),
                      label: const Text(
                        'Copy Details',
                        style: TextStyle(
                          color: Color(0xFF64B5F6),
                          fontSize: 12,  // Reduced size
                        ),
                      ),
                      onPressed: widget.onCopy,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  if (widget.order.status != OrderStatus.cancelled &&
                      widget.order.status != OrderStatus.delivered)
                    Expanded(  // Added Expanded
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showCancelDialog(context),
                            child: const Text(
                              'Cancel',  // Shortened text
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,  // Reduced size
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),  // Reduced spacing
                          ElevatedButton(
                            onPressed: () => _showUpdateStatusDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64B5F6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Update',  // Shortened text
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,  // Reduced size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF243772),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.imageUrls.first),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.quantity * item.price).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF64B5F6),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3164),
        title: const Text(
          'Update Order Status',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values
              .where((status) =>
          status.index > widget.order.status.index &&
              status != OrderStatus.cancelled)
              .map(
                (status) => ListTile(
              title: Text(
                _getStatusText(status),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _updateOrderStatus(context, status);
              },
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3164),
        title: const Text(
          'Cancel Order',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, OrderStatus newStatus) {
    final ordersService = Provider.of<OrdersService>(context, listen: false);
    ordersService.updateOrderStatus(widget.order.id, newStatus);
  }

  void _cancelOrder(BuildContext context) {
    final ordersService = Provider.of<OrdersService>(context, listen: false);
    ordersService.cancelOrder(widget.order.id);
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800);
      case OrderStatus.processing:
        return const Color(0xFF2196F3);
      case OrderStatus.shipped:
        return const Color(0xFF9C27B0);
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }
}













// // Modify AdminOrdersScreen
// class AdminOrdersScreen extends StatefulWidget {
//   const AdminOrdersScreen({super.key});
//
//   @override
//   State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
// }
//
// class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
//   OrderTimeFilter _timeFilter = OrderTimeFilter.all;
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Orders Management'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.filter_list),
//               onPressed: _showFilterDialog,
//             ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(96),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search orders...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchQuery.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 setState(() {
//                                   _searchQuery = '';
//                                   _searchController.clear();
//                                 });
//                               },
//                             )
//                           : null,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                   ),
//                 ),
//                 TabBar(
//                   isScrollable: true,
//                   tabs: OrderStatus.values.map((status) {
//                     return Tab(
//                       child: Text(
//                         _getStatusText(status),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: TabBarView(
//           children: OrderStatus.values.map((status) {
//             return OrdersListView(
//               status: status,
//               timeFilter: _timeFilter,
//               searchQuery: _searchQuery,
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter Orders'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: OrderTimeFilter.values.map((filter) {
//             return RadioListTile<OrderTimeFilter>(
//               title: Text(_getFilterText(filter)),
//               value: filter,
//               groupValue: _timeFilter,
//               onChanged: (value) {
//                 setState(() {
//                   _timeFilter = value!;
//                 });
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   String _getFilterText(OrderTimeFilter filter) {
//     switch (filter) {
//       case OrderTimeFilter.all:
//         return 'All Time';
//       case OrderTimeFilter.today:
//         return 'Today';
//       case OrderTimeFilter.thisWeek:
//         return 'This Week';
//       case OrderTimeFilter.thisMonth:
//         return 'This Month';
//     }
//   }
//
//   String _getStatusText(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.pending:
//         return 'PENDING';
//       case OrderStatus.processing:
//         return 'PROCESSING';
//       case OrderStatus.shipped:
//         return 'SHIPPED';
//       case OrderStatus.delivered:
//         return 'DELIVERED';
//       case OrderStatus.cancelled:
//         return 'CANCELLED';
//     }
//   }
// }
//
// // Modify OrdersListView
// class OrdersListView extends StatelessWidget {
//   final OrderStatus status;
//   final OrderTimeFilter timeFilter;
//   final String searchQuery;
//
//   const OrdersListView({
//     Key? key,
//     required this.status,
//     required this.timeFilter,
//     required this.searchQuery,
//   }) : super(key: key);
//
//   bool _matchesTimeFilter(DateTime orderDate) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
//
//     switch (timeFilter) {
//       case OrderTimeFilter.all:
//         return true;
//       case OrderTimeFilter.today:
//         return orderDay == today;
//       case OrderTimeFilter.thisWeek:
//         final weekStart = today.subtract(Duration(days: today.weekday - 1));
//         return orderDay.isAfter(weekStart.subtract(const Duration(days: 1)));
//       case OrderTimeFilter.thisMonth:
//         return orderDate.year == now.year && orderDate.month == now.month;
//     }
//   }
//
//   bool _matchesSearchQuery(Order order, String query) {
//     if (query.isEmpty) return true;
//
//     final searchLower = query.toLowerCase();
//     return order.id.toLowerCase().contains(searchLower) ||
//         order.shippingAddress?.toLowerCase().contains(searchLower) == true ||
//         order.contactNumber?.toLowerCase().contains(searchLower) == true ||
//         order.items.any((item) => item.title.toLowerCase().contains(searchLower));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrdersService>(
//       builder: (context, ordersService, _) {
//         return StreamBuilder<List<Order>>(
//           stream: ordersService.streamOrdersByStatus(status),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//
//             var orders = snapshot.data ?? [];
//
//             // Apply filters
//             orders = orders.where((order) => _matchesTimeFilter(order.orderDate) && _matchesSearchQuery(order, searchQuery)).toList();
//
//             if (orders.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No ${status.toString().split('.').last.toLowerCase()} orders found',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${orders.length} Orders',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       Text(
//                         'Total: \$${_calculateTotal(orders)}',
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                               color: Theme.of(context).primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: orders.length,
//                     itemBuilder: (context, index) {
//                       return OrderCard(
//                         order: orders[index],
//                         onCopy: () => _copyOrderDetails(context, orders[index]),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   String _calculateTotal(List<Order> orders) {
//     return orders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(2);
//   }
//
//   void _copyOrderDetails(BuildContext context, Order order) {
//     final details = '''
// Order #${order.id}
// Status: ${order.status.toString().split('.').last}
// Date: ${DateFormat('MMM dd, yyyy HH:mm').format(order.orderDate)}
// Items:
// ${order.items.map((item) => '- ${item.quantity}x ${item.title} (\$${item.price})').join('\n')}
// Total: \$${order.totalAmount}
// Shipping Address: ${order.shippingAddress}
// Contact: ${order.contactNumber}
// ''';
//
//     Clipboard.setData(ClipboardData(text: details));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Order details copied to clipboard')),
//     );
//   }
// }
//
// // Modify OrderCard
// class OrderCard extends StatefulWidget {
//   final Order order;
//   final VoidCallback? onCopy;
//
//   const OrderCard({
//     Key? key,
//     required this.order,
//     this.onCopy,
//   }) : super(key: key);
//
//   @override
//   State<OrderCard> createState() => _OrderCardState();
// }
//
// class _OrderCardState extends State<OrderCard> {
//   bool _isExpanded = false;
//
//   String _getStatusText(OrderStatus status) {
//     return status.toString().split('.').last.toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         children: [
//           ListTile(
//             title: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(widget.order.status),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     widget.order.status.toString().split('.').last,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Order #${widget.order.id.substring(0, 8)}',
//                         style: theme.textTheme.titleMedium,
//                       ),
//                       Text(
//                         DateFormat('MMM dd, yyyy HH:mm').format(widget.order.orderDate),
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '\$${widget.order.totalAmount.toStringAsFixed(2)}',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: theme.primaryColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
//                   onPressed: () {
//                     setState(() {
//                       _isExpanded = !_isExpanded;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           if (_isExpanded)
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader(theme, 'Items'),
//                   const SizedBox(height: 8),
//                   ...widget.order.items.map((item) => _buildOrderItem(theme, item)),
//                   const Divider(height: 32),
//                   _buildSectionHeader(theme, 'Delivery Information'),
//                   const SizedBox(height: 8),
//                   _buildInfoRow('Address', widget.order.shippingAddress ?? 'N/A'),
//                   _buildInfoRow('Contact', widget.order.contactNumber ?? 'N/A'),
//                   const SizedBox(height: 16),
//                   Column(
//                     children: [
//                       if (widget.onCopy != null)
//                         TextButton.icon(
//                           icon: const Icon(Icons.copy),
//                           label: const Text('Copy Details'),
//                           onPressed: widget.onCopy,
//                         ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//
//                           if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
//                             TextButton(
//                               onPressed: () => _showCancelDialog(context),
//                               child: const Text('Cancel Order'),
//                             ),
//                           const Spacer(),
//                           if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
//                             ElevatedButton(
//                               onPressed: () => _showUpdateStatusDialog(context),
//                               child: const Text('Update Status'),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(ThemeData theme, String title) {
//     return Text(
//       title,
//       style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//     );
//   }
//
//   Widget _buildOrderItem(ThemeData theme, OrderItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               image: DecorationImage(
//                 image: NetworkImage(item.imageUrls.first),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 Text(
//                   '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
//                   style: theme.textTheme.bodySmall,
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             '\$${(item.quantity * item.price).toStringAsFixed(2)}',
//             style: theme.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
//           TextButton(
//             onPressed: () => _showCancelDialog(context),
//             child: const Text('Cancel Order'),
//           ),
//         const SizedBox(width: 8),
//         if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
//           ElevatedButton(
//             onPressed: () => _showUpdateStatusDialog(context),
//             child: const Text('Update Status'),
//           ),
//       ],
//     );
//   }
//
//   void _showUpdateStatusDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Update Order Status'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: OrderStatus.values
//               .where((status) => status.index > widget.order.status.index && status != OrderStatus.cancelled)
//               .map(
//                 (status) => ListTile(
//                   title: Text(_getStatusText(status)),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _updateOrderStatus(context, status);
//                   },
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }
//
//   void _showCancelDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Order'),
//         content: const Text('Are you sure you want to cancel this order?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _cancelOrder(context);
//             },
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _updateOrderStatus(BuildContext context, OrderStatus newStatus) {
//     final ordersService = Provider.of<OrdersService>(context, listen: false);
//     ordersService.updateOrderStatus(widget.order.id, newStatus);
//   }
//
//   void _cancelOrder(BuildContext context) {
//     final ordersService = Provider.of<OrdersService>(context, listen: false);
//     ordersService.cancelOrder(widget.order.id);
//   }
//
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.pending:
//         return Colors.orange;
//       case OrderStatus.processing:
//         return Colors.blue;
//       case OrderStatus.shipped:
//         return Colors.purple;
//       case OrderStatus.delivered:
//         return Colors.green;
//       case OrderStatus.cancelled:
//         return Colors.red;
//     }
//   }
// }












// // admin_orders_screen.dart
// class AdminOrdersScreen extends StatelessWidget {
//   const AdminOrdersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Orders Management'),
//           bottom: TabBar(
//             isScrollable: true,
//             tabs: OrderStatus.values.map((status) {
//               return Tab(
//                 child: Text(
//                   _getStatusText(status),
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         body: TabBarView(
//           children: OrderStatus.values.map((status) {
//             return OrdersListView(status: status);
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   String _getStatusText(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.pending:
//         return 'PENDING';
//       case OrderStatus.processing:
//         return 'PROCESSING';
//       case OrderStatus.shipped:
//         return 'SHIPPED';
//       case OrderStatus.delivered:
//         return 'DELIVERED';
//       case OrderStatus.cancelled:
//         return 'CANCELLED';
//     }
//   }
// }
//
// class OrdersListView extends StatelessWidget {
//   final OrderStatus status;
//
//   const OrdersListView({Key? key, required this.status}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrdersService>(
//       builder: (context, ordersService, _) {
//         return StreamBuilder<List<Order>>(
//           stream: ordersService.streamOrdersByStatus(status),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//
//             final orders = snapshot.data ?? [];
//
//             if (orders.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No ${status.toString().split('.').last.toLowerCase()} orders',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: orders.length,
//               itemBuilder: (context, index) {
//                 return OrderCard(order: orders[index]);
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class OrderCard extends StatefulWidget {
//   final Order order;
//
//   const OrderCard({Key? key, required this.order}) : super(key: key);
//
//   @override
//   State<OrderCard> createState() => _OrderCardState();
// }
//
// class _OrderCardState extends State<OrderCard> {
//   String _formatDate(DateTime date) {
//     return DateFormat('MMM dd, yyyy HH:mm').format(date);
//   }
//
//   String _getStatusText(OrderStatus status) {
//     return status.toString().split('.').last.toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: ExpansionTile(
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(widget.order.status),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _getStatusText(widget.order.status),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Order #${widget.order.id.substring(0, 8)}',
//                     style: theme.textTheme.titleMedium,
//                   ),
//                   Text(
//                     _formatDate(widget.order.orderDate),
//                     style: theme.textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//             Text(
//               '\$${widget.order.totalAmount.toStringAsFixed(2)}',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: theme.primaryColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionHeader(theme, 'Items'),
//                 const SizedBox(height: 8),
//                 ...widget.order.items.map((item) => _buildOrderItem(theme, item)),
//                 const Divider(height: 32),
//                 _buildSectionHeader(theme, 'Delivery Information'),
//                 const SizedBox(height: 8),
//                 _buildInfoRow('Address', widget.order.shippingAddress ?? 'N/A'),
//                 _buildInfoRow('Contact', widget.order.contactNumber ?? 'N/A'),
//                 const SizedBox(height: 16),
//                 _buildActionButtons(context),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(ThemeData theme, String title) {
//     return Text(
//       title,
//       style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//     );
//   }
//
//   Widget _buildOrderItem(ThemeData theme, OrderItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               image: DecorationImage(
//                 image: NetworkImage(item.imageUrls.first),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 Text(
//                   '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
//                   style: theme.textTheme.bodySmall,
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             '\$${(item.quantity * item.price).toStringAsFixed(2)}',
//             style: theme.textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         if (widget.order.status != OrderStatus.cancelled &&
//             widget.order.status != OrderStatus.delivered)
//           TextButton(
//             onPressed: () => _showCancelDialog(context),
//             child: const Text('Cancel Order'),
//           ),
//         const SizedBox(width: 8),
//         if (widget.order.status != OrderStatus.cancelled &&
//             widget.order.status != OrderStatus.delivered)
//           ElevatedButton(
//             onPressed: () => _showUpdateStatusDialog(context),
//             child: const Text('Update Status'),
//           ),
//       ],
//     );
//   }
//
//   void _showUpdateStatusDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Update Order Status'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: OrderStatus.values
//               .where((status) =>
//           status.index > widget.order.status.index &&
//               status != OrderStatus.cancelled)
//               .map(
//                 (status) => ListTile(
//               title: Text(_getStatusText(status)),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 _updateOrderStatus(context, status);
//               },
//             ),
//           )
//               .toList(),
//         ),
//       ),
//     );
//   }
//
//   void _showCancelDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Cancel Order'),
//         content: const Text('Are you sure you want to cancel this order?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _cancelOrder(context);
//             },
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _updateOrderStatus(BuildContext context, OrderStatus newStatus) {
//     final ordersService = Provider.of<OrdersService>(context, listen: false);
//     ordersService.updateOrderStatus(widget.order.id, newStatus);
//   }
//
//   void _cancelOrder(BuildContext context) {
//     final ordersService = Provider.of<OrdersService>(context, listen: false);
//     ordersService.cancelOrder(widget.order.id);
//   }
//
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.pending:
//         return Colors.orange;
//       case OrderStatus.processing:
//         return Colors.blue;
//       case OrderStatus.shipped:
//         return Colors.purple;
//       case OrderStatus.delivered:
//         return Colors.green;
//       case OrderStatus.cancelled:
//         return Colors.red;
//     }
//   }
// }
