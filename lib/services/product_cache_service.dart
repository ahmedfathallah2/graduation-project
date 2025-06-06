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
      print('Cache expired, clearing...');
      await clearCache();
      return;
    }
    
    try {
      // Load product cache
      final productCacheJson = prefs.getString(_productCacheKey);
      if (productCacheJson != null) {
        final productCacheData = jsonDecode(productCacheJson);
        
        if (productCacheData is List) {
          // Array format
          for (final productData in productCacheData) {
            if (productData is List && productData.length >= 6) {
              try {
                final product = JumiaProduct.fromFirestore({
                  'id': productData[0],
                  'Title': productData[1],
                  'Brand': productData[2],
                  'Category': productData[3],
                  'Image_URL': productData[4],
                  'Price_EGP': productData[5],
                  'Link': productData.length > 6 ? productData[6] : '',
                  'Subcategory': productData.length > 7 ? productData[7] : '',
                  'Parsed_Storage': productData.length > 8 ? productData[8] : '',
                });
                _productMemoryCache[product.id] = product;
              } catch (e) {
                print('Error loading product from cache: $e');
                continue;
              }
            }
          }
        } else if (productCacheData is Map) {
          // Map format (backward compatibility)
          final productCache = productCacheData as Map<String, dynamic>;
          productCache.forEach((id, productData) {
            try {
              if (productData is String) {
                // Old JSON string format
                _productMemoryCache[id] = JumiaProduct.fromFirestore({
                  ...jsonDecode(productData),
                  'id': id,
                });
              } else if (productData is Map) {
                // New map format
                _productMemoryCache[id] = JumiaProduct.fromFirestore({
                  'id': id,
                  'Title': productData['title'],
                  'Brand': productData['brand'],
                  'Category': productData['category'],
                  'Image_URL': productData['imageUrl'],
                  'Price_EGP': productData['priceEGP'],
                  'Link': productData['link'] ?? '',
                  'Subcategory': productData['subcategory'] ?? '',
                  'Parsed_Storage': productData['parsedStorage'] ?? '',
                });
              }
            } catch (e) {
              print('Error loading product $id from cache: $e');
            }
          });
        }
      }
      
      // Load search cache
      final searchCacheJson = prefs.getString(_searchCacheKey);
      if (searchCacheJson != null) {
        try {
          final searchCache = jsonDecode(searchCacheJson) as Map<String, dynamic>;
          searchCache.forEach((query, results) {
            _searchMemoryCache[query] = List<String>.from(results);
          });
        } catch (e) {
          print('Error loading search cache: $e');
        }
      }
      
      // Load category cache
      final categoryCacheJson = prefs.getString(_categoryCacheKey);
      if (categoryCacheJson != null) {
        try {
          final categoryCache = jsonDecode(categoryCacheJson) as Map<String, dynamic>;
          categoryCache.forEach((category, products) {
            _categoryMemoryCache[category] = List<String>.from(products);
          });
        } catch (e) {
          print('Error loading category cache: $e');
        }
      }
      
      print('Cache initialized with ${_productMemoryCache.length} products, ${_searchMemoryCache.length} searches, ${_categoryMemoryCache.length} categories');
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
      
      // Limit cache size to prevent quota exceeded error
      const maxCacheSize = 500;
      final limitedProducts = _productMemoryCache.entries.take(maxCacheSize);
      
      // Use consistent array format for better space efficiency
      final List<List<dynamic>> productCache = [];
      for (final entry in limitedProducts) {
        final product = entry.value;
        productCache.add([
          entry.key,           // 0: id
          product.title,       // 1: title
          product.brand,       // 2: brand
          product.category,    // 3: category
          product.imageUrl,    // 4: imageUrl
          product.priceEGP,    // 5: priceEGP
          product.link,        // 6: link
          product.subcategory, // 7: subcategory
          product.parsedStorage, // 8: parsedStorage
        ]);
      }
      
      try {
        await prefs.setString(_productCacheKey, jsonEncode(productCache));
        
        // Persist search cache (limit entries)
        final limitedSearchCache = _searchMemoryCache.entries.take(50).toList();
        await prefs.setString(_searchCacheKey, jsonEncode(Map.fromEntries(limitedSearchCache)));
        
        // Persist category cache (limit entries)  
        final limitedCategoryCache = _categoryMemoryCache.entries.take(20).toList();
        await prefs.setString(_categoryCacheKey, jsonEncode(Map.fromEntries(limitedCategoryCache)));
        
      } catch (e) {
        if (e.toString().contains('QuotaExceededError') || 
            e.toString().contains('exceeded the quota')) {
          // If still too large, reduce cache size further
          await _reduceCacheSize();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('Error updating persisted cache: $e');
    }
  }
  
  // Add this helper method
  Future<void> _reduceCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Keep only 200 most recent products
      final limitedProducts = _productMemoryCache.entries.take(200);
      final List<List<dynamic>> productCache = [];
      
      for (final entry in limitedProducts) {
        final product = entry.value;
        // Store only essential data
        productCache.add([
          entry.key,
          product.title,
          product.brand,
          product.category,
          product.imageUrl,
          product.priceEGP,
        ]);
      }
      
      await prefs.setString(_productCacheKey, jsonEncode(productCache));
      
      // Clear search and category caches to save space
      _searchMemoryCache.clear();
      _categoryMemoryCache.clear();
      await prefs.remove(_searchCacheKey);
      await prefs.remove(_categoryCacheKey);
      
      print('Cache size reduced to prevent quota error');
    } catch (e) {
      print('Error reducing cache size: $e');
      // If all else fails, clear the cache
      await clearCache();
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

  // Check if a product is cached
  bool isProductCached(String productId) {
    return _productMemoryCache.containsKey(productId);
  }

  // Check if search results are cached
  bool areSearchResultsCached(String searchQuery) {
    final query = searchQuery.toLowerCase().trim();
    return _searchMemoryCache.containsKey(query);
  }

  // Check if category products are cached
  bool areCategoryProductsCached(String category) {
    return _categoryMemoryCache.containsKey(category);
  }

  // Get cache statistics for debugging
  Map<String, int> getCacheStats() {
    return {
      'products': _productMemoryCache.length,
      'searches': _searchMemoryCache.length,
      'categories': _categoryMemoryCache.length,
    };
  }
}
