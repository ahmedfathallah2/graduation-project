import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to user document
  DocumentReference? get _userRef {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // Get user's wishlist as stream
  Stream<List<String>> getWishlistStream() {
    final userRef = _userRef;
    if (userRef == null) {
      return Stream.value([]);
    }

    return userRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return [];
      
      return List<String>.from(data['wishlist'] ?? []);
    });
  }

  // Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    final userRef = _userRef;
    if (userRef == null) throw Exception('User not logged in');

    return userRef.update({
      'wishlist': FieldValue.arrayUnion([productId])
    });
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    final userRef = _userRef;
    if (userRef == null) throw Exception('User not logged in');

    return userRef.update({
      'wishlist': FieldValue.arrayRemove([productId])
    });
  }

  // Check if a product is in the wishlist
  Future<bool> isInWishlist(String productId) async {
    final userRef = _userRef;
    if (userRef == null) return false;

    final doc = await userRef.get();
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return false;

    final wishlist = List<String>.from(data['wishlist'] ?? []);
    return wishlist.contains(productId);
  }

  // Get all wishlist items
  Future<List<String>> getWishlist() async {
    final userRef = _userRef;
    if (userRef == null) return [];

    final doc = await userRef.get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return [];

    return List<String>.from(data['wishlist'] ?? []);
  }
}
