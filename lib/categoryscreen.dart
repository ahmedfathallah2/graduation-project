import 'package:flutter/material.dart';
// import the model if in another file
import 'models/categproduct.dart';
class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Product2> products;

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
            leading: Image.asset(product.imageUrl, width: 50),
            title: Text(product.name),
            subtitle: Text("EGP ${product.price.toStringAsFixed(2)} - ${product.discount}% off"),
          );
        },
      ),
    );
  }
}
