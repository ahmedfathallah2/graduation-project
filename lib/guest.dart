import 'package:ecommerce_app/about.dart';
import 'package:ecommerce_app/detailss2.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
            buildDealsSlider(),
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
            child: const Text('About Us us '),
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
        "Today's Deal",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDealsSlider() {
    final deals = [
      {
        "title": "Iphone 15 pro max",
        "price": "EGP89,999",
        "discount": "10% off",
        "image": "images/download.jpg",
      },
      {
        "title": "Xiaomi Redmi Buds 4 Lite",
        "price": "EGP698",
        "discount": "50% off",
        "image": "images/redmi.jpg",
      },
    ];

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return buildDealCard(context,
            deal["title"]!,
            deal["price"]!,
            deal["discount"]!,
            deal["image"]!,
          );
        },
      ),
    );
  }

  Widget buildDealCard(context, 
  //
  String title,
  String price,
  String discount,
  String imagePath,
) {
  return GestureDetector(
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>const  ProductDetailScreen2(
        
      ),
    ),
  );
},

    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, height: 100),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              discount,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const Text(
            "Limited time deal",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
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
