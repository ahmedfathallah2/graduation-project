// category_screen.dart
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // You can load real data here based on the category
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Text("Showing items for $category"),
      ),
    );
  }
}
