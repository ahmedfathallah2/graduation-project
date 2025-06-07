import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jumia_product.dart';

class ProductCacheService {
  // Singleton pattern
  static final ProductCacheService _instance = ProductCacheService._internal();
  factory ProductCacheService() => _instance;
  ProductCacheService._internal();

  // Cache keys
  static const String _productCacheKey = 'product_cache';
  static const String _searchCacheKey = 'search_cache';
  static const String _categoryCacheKey = 'category_cache';
  static const String _timestampKey = 'cache_timestamp';

  // Cache expiration in milliseconds (default: 1 hour)
  final int _cacheExpirationMs = 3600000;
  
  // In-memory cache for faster access during the session
  Map<String, JumiaProduct> _productMemoryCache = {};
  Map<String, List<String>> _searchMemoryCache = {};
  Map<String, List<String>> _categoryMemoryCache = {};
  DateTime? _cacheTimestamp;

  // Initialize the cache from SharedPreferences
  Future<void> initCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load cache timestamp
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp != null) {
      _cacheTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    // Check if cache has expired
    if (_isCacheExpired()) {
      await clearCache();
      return;
    }
    
    try {
      // Load product cache
      final productCacheJson = prefs.getString(_productCacheKey);
      if (productCacheJson != null) {
        final productCache = jsonDecode(productCacheJson) as Map<String, dynamic>;
        productCache.forEach((id, productJson) {
          _productMemoryCache[id] = JumiaProduct.fromFirestore({
            ...jsonDecode(productJson),
            'id': id,
          });
        });
      }
      
      // Load search cache
      final searchCacheJson = prefs.getString(_searchCacheKey);
      if (searchCacheJson != null) {
        final searchCache = jsonDecode(searchCacheJson) as Map<String, dynamic>;
        searchCache.forEach((query, results) {
          _searchMemoryCache[query] = List<String>.from(results);
        });
      }
      
      // Load category cache
      final categoryCacheJson = prefs.getString(_categoryCacheKey);
      if (categoryCacheJson != null) {
        final categoryCache = jsonDecode(categoryCacheJson) as Map<String, dynamic>;
        categoryCache.forEach((category, products) {
          _categoryMemoryCache[category] = List<String>.from(products);
        });
      }
      
      print('Cache initialized with ${_productMemoryCache.length} products');
    } catch (e) {
      print('Error initializing cache: $e');
      await clearCache();
    }
  }
  
  // Check if cache has expired
  bool _isCacheExpired() {
    if (_cacheTimestamp == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_cacheTimestamp!).inMilliseconds;
    
    return difference > _cacheExpirationMs;
  }

  // Get a product from cache by ID
  JumiaProduct? getProduct(String productId) {
    return _productMemoryCache[productId];
  }
  
  // Get multiple products from cache by IDs
  List<JumiaProduct> getProducts(List<String> productIds) {
    return productIds
        .map((id) => _productMemoryCache[id])
        .where((product) => product != null)
        .cast<JumiaProduct>()
        .toList();
  }
  
  // Get all cached products
  List<JumiaProduct> getAllProducts() {
    return _productMemoryCache.values.toList();
  }
  
  // Cache a product
  Future<void> cacheProduct(JumiaProduct product) async {
    _productMemoryCache[product.id] = product;
    await _updatePersistedCache();
  }
  
  // Cache multiple products
  Future<void> cacheProducts(List<JumiaProduct> products) async {
    for (final product in products) {
      _productMemoryCache[product.id] = product;
    }
    await _updatePersistedCache();
  }
  
  // Get search results from cache
  List<String>? getCachedSearchResults(String searchQuery) {
    final query = searchQuery.toLowerCase().trim();
    return _searchMemoryCache[query];
  }
  
  // Cache search results
  Future<void> cacheSearchResults(String searchQuery, List<String> productIds) async {
    final query = searchQuery.toLowerCase().trim();
    _searchMemoryCache[query] = productIds;
    await _updatePersistedCache();
  }
  
  // Get category products from cache
  List<String>? getCachedCategoryProducts(String category) {
    return _categoryMemoryCache[category];
  }
  
  // Cache category products
  Future<void> cacheCategoryProducts(String category, List<String> productIds) async {
    _categoryMemoryCache[category] = productIds;
    await _updatePersistedCache();
  }
  
  // Update the persisted cache in SharedPreferences
  Future<void> _updatePersistedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update timestamp
      final now = DateTime.now();
      _cacheTimestamp = now;
      await prefs.setInt(_timestampKey, now.millisecondsSinceEpoch);
      
      // Persist product cache
      final Map<String, String> productCache = {};
      _productMemoryCache.forEach((id, product) {
        final productMap = {
          'Title': product.title,
          'Brand': product.brand,
          'Category': product.category,
          'Subcategory': product.subcategory,
          'Image_URL': product.imageUrl,
          'Link': product.link,
          'Parsed_Storage': product.parsedStorage,
          'Price_EGP': product.priceEGP,
        };
        productCache[id] = jsonEncode(productMap);
      });
      await prefs.setString(_productCacheKey, jsonEncode(productCache));
      
      // Persist search cache
      await prefs.setString(_searchCacheKey, jsonEncode(_searchMemoryCache));
      
      // Persist category cache
      await prefs.setString(_categoryCacheKey, jsonEncode(_categoryMemoryCache));
    } catch (e) {
      print('Error updating persisted cache: $e');
    }
  }
  
  // Clear the cache
  Future<void> clearCache() async {
    _productMemoryCache = {};
    _searchMemoryCache = {};
    _categoryMemoryCache = {};
    _cacheTimestamp = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productCacheKey);
      await prefs.remove(_searchCacheKey);
      await prefs.remove(_categoryCacheKey);
      await prefs.remove(_timestampKey);
      print('Cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
