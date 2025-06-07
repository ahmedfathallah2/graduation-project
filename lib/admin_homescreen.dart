import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'adminedit.dart';
import 'admin_dashboard_screen.dart';
import 'models/jumia_product.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final int _limit = 50;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  List<DocumentSnapshot> _docs = [];
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    setState(() {
      _isLoadingMore = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('products')
        .orderBy('Title')
        .limit(_limit);

    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        if (loadMore) {
          _docs.addAll(snapshot.docs);
        } else {
          _docs = snapshot.docs;
        }
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _limit;
      });
    } else {
      setState(() {
        _hasMore = false;
      });
    }
    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _docs.where((doc) {
      final title = (doc['Title'] ?? '').toString().toLowerCase();
      final brand = (doc['Brand'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery) || brand.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Products',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "All Products",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Product cards
            Expanded(
              child: _docs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data = filteredDocs[index].data() as Map<String, dynamic>;
                        final id = filteredDocs[index].id;
                        final product = JumiaProduct.fromFirestore({
                          ...data,
                          'id': id,
                        });

                        return Stack(
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
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    product.imageUrl,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    'EGP ${product.priceEGP}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Text(
                                      "0%",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(product.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product deleted')),
                                  );
                                },
                                child: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (_hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _isLoadingMore ? null : () => _fetchProducts(loadMore: true),
                  child: _isLoadingMore
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
