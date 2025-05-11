import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/jumia_product.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch recommendations for the current user
  Future<List<JumiaProduct>> fetchRecommendations() async {
    if (currentUserId == null) {
      return [];
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
      return recommendedProducts.map((productMap) {
        return JumiaProduct(
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
      }).toList().cast<JumiaProduct>();
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }
}
