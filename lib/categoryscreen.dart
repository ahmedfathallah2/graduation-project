import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/jumia_product.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final List<JumiaProduct> products;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final int _limit = 20;
  List<JumiaProduct> _products = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _products = List<JumiaProduct>.from(widget.products);
    _scrollController = ScrollController()..addListener(_onScroll);
    if (_products.isNotEmpty) {
      // If initial products were passed, set _lastDocument for pagination
      _fetchLastDocument();
    } else {
      _fetchMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchMoreProducts();
    }
  }

  Future<void> _fetchLastDocument() async {
    // Get the last document for pagination if initial products were passed
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('Category', isEqualTo: widget.categoryName)
        .orderBy('Title')
        .limit(_products.length)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _limit;
      });
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('Category', isEqualTo: widget.categoryName)
        .orderBy('Title')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    final newProducts = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data != null) {
        final mapData = data as Map<String, dynamic>;
        mapData['id'] = doc.id;
        return JumiaProduct.fromFirestore(mapData);
      }
      return null;
    }).where((product) => product != null).cast<JumiaProduct>().toList();

    setState(() {
      _products.addAll(newProducts);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDocument;
      _hasMore = snapshot.docs.length == _limit;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _products.length) {
            final product = _products[index];
            return ListTile(
              leading: Image.network(product.imageUrl, width: 50),
              title: Text(product.title),
              subtitle: Text("EGP ${product.priceEGP}"),
              onTap: () {
                // Add navigation to details page if needed
              },
            );
          } else {
            // Show loading indicator at the end
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
