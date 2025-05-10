import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jumia_product.dart';

class SearchService {
  // Search across products in Firestore with flexible partial matching
  static Future<List<JumiaProduct>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    // Convert to lowercase for consistency
    final searchQuery = query.toLowerCase();
    final List<JumiaProduct> results = [];
    final Set<String> processedIds = {};
    
    // Try to get products by title prefix (most efficient)
    try {
      final titlePrefixSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('Title', isGreaterThanOrEqualTo: searchQuery)
          .where('Title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .limit(250)
          .get();
      
      for (final doc in titlePrefixSnapshot.docs) {
        final String docId = doc.id;
        if (!processedIds.contains(docId)) {
          processedIds.add(docId);
          final data = doc.data();
          data['id'] = docId;
          results.add(JumiaProduct.fromFirestore(data));
        }
      }
    } catch (e) {
      print('Error in title prefix search: $e');
    }
    
    // Try to get products by brand prefix
    try {
      final brandPrefixSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('Brand', isGreaterThanOrEqualTo: searchQuery)
          .where('Brand', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .limit(250)
          .get();
      
      for (final doc in brandPrefixSnapshot.docs) {
        final String docId = doc.id;
        if (!processedIds.contains(docId)) {
          processedIds.add(docId);
          final data = doc.data();
          data['id'] = docId;
          results.add(JumiaProduct.fromFirestore(data));
        }
      }
    } catch (e) {
      print('Error in brand prefix search: $e');
    }
    
    // Try to get products by category prefix
    try {
      final categoryPrefixSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('Category', isGreaterThanOrEqualTo: searchQuery)
          .where('Category', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .limit(250)
          .get();
      
      for (final doc in categoryPrefixSnapshot.docs) {
        final String docId = doc.id;
        if (!processedIds.contains(docId)) {
          processedIds.add(docId);
          final data = doc.data();
          data['id'] = docId;
          results.add(JumiaProduct.fromFirestore(data));
        }
      }
    } catch (e) {
      print('Error in category prefix search: $e');
    }
    
    // For partial word search (contains)
    // First, try to find matches for individual words in the search query
    final List<String> searchWords = searchQuery.split(' ').where((w) => w.isNotEmpty).toList();
    
    if (searchWords.isNotEmpty && results.length < 100) {
      for (final word in searchWords) {
        if (word.length >= 3) { // Only search for words with at least 3 characters
          try {
            // Get products containing this word in title
            final wordMatchSnapshot = await FirebaseFirestore.instance
                .collection('products')
                .orderBy('Title')
                .startAt([word])
                .endAt([word + '\uf8ff'])
                .limit(250)
                .get();
            
            for (final doc in wordMatchSnapshot.docs) {
              final String docId = doc.id;
              if (!processedIds.contains(docId)) {
                processedIds.add(docId);
                final data = doc.data();
                data['id'] = docId;
                results.add(JumiaProduct.fromFirestore(data));
              }
            }
          } catch (e) {
            print('Error in word search for "$word": $e');
          }
        }
      }
    }
    
    // Last resort: if still no results and query is very specific (like "Samsung Galaxy S22")
    // then perform a more comprehensive search but limit to a reasonable number
    if (results.isEmpty && searchQuery.length > 5) {
      try {
        final lastResortSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .limit(500)
            .get();
            
        for (final doc in lastResortSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          
          final title = (data['Title'] ?? '').toString().toLowerCase();
          final brand = (data['Brand'] ?? '').toString().toLowerCase();
          
          // Check if product details contain the search terms
          bool matches = false;
          for (final word in searchWords) {
            if (word.length >= 3 && (title.contains(word) || brand.contains(word))) {
              matches = true;
              break;
            }
          }
          
          if (matches && !processedIds.contains(doc.id)) {
            processedIds.add(doc.id);
            results.add(JumiaProduct.fromFirestore(data));
          }
        }
      } catch (e) {
        print('Error in last resort search: $e');
      }
    }
    
    return results;
  }
}
