import 'package:ecommerce_app/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'profile.dart';
import 'productdetails.dart';
import 'models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            buildCategoryButtons(),
            buildCarouselSlider(),
            buildDealsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context),
      floatingActionButton: buildChatButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text('Home', style: TextStyle(color: Colors.black)),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: "Search",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildCategoryButtons() {
    List<String> categories = [
      "TV",
      "Mobile Phones",
      "Airpods",
      "Laptops",
      "Tablets",
      "Cameras",
      "Smart Watches",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildCarouselSlider() {
    List<String> images = ['images/pic1.jpg', 'images/pic1.jpg'];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: images.map((imgPath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(imgPath, fit: BoxFit.cover),
        );
      }).toList(),
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
        dimensions: ['45','51','44'],
        colors: ['white','c'],
        vendors: ['amazon','jumia']
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
            builder: (_) => ProductPage(product: product, showDimensions:true),
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

  Widget buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildChatButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: const Icon(Icons.android, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  const ChatPage()),
        );
      },
    );
  }
}
