import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/about.dart'; 

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(100) // Limit to 100 products as required
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading products: $e');
    }
  }

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
            onTap: () => Navigator.pop(context),
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
            child: const Text('About Us'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context)=>SignUpScreen())
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
        child: Image.asset(
          images[0],
          fit: BoxFit.cover,
          height: 140,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget buildDealsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        "Our Products",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDealsSection(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "No products found 😕",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return buildDealCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDealCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        // Replace with your ProductDetails screen and pass product details
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
      },
      child: Stack(
        children: [
          Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product['Image_URL'] ?? '',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product['Title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'EGP ${product['Price_EGP'] ?? ""}',
                  style: const TextStyle(
                    color:Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    product['Brand']?.toString() ?? "",
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
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
      child: const Icon(Icons.search, size: 30),
    );
  }
}
