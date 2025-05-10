import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/chat_page.dart';
import 'package:ecommerce_app/models/jumia_product.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/productdetails.dart';
import 'package:ecommerce_app/profile.dart';
import 'package:ecommerce_app/services/search_service.dart';
import 'package:ecommerce_app/services/recommendation_service.dart';
import 'package:flutter/material.dart';
import 'categoryscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.email});
  final String email;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, List<JumiaProduct>> _categorizedProducts = {};
  bool _isLoadingCategories = true;

  List<JumiaProduct> _products = [];
  List<JumiaProduct> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _limit = 100;

  
  final RecommendationService _recommendationService = RecommendationService();
  List<JumiaProduct> _recommendedProducts = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    fetchAndGroupProducts();
    _fetchInitialProducts();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() => _isLoadingRecommendations = true);
    
    try {
      final recommendations = await _recommendationService.fetchRecommendations();
      
      setState(() {
        _recommendedProducts = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
      setState(() => _isLoadingRecommendations = false);
    }
  }

  void fetchAndGroupProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final allProducts =
        snapshot.docs
            .map((doc) => JumiaProduct.fromFirestore(doc.data()))
            .toList();

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

  Future<void> _fetchInitialProducts() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .orderBy('Title')
            .limit(_limit)
            .get();

    final fetched =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return JumiaProduct.fromFirestore(data);
        }).toList();

    setState(() {
      _products = fetched;
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == _limit;
    });
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .orderBy('Title')
            .startAfterDocument(_lastDocument!)
            .limit(_limit)
            .get();

    final fetched =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return JumiaProduct.fromFirestore(data);
        }).toList();

    setState(() {
      _products.addAll(fetched);
      _lastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDocument;
      _hasMore = snapshot.docs.length == _limit;
      _isLoadingMore = false;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Debounce search to avoid frequent Firestore calls
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoadingSearch = true;
        _isSearching = true;
      });

      try {
        final results = await SearchService.searchProducts(query);
        setState(() {
          _searchResults = results;
          _isLoadingSearch = false;
        });
      } catch (e) {
        print('Search error: $e');
        setState(() {
          _isLoadingSearch = false;
        });
      }
    });
  }
  
  Timer? _searchDebounce;

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
            if (_isSearching)
              buildSearchResults()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCategoryButtons(context),
                  const SizedBox(height: 10),
                  buildCarouselSlider(),
                  buildFirestoreProductsSection(),
                  const SizedBox(height: 10),
                  buildDealsSection(context),
                ],
              ),
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
          _performSearch(_searchQuery);
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              : null,
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

  Widget buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No products found. Try a different search term.",
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
          Text(
            "Search Results (${_searchResults.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              final wishlistProvider = Provider.of<WishlistProvider>(
                context,
              );
              final isWishlisted = wishlistProvider.isInWishlist(product);

              return GestureDetector(
                onTap: () {
                  // Navigate to product details
                  // You can create a JumiaProductDetails page similar to ProductPage
                },
                child: Stack(
                  children: [
                    Container(
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
                          Center(
                            child: Image.network(
                              product.imageUrl,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand,
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'EGP ${product.priceEGP}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "0%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => wishlistProvider.toggleWishlist(product),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
          children:
              _categorizedProducts.keys.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CategoryScreen(
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
      items:
          images.map((imgPath) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imgPath, fit: BoxFit.cover),
            );
          }).toList(),
    );
  }

  Widget buildFirestoreProductsSection() {
    // Only filter local products when not in search mode
    final filteredProducts = _searchQuery.isEmpty
        ? _products
        : _products.where((product) {
            final title = product.title.toLowerCase();
            final brand = product.brand.toLowerCase();
            final category = product.category.toLowerCase();
            return title.contains(_searchQuery) ||
                brand.contains(_searchQuery) ||
                category.contains(_searchQuery);
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Our Products",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (filteredProducts.isEmpty && !_isSearching)
            const Center(child: Text("No products found 😕"))
          else
            SizedBox(
              height: 260,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final wishlistProvider = Provider.of<WishlistProvider>(
                          context,
                        );
                        final isWishlisted = wishlistProvider.isInWishlist(
                          product,
                        );

                        return GestureDetector(
                          onTap: () {},
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
                                  children: [
                                    Image.network(
                                      product.imageUrl,
                                      height: 100,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),

                                    Text(
                                      'EGP ${product.priceEGP}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        "0%",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap:
                                      () => wishlistProvider.toggleWishlist(
                                        product,
                                      ),
                                  child: Icon(
                                    isWishlisted
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isWishlisted ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_hasMore && !_isSearching)
                    ElevatedButton(
                      onPressed: _fetchMoreProducts,
                      child:
                          _isLoadingMore
                              ? const CircularProgressIndicator()
                              : const Text("Load More"),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDealsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Most Recommended",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          if (_isLoadingRecommendations)
            const Center(child: CircularProgressIndicator())
          else if (_recommendedProducts.isEmpty)
            const Center(
              child: Text(
                "No recommendations available yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _recommendedProducts.map((product) => 
                  buildRecommendedProductCard(context, product)
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRecommendedProductCard(BuildContext context, JumiaProduct product) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isInWishlist(product);
    
    return GestureDetector(
      onTap: () {
        // Navigate to product details when tapped
        // You'll need to implement JumiaProductDetails page or use ProductPage with conversion
      },
      child: Stack(
        children: [
          Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product.imageUrl,
                    height: 90,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 90,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'EGP ${product.priceEGP}',
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
                  child: const Text(
                    "Recommended",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => wishlistProvider.toggleWishlist(product),
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey,
              ),
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
            builder: (_) => ProductPage(product: product, showDimensions: true),
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
          MaterialPageRoute(
            builder: (context) => ChatPage(email: widget.email),
          ),
        );
      },
    );
  }
}
