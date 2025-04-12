import 'package:flutter/material.dart';

class ProductDetailScreen2 extends StatelessWidget {
  const ProductDetailScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 2); // Show third page

    final List<Widget> productPages = [
      const ProductPage(showDimensions: false),
      const ProductPage(showDimensions: false),
      const ProductPage(showDimensions: true), // dimensions section is still passed, but no longer auto-expanded
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: productPages,
        ),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final bool showDimensions;

  const ProductPage({super.key, required this.showDimensions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              Image.asset("images/download.jpg", height: 100),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("IPHONE 15 PRO MAX", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      "The iPhone 15 Pro Max 256 GB is Apple’s top-of-the-line flagship phone, boasting a titanium design, "
                      "a powerful A17 Pro chip for unparalleled performance...",
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
          const Text("89,999 EGP", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Dimensions
          const ExpansionTile(
            title: Text("DIMENSIONS", style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              ListTile(
                title: Text("Product Dimensions"),
                trailing: Text("159.9 × 76.7 × 8.3 mm"),
              ),
              ListTile(
                title: Text("Product Weight"),
                trailing: Text("221 g"),
              ),
              ListTile(
                title: Text("Packaged Weight"),
                trailing: Text("260 g"),
              ),
              ListTile(
                title: Text("IP Rating"),
                subtitle: Text("IP68 Dust and water resistant (up to 6m for 30 minutes)"),
              ),
            ],
          ),

          // Vendor section
          const ExpansionTile(
            title: Text("vendor", style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              ListTile(
                title: Text("Amazon"),
              ),
            ],
          ),

          // Color section
          const ExpansionTile(
            title: Text("color", style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              ListTile(title: Text("Natural Titanium")),
              ListTile(title: Text("White Titanium")),
              ListTile(title: Text("Blue Titanium")),
              ListTile(title: Text("Black Titanium")),
            ],
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