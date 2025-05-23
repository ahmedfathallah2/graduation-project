import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final bool showDimensions;

  const ProductPage({super.key, required this.showDimensions, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            Row(
              children: [
                IconButton(icon:  Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),),
                const SizedBox(width: 16),
                Image.asset(product.imageUrl, height: 100),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 18),
                Text("3.5"),
                SizedBox(width: 10),
                Text("1922 Reviews", style: TextStyle(color: Colors.red)),
                SizedBox(width: 10),
                Text("936 Sold", style: TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Text(product.price, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
      
            // Dimensions
             ExpansionTile(
              title: const Text("DIMENSIONS", style: TextStyle(fontWeight: FontWeight.bold)),
              initiallyExpanded: false,
              children: [
                ListTile(
                  title: const Text("Product Dimensions"),
                  trailing: Text("${product.dimensions[0]} ×${product.dimensions[1]}  ×${product.dimensions[2]}  mm"),
                )
              ],
            ),
      
            // Vendor section
             ExpansionTile(
              title: const Text("vendor", style: TextStyle(fontWeight: FontWeight.bold)),
              initiallyExpanded: false,
              children: List.generate(product.vendors.length,(index){
                return ListTile(title: Text(product.vendors[index]),);
              })
                
                
              
            ),
      
            // Color section
            ExpansionTile(
              title: const Text("color", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    imagePath: "images/iphone_16.png",
                    price: "EGP47,977",
                    name: "iPhone 16",
                    rating: 5,
                  ),
                  ProductSuggestionCard(
                    imagePath: "images/iphone_15.png",
                    price: "EGP34,999",
                    name: "iPhone 15",
                    rating: 4,
                  ),
                  ProductSuggestionCard(
                    imagePath: "images/iphone_13.jpg",
                    price: "EGP24,999",
                    name: "iPhone 13",
                    rating: 5,
                  ),
                  ProductSuggestionCard(
                    imagePath: "images/iphone_11.jpg",
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
    );
  }
}
class ProductSuggestionCard extends StatelessWidget {
  final String imagePath;
  final String price;
  final String name;
  final int rating;

  const ProductSuggestionCard({
    super.key,
    required this.imagePath,
    required this.price,
    required this.name,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 60),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              rating,
              (index) => const Icon(Icons.star, color: Colors.orange, size: 14),
            ),
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(name),
        ],
      ),
    );
  }
}