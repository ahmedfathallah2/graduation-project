import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> wishlistItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get the user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Extract wishlist product IDs
      final userData = userDoc.data()!;
      final List<String> wishlistIds = List<String>.from(userData['wishlist'] ?? []);

      // Load product details if wishlist is not empty
      if (wishlistIds.isNotEmpty) {
        // If you have a products collection, you can fetch the actual product details
        // This is a placeholder for product data
        final items = await Future.wait(
          wishlistIds.map((id) async {
            // Try to get product from Firestore (if you have a products collection)
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(id)
                  .get();
                  
              if (doc.exists) {
                final data = doc.data()!;
                data['id'] = id; // Add id to the data
                return data;
              }
            } catch (e) {
              print('Error fetching product $id: $e');
            }
            
            // Return placeholder data if product not found
            return {
              'id': id,
              'name': 'Product $id',
              'price': 'Unknown',
              'image': null,
            };
          }),
        );

        setState(() {
          wishlistItems = items.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'wishlist': FieldValue.arrayRemove([productId])
      });

      // Refresh the wishlist
      setState(() {
        wishlistItems.removeWhere((item) => item['id'] == productId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from wishlist')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your wishlist is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Items you like will be saved here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = wishlistItems[index];
                    return WishlistItem(
                      product: item,
                      onRemove: () => _removeFromWishlist(item['id']),
                    );
                  },
                ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onRemove;

  const WishlistItem({
    super.key,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ${product['price']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
