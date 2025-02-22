import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_panel/provider/banner_images_provider.dart';
import 'package:shopping_panel/provider/orders_service.dart';
import 'package:shopping_panel/provider/product_upload_provider.dart';
import 'package:shopping_panel/provider/products.dart';
import 'package:shopping_panel/widget_tree.dart';
import 'constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => Products()),
        ChangeNotifierProvider(create: (_) => ProductUploadProvider()),
        ChangeNotifierProvider(create: (_) => BannerImagesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(scaffoldBackgroundColor: Constants.purpleDark, primarySwatch: Colors.blue, canvasColor: Constants.purpleLight),
      home: WidgetTree(),
    );
  }
}
