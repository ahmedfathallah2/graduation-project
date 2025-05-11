import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/jumia_product.dart';
import 'product_cache_service.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductCacheService _cacheService = ProductCacheService();

  // Cache keys
  static const String _recommendationCacheKey = 'user_recommendations';
  static const String _recommendationTimestampKey = 'recommendations_timestamp';
  
  // Cache expiration in milliseconds (default: 2 hours)
  final int _cacheExpirationMs = 7200000;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch recommendations for the current user with caching
  Future<List<JumiaProduct>> fetchRecommendations() async {
    if (currentUserId == null) {
      return [];
    }

    // Check cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRecommendationsJson = prefs.getString('${_recommendationCacheKey}_$currentUserId');
      final timestamp = prefs.getInt('${_recommendationTimestampKey}_$currentUserId');
      
      // Check if cache is valid
      if (cachedRecommendationsJson != null && timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp < _cacheExpirationMs) {
          // Cache is valid
          final cachedRecommendations = List<String>.from(jsonDecode(cachedRecommendationsJson));
          
          // Get products from cache
          final products = _cacheService.getProducts(cachedRecommendations);
          
          // If all products are in cache, return them
          if (products.length == cachedRecommendations.length) {
            print('Using cached recommendations for user: $currentUserId');
            return products;
          }
        }
      }
    } catch (e) {
      print('Error checking recommendation cache: $e');
      // Continue to fetch from Firestore
    }

    try {
      // Get the recommendations document for the current user
      DocumentSnapshot recommendationDoc = await _firestore
          .collection('recommendations')
          .doc(currentUserId)
          .get();

      if (!recommendationDoc.exists || recommendationDoc.data() == null) {
        print('No recommendations document found for user: $currentUserId');
        return [];
      }

      // Extract the array of recommended products
      Map<String, dynamic> data = recommendationDoc.data() as Map<String, dynamic>;
      
      // Check if recommendations field exists and is not empty
      List<dynamic> recommendedProducts = data['recommendations'] ?? [];
      print('Found ${recommendedProducts.length} recommendations for user: $currentUserId');
      
      // Convert each product map to JumiaProduct
      final products = recommendedProducts.map((productMap) {
        final product = JumiaProduct(
          id: productMap['id'] ?? '',
          title: productMap['Title'] ?? '',
          brand: productMap['Brand'] ?? '',
          category: productMap['Category'] ?? '',
          subcategory: productMap['Subcategory'] ?? '',
          imageUrl: productMap['Image_URL'] ?? '',
          link: productMap['Link'] ?? '',
          parsedStorage: productMap['Parsed_Storage'] ?? 0,
          priceEGP: productMap['Price_EGP'] ?? 0,
        );
        
        // Cache individual products
        _cacheService.cacheProduct(product);
        
        return product;
      }).toList().cast<JumiaProduct>();
      
      // Cache recommendation list
      if (products.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          '${_recommendationCacheKey}_$currentUserId',
          jsonEncode(products.map((p) => p.id).toList())
        );
        await prefs.setInt(
          '${_recommendationTimestampKey}_$currentUserId',
          DateTime.now().millisecondsSinceEpoch
        );
      }
      
      return products;
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }
  
  // Clear recommendations cache for current user
  Future<void> clearRecommendationsCache() async {
    if (currentUserId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_recommendationCacheKey}_$currentUserId');
      await prefs.remove('${_recommendationTimestampKey}_$currentUserId');
    } catch (e) {
      print('Error clearing recommendations cache: $e');
    }
  }
}
