
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';


class DealsScreen extends StatelessWidget {
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
          CircleAvatar(backgroundColor: Colors.grey[200], child: Icon(Icons.arrow_back)),
          
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
            },
            child: Text('About Us'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              side: BorderSide(color: Colors.black12),
            ),
          ),
          CircleAvatar(backgroundColor: Colors.grey[200], child: Icon(Icons.person)),
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
          items: images.map((img) {
            return Image.asset(img, fit: BoxFit.cover, width: double.infinity);
          }).toList(),
        ),
      ),
    );
  }

  Widget buildDealsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text("Today's Deal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        "image": "assets/images/redmi.jpg",
      },
    ];

    return Container(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return buildDealCard(
            deal["title"]!,
            deal["price"]!,
            deal["discount"]!,
            deal["image"]!,
          );
        },
      ),
    );
  }

  Widget buildDealCard(String title, String price, String discount, String imagePath) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, height: 100),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: Text(discount, style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Text("Limited time deal", style: TextStyle(color: Colors.red, fontSize: 12)),
          SizedBox(height: 4),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget buildSearchButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        // Add search or navigation logic
      },
      child: Icon(Icons.search, size: 30),
    );
  }
}
