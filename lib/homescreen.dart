import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/chat_page.dart';
import 'package:ecommerce_app/models/jumia_product.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/productdetails.dart';
import 'package:ecommerce_app/profile.dart';
import 'package:flutter/material.dart';
import 'categoryscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, List<JumiaProduct>> _categorizedProducts = {};
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchAndGroupProducts();
  }

  void fetchAndGroupProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final allProducts = snapshot.docs.map((doc) => JumiaProduct.fromFirestore(doc.data())).toList();

    final Map<String, List<JumiaProduct>> grouped = {};
    for (var product in allProducts) {
      if (!grouped.containsKey(product.category)) {
        grouped[product.category] = [];
      }
      grouped[product.category]!.add(product);
    }

    setState(() {
      _categorizedProducts = grouped;
      _isLoadingCategories = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            buildCategoryButtons(context),
            const SizedBox(height: 10),
            buildCarouselSlider(),
            buildFirestoreProductsSection(),
            const SizedBox(height: 10),
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
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase().trim();
          });
        },
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

  Widget buildCategoryButtons(BuildContext context) {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categorizedProducts.keys.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(
                        categoryName: category,
                        products: _categorizedProducts[category]!,
                      ),
                    ),
                  );
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

  Widget buildFirestoreProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Our Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<List<JumiaProduct>>(
            stream: fetchJumiaProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProducts = snapshot.data!;
              final products = _searchQuery.isEmpty
                  ? allProducts
                  : allProducts.where((product) {
                      final title = product.title.toLowerCase();
                      final brand = product.brand.toLowerCase();
                      final category = product.category.toLowerCase();
                      return title.contains(_searchQuery) ||
                          brand.contains(_searchQuery) ||
                          category.contains(_searchQuery);
                    }).toList();

              if (products.isEmpty) {
                return const Center(child: Text("No products found 😕"));
              }

              return SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final wishlistProvider = Provider.of<WishlistProvider>(context);
                    final isWishlisted = wishlistProvider.isInWishlist(product);

                    return Stack(
                      children: [
                        Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                          ),
                          child: Column(
                            children: [
                              Image.network(product.imageUrl, height: 100),
                              const SizedBox(height: 5),
                              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('EGP ${product.priceEGP}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                                child: const Text("0%", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              wishlistProvider.toggleWishlist(product);
                            },
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
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
        dimensions: ['159.9', '76.7', '8.3'],
        colors: ['white', 'c'],
        vendors: ['amazon', 'jumia'],
      ),
      Product(
        name: "Xiaomi Redmi Buds",
        price: "EGP 698",
        discount: "50% off",
        imageUrl: "images/redmi.jpg",
        description: "Great sound quality, long battery, and sleek design.",
        dimensions: ['45', '51', '155'],
        colors: ['white', 'c'],
        vendors: ['sd'],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Deal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: deals.map((product) => buildDealCard(context, product)).toList()),
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
          MaterialPageRoute(builder: (_) => ProductPage(product: product, showDimensions: true)),
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
            Text(product.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(product.price, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
              child: Text(product.discount, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      },
    );
  }

  Stream<List<JumiaProduct>> fetchJumiaProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return JumiaProduct.fromFirestore(doc.data());
        }).toList();
      },
    );
  }
}
