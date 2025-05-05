import 'package:flutter/material.dart';
import 'models/jumia_product.dart'; // ✅ Make sure this path is correct

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<JumiaProduct> products;

  const CategoryScreen({super.key, required this.categoryName, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50),
            title: Text(product.title),
            subtitle: Text("EGP ${product.priceEGP}"),
            onTap: () {
              // Add navigation to details page if needed
            },
          );
        },
      ),
    );
  }
}
