import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jumia_product.dart';
import 'product_cache_service.dart';

class ProductService {
  static final ProductCacheService _cacheService = ProductCacheService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a single product by ID with caching
  static Future<JumiaProduct?> fetchProductById(String productId) async {
    // Check cache first
    final cachedProduct = _cacheService.getProduct(productId);
    if (cachedProduct != null) {
      print('Using cached product: ${cachedProduct.id}');
      return cachedProduct;
    }

    // Cache miss - fetch from Firestore
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      final data = doc.data()!;
      data['id'] = doc.id;
      
      final product = JumiaProduct.fromFirestore(data);
      
      // Cache the product
      await _cacheService.cacheProduct(product);
      
      return product;
    } catch (e) {
      print('Error fetching product $productId: $e');
      return null;
    }
  }

  // Fetch products by category with caching
  static Future<List<JumiaProduct>> fetchProductsByCategory(String category) async {
    // Check cache first
    final cachedProductIds = _cacheService.getCachedCategoryProducts(category);
    if (cachedProductIds != null) {
      final cachedProducts = _cacheService.getProducts(cachedProductIds);
      
      // If we have all products in cache, return them
      if (cachedProducts.length == cachedProductIds.length) {
        print('Using ${cachedProducts.length} cached products for category: $category');
        return cachedProducts;
      }
    }

    // Cache miss - fetch from Firestore
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('Category', isEqualTo: category)
          .get();
          
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JumiaProduct.fromFirestore(data);
      }).toList();
      
      // Cache the results
      if (products.isNotEmpty) {
        await _cacheService.cacheProducts(products);
        await _cacheService.cacheCategoryProducts(
          category, 
          products.map((p) => p.id).toList()
        );
      }
      
      return products;
    } catch (e) {
      print('Error fetching products for category $category: $e');
      return [];
    }
  }

  // Fetch all products with pagination and caching
  static Future<List<JumiaProduct>> fetchProducts({
    DocumentSnapshot? startAfter, 
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    // If not forcing refresh and it's the first page, try to use cache
    if (!forceRefresh && startAfter == null) {
      final cachedProducts = _cacheService.getAllProducts();
      if (cachedProducts.isNotEmpty) {
        print('Using ${cachedProducts.length} cached products');
        return cachedProducts.take(limit).toList();
      }
    }
    
    // Build the query
    Query query = _firestore.collection('products').orderBy('Title').limit(limit);
    
    // Add pagination if needed
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    try {
      final snapshot = await query.get();
      
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return JumiaProduct.fromFirestore(data);
      }).toList();
      
      // Cache the products
      if (products.isNotEmpty && startAfter == null) {
        // Only cache the first page
        await _cacheService.cacheProducts(products);
      }
      
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}

// Stream of products for real-time updates
Stream<List<JumiaProduct>> fetchJumiaProducts() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
    (snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JumiaProduct.fromFirestore(data);
      }).toList();
      
      // Update cache in the background
      ProductService._cacheService.cacheProducts(products);
      
      return products;
    },
  );
}
