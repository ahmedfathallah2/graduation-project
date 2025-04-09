import 'package:ecommerce_app/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'chatscreen.dart';

class HomeScreen extends StatelessWidget {
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
            buildDealsSection(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(),
      floatingActionButton: buildChatButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
    );
  }

  // 🔹 Build App Bar (Back Button)
  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () { LoginScreen(); },
      ),
    );
  }

  // 🔹 Build Search Bar
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
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

  // 🔹 Build Category Buttons
  Widget buildCategoryButtons() {
    List<String> categories = [
      "TV",
      "Mobile Phones",
      "Airpods",
      "Laptops",
      "Tablets",
      "Cameras",
      "Smart Watches"
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
                onPressed: () {
                  // TODO: Add your logic here
                },
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

  // 🔹 Build Carousel Slider (Banner)

  Widget buildCarouselSlider() {
    List<String> images = [
      'images/pic1.jpg',
      'images/pic1.jpg',
    ];

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

  // 🔹 Build "Today's Deals" Section
  Widget buildDealsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Deal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildDealCard("iPhone 15 Pro Max", "EGP 89,999", "10% off",
                    "images/download.jpg"),
                buildDealCard("Xiaomi Redmi Buds", "EGP 698", "50% off",
                    "images/redmi.jpg"),
                buildDealCard("Samsung Galaxy S24", "EGP 72,000", "15% off",
                    "images/s24.webp"),
                // Add more cards here
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Build Individual Deal Card
  Widget buildDealCard(
      String title, String price, String discount, String image) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Image.asset(image),
          SizedBox(height: 5),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(price,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(discount,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 🔹 Build Bottom Navigation Bar
  Widget buildBottomNavBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(Icons.home, color: Colors.black), onPressed: () {}),
          SizedBox(width: 40), // Space for the floating button
          IconButton(
              icon: Icon(Icons.person, color: Colors.black), onPressed: () {}),
        ],
      ),
    );
  }

  // 🔹 Floating Action Button (Chatbot)
  Widget buildChatButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: const Icon(Icons.android, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
    );
  }
}
