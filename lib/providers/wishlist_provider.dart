import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wishlist_analyzer_service.dart';
import '../models/jumia_product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<JumiaProduct> _wishlist = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<JumiaProduct> get wishlist => _wishlist;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to user document
  DocumentReference? get _userRef {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // Initialize wishlist from Firebase
  Future<void> loadWishlist() async {
    if (currentUserId == null) return;

    try {
      // Clear existing wishlist
      _wishlist.clear();

      // Get wishlist product IDs from user document
      final userDoc = await _userRef?.get();
      if (userDoc == null || !userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) return;

      final wishlistIds = List<String>.from(userData['wishlist'] ?? []);

      if (wishlistIds.isEmpty) {
        notifyListeners();
        return;
      }

      // Fetch products from Firestore using the IDs
      final productsSnapshot = await _firestore
          .collection('products')
          .get();

      // Filter products that match our wishlist IDs
      final products = productsSnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID to data
            return JumiaProduct.fromFirestore(data);
          })
          .where((product) => wishlistIds.contains(product.id))
          .toList();

      _wishlist.addAll(products);
      notifyListeners();
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  // Check if a product is in wishlist
  bool isInWishlist(JumiaProduct product) {
    return _wishlist.any((item) => item.id == product.id);
  }

  // Toggle product in wishlist
  Future<void> toggleWishlist(JumiaProduct product) async {
    if (currentUserId == null) return;

    try {
      final isCurrentlyInWishlist = isInWishlist(product);

      if (isCurrentlyInWishlist) {
        // Remove from local list
        _wishlist.removeWhere((item) => item.id == product.id);

        // Remove from Firebase
        await _userRef?.update({
          'wishlist': FieldValue.arrayRemove([product.id])
        });
      } else {
        // Add to local list
        _wishlist.add(product);

        // Add to Firebase
        await _userRef?.update({
          'wishlist': FieldValue.arrayUnion([product.id])
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling wishlist: $e');
      // Revert local change if Firebase update fails
      await loadWishlist();
    }

    await updatePreferencesAfterWishlistChange();
  }

  // Remove product from wishlist by ID
  Future<void> removeFromWishlist(String productId) async {
    if (currentUserId == null) return;

    try {
      // Remove from local list
      final productIndex = _wishlist.indexWhere((item) => item.id == productId);
      if (productIndex >= 0) {
        _wishlist.removeAt(productIndex);
      }

      // Remove from Firebase
      await _userRef?.update({
        'wishlist': FieldValue.arrayRemove([productId])
      });

      notifyListeners();
    } catch (e) {
      print('Error removing from wishlist: $e');
      // Revert local change if Firebase update fails
      await loadWishlist();
    }

    await updatePreferencesAfterWishlistChange();
  }
}

Future<void> updatePreferencesAfterWishlistChange() async {
  try {
    final analyzerService = WishlistAnalyzerService();
    await analyzerService.updateAutomaticPreferences();
  } catch (e) {
    print('Error updating preferences: $e');
  }
}
