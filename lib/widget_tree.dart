import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shopping_panel/pages/drawer/drawer_page.dart';
import 'package:shopping_panel/pages/panel_center/panel_center_page.dart';
import 'package:shopping_panel/pages/panel_left/panel_left_page.dart';
import 'package:shopping_panel/pages/panel_right/panel_right_page.dart';
import 'package:shopping_panel/pages/widgets/app_bar_widget.dart';
import 'package:shopping_panel/responsive_layout.dart';
import 'constants.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int currentIndex = 0;

  final List<Widget> _icons = [
    Icon(Icons.home_filled, size: 30),
    Icon(Icons.list, size: 30),
    Icon(Icons.add_business, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 2? null : PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: (ResponsiveLayout.isTinyLimit(context) || ResponsiveLayout.isTinyHeightLimit(context))
            ? Container()
            : AppBarWidget(),
      ),
      body: ResponsiveLayout(
        tiny: Container(),
        phone: currentIndex == 0
            ? PanelLeftPage()
            : currentIndex == 1
                ? PanelCenterPage()
                : AdminOrdersScreen(),
        tablet: Row(
          children: [
            Expanded(child: PanelLeftPage()),
            Expanded(
              child: PanelCenterPage(),
            )
          ],
        ),
        largeTablet: Row(
          children: [
            Expanded(child: PanelLeftPage()),
            Expanded(child: PanelCenterPage()),
            Expanded(
              child: AdminOrdersScreen(),
            )
          ],
        ),
        computer: Row(
          children: [
            Expanded(child: DrawerPage()),
            Expanded(child: PanelLeftPage()),
            Expanded(
              child: PanelCenterPage(),
            ),
            Expanded(
              child: AdminOrdersScreen(),
            )
          ],
        ),
      ),
      drawer: DrawerPage(),
      bottomNavigationBar: ResponsiveLayout.isPhone(context)
          ? CurvedNavigationBar(
              index: currentIndex,
              backgroundColor: Constants.purpleDark,
              items: _icons,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )
          : SizedBox(),
    );
  }
}
