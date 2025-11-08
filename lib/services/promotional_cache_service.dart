import 'package:customer/utils/fire_store_utils.dart';

/// **ULTRA-FAST PROMOTIONAL CACHE SERVICE**
/// 
/// This service provides instant access to promotional data without Firebase queries.
/// It caches promotional data per restaurant and provides zero-latency access.
class PromotionalCacheService {
  static final PromotionalCacheService _instance = PromotionalCacheService._internal();
  factory PromotionalCacheService() => _instance;
  PromotionalCacheService._internal();

  // **PROMOTIONAL CACHE STORAGE**
  static final Map<String, Map<String, dynamic>> _promotionalCache = {};
  static final Map<String, int> _promotionalLimits = {};
  static final Map<String, bool> _promotionalAvailability = {};
  static final Map<String, bool> _restaurantCacheLoaded = {};

  /// **ULTRA-FAST LAZY LOADING PROMOTIONAL CACHE**
  static Future<void> loadRestaurantPromotions(String restaurantId) async {
    if (_restaurantCacheLoaded[restaurantId] == true) {
      print('DEBUG: Promotional cache already loaded for restaurant: $restaurantId');
      return;
    }

    try {
      print('DEBUG: ULTRA-FAST loading promotional cache for restaurant: $restaurantId');
      
      // **ULTRA-FAST: Load only essential data first**
      final promotions = await FireStoreUtils.fetchActivePromotions(
        restaurantId: restaurantId
      );
      
      print('DEBUG: Found ${promotions.length} promotions instantly for restaurant $restaurantId');
      
      // **PARALLEL CACHE BUILDING: Process all promotions simultaneously**
      final cacheFutures = promotions.map((promo) async {
        final productId = promo['product_id'] as String?;
        final restaurantIdFromPromo = promo['restaurant_id'] as String?;
        
        if (productId != null && restaurantIdFromPromo != null) {
          final cacheKey = '$productId-$restaurantIdFromPromo';
          
          // **INSTANT CACHE STORAGE**
          _promotionalCache[cacheKey] = promo;
          
          // **PRE-CALCULATE FOR INSTANT ACCESS**
          final itemLimitData = promo['item_limit'];
          int? itemLimit;
          if (itemLimitData != null) {
            if (itemLimitData is int) {
              itemLimit = itemLimitData;
            } else if (itemLimitData is double) {
              itemLimit = itemLimitData.toInt();
            } else if (itemLimitData is String) {
              itemLimit = int.tryParse(itemLimitData);
            } else if (itemLimitData is num) {
              itemLimit = itemLimitData.toInt();
            }
          }
          _promotionalLimits[cacheKey] = itemLimit ?? 0;
          _promotionalAvailability[cacheKey] = itemLimit != null && itemLimit > 0;
        }
      });
      
      // **PARALLEL EXECUTION: All cache building happens simultaneously**
      await Future.wait(cacheFutures);
      
      _restaurantCacheLoaded[restaurantId] = true;
      print('DEBUG: ULTRA-FAST promotional cache loaded for restaurant $restaurantId with ${_promotionalCache.length} items');
    } catch (e) {
      print('DEBUG: Error in ultra-fast promotional cache loading for restaurant $restaurantId: $e');
    }
  }

  /// **GET CACHED PROMOTIONAL DATA (INSTANT - ZERO ASYNC)**
  static Map<String, dynamic>? getCachedPromotionalData(String productId, String restaurantId) {
    final cacheKey = '$productId-$restaurantId';
    return _promotionalCache[cacheKey];
  }

  /// **CHECK PROMOTIONAL AVAILABILITY (INSTANT - ZERO ASYNC)**
  static bool isPromotionalAvailable(String productId, String restaurantId) {
    final cacheKey = '$productId-$restaurantId';
    return _promotionalAvailability[cacheKey] ?? false;
  }

  /// **GET PROMOTIONAL LIMIT (INSTANT - ZERO ASYNC)**
  static int getPromotionalLimit(String productId, String restaurantId) {
    final cacheKey = '$productId-$restaurantId';
    return _promotionalLimits[cacheKey] ?? 0;
  }

  /// **GET PROMOTIONAL ITEM LIMIT (INSTANT - ZERO ASYNC)**
  static int? getPromotionalItemLimit(String productId, String restaurantId) {
    if (!isPromotionalAvailable(productId, restaurantId)) {
      return null;
    }
    final limit = getPromotionalLimit(productId, restaurantId);
    return limit > 0 ? limit : null;
  }

  /// **CHECK IF PROMOTIONAL ITEM QUANTITY IS ALLOWED (INSTANT - ZERO ASYNC)**
  static bool isPromotionalItemQuantityAllowed(String productId, String restaurantId, int currentQuantity) {
    if (currentQuantity <= 0) {
      return true; // Allow decrement
    }
    
    if (!isPromotionalAvailable(productId, restaurantId)) {
      return false;
    }
    
    final limit = getPromotionalLimit(productId, restaurantId);
    return currentQuantity <= limit;
  }

  /// **CLEAR CACHE FOR RESTAURANT**
  static void clearRestaurantCache(String restaurantId) {
    _restaurantCacheLoaded[restaurantId] = false;
    
    // Remove all cached items for this restaurant
    final keysToRemove = <String>[];
    for (final key in _promotionalCache.keys) {
      if (key.endsWith('-$restaurantId')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _promotionalCache.remove(key);
      _promotionalLimits.remove(key);
      _promotionalAvailability.remove(key);
    }
    
    print('DEBUG: Cleared promotional cache for restaurant: $restaurantId');
  }

  /// **CLEAR ALL CACHE**
  static void clearAllCache() {
    _promotionalCache.clear();
    _promotionalLimits.clear();
    _promotionalAvailability.clear();
    _restaurantCacheLoaded.clear();
    print('DEBUG: Cleared all promotional cache');
  }

  /// **GET CACHE STATS**
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedItems': _promotionalCache.length,
      'loadedRestaurants': _restaurantCacheLoaded.keys.toList(),
      'cacheKeys': _promotionalCache.keys.toList(),
    };
  }
}
