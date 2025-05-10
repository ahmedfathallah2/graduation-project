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

  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Product Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FORM FOR ADDING NEW PRODUCT
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _subcategoryController, decoration: const InputDecoration(labelText: 'Subcategory'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Image URL'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _linkController, decoration: const InputDecoration(labelText: 'Link'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _parsedStorageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Parsed Storage')),
                  TextFormField(controller: _priceEGPController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (EGP)')),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _addProduct, child: const Text('Add Product')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // SEARCH BAR
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),

            // PRODUCT LIST
            const Text('Existing Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').orderBy('Title').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final title = (doc['Title'] ?? '').toString().toLowerCase();
                    final brand = (doc['Brand'] ?? '').toString().toLowerCase();
                    return title.contains(_searchQuery) || brand.contains(_searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text('No matching products.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final product = docs[index];
                      return ListTile(
                        title: Text(product['Title']),
                        subtitle: Text("EGP ${product['Price_EGP']} • ${product['Brand']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
