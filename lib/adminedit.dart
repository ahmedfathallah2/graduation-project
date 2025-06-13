import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _linkController = TextEditingController();
  final _parsedStorageController = TextEditingController();
  final _priceEGPController = TextEditingController();

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('products').add({
        'Title': _titleController.text.trim(),
        'Brand': _brandController.text.trim(),
        'Category': _categoryController.text.trim(),
        'Subcategory': _subcategoryController.text.trim(),
        'Image_URL': _imageUrlController.text.trim(),
        'Link': _linkController.text.trim(),
        'Parsed_Storage': int.tryParse(_parsedStorageController.text) ?? 0,
        'Price_EGP': int.tryParse(_priceEGPController.text) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      _formKey.currentState!.reset();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Admin Product Manager')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _subcategoryController,
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'Link'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _parsedStorageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Parsed Storage'),
                ),
                TextFormField(
                  controller: _priceEGPController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (EGP)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
