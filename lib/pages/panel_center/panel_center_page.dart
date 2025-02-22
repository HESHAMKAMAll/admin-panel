import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_panel/pages/panel_center/upload_new_product.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../provider/banner_images_provider.dart';

class PanelCenterPage extends StatefulWidget {
  const PanelCenterPage({Key? key}) : super(key: key);

  @override
  State<PanelCenterPage> createState() => _PanelCenterPageState();
}

class _PanelCenterPageState extends State<PanelCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _categoryNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedImagePath;
  String? _selectedImageUrl;
  bool _isLoading = false;
  bool _isUrlImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryNameController.dispose();
    _brandNameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }


  // Only showing the modified sections for clarity
  Future<String?> _uploadImage() async {
    // If using URL image, return the URL directly without uploading
    if (_isUrlImage && _selectedImageUrl != null) {
      // Validate the URL format
      try {
        final uri = Uri.parse(_selectedImageUrl!);
        if (!uri.isAbsolute) {
          _showErrorSnackBar('Invalid image URL format');
          return null;
        }
        return _selectedImageUrl;
      } catch (e) {
        _showErrorSnackBar('Invalid URL: $e');
        return null;
      }
    }

    // Handle device/web file upload
    if (_selectedImagePath == null && !_isUrlImage) return null;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          path.extension(_selectedImagePath ?? '.jpg');
      final ref = FirebaseStorage.instance.ref().child('images/$fileName');

      if (kIsWeb && !_isUrlImage) {
        final data = _selectedImageUrl!.split(',').last;
        await ref.putString(data, format: PutStringFormat.base64);
      } else if (!_isUrlImage) {
        await ref.putFile(File(_selectedImagePath!));
      }

      return await ref.getDownloadURL();
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
      return null;
    }
  }

  void _setImageFromUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      _showErrorSnackBar('Please enter an image URL');
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) {
        _showErrorSnackBar('Please enter a valid URL');
        return;
      }

      // Check if URL points to an image
      if (!url.toLowerCase().endsWith('.jpg') &&
          !url.toLowerCase().endsWith('.jpeg') &&
          !url.toLowerCase().endsWith('.png') &&
          !url.toLowerCase().endsWith('.gif') &&
          !url.toLowerCase().endsWith('.webp')) {
        _showErrorSnackBar('URL must point to an image file');
        return;
      }

      setState(() {
        _selectedImageUrl = url;
        _selectedImagePath = null;
        _isUrlImage = true;
      });

      // Optional: Preload image to verify it loads correctly
      precacheImage(NetworkImage(url), context).catchError((error) {
        _showErrorSnackBar('Could not load image from URL');
        setState(() {
          _selectedImageUrl = null;
          _isUrlImage = false;
        });
      });

    } catch (e) {
      _showErrorSnackBar('Invalid URL format');
    }
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImagePath == null && _selectedImageUrl == null) {
      _showErrorSnackBar('Please select an image or enter URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrl = await _uploadImage();
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('categories').add({
          'categoryName': _categoryNameController.text,
          'categoryImagesPath': imageUrl,
          'isUrlImage': _isUrlImage, // Add flag to indicate URL image
        });
        _showSuccessSnackBar('Category added successfully');
        _clearForm();
      }
    } catch (e) {
      _showErrorSnackBar('Error adding category: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBrand() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImagePath == null && _selectedImageUrl == null) {
      _showErrorSnackBar('Please select an image or enter URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrl = await _uploadImage();
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('brands').add({
          'brandName': _brandNameController.text,
          'brandImagesPath': imageUrl,
          'isUrlImage': _isUrlImage, // Add flag to indicate URL image
        });
        _showSuccessSnackBar('Brand added successfully');
        _clearForm();
      }
    } catch (e) {
      _showErrorSnackBar('Error adding brand: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _pickImage({required bool isWeb}) async {
    try {
      setState(() => _isLoading = true);

      if (isWeb) {
        final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
        input.click();

        await input.onChange.first;
        if (input.files?.isNotEmpty ?? false) {
          final file = input.files!.first;
          final reader = html.FileReader();
          reader.readAsDataUrl(file);
          await reader.onLoad.first;

          setState(() {
            _selectedImageUrl = reader.result as String;
            _selectedImagePath = file.name;
            _isUrlImage = false;
            _imageUrlController.clear();
          });
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            _selectedImagePath = image.path;
            _selectedImageUrl = null;
            _isUrlImage = false;
            _imageUrlController.clear();
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addBanner() async {
    if (_selectedImagePath == null && _selectedImageUrl == null) {
      _showErrorSnackBar('Please select an image or enter URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrl = await _uploadImage();
      if (imageUrl != null) {
        await context.read<BannerImagesProvider>().uploadImageFromUrl(imageUrl);
        _showSuccessSnackBar('Banner added successfully');
        _clearForm();
      }
    } catch (e) {
      _showErrorSnackBar('Error adding banner: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _clearForm() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageUrl = null;
      _isUrlImage = false;
      _categoryNameController.clear();
      _brandNameController.clear();
      _imageUrlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D193E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D193E),
          elevation: 0,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Items', style: TextStyle(fontSize: 24)),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Product'),
              Tab(text: 'Banner'),
              Tab(text: 'Category'),
              Tab(text: 'Brand'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              UploadProductScreen(),
              _buildBannerTab(),
              _buildCategoryTab(),
              _buildBrandTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildAddButton('Add Banner', _addBanner),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildAddButton('Add Category', _addCategory),
        ],
      ),
    );
  }

  Widget _buildBrandTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _brandNameController,
            decoration: const InputDecoration(
              labelText: 'Brand Name',
              prefixIcon: Icon(Icons.branding_watermark),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter brand name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildAddButton('Add Brand', _addBrand),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Image',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.87),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedImagePath != null || _selectedImageUrl != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isUrlImage || kIsWeb
                  ? Image.network(
                _selectedImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Text('Error loading image')),
              )
                  : Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            labelText: 'Image URL',
            prefixIcon: const Icon(Icons.link),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _setImageFromUrl,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'OR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _pickImage(isWeb: kIsWeb),
          icon: const Icon(Icons.image),
          label: const Text('Choose from Device'),
        ),
      ],
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}