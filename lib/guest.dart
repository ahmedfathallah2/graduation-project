import 'package:ecommerce_app/about.dart';
import 'package:ecommerce_app/productdetails.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'models/product.dart';

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            buildHeader(context),
            buildBannerCarousel(),
            buildDealsTitle(),
            buildDealsSection(context),
            
          ],
        ),
      ),
      floatingActionButton: buildSearchButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // This will navigate back
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.arrow_back),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              side: const BorderSide(color: Colors.black12),
            ),
            child: const Text('About Us '),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBannerCarousel() {
    final images = [
      'images/pic1.jpg', // Replace with your asset path
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CarouselSlider(
          options: CarouselOptions(height: 140, autoPlay: true),
          items:
              images.map((img) {
                return Image.asset(
                  img,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget buildDealsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        "",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  
Widget buildDealsSection(BuildContext context) {
    final List<Product> deals = [
      Product(
        name: "iPhone 15 Pro Max",
        price: "EGP 89,999",
        discount: "10% off",
        imageUrl: "images/download.jpg",
        description: "The latest iPhone 15 Pro Max with A17 chip and amazing performance.",
        dimensions: ['45','51','155'],
        colors: ['white','c'],
        vendors: ['sd']
      ),
      Product(
        name: "Xiaomi Redmi Buds",
        price: "EGP 698",
        discount: "50% off",
        imageUrl: "images/redmi.jpg",
        description: "Great sound quality, long battery, and sleek design.",
        dimensions: ['45','51','155'],
        colors: ['white','c'],
        vendors: ['sd']
      ),
      Product(
        name: "Samsung Galaxy S24",
        price: "EGP 72,000",
        discount: "15% off",
        imageUrl: "images/s24.webp",
        description: "Powerful flagship with excellent display and camera.",
        dimensions: ['45','51','155'],
        colors: ['white','c'],
        vendors: ['sd']
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Deal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: deals
                  .map((product) => buildDealCard(context, product))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDealCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductPage(product: product, showDimensions: true,),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Image.asset(product.imageUrl, height: 90),
            const SizedBox(height: 5),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product.price,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                product.discount,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildSearchButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        // Add search or navigation logic
      },
      child: const Icon(Icons.search, size: 30),
    );
  }
}
