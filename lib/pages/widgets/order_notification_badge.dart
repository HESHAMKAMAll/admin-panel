// Create a NotificationBadge widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/orders_service.dart';
import '../panel_right/panel_right_page.dart';

class OrderNotificationBadge extends StatelessWidget {
  final String? userId; // Optional: If you want to show notifications for a specific user

  const OrderNotificationBadge({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ordersService = Provider.of<OrdersService>(context);

    return Stack(
      children: [
        IconButton(
          color: Colors.white,
          iconSize: 30,
          onPressed: () {
            // Add your notification tap handler here
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminOrdersScreen()));
          },
          icon: Icon(Icons.notifications_none_outlined),
        ),
        StreamBuilder<int>(
          stream: userId != null
              ? ordersService.streamUserPendingOrdersCount(userId!)
              : ordersService.streamPendingOrdersCount(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == 0) {
              return SizedBox.shrink();
            }

            return Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                backgroundColor: Colors.pink,
                radius: 8,
                child: Text(
                  snapshot.data.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}