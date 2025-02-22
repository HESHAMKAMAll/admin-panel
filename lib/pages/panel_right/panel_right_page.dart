import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/orders_service.dart';

// Modify AdminOrdersScreen
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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders Management'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search orders...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  tabs: OrderStatus.values.map((status) {
                    return Tab(
                      child: Text(
                        _getStatusText(status),
                        style: const TextStyle(fontSize: 12),
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
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderTimeFilter.values.map((filter) {
            return RadioListTile<OrderTimeFilter>(
              title: Text(_getFilterText(filter)),
              value: filter,
              groupValue: _timeFilter,
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

// Modify OrdersListView
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

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersService>(
      builder: (context, ordersService, _) {
        return StreamBuilder<List<Order>>(
          stream: ordersService.streamOrdersByStatus(status),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var orders = snapshot.data ?? [];

            // Apply filters
            orders = orders.where((order) => _matchesTimeFilter(order.orderDate) && _matchesSearchQuery(order, searchQuery)).toList();

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No ${status.toString().split('.').last.toLowerCase()} orders found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${orders.length} Orders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Total: \$${_calculateTotal(orders)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
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

  String _calculateTotal(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(2);
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
      const SnackBar(content: Text('Order details copied to clipboard')),
    );
  }
}

// Modify OrderCard
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

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.order.status),
                    borderRadius: BorderRadius.circular(12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${widget.order.id.substring(0, 8)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(widget.order.orderDate),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, 'Items'),
                  const SizedBox(height: 8),
                  ...widget.order.items.map((item) => _buildOrderItem(theme, item)),
                  const Divider(height: 32),
                  _buildSectionHeader(theme, 'Delivery Information'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Address', widget.order.shippingAddress ?? 'N/A'),
                  _buildInfoRow('Contact', widget.order.contactNumber ?? 'N/A'),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      if (widget.onCopy != null)
                        TextButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Details'),
                          onPressed: widget.onCopy,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
                            TextButton(
                              onPressed: () => _showCancelDialog(context),
                              child: const Text('Cancel Order'),
                            ),
                          const Spacer(),
                          if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
                            ElevatedButton(
                              onPressed: () => _showUpdateStatusDialog(context),
                              child: const Text('Update Status'),
                            ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderItem(ThemeData theme, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.quantity * item.price).toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium,
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
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
          TextButton(
            onPressed: () => _showCancelDialog(context),
            child: const Text('Cancel Order'),
          ),
        const SizedBox(width: 8),
        if (widget.order.status != OrderStatus.cancelled && widget.order.status != OrderStatus.delivered)
          ElevatedButton(
            onPressed: () => _showUpdateStatusDialog(context),
            child: const Text('Update Status'),
          ),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values
              .where((status) => status.index > widget.order.status.index && status != OrderStatus.cancelled)
              .map(
                (status) => ListTile(
                  title: Text(_getStatusText(status)),
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
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelOrder(context);
            },
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

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
