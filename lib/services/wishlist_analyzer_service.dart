import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistAnalyzerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Threshold for considering a preference significant (25%)
  final double _threshold = 0.25;
  
  // Maximum number of top preferences to consider
  final int _maxTopPreferences = 5;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to user document
  DocumentReference? get _userRef {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // Analyze wishlist and generate recommended preferences
  Future<Map<String, dynamic>> analyzeWishlist() async {
    final userRef = _userRef;
    if (userRef == null) {
      throw Exception('User not logged in');
    }

    // Get user's wishlist
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      return {'brands': [], 'categories': [], 'subcategories': [], 'avgPrice': 0};
    }

    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData == null) {
      return {'brands': [], 'categories': [], 'subcategories': [], 'avgPrice': 0};
    }

    final wishlistIds = List<String>.from(userData['wishlist'] ?? []);
    
    if (wishlistIds.isEmpty) {
      return {'brands': [], 'categories': [], 'subcategories': [], 'avgPrice': 0};
    }

    // Get all products in wishlist
    final productsCollection = _firestore.collection('products');
    final products = await Future.wait(
      wishlistIds.map((id) => productsCollection.doc(id).get())
    );

    // Extract data for analysis
    final validProducts = products
        .where((doc) => doc.exists)
        .map((doc) {
          final data = doc.data();
          return data;
        })
        .where((data) => data != null)
        .cast<Map<String, dynamic>>()
        .toList();

    if (validProducts.isEmpty) {
      return {'brands': [], 'categories': [], 'subcategories': [], 'avgPrice': 0};
    }

    // Analyze data
    return _analyzeProducts(validProducts);
  }

  Map<String, dynamic> _analyzeProducts(List<Map<String, dynamic>> products) {
    // Count frequencies
    final Map<String, int> brandFrequency = {};
    final Map<String, int> categoryFrequency = {};
    final Map<String, int> subcategoryFrequency = {};
    double totalPrice = 0;
    
    for (final product in products) {
      // Skip products with "brand could not be extracted"
      final brand = product['Brand'] as String?;
      if (brand != null && brand != "brand could not be extracted") {
        brandFrequency[brand] = (brandFrequency[brand] ?? 0) + 1;
      }
      
      final category = product['Category'] as String?;
      if (category != null) {
        categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
      }
      
      final subcategory = product['Subcategory'] as String?;
      if (subcategory != null) {
        subcategoryFrequency[subcategory] = (subcategoryFrequency[subcategory] ?? 0) + 1;
      }
      
      final price = product['Price_EGP'];
      if (price != null && price is num) {
        totalPrice += price.toDouble();
      }
    }
    
    final totalProducts = products.length;
    final avgPrice = totalProducts > 0 ? totalPrice / totalProducts : 0;
    
    // Apply threshold and get top N preferences
    final recommendedBrands = _getTopPreferences(brandFrequency, totalProducts);
    final recommendedCategories = _getTopPreferences(categoryFrequency, totalProducts);
    final recommendedSubcategories = _getTopPreferences(subcategoryFrequency, totalProducts);
    
    // Calculate metrics about the wishlist
    final metrics = _calculateMetrics(
      brandFrequency: brandFrequency,
      categoryFrequency: categoryFrequency,
      totalProducts: totalProducts
    );
    
    return {
      'brands': recommendedBrands,
      'categories': recommendedCategories,
      'subcategories': recommendedSubcategories,
      'avgPrice': avgPrice,
      'metrics': metrics,
    };
  }
  
  List<String> _getTopPreferences(Map<String, int> frequency, int totalItems) {
    if (totalItems == 0) return [];
    
    // Filter by threshold
    final thresholdItems = frequency.entries
        .where((entry) => entry.value / totalItems >= _threshold)
        .toList();
    
    // Sort by frequency (descending)
    thresholdItems.sort((a, b) => b.value.compareTo(a.value));
    
    // Take top N
    return thresholdItems
        .take(_maxTopPreferences)
        .map((entry) => entry.key)
        .toList();
  }
  
  Map<String, String> _calculateMetrics({
    required Map<String, int> brandFrequency,
    required Map<String, int> categoryFrequency,
    required int totalProducts
  }) {
    final metrics = <String, String>{};
    
    if (totalProducts == 0) return metrics;
    
    // Find most common brand
    if (brandFrequency.isNotEmpty) {
      final mostCommonBrand = brandFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      final percentage = (mostCommonBrand.value / totalProducts * 100).round();
      if (percentage >= 15) { // Only show if significant
        metrics['brandDistribution'] = 
            '$percentage% of your wishlist items are from ${mostCommonBrand.key}';
      }
    }
    
    // Find most common category
    if (categoryFrequency.isNotEmpty) {
      final mostCommonCategory = categoryFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      final percentage = (mostCommonCategory.value / totalProducts * 100).round();
      if (percentage >= 15) { // Only show if significant
        metrics['categoryDistribution'] = 
            '$percentage% of your wishlist is in the ${mostCommonCategory.key} category';
      }
    }
    
    return metrics;
  }
  
  // Apply automatic preferences to user (silently)
  Future<void> updateAutomaticPreferences() async {
    try {
      final recommendations = await analyzeWishlist();
      final userRef = _userRef;
      
      if (userRef == null) return;
      
      await userRef.update({
        'auto_preferences': {
          'brand': recommendations['brands'],
          'category': recommendations['categories'],
          'subcategory': recommendations['subcategories'],
          'avg_price': recommendations['avgPrice'],
          'metrics': recommendations['metrics'],
        }
      });
    } catch (e) {
      print('Error updating automatic preferences: $e');
    }
  }
}
