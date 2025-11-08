import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/utils/fire_store_utils.dart';

class PromotionDebugUtils {
  /// Test specific promotion data
  static Future<void> testSpecificPromotion({
    required String productId,
    required String restaurantId,
    required String promotionId,
  }) async {
    print('\n🔍 ===== PROMOTION DEBUG TEST START =====');
    print('Product ID: $productId');
    print('Restaurant ID: $restaurantId');
    print('Promotion ID: $promotionId');
    print('==========================================\n');

    try {
      // 1. Test product data
      await _testProductData(productId, restaurantId);
      
      // 2. Test promotion data
      await _testPromotionData(promotionId, productId, restaurantId);
      
      // 3. Test restaurant data
      await _testRestaurantData(restaurantId);
      
      // 4. Test active promotions query
      await _testActivePromotionsQuery();
      
      // 5. Test specific promotion lookup
      await _testSpecificPromotionLookup(productId, restaurantId);
      
      // 6. Test cache clearing
      await _testCacheClearing();
      
    } catch (e) {
      print('❌ ERROR during promotion debug test: $e');
    }
    
    print('\n🔍 ===== PROMOTION DEBUG TEST END =====\n');
  }

  static Future<void> _testProductData(String productId, String restaurantId) async {
    print('📦 Testing Product Data...');
    
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('vendor_products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        final data = productDoc.data()!;
        print('✅ Product exists');
        print('   - Name: ${data['name']}');
        print('   - Publish: ${data['publish']}');
        print('   - isAvailable: ${data['isAvailable']}');
        print('   - vendorID: ${data['vendorID']}');
        print('   - Price: ${data['price']}');
        print('   - Category ID: ${data['categoryID']}');
        
        // Check if vendorID matches
        if (data['vendorID'] == restaurantId) {
          print('✅ Product vendorID matches restaurant ID');
        } else {
          print('❌ Product vendorID mismatch: expected $restaurantId, got ${data['vendorID']}');
        }
        
        // Check if product is published
        if (data['publish'] == true) {
          print('✅ Product is published');
        } else {
          print('❌ Product is not published');
        }
        
        // Check if product is available
        if (data['isAvailable'] == true) {
          print('✅ Product is available');
        } else {
          print('❌ Product is not available');
        }
      } else {
        print('❌ Product does not exist!');
      }
    } catch (e) {
      print('❌ Error testing product data: $e');
    }
    print('');
  }

  static Future<void> _testPromotionData(String promotionId, String productId, String restaurantId) async {
    print('🎯 Testing Promotion Data...');
    
    try {
      final promotionDoc = await FirebaseFirestore.instance
          .collection('promotions')
          .doc(promotionId)
          .get();
      
      if (promotionDoc.exists) {
        final data = promotionDoc.data()!;
        print('✅ Promotion exists');
        print('   - product_id: ${data['product_id']}');
        print('   - restaurant_id: ${data['restaurant_id']}');
        print('   - isAvailable: ${data['isAvailable']}');
        print('   - special_price: ${data['special_price']}');
        print('   - start_time: ${data['start_time']}');
        print('   - end_time: ${data['end_time']}');
        print('   - item_limit: ${data['item_limit']}');
        
        // Check IDs match
        if (data['product_id'] == productId) {
          print('✅ Promotion product_id matches');
        } else {
          print('❌ Promotion product_id mismatch: expected $productId, got ${data['product_id']}');
        }
        
        if (data['restaurant_id'] == restaurantId) {
          print('✅ Promotion restaurant_id matches');
        } else {
          print('❌ Promotion restaurant_id mismatch: expected $restaurantId, got ${data['restaurant_id']}');
        }
        
        // Check availability
        if (data['isAvailable'] == true) {
          print('✅ Promotion is available');
        } else {
          print('❌ Promotion is not available');
        }
        
        // Check timing
        final now = Timestamp.now();
        final startTime = data['start_time'] as Timestamp;
        final endTime = data['end_time'] as Timestamp;
        
        print('   - Current time: ${now.toDate()}');
        print('   - Start time: ${startTime.toDate()}');
        print('   - End time: ${endTime.toDate()}');
        
        if (startTime.compareTo(now) <= 0) {
          print('✅ Promotion has started');
        } else {
          print('❌ Promotion has not started yet');
        }
        
        if (endTime.compareTo(now) >= 0) {
          print('✅ Promotion has not ended');
        } else {
          print('❌ Promotion has ended');
        }
        
      } else {
        print('❌ Promotion does not exist!');
      }
    } catch (e) {
      print('❌ Error testing promotion data: $e');
    }
    print('');
  }

  static Future<void> _testRestaurantData(String restaurantId) async {
    print('🏪 Testing Restaurant Data...');
    
    try {
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(restaurantId)
          .get();
      
      if (restaurantDoc.exists) {
        final data = restaurantDoc.data()!;
        print('✅ Restaurant exists');
        print('   - Name: ${data['title']}');
        print('   - isOpen: ${data['isOpen']}');
        print('   - isPublish: ${data['isPublish']}');
        
        if (data['isOpen'] == true) {
          print('✅ Restaurant is open');
        } else {
          print('❌ Restaurant is closed');
        }
        
        if (data['isPublish'] == true) {
          print('✅ Restaurant is published');
        } else {
          print('❌ Restaurant is not published');
        }
      } else {
        print('❌ Restaurant does not exist!');
      }
    } catch (e) {
      print('❌ Error testing restaurant data: $e');
    }
    print('');
  }

  static Future<void> _testActivePromotionsQuery() async {
    print('🔍 Testing Active Promotions Query...');
    
    try {
      final promotions = await FireStoreUtils.fetchActivePromotions();
      print('✅ Active promotions query successful');
      print('   - Total active promotions: ${promotions.length}');
      
      for (int i = 0; i < promotions.length; i++) {
        final promo = promotions[i];
        print('   - Promotion $i: product_id=${promo['product_id']}, restaurant_id=${promo['restaurant_id']}, isAvailable=${promo['isAvailable']}');
      }
    } catch (e) {
      print('❌ Error testing active promotions query: $e');
    }
    print('');
  }

  static Future<void> _testSpecificPromotionLookup(String productId, String restaurantId) async {
    print('🎯 Testing Specific Promotion Lookup...');
    
    try {
      final promotion = await FireStoreUtils.getActivePromotionForProduct(
        productId: productId,
        restaurantId: restaurantId,
      );
      
      if (promotion != null) {
        print('✅ Specific promotion lookup successful');
        print('   - special_price: ${promotion['special_price']}');
        print('   - item_limit: ${promotion['item_limit']}');
        print('   - isAvailable: ${promotion['isAvailable']}');
      } else {
        print('❌ Specific promotion lookup returned null');
      }
    } catch (e) {
      print('❌ Error testing specific promotion lookup: $e');
    }
    print('');
  }

  static Future<void> _testCacheClearing() async {
    print('🗑️ Testing Cache Clearing...');
    
    try {
      await FireStoreUtils.clearPromotionalCache();
      print('✅ Cache clearing successful');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
    print('');
  }

  /// Quick test for the specific promotion mentioned in the issue
  static Future<void> testRayalaseemaBiryaniPromotion() async {
    await testSpecificPromotion(
      productId: "E5uQMHSJY9hj9yD5NTp3",
      restaurantId: "0qa2SpBLu36nvp17qd1m",
      promotionId: "fDjQ4B9cwtaM8ta7Z9F3",
    );
  }

  /// Test all promotions for a specific restaurant
  static Future<void> testAllPromotionsForRestaurant(String restaurantId) async {
    print('\n🔍 ===== TESTING ALL PROMOTIONS FOR RESTAURANT =====');
    print('Restaurant ID: $restaurantId');
    print('==================================================\n');

    try {
      final promotions = await FireStoreUtils.fetchActivePromotions();
      final restaurantPromotions = promotions.where((p) => p['restaurant_id'] == restaurantId).toList();
      
      print('Found ${restaurantPromotions.length} active promotions for restaurant $restaurantId');
      
      for (int i = 0; i < restaurantPromotions.length; i++) {
        final promo = restaurantPromotions[i];
        print('\n--- Promotion ${i + 1} ---');
        print('Product ID: ${promo['product_id']}');
        print('Restaurant ID: ${promo['restaurant_id']}');
        print('Special Price: ${promo['special_price']}');
        print('Is Available: ${promo['isAvailable']}');
        print('Start Time: ${promo['start_time']}');
        print('End Time: ${promo['end_time']}');
        print('Item Limit: ${promo['item_limit']}');
      }
    } catch (e) {
      print('❌ Error testing all promotions for restaurant: $e');
    }
    
    print('\n🔍 ===== TESTING ALL PROMOTIONS FOR RESTAURANT END =====\n');
  }
}
