// screens/product_details_screen.dart
import 'package:ecommerce_app/detailss2.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final bool showDimensions;

  const ProductPage({super.key, required this.showDimensions, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(product.imageUrl, height: 100),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(product.description,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const Text("3.5"),
                  const SizedBox(width: 10),
                  Text("1922 Reviews", style: TextStyle(color: Colors.red)),
                  const SizedBox(width: 10),
                  Text("936 Sold", style: TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              Text(product.price, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
        
              // Dimensions
               ExpansionTile(
                title: Text("DIMENSIONS", style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: false,
                children: [
                  ListTile(
                    title: Text("Product Dimensions"),
                    trailing: Text("${product.dimensions[0]} ×${product.dimensions[1]}  ×${product.dimensions[2]}  mm"),
                  )
                ],
              ),
        
              // Vendor section
               ExpansionTile(
                title: Text("vendor", style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: false,
                children: List.generate(product.vendors.length,(index){
                  return ListTile(title: Text(product.vendors[index]),);
                })
                  
                  
                
              ),
        
              // Color section
              ExpansionTile(
                title: Text("color", style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: false,
                children: List.generate(product.colors.length,(index){
                  return ListTile(title: Text(product.colors[index]),);
                })
              ),
        
              const SizedBox(height: 16),
              const Text("You might also like", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
        
              // Horizontally scrollable product suggestions
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    ProductSuggestionCard(
                      imagePath: "assets/iphone_16.png",
                      price: "EGP47,977",
                      name: "iPhone 16",
                      rating: 5,
                    ),
                    ProductSuggestionCard(
                      imagePath: "assets/iphone_15.png",
                      price: "EGP34,999",
                      name: "iPhone 15",
                      rating: 4,
                    ),
                    ProductSuggestionCard(
                      imagePath: "assets/iphone_13.png",
                      price: "EGP24,999",
                      name: "iPhone 13",
                      rating: 5,
                    ),
                    ProductSuggestionCard(
                      imagePath: "assets/iphone_11.png",
                      price: "EGP22,499",
                      name: "iPhone 11",
                      rating: 4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}