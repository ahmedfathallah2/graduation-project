// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/chat_page.dart';
import 'package:ecommerce_app/models/jumia_product.dart';
import 'package:ecommerce_app/productdetails.dart';
import 'package:ecommerce_app/profile.dart';
import 'package:ecommerce_app/services/search_service.dart';
import 'package:ecommerce_app/services/recommendation_service.dart';
import 'package:flutter/material.dart';
import 'categoryscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  List<JumiaProduct> _products = [];
  List<JumiaProduct> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _limit = 20;

  final RecommendationService _recommendationService = RecommendationService();
  List<JumiaProduct> _recommendedProducts = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts();
    _fetchRecommendations();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .limit(100)
            .get();

    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('Category')) {
        categories.add(data['Category']);
      }
    }
    setState(() {
      _categories = categories.toList();
      _isLoadingCategories = false;
    });
  }

  Future<void> _fetchProducts({bool loadMore = false, String? category}) async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    Query query = FirebaseFirestore.instance
        .collection('products')
        .orderBy('Title')
        .limit(_limit);

    if (category != null) {
      query = query.where('Category', isEqualTo: category);
    }

    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    print("Fetching Products");

    final snapshot = await query.get();
    final products =
        snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data != null) {
                final mapData = data as Map<String, dynamic>;
                mapData['id'] = doc.id;
                return JumiaProduct.fromFirestore(mapData);
              }
              return null;
            })
            .where((product) => product != null)
            .cast<JumiaProduct>()
            .toList();

    setState(() {
      if (loadMore) {
        _products.addAll(products);
      } else {
        _products = products;
      }
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == _limit;
      _isLoadingMore = false;
    });
  }

  Future<void> _fetchMoreProducts() async {
    if (!_hasMore || _isLoadingMore) return;
    await _fetchProducts(loadMore: true);
  }

  Future<void> refreshData() async {
    setState(() {
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchProducts();
    await _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() => _isLoadingRecommendations = true);
    try {
      final recommendations =
          await _recommendationService.fetchRecommendations();
      setState(() {
        _recommendedProducts = recommendations;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecommendations = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
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
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
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
          suffixIcon:
              _searchQuery.isNotEmpty
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
              final wishlistProvider = Provider.of<WishlistProvider>(context);
              final isWishlisted = wishlistProvider.isInWishlist(product);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
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
              _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );
                      final products = await _fetchProductsForCategory(
                        category,
                      );
                      Navigator.pop(context); // Remove loading indicator

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CategoryScreen(
                                categoryName: category,
                                products: products,
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
    List<String> images = ['images/offer3.jpg', 'images/offer2.jpg','images/offer1.jpg'];
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items:
          images
              .map(
                (imgPath) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imgPath, fit: BoxFit.cover),
                ),
              )
              .toList(),
    );
  }

  Widget buildFirestoreProductsSection() {
    final filteredProducts =
        _searchQuery.isEmpty
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProductDetailsScreen(product: product),
                              ),
                            );
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
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: double.infinity,
                                      placeholder:
                                          (context, url) => Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              Icon(Icons.error),
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
                children:
                    _recommendedProducts
                        .map(
                          (product) =>
                              buildRecommendedProductCard(context, product),
                        )
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRecommendedProductCard(
    BuildContext context,
    JumiaProduct product,
  ) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isInWishlist(product);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
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
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    height: 100,
                    width: double.infinity,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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

  Future<List<JumiaProduct>> _fetchProductsForCategory(String category) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('Category', isEqualTo: category)
            .orderBy('Title')
            .limit(_limit)
            .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data != null) {
            // ignore: unnecessary_cast
            final mapData = data as Map<String, dynamic>;
            mapData['id'] = doc.id;
            return JumiaProduct.fromFirestore(mapData);
          }
          return null;
        })
        .where((product) => product != null)
        .cast<JumiaProduct>()
        .toList();
  }
}
