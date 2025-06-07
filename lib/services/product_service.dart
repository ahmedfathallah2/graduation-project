import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jumia_product.dart';
import 'product_cache_service.dart';

class ProductService {
  static final ProductCacheService _cacheService = ProductCacheService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a single product by ID with caching
  static Future<JumiaProduct?> fetchProductById(String productId) async {
    final cachedProduct = _cacheService.getProduct(productId);
    if (cachedProduct != null) {
      print('Using cached product: ${cachedProduct.id}');
      return cachedProduct;
    }

    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      final product = JumiaProduct.fromFirestore(data);
      await _cacheService.cacheProduct(product);
      return product;
    } catch (e) {
      print('Error fetching product $productId: $e');
      return null;
    }
  }

  // Fetch products by category with caching and enforced limit
  static Future<List<JumiaProduct>> fetchProductsByCategory(String category, {int limit = 20}) async {
    final cachedProductIds = _cacheService.getCachedCategoryProducts(category);
    if (cachedProductIds != null) {
      final cachedProducts = _cacheService.getProducts(cachedProductIds);
      if (cachedProducts.length == cachedProductIds.length) {
        print('Using ${cachedProducts.length} cached products for category: $category');
        return cachedProducts.take(limit).toList();
      }
    }

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('Category', isEqualTo: category)
          .limit(limit)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JumiaProduct.fromFirestore(data);
      }).toList();

      if (products.isNotEmpty) {
        await _cacheService.cacheProducts(products);
        await _cacheService.cacheCategoryProducts(
          category,
          products.map((p) => p.id).toList(),
        );
      }

      return products;
    } catch (e) {
      print('Error fetching products for category $category: $e');
      return [];
    }
  }

  // Fetch all products with pagination and enforced limit
  static Future<List<JumiaProduct>> fetchProducts({
    DocumentSnapshot? startAfter,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && startAfter == null) {
      final cachedProducts = _cacheService.getAllProducts();
      if (cachedProducts.isNotEmpty) {
        print('Using ${cachedProducts.length} cached products');
        return cachedProducts.take(limit).toList();
      }
    }

    // Always enforce a reasonable limit
    if (limit > 200) {
      print('Warning: High limit requested ($limit). Consider lowering for performance.');
    }

    Query query = _firestore.collection('products').orderBy('Title').limit(limit);

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

      if (products.isNotEmpty && startAfter == null) {
        await _cacheService.cacheProducts(products);
      }

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Efficiently fetch a list of products by their IDs (for wishlist, etc.)
  static Future<List<JumiaProduct>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Firestore allows up to 10 'in' values per query; batch if needed
    const batchSize = 10;
    List<JumiaProduct> products = [];
    for (var i = 0; i < ids.length; i += batchSize) {
      final batchIds = ids.sublist(i, i + batchSize > ids.length ? ids.length : i + batchSize);
      final snapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();
      products.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return JumiaProduct.fromFirestore(data);
      }));
    }
    return products;
  }
}
