import 'dart:async';
import 'dart:developer';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/AttributesModel.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/services/promotional_cache_service.dart';
import 'package:customer/utils/cache_manager.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/performance_monitor.dart';
import 'package:customer/utils/restaurant_status_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantDetailsController extends GetxController {
  final String? scrollToProductId;

  RestaurantDetailsController({this.scrollToProductId});
  RxInt selectedCategoryIndex = 0.obs;
  //New Logic
  RxList<ProductModel> filteredProductList = <ProductModel>[].obs;
  // RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  bool productsLoading = false;
  void productLoadingFunction(bool value) {
    productsLoading = value;
    update();
  }

  final ScrollController scrollControllerProduct = ScrollController();
// In RestaurantDetailsController
  final Map<String, GlobalKey> categoryKeys = {};

  String getCategoryKey(int index) {
    return 'category_$index';
  }

// Improved scrollToCategory method
  void scrollToCategory(int index) {
    if (!scrollControllerProduct.hasClients) {
      print("DEBUG: Scroll controller not attached yet");
      return;
    }

    // Wait for the next frame to ensure UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final categoryKey = getCategoryKey(index);

        if (categoryKeys.containsKey(categoryKey)) {
          final key = categoryKeys[categoryKey]!;
          final context = key.currentContext;

          if (context != null) {
            // Use Scrollable.ensureVisible for precise scrolling
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.1, // Scroll to 10% from top for better visibility
            );

            print("DEBUG: Successfully scrolled to category $index");
          } else {
            print("DEBUG: Context is null for category $index");
            // Fallback to manual scrolling
            _fallbackScrollToCategory(index);
          }
        } else {
          print("DEBUG: Category key not found for index $index");
          _fallbackScrollToCategory(index);
        }
      } catch (e) {
        print("DEBUG: Error scrolling to category: $e");
        _fallbackScrollToCategory(index);
      }
    });
  }

// Fallback method for manual scrolling
  void _fallbackScrollToCategory(int index) {
    try {
      double estimatedPosition = 0.0;

      // Estimate position based on previous categories
      for (int i = 0; i < index; i++) {
        if (i < vendorCategoryList.length) {
          final categoryId = vendorCategoryList[i].id.toString();
          final productCount = getProductsByCategory(categoryId).length;
          // More accurate estimation
          estimatedPosition += 80.0 + (productCount * 140.0) + 20.0;
        }
      }

      print(
          "DEBUG: Fallback scrolling to category $index at position $estimatedPosition");

      scrollControllerProduct.animateTo(
        estimatedPosition,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      print("DEBUG: Error in fallback scroll: $e");
    }
  }

  List<ProductModel> getProductsByCategory(String categoryId) {
    return categoryProductsMap[categoryId] ?? [];
  }

  Map<String, List<ProductModel>> categoryProductsMap = {};

// Also update the getProductList method to ensure categories are properly loaded
  Future<void> getProductList() async {
    try {
      print(" getProductList called, total products: ${productList.length}");

      // Clear existing data
      vendorCategoryList.clear();
      categoryProductsMap.clear();
      categoryKeys.clear();

      for (var product in productList) {
        // Skip if product has no category
        if (product.categoryID == null || product.categoryID!.isEmpty) continue;

        // Check if we already have the category
        bool alreadyExists = vendorCategoryList
            .any((cat) => cat.id.toString() == product.categoryID.toString());

        if (!alreadyExists) {
          // Fetch category from Firebase
          var category = await FireStoreUtils.getVendorCategoryByCategoryId(
            product.categoryID.toString(),
          );

          if (category != null) {
            vendorCategoryList.add(category);
            // Initialize key for this category
            final categoryKey = getCategoryKey(vendorCategoryList.length - 1);
            categoryKeys[categoryKey] = GlobalKey();
            print(
                "Added new category: ${category.title} (${vendorCategoryList.length} total)");
          }
        }

        // Group products under the categoryID
        if (!categoryProductsMap.containsKey(product.categoryID)) {
          categoryProductsMap[product.categoryID.toString()] = [];
        }
        categoryProductsMap[product.categoryID.toString()]!.add(product);
      }

      productLoadingFunction(false);
      update();
    } catch (e) {
      productLoadingFunction(false);
      log("Error in getProductList: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Failed to load products");
    }
  }
  // Future<void> getProductList() async {
  //   try {
  //     print(" getProductList called, total products: ${productList.length}");
  //     for (var product in productList) {
  //       // Skip if product has no category
  //       if (product.categoryID == null || product.categoryID!.isEmpty) continue;
  //
  //       // Check if we already have the category
  //       bool alreadyExists = vendorCategoryList
  //           .any((cat) => cat.id.toString() == product.categoryID.toString());
  //
  //       if (!alreadyExists) {
  //         // Fetch category from Firebase
  //         var category = await FireStoreUtils.getVendorCategoryByCategoryId(
  //           product.categoryID.toString(),
  //         );
  //
  //         if (category != null) {
  //           vendorCategoryList.add(category);
  //           print(
  //               "Added new category: ${category.title} (${vendorCategoryList.length} total)");
  //         }
  //       }
  //
  //       // Group products under the categoryID
  //       if (!categoryProductsMap.containsKey(product.categoryID)) {
  //         categoryProductsMap[product.categoryID.toString()] = [];
  //       }
  //       categoryProductsMap[product.categoryID.toString()]!.add(product);
  //     }
  //
  //     productLoadingFunction(false);
  //     update();
  //   } catch (e) {
  //     productLoadingFunction(false);
  //     log("Error in getProductList: $e");
  //     ShowToastDialog.closeLoader();
  //     ShowToastDialog.showToast("Failed to load products");
  //   }
  // }

  /// Get restaurant by ID for deep linking
  Future<VendorModel?> getRestaurantById(String restaurantId) async {
    try {
      print(
          '[RESTAURANT CONTROLLER] 🔍 Fetching restaurant by ID: $restaurantId');

      // Query Firestore for restaurant by ID
      final doc = await FireStoreUtils.getVendorById(restaurantId);

      if (doc != null) {
        print('[RESTAURANT CONTROLLER] ✅ Restaurant found: ${doc.title}');
        return doc;
      } else {
        print('[RESTAURANT CONTROLLER] ❌ Restaurant not found: $restaurantId');
        return null;
      }
    } catch (e) {
      print('[RESTAURANT CONTROLLER] ❌ Error fetching restaurant by ID: $e');
      return null;
    }
  }

  Rx<TextEditingController> searchEditingController =
      TextEditingController().obs;

  RxBool isLoading = true.obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;

  RxBool isVag = false.obs;
  RxBool isNonVag = false.obs;
  RxBool isOfferFilter = false.obs;
  RxBool isMenuOpen = false.obs;

  // Scroll controller for scrolling to specific product
  Rx<ScrollController> scrollController = ScrollController().obs;
  RxBool shouldScrollToProduct = false.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> allProductList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;

  RxList<CouponModel> couponList = <CouponModel>[].obs;

  // **ENHANCED CACHE FOR FASTER FILTERING**
  Map<String, List<ProductModel>> _productsByCategory = {};

  @override
  void onInit() {
    getArgument();
    super.onInit();

    // If we need to scroll to a specific product, set the flag
    if (scrollToProductId != null) {
      shouldScrollToProduct.value = true;
    }
  }

  /// **DEEP LINK UPDATE METHOD**
  ///
  /// Updates restaurant data when new deep links come in
  /// This ensures UI refreshes even when controller is already in memory
  void updateRestaurant(VendorModel newRestaurant) {
    print(
        '[RESTAURANT CONTROLLER] 🔄 Updating with new restaurant: ${newRestaurant.title}');
    print(
        '[RESTAURANT CONTROLLER] 🔄 Previous restaurant: ${vendorModel.value.title}');
    print('[RESTAURANT CONTROLLER] 🔄 New restaurant ID: ${newRestaurant.id}');
    print(
        '[RESTAURANT CONTROLLER] 🔄 Previous restaurant ID: ${vendorModel.value.id}');

    // Update the vendor model directly
    vendorModel.value = newRestaurant;
    print('[RESTAURANT CONTROLLER] 🔄 Vendor model updated');

    // **CRITICAL FIX: Clear promotional cache for new restaurant**
    PromotionalCacheService.clearRestaurantCache(vendorModel.value.id ?? '');
    _promotionalCacheLoaded = false;
    print(
        '[RESTAURANT CONTROLLER] 🔄 Cleared promotional cache for new restaurant');

    // Reset loading state
    isLoading.value = true;
    print('[RESTAURANT CONTROLLER] 🔄 Loading state set to true');

    // Reload all data for the new restaurant
    _loadCriticalDataInParallel().then((_) async {
      // **CRITICAL FIX: Reload promotional cache for new restaurant**
      await _loadPromotionalCache();
      isLoading.value = false;
      update(); // Force UI refresh
      print(
          '[RESTAURANT CONTROLLER] ✅ Restaurant updated successfully: ${newRestaurant.title}');
      print('[RESTAURANT CONTROLLER] ✅ UI refresh triggered');
    }).catchError((error) {
      print('[RESTAURANT CONTROLLER] ❌ Error updating restaurant: $error');
      isLoading.value = false;
    });
  }

  void animateSlider() {
    if (vendorModel.value.photos != null &&
        vendorModel.value.photos!.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        // Check if controller is still valid and widget is mounted
        if (!Get.isRegistered<RestaurantDetailsController>() ||
            !pageController.value.hasClients) {
          timer.cancel();
          return;
        }

        if (currentPage < vendorModel.value.photos!.length - 1) {
          currentPage++;
        } else {
          currentPage.value = 0;
        }

        // Only animate if attached
        try {
          if (pageController.value.hasClients) {
            pageController.value.animateToPage(
              currentPage.value,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        } catch (e) {
          // If any error occurs, cancel the timer
          timer.cancel();
        }
      });
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  final CartProvider cartProvider = CartProvider();

  // **ULTRA-FAST PROMOTIONAL DATA CACHE FOR INSTANT BUTTON RESPONSE**
  Map<String, Map<String, dynamic>> _promotionalCache = {};
  Map<String, int> _promotionalLimits = {}; // Pre-calculated limits
  Map<String, bool> _promotionalAvailability =
      {}; // Pre-calculated availability
  bool _promotionalCacheLoaded = false;

  // **ULTRA-FAST METHOD TO LOAD AND PRE-CALCULATE ALL PROMOTIONAL DATA (OPTIMIZED)**
  Future<void> _loadPromotionalCache() async {
    if (_promotionalCacheLoaded) {
      print('DEBUG: Promotional cache already loaded');
      return;
    }

    try {
      print('DEBUG: Loading promotional cache using shared service...');

      // **PERFORMANCE FIX: Use shared promotional cache service**
      await PromotionalCacheService.loadRestaurantPromotions(
          vendorModel.value.id ?? '');

      _promotionalCacheLoaded = true;
      print('DEBUG: Promotional cache loaded successfully');

      // **CRITICAL FIX: Force UI update after cache is loaded**
      update();
    } catch (e) {
      print('DEBUG: Error loading promotional cache: $e');
      _promotionalCacheLoaded = false;
    }
  }

  // **INSTANT METHOD TO GET CACHED PROMOTIONAL DATA (ZERO ASYNC)**
  Map<String, dynamic>? _getCachedPromotionalData(
      String productId, String restaurantId) {
    // **PERFORMANCE FIX: Use shared promotional cache service**
    return PromotionalCacheService.getCachedPromotionalData(
        productId, restaurantId);
  }

  // **INSTANT METHOD TO CHECK PROMOTIONAL AVAILABILITY (ZERO ASYNC)**
  bool _isPromotionalAvailable(String productId, String restaurantId) {
    // **PERFORMANCE FIX: Use shared promotional cache service**
    return PromotionalCacheService.isPromotionalAvailable(
        productId, restaurantId);
  }

  // **INSTANT METHOD TO GET PROMOTIONAL LIMIT (ZERO ASYNC)**
  int _getPromotionalLimit(String productId, String restaurantId) {
    // **PERFORMANCE FIX: Use shared promotional cache service**
    return PromotionalCacheService.getPromotionalLimit(productId, restaurantId);
  }

  // **METHOD TO CHECK IF CART HAS PROMOTIONAL ITEMS**
  bool hasPromotionalItems() {
    return cartItem
        .any((item) => item.promoId != null && item.promoId!.isNotEmpty);
  }

  // **ULTRA-FAST METHOD TO GET PROMOTIONAL ITEM LIMIT (ZERO ASYNC)**
  int? getPromotionalItemLimit(String productId, String restaurantId) {
    if (!_isPromotionalAvailable(productId, restaurantId)) {
      return null;
    }
    final limit = _getPromotionalLimit(productId, restaurantId);
    return limit > 0 ? limit : null;
  }

  // **ULTRA-FAST METHOD TO CHECK IF PROMOTIONAL ITEM QUANTITY IS WITHIN LIMIT (ZERO ASYNC)**
  bool isPromotionalItemQuantityAllowed(
      String productId, String restaurantId, int currentQuantity) {
    if (currentQuantity <= 0) {
      return true; // Allow decrement
    }

    if (!_isPromotionalAvailable(productId, restaurantId)) {
      return false;
    }

    final limit = _getPromotionalLimit(productId, restaurantId);
    return currentQuantity <= limit;
  }

  bool isLoadingAddButton = false;

  // **ULTRA-FAST METHOD TO GET ACTIVE PROMOTION WITH LAZY LOADING**
  Map<String, dynamic>? getActivePromotionForProduct({
    required String productId,
    required String restaurantId,
  }) {
    // **LAZY LOADING: Check if cache is loaded, if not trigger background load**
    if (!_promotionalCacheLoaded) {
      _loadPromotionalCache(); // **BACKGROUND LOADING: Non-blocking**
    }

    // Use cached data instead of Firebase query - INSTANT RESPONSE
    final promo = _getCachedPromotionalData(productId, restaurantId);

    // **DEBUG: Log promotional data access for troubleshooting**
    if (kDebugMode) {
      print('[DEBUG] getActivePromotionForProduct called:');
      print('[DEBUG] - Product ID: $productId');
      print('[DEBUG] - Restaurant ID: $restaurantId');
      print('[DEBUG] - Cache loaded: $_promotionalCacheLoaded');
      print('[DEBUG] - Promo found: ${promo != null}');
      if (promo != null) {
        print('[DEBUG] - Promo data: $promo');
      }
    }

    return promo;
  }

  /// **OPTIMIZED PARALLEL DATA LOADING ARCHITECTURE**
  ///
  /// Loads all data in parallel for maximum performance:
  /// 1. Critical data (products, categories, favorites) - parallel
  /// 2. Secondary data (coupons, attributes, promotional) - parallel
  /// 3. Background data (promotional testing) - non-blocking
  Future<void> getArgument() async {
    // PerformanceMonitor.startTiming('totalScreenLoad');

    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );

    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }

    animateSlider();
    statusCheck();

    // **STEP 1: Load critical data in parallel (products, categories, favorites)**
    await _loadCriticalDataInParallel();

    // **STEP 2: Mark screen as ready immediately**
    isLoading.value = false;
    update();

    // **STEP 3: Load secondary data in parallel (non-blocking)**
    _loadSecondaryDataInParallel();

    // **STEP 4: Load promotional cache in parallel with secondary data (non-blocking)**
    _loadPromotionalCache(); // **ULTRA-FAST: Non-blocking parallel loading**

    // PerformanceMonitor.endTiming('totalScreenLoad');
  }

  /// **PARALLEL CRITICAL DATA LOADING**
  ///
  /// Loads products, categories, and favorites simultaneously
  Future<void> _loadCriticalDataInParallel() async {
    return await PerformanceMonitor.monitorOperation(
      'loadCriticalDataInParallel',
      () async {
        print("DEBUG: Starting parallel critical data loading");
        // Load products, categories, and favorites in parallel
        productLoadingFunction(true);
        await Future.wait([
          _loadProducts(),
          // _loadCategories(),
          _loadFavorites(),
        ]);
        getProductList();
        // Build product cache after both products and categories are loaded
        _buildProductCache();
        print(
            "DEBUG: Cache built with ${_productsByCategory.length} categories");

        print("DEBUG: Parallel critical data loading completed");
      },
    );
  }

  /// **PARALLEL SECONDARY DATA LOADING**
  ///
  /// Loads coupons, attributes, and other secondary data in parallel
  void _loadSecondaryDataInParallel() async {
    try {
      await PerformanceMonitor.monitorOperation(
        'loadSecondaryDataInParallel',
        () async {
          print("DEBUG: Starting parallel secondary data loading");

          if (Constant.userModel != null) {
            // Load coupons and attributes in parallel
            await Future.wait([
              _loadCoupons(),
              _loadAttributes(),
            ]);
          } else {
            // Load only attributes if user not logged in
            await _loadAttributes();
          }

          print("DEBUG: Parallel secondary data loading completed");
          update();
        },
      );
    } catch (e) {
      print("DEBUG: Secondary data loading failed (non-critical): $e");
    }
  }

  /// **OPTIMIZED PRODUCT LOADING**
  Future<void> _loadProducts() async {
    return await PerformanceMonitor.monitorOperation(
      'loadProducts',
      () async {
        print("DEBUG: Loading products for vendor: ${vendorModel.value.id}");

        // Check cache first with enhanced validation
        final cacheKey = 'products_${vendorModel.value.id}';
        final cachedProducts =
            await CacheManager.get<List<ProductModel>>(cacheKey);

        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          // PerformanceMonitor.recordCacheHit(cacheKey);
          allProductList.value = cachedProducts;
          productList.value = cachedProducts;

          // **APPLY SMART SORTING AFTER LOADING FROM CACHE**
          _applySmartSorting();

          print("DEBUG: Using cached products: ${cachedProducts.length} items");
        } else {
          // Cache miss or empty - clear potentially corrupted cache
          if (cachedProducts != null && cachedProducts.isEmpty) {
            print("DEBUG: Clearing empty cached products for key: $cacheKey");
            CacheManager.clear(cacheKey);
          }
          // PerformanceMonitor.recordCacheMiss(cacheKey);

          // **SINGLE QUERY FOR ALL PRODUCTS**
          final products = await FireStoreUtils.getProductByVendorId(
              vendorModel.value.id.toString());
          print("DEBUG: Loaded ${products.length} products");
          if ((Constant.isSubscriptionModelApplied == true ||
                  Constant.adminCommission?.isEnabled == true) &&
              vendorModel.value.subscriptionPlan != null) {
            if (vendorModel.value.subscriptionPlan?.itemLimit == '-1') {
              allProductList.value = products;
              productList.value = products;
            } else {
              int selectedProduct = products.length <
                      int.parse(
                          vendorModel.value.subscriptionPlan?.itemLimit ?? '0')
                  ? (products.isEmpty ? 0 : (products.length))
                  : int.parse(
                      vendorModel.value.subscriptionPlan?.itemLimit ?? '0');
              allProductList.value = products.sublist(0, selectedProduct);
              productList.value = products.sublist(0, selectedProduct);
            }
          } else {
            allProductList.value = products;
            productList.value = products;
          }

          // **APPLY SMART SORTING AFTER LOADING**
          _applySmartSorting();

          // Cache the products
          await CacheManager.setProductData(cacheKey, productList);
          print("DEBUG: Cached ${productList.length} products");
        }

        print("DEBUG: Final product list has ${productList.length} items");

        // DEBUG: Cache diagnostics for testing
        if (kDebugMode) {
          await _logCacheDiagnostics();
        }

        // Scroll to specific product if needed
        if (scrollToProductId != null) {
          scrollToProductAfterLoad();
        }
      },
    );
  }

  /// **OPTIMIZED CATEGORY LOADING**
  Future<void> _loadCategories() async {
    return await PerformanceMonitor.monitorOperation(
      'loadCategories',
      () async {
        final cacheKey = 'categories_${vendorModel.value.id}';
        final cachedCategories =
            await CacheManager.get<List<VendorCategoryModel>>(cacheKey);

        if (cachedCategories != null) {
          // PerformanceMonitor.recordCacheHit(cacheKey);
          vendorCategoryList.value = cachedCategories;
          print(
              "DEBUG: Using cached categories: ${cachedCategories.length} items");
        } else {
          // PerformanceMonitor.recordCacheMiss(cacheKey);

          // **SINGLE QUERY FOR ALL CATEGORIES**
          final categories = await FireStoreUtils.getAllVendorCategories(
              vendorModel.value.id.toString());
          print(
              "DEBUG: Loaded  categories ${vendorModel.value.id.toString()} ${categories.length} categories");

          // Set categories directly instead of fetching one by one
          vendorCategoryList.value = categories;
          print("DEBUG: Using  categories: ${vendorCategoryList.length} items");
          // Cache the categories
          await CacheManager.setProductData(cacheKey, categories);
          print("DEBUG: Cached ${categories.length} categories");
        }
      },
    );
  }

  /// **OPTIMIZED FAVORITES LOADING**
  Future<void> _loadFavorites() async {
    return await PerformanceMonitor.monitorOperation(
      'loadFavorites',
      () async {
        if (Constant.userModel != null) {
          print("DEBUG: Loading favorites for user");

          // Load favorite restaurants and items in parallel
          await Future.wait([
            FireStoreUtils.getFavouriteRestaurant().then((value) {
              favouriteList.value = value;
              print("DEBUG: Loaded ${value.length} favorite restaurants");
            }),
            FireStoreUtils.getFavouriteItem().then((value) {
              favouriteItemList.value = value;
              print("DEBUG: Loaded ${value.length} favorite items");
            }),
          ]);
        } else {
          print("DEBUG: No user logged in, skipping favorites");
        }
      },
    );
  }

  /// **OPTIMIZED COUPONS LOADING**
  Future<void> _loadCoupons() async {
    return await PerformanceMonitor.monitorOperation(
      'loadCoupons',
      () async {
        print("DEBUG: Loading coupons");

        // Load vendor-specific and global coupons in parallel
        await Future.wait([
          FireStoreUtils.getOfferByVendorId(vendorModel.value.id.toString())
              .then((value) {
            couponList.value = value;
            print("DEBUG: Loaded ${value.length} vendor coupons");
          }),
          FireStoreUtils.getHomeCoupon().then((globalCoupons) {
            final filteredGlobalCoupons = globalCoupons
                .where((c) =>
                    c.resturantId == null ||
                    c.resturantId == '' ||
                    c.resturantId?.toUpperCase() == 'ALL')
                .toList();
            couponList.addAll(filteredGlobalCoupons
                .where((g) => !couponList.any((c) => c.id == g.id)));
            print(
                "DEBUG: Loaded ${filteredGlobalCoupons.length} global coupons");
          }),
        ]);

        print("DEBUG: Total coupons loaded: ${couponList.length}");
      },
    );
  }

  /// **OPTIMIZED ATTRIBUTES LOADING**
  Future<void> _loadAttributes() async {
    return await PerformanceMonitor.monitorOperation(
      'loadAttributes',
      () async {
        print("DEBUG: Loading attributes");
        await FireStoreUtils.getAttributes().then((value) {
          if (value != null) {
            attributesList.value = value;
            print("DEBUG: Loaded ${value.length} attributes");
          }
        });
      },
    );
  }

  /// **TEST METHOD TO VERIFY PROMOTIONAL DATA FETCHING**
  Future<void> testPromotionalDataFetching() async {
    return await PerformanceMonitor.monitorOperation(
      'testPromotionalDataFetching',
      () async {
        print('DEBUG: Testing promotional data fetching...');

        // Test with a sample product ID (you can replace this with an actual product ID)
        final testProductId =
            "TgogRU5rLNmkoO4Cz1d5"; // Your promotional product ID
        final testRestaurantId = vendorModel.value.id ?? '';

        print('DEBUG: Testing with product ID: $testProductId');
        print('DEBUG: Testing with restaurant ID: $testRestaurantId');

        final promo = await FireStoreUtils.getActivePromotionForProduct(
          productId: testProductId,
          restaurantId: testRestaurantId,
        );

        if (promo != null) {
          print('DEBUG: ✅ Promotional data found:');
          print('DEBUG: - item_limit: ${promo['item_limit']}');
          print('DEBUG: - special_price: ${promo['special_price']}');
          print('DEBUG: - free_delivery_km: ${promo['free_delivery_km']}');
          print('DEBUG: - extra_km_charge: ${promo['extra_km_charge']}');
          print('DEBUG: - start_time: ${promo['start_time']}');
          print('DEBUG: - end_time: ${promo['end_time']}');
          print('DEBUG: - isAvailable: ${promo['isAvailable']}');
        } else {
          print(
              'DEBUG: ❌ No promotional data found for product: $testProductId');
        }
      },
    );
  }

  /// **SMART PRODUCT CACHING SYSTEM**
  ///
  /// Builds cache for instant category filtering
  void _buildProductCache() {
    _productsByCategory.clear();
    for (var product in productList) {
      final categoryId = product.categoryID.toString();
      if (!_productsByCategory.containsKey(categoryId)) {
        _productsByCategory[categoryId] = [];
      }
      _productsByCategory[categoryId]!.add(product);
    }
  }

  /// **INSTANT CATEGORY FILTERING**
  ///
  /// Returns products by category from cache (no database queries)
  // List<ProductModel> getProductsByCategory(String categoryId) {
  //   return _productsByCategory[categoryId] ?? [];
  // }

  searchProduct(String name) {
    if (name.isEmpty) {
      productList.clear();
      productList.addAll(allProductList);
      _applySmartSorting(); // Apply smart sorting after resetting
    } else {
      isVag.value = false;
      isNonVag.value = false;
      isOfferFilter.value = false;
      productList.value = allProductList
          .where((p0) => p0.name!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    update();
  }

  filterRecord() {
    List<ProductModel> filteredList = [];

    if (isVag.value == true && isNonVag.value == true) {
      filteredList = allProductList
          .where((p0) => p0.nonveg == true || p0.nonveg == false)
          .toList();
    } else if (isVag.value == true && isNonVag.value == false) {
      filteredList = allProductList.where((p0) => p0.nonveg == false).toList();
    } else if (isVag.value == false && isNonVag.value == true) {
      filteredList = allProductList.where((p0) => p0.nonveg == true).toList();
    } else if (isVag.value == false && isNonVag.value == false) {
      filteredList = allProductList
          .where((p0) => p0.nonveg == true || p0.nonveg == false)
          .toList();
    }

    // Apply offer filter if enabled
    if (isOfferFilter.value) {
      filteredList =
          filteredList.where((product) => _isPromotionalItem(product)).toList();
    }

    productList.value = filteredList;
    _applySmartSorting();
  }

  Future<List<ProductModel>> getProductByCategory(
      VendorCategoryModel vendorCategoryModel) async {
    return productList
        .where((p0) => p0.categoryID == vendorCategoryModel.id)
        .toList();
  }

  /// **ULTRA-FAST PROMOTIONAL ITEM DETECTION**
  ///
  /// Uses cached promotional data for instant detection without Firebase queries
  bool _isPromotionalItem(ProductModel product) {
    final productId = product.id ?? '';
    final restaurantId = vendorModel.value.id ?? '';

    // **PERFORMANCE FIX: Use cached promotional data (instant)**
    final hasPromotion = _isPromotionalAvailable(productId, restaurantId);

    if (hasPromotion) {
      return true;
    }

    // **FALLBACK: Check for price-based promotional items**
    final priceValue = double.tryParse(product.price ?? '0') ?? 0.0;
    final discountPriceValue = double.tryParse(product.disPrice ?? '0') ?? 0.0;

    // Consider it promotional if there's a discount price lower than regular price
    return priceValue > 0 &&
        discountPriceValue > 0 &&
        priceValue < discountPriceValue;
  }

  /// **SMART SORTING SYSTEM**
  ///
  /// Sorts items in this order for optimal user experience:
  /// 1. Promotional items (on top)
  /// 2. Available regular items
  /// 3. Unavailable items (at bottom)
  void _applySmartSorting() {
    if (isOfferFilter.value) {
      // When offer filter is active, show only promotional items
      return;
    }

    // Sort products for better user experience
    productList.sort((a, b) {
      // 1. Check promotional status
      final aIsPromotional = _isPromotionalItem(a);
      final bIsPromotional = _isPromotionalItem(b);

      if (aIsPromotional && !bIsPromotional) return -1; // a comes first
      if (!aIsPromotional && bIsPromotional) return 1; // b comes first

      // 2. If both have same promotional status, check availability
      final aIsAvailable = a.isAvailable ?? true;
      final bIsAvailable = b.isAvailable ?? true;

      if (aIsAvailable && !bIsAvailable) return -1; // a comes first
      if (!aIsAvailable && bIsAvailable) return 1; // b comes first

      // 3. If both have same promotional status and availability, sort by name
      return (a.name ?? '').compareTo(b.name ?? '');
    });
  }

  /// **OFFER FILTER TOGGLE METHOD**
  void toggleOfferFilter() {
    isOfferFilter.value = !isOfferFilter.value;

    // Reset other filters when offer filter is activated
    if (isOfferFilter.value) {
      isVag.value = false;
      isNonVag.value = false;
    }

    filterRecord();
  }

  /// **CLEAR ALL FILTERS METHOD**
  void clearAllFilters() {
    try {
      // Reset all filter states with safety checks
      if (isVag.value != null) isVag.value = false;
      if (isNonVag.value != null) isNonVag.value = false;
      if (isOfferFilter.value != null) isOfferFilter.value = false;

      // Clear search text with safety check
      if (searchEditingController.value != null) {
        searchEditingController.value.clear();
      }

      // Reset product list to show all products with safety checks
      if (productList.isNotEmpty) {
        productList.clear();
      }
      if (allProductList.isNotEmpty) {
        productList.addAll(allProductList);
      }

      // Apply smart sorting with safety check
      try {
        _applySmartSorting();
      } catch (e) {
        print('Error applying smart sorting: $e');
      }

      // Update UI with safety check
      try {
        update();
      } catch (e) {
        print('Error updating UI: $e');
      }
    } catch (e) {
      print('Error in clearAllFilters: $e');
      // Fallback: just reset the basic filter states
      try {
        isVag.value = false;
        isNonVag.value = false;
        isOfferFilter.value = false;
      } catch (fallbackError) {
        print('Error in fallback clear: $fallbackError');
      }
    }
  }

  // **BACKWARD COMPATIBILITY METHODS**

  /// **LEGACY PRODUCT LOADING (now uses parallel loading)**
  getProduct() async {
    print("DEBUG: getProduct() called - using parallel loading instead");
    await _loadCriticalDataInParallel();
  }

  /// **LEGACY FAVOURITE AND COUPON LOADING (now uses parallel loading)**
  getFavouriteList() async {
    print("DEBUG: getFavouriteList() called - using parallel loading instead");
    _loadSecondaryDataInParallel();
  }

  RxBool isOpen = false.obs;
  RxMap<String, dynamic> restaurantStatus = <String, dynamic>{}.obs;

  /// **FAILPROOF RESTAURANT STATUS SYSTEM**
  ///
  /// Implements the comprehensive failproof system where restaurant is ONLY OPEN if:
  /// 1. Manual toggle (isOpen) is explicitly true AND
  /// 2. Current time is within working hours
  ///
  /// This replaces the old reststatus-based logic with the new isOpen field
  void statusCheck() {
    print(
        'DEBUG: RestaurantDetailsController - Running failproof status check');

    // Use the RestaurantStatusManager for failproof logic
    final statusManager = RestaurantStatusManager();

    // Get current status using the new isOpen field from Firebase
    final status = statusManager.getRestaurantStatus(
      vendorModel.value.workingHours,
      vendorModel
          .value.isOpen, // Use the new isOpen field instead of reststatus
    );

    // Update reactive variables
    isOpen.value = status['isOpen'];
    restaurantStatus.assignAll(status);

    // Log status for debugging
    print('DEBUG: Status check result:');
    print('  - Manual toggle (isOpen): ${vendorModel.value.isOpen}');
    print('  - Within working hours: ${status['withinWorkingHours']}');
    print('  - Final status: ${status['isOpen'] ? 'OPEN' : 'CLOSED'}');
    print('  - Reason: ${status['reason']}');

    // Start monitoring for status changes
    _startStatusMonitoring();
  }

  /// **START STATUS MONITORING**
  ///
  /// Monitors restaurant status every 5 minutes
  void _startStatusMonitoring() {
    final statusManager = RestaurantStatusManager();

    statusManager.startStatusMonitoring(
      workingHours: vendorModel.value.workingHours,
      isOpen: vendorModel.value.isOpen,
      onStatusUpdate: (status) {
        // Update status if it changed
        if (isOpen.value != status['isOpen']) {
          print(
              'DEBUG: Status changed from ${isOpen.value} to ${status['isOpen']}');
          isOpen.value = status['isOpen'];
          restaurantStatus.assignAll(status);
        }
      },
      intervalMinutes: 5,
    );
  }

  /// **GET RESTAURANT STATUS INFO (LEGACY COMPATIBILITY)**
  Map<String, dynamic> getRestaurantStatusInfo() {
    if (restaurantStatus.isEmpty) {
      // Fallback to old logic if status not yet calculated
      final statusManager = RestaurantStatusManager();
      final status = statusManager.getRestaurantStatus(
        vendorModel.value.workingHours,
        vendorModel.value.isOpen,
      );
      restaurantStatus.assignAll(status);
      isOpen.value = status['isOpen'];
    }

    return Map<String, dynamic>.from(restaurantStatus);
  }

  /// **CHECK IF RESTAURANT ACCEPTS ORDERS**
  ///
  /// Uses the failproof system to determine if orders can be accepted
  bool canAcceptOrders() {
    return isOpen.value;
  }

  /// **GET NEXT OPENING TIME**
  String? getNextOpeningTime() {
    final status = getRestaurantStatusInfo();
    return status['nextOpeningTime'];
  }

  /// **GET STATUS SUMMARY FOR DEBUGGING**
  String getStatusSummary() {
    final statusManager = RestaurantStatusManager();
    return statusManager.getStatusSummary(
      vendorModel.value.workingHours,
      vendorModel.value.isOpen,
    );
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList selectedVariants = [].obs;
  RxList selectedIndexVariants = [].obs;
  RxList selectedIndexArray = [].obs;

  RxList selectedAddOns = [].obs;

  RxInt quantity = 1.obs;

  calculatePrice(ProductModel productModel) {
    String mainPrice = "0";
    String variantPrice = "0";
    String adOnsPrice = "0";

    if (productModel.itemAttribute != null) {
      if (productModel.itemAttribute!.variants!
          .where((element) => element.variantSku == selectedVariants.join('-'))
          .isNotEmpty) {
        variantPrice = Constant.productCommissionPrice(
            vendorModel.value,
            productModel.itemAttribute!.variants!
                    .where((element) =>
                        element.variantSku == selectedVariants.join('-'))
                    .first
                    .variantPrice ??
                '0');
      }
    } else {
      String price = Constant.productCommissionPrice(
          vendorModel.value, productModel.price.toString());
      String disPrice = double.parse(productModel.disPrice.toString()) <= 0
          ? "0"
          : Constant.productCommissionPrice(
              vendorModel.value, productModel.disPrice.toString());
      if (double.parse(disPrice) <= 0) {
        variantPrice = price;
      } else {
        variantPrice = disPrice;
      }
    }

    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true) {
        adOnsPrice = (double.parse(adOnsPrice.toString()) +
                double.parse(Constant.productCommissionPrice(vendorModel.value,
                    productModel.addOnsPrice![i].toString())))
            .toString();
      }
    }
    adOnsPrice = (quantity.value * double.parse(adOnsPrice)).toString();
    mainPrice = ((double.parse(variantPrice.toString()) *
                double.parse(quantity.value.toString())) +
            double.parse(adOnsPrice.toString()))
        .toString();
    return mainPrice;
  }

  getAttributeData() async {
    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
      }
    });
  }

  addToCart({
    required ProductModel productModel,
    required String price,
    required String discountPrice,
    required bool isIncrement,
    required int quantity,
    VariantInfo? variantInfo,
  }) async {
    // **CHECK PROMOTIONAL ITEM LIMIT BEFORE ADDING TO CART (OPTIMIZED)**
    if (isIncrement) {
      // **PERFORMANCE FIX: Use cached promotional data instead of Firebase query**
      final promo = _getCachedPromotionalData(
        productModel.id ?? '',
        vendorModel.value.id ?? '',
      );

      print(
          'DEBUG: RestaurantDetailsController - Checking promotional item: ${productModel.id}');
      print('DEBUG: RestaurantDetailsController - Promo data: $promo');

      if (promo != null) {
        // **PERFORMANCE FIX: Use cached availability check (instant)**
        final isAllowed = isPromotionalItemQuantityAllowed(
            productModel.id ?? '', vendorModel.value.id ?? '', quantity);

        if (!isAllowed) {
          // **PERFORMANCE FIX: Use cached limit (instant)**
          final limit = getPromotionalItemLimit(
              productModel.id ?? '', vendorModel.value.id ?? '');
          ShowToastDialog.showToast(
              "Maximum $limit items allowed for this promotional offer".tr);
          return; // Don't add to cart if limit exceeded
        }
      } else {
        print(
            'DEBUG: RestaurantDetailsController - No promotional data found for product: ${productModel.id}');
      }
    }

    CartProductModel cartProductModel = CartProductModel();

    String adOnsPrice = "0";
    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true &&
          productModel.addOnsPrice![i] != '0') {
        adOnsPrice = (double.parse(adOnsPrice.toString()) +
                double.parse(Constant.productCommissionPrice(vendorModel.value,
                    productModel.addOnsPrice![i].toString())))
            .toString();
      }
    }

    if (variantInfo != null) {
      cartProductModel.id =
          "${productModel.id!}~${variantInfo.variantId.toString()}";
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.vendorName = vendorModel.value.title;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = variantInfo;
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;

      // Set promoId for promotional items (OPTIMIZED)
      if (isIncrement) {
        // **PERFORMANCE FIX: Use cached promotional data instead of Firebase query**
        final promo = _getCachedPromotionalData(
          productModel.id ?? '',
          vendorModel.value.id ?? '',
        );
        if (promo != null) {
          cartProductModel.promoId = promo['product_id'] ?? '';
          print(
              'DEBUG: RestaurantDetailsController - Set promoId for variant: ${cartProductModel.promoId}');
        }
      }
    } else {
      cartProductModel.id = productModel.id!;
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.vendorName = vendorModel.value.title;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = VariantInfo();
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;

      // Set promoId for promotional items
      if (isIncrement) {
        final promo = await FireStoreUtils.getActivePromotionForProduct(
          productId: productModel.id ?? '',
          restaurantId: vendorModel.value.id ?? '',
        );
        if (promo != null) {
          cartProductModel.promoId = promo['product_id'] ?? '';
          print(
              'DEBUG: RestaurantDetailsController - Set promoId: ${cartProductModel.promoId}');
        }
      }
    }

    if (isIncrement) {
      await cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      await cartProvider.removeFromCart(cartProductModel, quantity);
    }
    log("===> new ${cartItem.length}");
    update();
  }

  // Method to scroll to a specific product
  void scrollToProduct(String productId) {
    print("DEBUG: scrollToProduct called with productId: $productId");
    print(
        "DEBUG: scrollController has clients: ${scrollController.value.hasClients}");
    print("DEBUG: productList length: ${productList.length}");

    if (scrollController.value.hasClients) {
      // Find the index of the product in the product list
      int productIndex = -1;
      for (int i = 0; i < productList.length; i++) {
        if (productList[i].id == productId) {
          productIndex = i;
          break;
        }
      }

      if (productIndex != -1) {
        // Calculate approximate position (each product card is roughly 120px height)
        double scrollPosition = productIndex * 120.0;

        // Add some offset for better visibility
        scrollPosition = scrollPosition - 100.0;
        if (scrollPosition < 0) scrollPosition = 0;

        scrollController.value.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );

        print(
            "DEBUG: Scrolled to product $productId at position $scrollPosition");
      } else {
        print("DEBUG: Product $productId not found in product list");
      }
    }
  }

  // Method to scroll to product after data is loaded
  void scrollToProductAfterLoad() {
    if (scrollToProductId != null && shouldScrollToProduct.value) {
      print("DEBUG: Will scroll to product: $scrollToProductId");
      // Wait a bit for the UI to be ready
      Future.delayed(const Duration(milliseconds: 500), () {
        print("DEBUG: Attempting to scroll to product: $scrollToProductId");
        scrollToProduct(scrollToProductId!);
        shouldScrollToProduct.value = false;
      });
    }
  }

  @override
  void onClose() {
    try {
      if (pageController.value.hasClients) {
        pageController.value.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
    }

    // Print performance report when controller is closed
    // PerformanceMonitor.printPerformanceReport();

    super.onClose();
  }

  /// **CACHE DIAGNOSTICS FOR TESTING**
  Future<void> _logCacheDiagnostics() async {
    if (!kDebugMode) return;

    try {
      final vendorId = vendorModel.value.id;
      final cacheKey = 'restaurant_products_$vendorId';

      print("🔍 CACHE DIAGNOSTICS:");
      print("📋 Vendor ID: $vendorId");
      print("🔑 Cache Key: $cacheKey");
      print("📊 Products Loaded: ${productList.length}");
      print(
          "💾 Cache Status: ${CacheManager.hasCache(cacheKey) ? 'HIT' : 'MISS'}");

      if (CacheManager.hasCache(cacheKey)) {
        final cachedData = await CacheManager.get<List<dynamic>>(cacheKey);
        print("📦 Cached Products: ${cachedData?.length ?? 0}");
        print("⏰ Cache Age: ${CacheManager.getCacheAge(cacheKey)}");
      }

      print("🔍 END CACHE DIAGNOSTICS");
    } catch (e) {
      print("❌ Cache diagnostics error: $e");
    }
  }
}

// import 'dart:async';

// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:customer/constant/collection_name.dart';
// import 'package:customer/constant/constant.dart';
// import 'package:customer/constant/show_toast_dialog.dart';
// import 'package:customer/models/AttributesModel.dart';
// import 'package:customer/models/cart_product_model.dart';
// import 'package:customer/models/coupon_model.dart';
// import 'package:customer/models/favourite_item_model.dart';
// import 'package:customer/models/favourite_model.dart';
// import 'package:customer/models/product_model.dart';
// import 'package:customer/models/vendor_category_model.dart';
// import 'package:customer/models/vendor_model.dart';
// import 'package:customer/services/cart_provider.dart';
// import 'package:customer/services/promotional_cache_service.dart';
// import 'package:customer/utils/cache_manager.dart';
// import 'package:customer/utils/fire_store_utils.dart';
// import 'package:customer/utils/performance_monitor.dart';
// import 'package:customer/utils/restaurant_status_manager.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class RestaurantDetailsController extends GetxController {
//   final String? scrollToProductId;
//
//   RestaurantDetailsController({this.scrollToProductId});
//   RxInt selectedCategoryIndex = 0.obs;
//   //New Logic
//   RxList<ProductModel> filteredProductList = <ProductModel>[].obs;
//   // RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
//   bool productsLoading = false;
//   void productLoadingFunction(bool value) {
//     productsLoading = value;
//     update();
//   }
//
//   final ScrollController scrollControllerProduct = ScrollController();
// // In RestaurantDetailsController
//   final Map<String, GlobalKey> categoryKeys = {};
//
//   String getCategoryKey(int index) {
//     return 'category_$index';
//   }
//
// // Improved scrollToCategory method
//   void scrollToCategory(int index) {
//     if (!scrollControllerProduct.hasClients) {
//       print("DEBUG: Scroll controller not attached yet");
//       return;
//     }
//     // Wait for the next frame to ensure UI is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         // Calculate the approximate position based on category index
//         // Each category header is roughly 60px, products vary in height
//         double estimatedPosition = 0.0;
//
//         // Estimate position based on previous categories
//         for (int i = 0; i < index; i++) {
//           if (i < vendorCategoryList.length) {
//             final categoryId = vendorCategoryList[i].id.toString();
//             final productCount = getProductsByCategory(categoryId).length;
//             // Estimate: header (60px) + each product (120px) + padding
//             estimatedPosition += 150.0 + (productCount * 120.0) + 40.0;
//           }
//         }
//
//         print(
//             "DEBUG: Scrolling to category $index at position $estimatedPosition");
//
//         scrollControllerProduct.animateTo(
//           estimatedPosition,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//         );
//       } catch (e) {
//         print("DEBUG: Error scrolling to category: $e");
//       }
//     });
//   }
//
//   List<ProductModel> getProductsByCategory(String categoryId) {
//     return categoryProductsMap[categoryId] ?? [];
//   }
//
//   Map<String, List<ProductModel>> categoryProductsMap = {};
//
//   Future<void> getProductList() async {
//     try {
//       print(" getProductList called, total products: ${productList.length}");
//       for (var product in productList) {
//         // Skip if product has no category
//         if (product.categoryID == null || product.categoryID!.isEmpty) continue;
//
//         // Check if we already have the category
//         bool alreadyExists = vendorCategoryList
//             .any((cat) => cat.id.toString() == product.categoryID.toString());
//
//         if (!alreadyExists) {
//           // Fetch category from Firebase
//           var category = await FireStoreUtils.getVendorCategoryByCategoryId(
//             product.categoryID.toString(),
//           );
//
//           if (category != null) {
//             vendorCategoryList.add(category);
//             print(
//                 "Added new category: ${category.title} (${vendorCategoryList.length} total)");
//           }
//         }
//
//         // Group products under the categoryID
//         if (!categoryProductsMap.containsKey(product.categoryID)) {
//           categoryProductsMap[product.categoryID.toString()] = [];
//         }
//         categoryProductsMap[product.categoryID.toString()]!.add(product);
//       }
//
//       productLoadingFunction(false);
//       update();
//     } catch (e) {
//       productLoadingFunction(false);
//       log("Error in getProductList: $e");
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast("Failed to load products");
//     }
//   }
//
//   /// Get restaurant by ID for deep linking
//   Future<VendorModel?> getRestaurantById(String restaurantId) async {
//     try {
//       print(
//           '[RESTAURANT CONTROLLER] 🔍 Fetching restaurant by ID: $restaurantId');
//
//       // Query Firestore for restaurant by ID
//       final doc = await FireStoreUtils.getVendorById(restaurantId);
//
//       if (doc != null) {
//         print('[RESTAURANT CONTROLLER] ✅ Restaurant found: ${doc.title}');
//         return doc;
//       } else {
//         print('[RESTAURANT CONTROLLER] ❌ Restaurant not found: $restaurantId');
//         return null;
//       }
//     } catch (e) {
//       print('[RESTAURANT CONTROLLER] ❌ Error fetching restaurant by ID: $e');
//       return null;
//     }
//   }
//
//   Rx<TextEditingController> searchEditingController =
//       TextEditingController().obs;
//
//   RxBool isLoading = true.obs;
//   Rx<PageController> pageController = PageController().obs;
//   RxInt currentPage = 0.obs;
//
//   RxBool isVag = false.obs;
//   RxBool isNonVag = false.obs;
//   RxBool isOfferFilter = false.obs;
//   RxBool isMenuOpen = false.obs;
//
//   // Scroll controller for scrolling to specific product
//   Rx<ScrollController> scrollController = ScrollController().obs;
//   RxBool shouldScrollToProduct = false.obs;
//
//   RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
//   RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
//   RxList<ProductModel> allProductList = <ProductModel>[].obs;
//   RxList<ProductModel> productList = <ProductModel>[].obs;
//   RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
//
//   RxList<CouponModel> couponList = <CouponModel>[].obs;
//
//   // **ENHANCED CACHE FOR FASTER FILTERING**
//   Map<String, List<ProductModel>> _productsByCategory = {};
//
//   @override
//   void onInit() {
//     getArgument();
//     super.onInit();
//
//     // If we need to scroll to a specific product, set the flag
//     if (scrollToProductId != null) {
//       shouldScrollToProduct.value = true;
//     }
//   }
//
//   /// **DEEP LINK UPDATE METHOD**
//   ///
//   /// Updates restaurant data when new deep links come in
//   /// This ensures UI refreshes even when controller is already in memory
//   void updateRestaurant(VendorModel newRestaurant) {
//     print(
//         '[RESTAURANT CONTROLLER] 🔄 Updating with new restaurant: ${newRestaurant.title}');
//     print(
//         '[RESTAURANT CONTROLLER] 🔄 Previous restaurant: ${vendorModel.value.title}');
//     print('[RESTAURANT CONTROLLER] 🔄 New restaurant ID: ${newRestaurant.id}');
//     print(
//         '[RESTAURANT CONTROLLER] 🔄 Previous restaurant ID: ${vendorModel.value.id}');
//
//     // Update the vendor model directly
//     vendorModel.value = newRestaurant;
//     print('[RESTAURANT CONTROLLER] 🔄 Vendor model updated');
//
//     // **CRITICAL FIX: Clear promotional cache for new restaurant**
//     PromotionalCacheService.clearRestaurantCache(vendorModel.value.id ?? '');
//     _promotionalCacheLoaded = false;
//     print(
//         '[RESTAURANT CONTROLLER] 🔄 Cleared promotional cache for new restaurant');
//
//     // Reset loading state
//     isLoading.value = true;
//     print('[RESTAURANT CONTROLLER] 🔄 Loading state set to true');
//
//     // Reload all data for the new restaurant
//     _loadCriticalDataInParallel().then((_) async {
//       // **CRITICAL FIX: Reload promotional cache for new restaurant**
//       await _loadPromotionalCache();
//       isLoading.value = false;
//       update(); // Force UI refresh
//       print(
//           '[RESTAURANT CONTROLLER] ✅ Restaurant updated successfully: ${newRestaurant.title}');
//       print('[RESTAURANT CONTROLLER] ✅ UI refresh triggered');
//     }).catchError((error) {
//       print('[RESTAURANT CONTROLLER] ❌ Error updating restaurant: $error');
//       isLoading.value = false;
//     });
//   }
//
//   void animateSlider() {
//     if (vendorModel.value.photos != null &&
//         vendorModel.value.photos!.isNotEmpty) {
//       Timer.periodic(const Duration(seconds: 2), (Timer timer) {
//         // Check if controller is still valid and widget is mounted
//         if (!Get.isRegistered<RestaurantDetailsController>() ||
//             !pageController.value.hasClients) {
//           timer.cancel();
//           return;
//         }
//
//         if (currentPage < vendorModel.value.photos!.length - 1) {
//           currentPage++;
//         } else {
//           currentPage.value = 0;
//         }
//
//         // Only animate if attached
//         try {
//           if (pageController.value.hasClients) {
//             pageController.value.animateToPage(
//               currentPage.value,
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeIn,
//             );
//           }
//         } catch (e) {
//           // If any error occurs, cancel the timer
//           timer.cancel();
//         }
//       });
//     }
//   }
//
//   Rx<VendorModel> vendorModel = VendorModel().obs;
//
//   final CartProvider cartProvider = CartProvider();
//
//   // **ULTRA-FAST PROMOTIONAL DATA CACHE FOR INSTANT BUTTON RESPONSE**
//   Map<String, Map<String, dynamic>> _promotionalCache = {};
//   Map<String, int> _promotionalLimits = {}; // Pre-calculated limits
//   Map<String, bool> _promotionalAvailability =
//       {}; // Pre-calculated availability
//   bool _promotionalCacheLoaded = false;
//
//   // **ULTRA-FAST METHOD TO LOAD AND PRE-CALCULATE ALL PROMOTIONAL DATA (OPTIMIZED)**
//   Future<void> _loadPromotionalCache() async {
//     if (_promotionalCacheLoaded) {
//       print('DEBUG: Promotional cache already loaded');
//       return;
//     }
//
//     try {
//       print('DEBUG: Loading promotional cache using shared service...');
//
//       // **PERFORMANCE FIX: Use shared promotional cache service**
//       await PromotionalCacheService.loadRestaurantPromotions(
//           vendorModel.value.id ?? '');
//
//       _promotionalCacheLoaded = true;
//       print('DEBUG: Promotional cache loaded successfully');
//
//       // **CRITICAL FIX: Force UI update after cache is loaded**
//       update();
//     } catch (e) {
//       print('DEBUG: Error loading promotional cache: $e');
//       _promotionalCacheLoaded = false;
//     }
//   }
//
//   // **INSTANT METHOD TO GET CACHED PROMOTIONAL DATA (ZERO ASYNC)**
//   Map<String, dynamic>? _getCachedPromotionalData(
//       String productId, String restaurantId) {
//     // **PERFORMANCE FIX: Use shared promotional cache service**
//     return PromotionalCacheService.getCachedPromotionalData(
//         productId, restaurantId);
//   }
//
//   // **INSTANT METHOD TO CHECK PROMOTIONAL AVAILABILITY (ZERO ASYNC)**
//   bool _isPromotionalAvailable(String productId, String restaurantId) {
//     // **PERFORMANCE FIX: Use shared promotional cache service**
//     return PromotionalCacheService.isPromotionalAvailable(
//         productId, restaurantId);
//   }
//
//   // **INSTANT METHOD TO GET PROMOTIONAL LIMIT (ZERO ASYNC)**
//   int _getPromotionalLimit(String productId, String restaurantId) {
//     // **PERFORMANCE FIX: Use shared promotional cache service**
//     return PromotionalCacheService.getPromotionalLimit(productId, restaurantId);
//   }
//
//   // **METHOD TO CHECK IF CART HAS PROMOTIONAL ITEMS**
//   bool hasPromotionalItems() {
//     return cartItem
//         .any((item) => item.promoId != null && item.promoId!.isNotEmpty);
//   }
//
//   // **ULTRA-FAST METHOD TO GET PROMOTIONAL ITEM LIMIT (ZERO ASYNC)**
//   int? getPromotionalItemLimit(String productId, String restaurantId) {
//     if (!_isPromotionalAvailable(productId, restaurantId)) {
//       return null;
//     }
//     final limit = _getPromotionalLimit(productId, restaurantId);
//     return limit > 0 ? limit : null;
//   }
//
//   // **ULTRA-FAST METHOD TO CHECK IF PROMOTIONAL ITEM QUANTITY IS WITHIN LIMIT (ZERO ASYNC)**
//   bool isPromotionalItemQuantityAllowed(
//       String productId, String restaurantId, int currentQuantity) {
//     if (currentQuantity <= 0) {
//       return true; // Allow decrement
//     }
//
//     if (!_isPromotionalAvailable(productId, restaurantId)) {
//       return false;
//     }
//
//     final limit = _getPromotionalLimit(productId, restaurantId);
//     return currentQuantity <= limit;
//   }
//
//   bool isLoadingAddButton = false;
//
//   // **ULTRA-FAST METHOD TO GET ACTIVE PROMOTION WITH LAZY LOADING**
//   Map<String, dynamic>? getActivePromotionForProduct({
//     required String productId,
//     required String restaurantId,
//   }) {
//     // **LAZY LOADING: Check if cache is loaded, if not trigger background load**
//     if (!_promotionalCacheLoaded) {
//       _loadPromotionalCache(); // **BACKGROUND LOADING: Non-blocking**
//     }
//
//     // Use cached data instead of Firebase query - INSTANT RESPONSE
//     final promo = _getCachedPromotionalData(productId, restaurantId);
//
//     // **DEBUG: Log promotional data access for troubleshooting**
//     if (kDebugMode) {
//       print('[DEBUG] getActivePromotionForProduct called:');
//       print('[DEBUG] - Product ID: $productId');
//       print('[DEBUG] - Restaurant ID: $restaurantId');
//       print('[DEBUG] - Cache loaded: $_promotionalCacheLoaded');
//       print('[DEBUG] - Promo found: ${promo != null}');
//       if (promo != null) {
//         print('[DEBUG] - Promo data: $promo');
//       }
//     }
//
//     return promo;
//   }
//
//   /// **OPTIMIZED PARALLEL DATA LOADING ARCHITECTURE**
//   ///
//   /// Loads all data in parallel for maximum performance:
//   /// 1. Critical data (products, categories, favorites) - parallel
//   /// 2. Secondary data (coupons, attributes, promotional) - parallel
//   /// 3. Background data (promotional testing) - non-blocking
//   Future<void> getArgument() async {
//     // PerformanceMonitor.startTiming('totalScreenLoad');
//
//     cartProvider.cartStream.listen(
//       (event) async {
//         cartItem.clear();
//         cartItem.addAll(event);
//       },
//     );
//
//     dynamic argumentData = Get.arguments;
//     if (argumentData != null) {
//       vendorModel.value = argumentData['vendorModel'];
//     }
//
//     animateSlider();
//     statusCheck();
//
//     // **STEP 1: Load critical data in parallel (products, categories, favorites)**
//     await _loadCriticalDataInParallel();
//
//     // **STEP 2: Mark screen as ready immediately**
//     isLoading.value = false;
//     update();
//
//     // **STEP 3: Load secondary data in parallel (non-blocking)**
//     _loadSecondaryDataInParallel();
//
//     // **STEP 4: Load promotional cache in parallel with secondary data (non-blocking)**
//     _loadPromotionalCache(); // **ULTRA-FAST: Non-blocking parallel loading**
//
//     // PerformanceMonitor.endTiming('totalScreenLoad');
//   }
//
//   /// **PARALLEL CRITICAL DATA LOADING**
//   ///
//   /// Loads products, categories, and favorites simultaneously
//   Future<void> _loadCriticalDataInParallel() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadCriticalDataInParallel',
//       () async {
//         print("DEBUG: Starting parallel critical data loading");
//         // Load products, categories, and favorites in parallel
//         productLoadingFunction(true);
//         await Future.wait([
//           _loadProducts(),
//           // _loadCategories(),
//           _loadFavorites(),
//         ]);
//         getProductList();
//         // Build product cache after both products and categories are loaded
//         _buildProductCache();
//         print(
//             "DEBUG: Cache built with ${_productsByCategory.length} categories");
//
//         print("DEBUG: Parallel critical data loading completed");
//       },
//     );
//   }
//
//   /// **PARALLEL SECONDARY DATA LOADING**
//   ///
//   /// Loads coupons, attributes, and other secondary data in parallel
//   void _loadSecondaryDataInParallel() async {
//     try {
//       await PerformanceMonitor.monitorOperation(
//         'loadSecondaryDataInParallel',
//         () async {
//           print("DEBUG: Starting parallel secondary data loading");
//
//           if (Constant.userModel != null) {
//             // Load coupons and attributes in parallel
//             await Future.wait([
//               _loadCoupons(),
//               _loadAttributes(),
//             ]);
//           } else {
//             // Load only attributes if user not logged in
//             await _loadAttributes();
//           }
//
//           print("DEBUG: Parallel secondary data loading completed");
//           update();
//         },
//       );
//     } catch (e) {
//       print("DEBUG: Secondary data loading failed (non-critical): $e");
//     }
//   }
//
//   /// **OPTIMIZED PRODUCT LOADING**
//   Future<void> _loadProducts() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadProducts',
//       () async {
//         print("DEBUG: Loading products for vendor: ${vendorModel.value.id}");
//
//         // Check cache first with enhanced validation
//         final cacheKey = 'products_${vendorModel.value.id}';
//         final cachedProducts =
//             await CacheManager.get<List<ProductModel>>(cacheKey);
//
//         if (cachedProducts != null && cachedProducts.isNotEmpty) {
//           // PerformanceMonitor.recordCacheHit(cacheKey);
//           allProductList.value = cachedProducts;
//           productList.value = cachedProducts;
//
//           // **APPLY SMART SORTING AFTER LOADING FROM CACHE**
//           _applySmartSorting();
//
//           print("DEBUG: Using cached products: ${cachedProducts.length} items");
//         } else {
//           // Cache miss or empty - clear potentially corrupted cache
//           if (cachedProducts != null && cachedProducts.isEmpty) {
//             print("DEBUG: Clearing empty cached products for key: $cacheKey");
//             CacheManager.clear(cacheKey);
//           }
//           // PerformanceMonitor.recordCacheMiss(cacheKey);
//
//           // **SINGLE QUERY FOR ALL PRODUCTS**
//           final products = await FireStoreUtils.getProductByVendorId(
//               vendorModel.value.id.toString());
//           print("DEBUG: Loaded ${products.length} products");
//           if ((Constant.isSubscriptionModelApplied == true ||
//                   Constant.adminCommission?.isEnabled == true) &&
//               vendorModel.value.subscriptionPlan != null) {
//             if (vendorModel.value.subscriptionPlan?.itemLimit == '-1') {
//               allProductList.value = products;
//               productList.value = products;
//             } else {
//               int selectedProduct = products.length <
//                       int.parse(
//                           vendorModel.value.subscriptionPlan?.itemLimit ?? '0')
//                   ? (products.isEmpty ? 0 : (products.length))
//                   : int.parse(
//                       vendorModel.value.subscriptionPlan?.itemLimit ?? '0');
//               allProductList.value = products.sublist(0, selectedProduct);
//               productList.value = products.sublist(0, selectedProduct);
//             }
//           } else {
//             allProductList.value = products;
//             productList.value = products;
//           }
//
//           // **APPLY SMART SORTING AFTER LOADING**
//           _applySmartSorting();
//
//           // Cache the products
//           await CacheManager.setProductData(cacheKey, productList);
//           print("DEBUG: Cached ${productList.length} products");
//         }
//
//         print("DEBUG: Final product list has ${productList.length} items");
//
//         // DEBUG: Cache diagnostics for testing
//         if (kDebugMode) {
//           await _logCacheDiagnostics();
//         }
//
//         // Scroll to specific product if needed
//         if (scrollToProductId != null) {
//           scrollToProductAfterLoad();
//         }
//       },
//     );
//   }
//
//   /// **OPTIMIZED CATEGORY LOADING**
//   Future<void> _loadCategories() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadCategories',
//       () async {
//         final cacheKey = 'categories_${vendorModel.value.id}';
//         final cachedCategories =
//             await CacheManager.get<List<VendorCategoryModel>>(cacheKey);
//
//         if (cachedCategories != null) {
//           // PerformanceMonitor.recordCacheHit(cacheKey);
//           vendorCategoryList.value = cachedCategories;
//           print(
//               "DEBUG: Using cached categories: ${cachedCategories.length} items");
//         } else {
//           // PerformanceMonitor.recordCacheMiss(cacheKey);
//
//           // **SINGLE QUERY FOR ALL CATEGORIES**
//           final categories = await FireStoreUtils.getAllVendorCategories(
//               vendorModel.value.id.toString());
//           print(
//               "DEBUG: Loaded  categories ${vendorModel.value.id.toString()} ${categories.length} categories");
//
//           // Set categories directly instead of fetching one by one
//           vendorCategoryList.value = categories;
//           print("DEBUG: Using  categories: ${vendorCategoryList.length} items");
//           // Cache the categories
//           await CacheManager.setProductData(cacheKey, categories);
//           print("DEBUG: Cached ${categories.length} categories");
//         }
//       },
//     );
//   }
//
//   /// **OPTIMIZED FAVORITES LOADING**
//   Future<void> _loadFavorites() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadFavorites',
//       () async {
//         if (Constant.userModel != null) {
//           print("DEBUG: Loading favorites for user");
//
//           // Load favorite restaurants and items in parallel
//           await Future.wait([
//             FireStoreUtils.getFavouriteRestaurant().then((value) {
//               favouriteList.value = value;
//               print("DEBUG: Loaded ${value.length} favorite restaurants");
//             }),
//             FireStoreUtils.getFavouriteItem().then((value) {
//               favouriteItemList.value = value;
//               print("DEBUG: Loaded ${value.length} favorite items");
//             }),
//           ]);
//         } else {
//           print("DEBUG: No user logged in, skipping favorites");
//         }
//       },
//     );
//   }
//
//   /// **OPTIMIZED COUPONS LOADING**
//   Future<void> _loadCoupons() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadCoupons',
//       () async {
//         print("DEBUG: Loading coupons");
//
//         // Load vendor-specific and global coupons in parallel
//         await Future.wait([
//           FireStoreUtils.getOfferByVendorId(vendorModel.value.id.toString())
//               .then((value) {
//             couponList.value = value;
//             print("DEBUG: Loaded ${value.length} vendor coupons");
//           }),
//           FireStoreUtils.getHomeCoupon().then((globalCoupons) {
//             final filteredGlobalCoupons = globalCoupons
//                 .where((c) =>
//                     c.resturantId == null ||
//                     c.resturantId == '' ||
//                     c.resturantId?.toUpperCase() == 'ALL')
//                 .toList();
//             couponList.addAll(filteredGlobalCoupons
//                 .where((g) => !couponList.any((c) => c.id == g.id)));
//             print(
//                 "DEBUG: Loaded ${filteredGlobalCoupons.length} global coupons");
//           }),
//         ]);
//
//         print("DEBUG: Total coupons loaded: ${couponList.length}");
//       },
//     );
//   }
//
//   /// **OPTIMIZED ATTRIBUTES LOADING**
//   Future<void> _loadAttributes() async {
//     return await PerformanceMonitor.monitorOperation(
//       'loadAttributes',
//       () async {
//         print("DEBUG: Loading attributes");
//         await FireStoreUtils.getAttributes().then((value) {
//           if (value != null) {
//             attributesList.value = value;
//             print("DEBUG: Loaded ${value.length} attributes");
//           }
//         });
//       },
//     );
//   }
//
//   /// **TEST METHOD TO VERIFY PROMOTIONAL DATA FETCHING**
//   Future<void> testPromotionalDataFetching() async {
//     return await PerformanceMonitor.monitorOperation(
//       'testPromotionalDataFetching',
//       () async {
//         print('DEBUG: Testing promotional data fetching...');
//
//         // Test with a sample product ID (you can replace this with an actual product ID)
//         final testProductId =
//             "TgogRU5rLNmkoO4Cz1d5"; // Your promotional product ID
//         final testRestaurantId = vendorModel.value.id ?? '';
//
//         print('DEBUG: Testing with product ID: $testProductId');
//         print('DEBUG: Testing with restaurant ID: $testRestaurantId');
//
//         final promo = await FireStoreUtils.getActivePromotionForProduct(
//           productId: testProductId,
//           restaurantId: testRestaurantId,
//         );
//
//         if (promo != null) {
//           print('DEBUG: ✅ Promotional data found:');
//           print('DEBUG: - item_limit: ${promo['item_limit']}');
//           print('DEBUG: - special_price: ${promo['special_price']}');
//           print('DEBUG: - free_delivery_km: ${promo['free_delivery_km']}');
//           print('DEBUG: - extra_km_charge: ${promo['extra_km_charge']}');
//           print('DEBUG: - start_time: ${promo['start_time']}');
//           print('DEBUG: - end_time: ${promo['end_time']}');
//           print('DEBUG: - isAvailable: ${promo['isAvailable']}');
//         } else {
//           print(
//               'DEBUG: ❌ No promotional data found for product: $testProductId');
//         }
//       },
//     );
//   }
//
//   /// **SMART PRODUCT CACHING SYSTEM**
//   ///
//   /// Builds cache for instant category filtering
//   void _buildProductCache() {
//     _productsByCategory.clear();
//     for (var product in productList) {
//       final categoryId = product.categoryID.toString();
//       if (!_productsByCategory.containsKey(categoryId)) {
//         _productsByCategory[categoryId] = [];
//       }
//       _productsByCategory[categoryId]!.add(product);
//     }
//   }
//
//   /// **INSTANT CATEGORY FILTERING**
//   ///
//   /// Returns products by category from cache (no database queries)
//   // List<ProductModel> getProductsByCategory(String categoryId) {
//   //   return _productsByCategory[categoryId] ?? [];
//   // }
//
//   searchProduct(String name) {
//     if (name.isEmpty) {
//       productList.clear();
//       productList.addAll(allProductList);
//       _applySmartSorting(); // Apply smart sorting after resetting
//     } else {
//       isVag.value = false;
//       isNonVag.value = false;
//       isOfferFilter.value = false;
//       productList.value = allProductList
//           .where((p0) => p0.name!.toLowerCase().contains(name.toLowerCase()))
//           .toList();
//     }
//     update();
//   }
//
//   filterRecord() {
//     List<ProductModel> filteredList = [];
//
//     if (isVag.value == true && isNonVag.value == true) {
//       filteredList = allProductList
//           .where((p0) => p0.nonveg == true || p0.nonveg == false)
//           .toList();
//     } else if (isVag.value == true && isNonVag.value == false) {
//       filteredList = allProductList.where((p0) => p0.nonveg == false).toList();
//     } else if (isVag.value == false && isNonVag.value == true) {
//       filteredList = allProductList.where((p0) => p0.nonveg == true).toList();
//     } else if (isVag.value == false && isNonVag.value == false) {
//       filteredList = allProductList
//           .where((p0) => p0.nonveg == true || p0.nonveg == false)
//           .toList();
//     }
//
//     // Apply offer filter if enabled
//     if (isOfferFilter.value) {
//       filteredList =
//           filteredList.where((product) => _isPromotionalItem(product)).toList();
//     }
//
//     productList.value = filteredList;
//     _applySmartSorting();
//   }
//
//   Future<List<ProductModel>> getProductByCategory(
//       VendorCategoryModel vendorCategoryModel) async {
//     return productList
//         .where((p0) => p0.categoryID == vendorCategoryModel.id)
//         .toList();
//   }
//
//   /// **ULTRA-FAST PROMOTIONAL ITEM DETECTION**
//   ///
//   /// Uses cached promotional data for instant detection without Firebase queries
//   bool _isPromotionalItem(ProductModel product) {
//     final productId = product.id ?? '';
//     final restaurantId = vendorModel.value.id ?? '';
//
//     // **PERFORMANCE FIX: Use cached promotional data (instant)**
//     final hasPromotion = _isPromotionalAvailable(productId, restaurantId);
//
//     if (hasPromotion) {
//       return true;
//     }
//
//     // **FALLBACK: Check for price-based promotional items**
//     final priceValue = double.tryParse(product.price ?? '0') ?? 0.0;
//     final discountPriceValue = double.tryParse(product.disPrice ?? '0') ?? 0.0;
//
//     // Consider it promotional if there's a discount price lower than regular price
//     return priceValue > 0 &&
//         discountPriceValue > 0 &&
//         priceValue < discountPriceValue;
//   }
//
//   /// **SMART SORTING SYSTEM**
//   ///
//   /// Sorts items in this order for optimal user experience:
//   /// 1. Promotional items (on top)
//   /// 2. Available regular items
//   /// 3. Unavailable items (at bottom)
//   void _applySmartSorting() {
//     if (isOfferFilter.value) {
//       // When offer filter is active, show only promotional items
//       return;
//     }
//
//     // Sort products for better user experience
//     productList.sort((a, b) {
//       // 1. Check promotional status
//       final aIsPromotional = _isPromotionalItem(a);
//       final bIsPromotional = _isPromotionalItem(b);
//
//       if (aIsPromotional && !bIsPromotional) return -1; // a comes first
//       if (!aIsPromotional && bIsPromotional) return 1; // b comes first
//
//       // 2. If both have same promotional status, check availability
//       final aIsAvailable = a.isAvailable ?? true;
//       final bIsAvailable = b.isAvailable ?? true;
//
//       if (aIsAvailable && !bIsAvailable) return -1; // a comes first
//       if (!aIsAvailable && bIsAvailable) return 1; // b comes first
//
//       // 3. If both have same promotional status and availability, sort by name
//       return (a.name ?? '').compareTo(b.name ?? '');
//     });
//   }
//
//   /// **OFFER FILTER TOGGLE METHOD**
//   void toggleOfferFilter() {
//     isOfferFilter.value = !isOfferFilter.value;
//
//     // Reset other filters when offer filter is activated
//     if (isOfferFilter.value) {
//       isVag.value = false;
//       isNonVag.value = false;
//     }
//
//     filterRecord();
//   }
//
//   /// **CLEAR ALL FILTERS METHOD**
//   void clearAllFilters() {
//     try {
//       // Reset all filter states with safety checks
//       if (isVag.value != null) isVag.value = false;
//       if (isNonVag.value != null) isNonVag.value = false;
//       if (isOfferFilter.value != null) isOfferFilter.value = false;
//
//       // Clear search text with safety check
//       if (searchEditingController.value != null) {
//         searchEditingController.value.clear();
//       }
//
//       // Reset product list to show all products with safety checks
//       if (productList.isNotEmpty) {
//         productList.clear();
//       }
//       if (allProductList.isNotEmpty) {
//         productList.addAll(allProductList);
//       }
//
//       // Apply smart sorting with safety check
//       try {
//         _applySmartSorting();
//       } catch (e) {
//         print('Error applying smart sorting: $e');
//       }
//
//       // Update UI with safety check
//       try {
//         update();
//       } catch (e) {
//         print('Error updating UI: $e');
//       }
//     } catch (e) {
//       print('Error in clearAllFilters: $e');
//       // Fallback: just reset the basic filter states
//       try {
//         isVag.value = false;
//         isNonVag.value = false;
//         isOfferFilter.value = false;
//       } catch (fallbackError) {
//         print('Error in fallback clear: $fallbackError');
//       }
//     }
//   }
//
//   // **BACKWARD COMPATIBILITY METHODS**
//
//   /// **LEGACY PRODUCT LOADING (now uses parallel loading)**
//   getProduct() async {
//     print("DEBUG: getProduct() called - using parallel loading instead");
//     await _loadCriticalDataInParallel();
//   }
//
//   /// **LEGACY FAVOURITE AND COUPON LOADING (now uses parallel loading)**
//   getFavouriteList() async {
//     print("DEBUG: getFavouriteList() called - using parallel loading instead");
//     _loadSecondaryDataInParallel();
//   }
//
//   RxBool isOpen = false.obs;
//   RxMap<String, dynamic> restaurantStatus = <String, dynamic>{}.obs;
//
//   /// **FAILPROOF RESTAURANT STATUS SYSTEM**
//   ///
//   /// Implements the comprehensive failproof system where restaurant is ONLY OPEN if:
//   /// 1. Manual toggle (isOpen) is explicitly true AND
//   /// 2. Current time is within working hours
//   ///
//   /// This replaces the old reststatus-based logic with the new isOpen field
//   void statusCheck() {
//     print(
//         'DEBUG: RestaurantDetailsController - Running failproof status check');
//
//     // Use the RestaurantStatusManager for failproof logic
//     final statusManager = RestaurantStatusManager();
//
//     // Get current status using the new isOpen field from Firebase
//     final status = statusManager.getRestaurantStatus(
//       vendorModel.value.workingHours,
//       vendorModel
//           .value.isOpen, // Use the new isOpen field instead of reststatus
//     );
//
//     // Update reactive variables
//     isOpen.value = status['isOpen'];
//     restaurantStatus.assignAll(status);
//
//     // Log status for debugging
//     print('DEBUG: Status check result:');
//     print('  - Manual toggle (isOpen): ${vendorModel.value.isOpen}');
//     print('  - Within working hours: ${status['withinWorkingHours']}');
//     print('  - Final status: ${status['isOpen'] ? 'OPEN' : 'CLOSED'}');
//     print('  - Reason: ${status['reason']}');
//
//     // Start monitoring for status changes
//     _startStatusMonitoring();
//   }
//
//   /// **START STATUS MONITORING**
//   ///
//   /// Monitors restaurant status every 5 minutes
//   void _startStatusMonitoring() {
//     final statusManager = RestaurantStatusManager();
//
//     statusManager.startStatusMonitoring(
//       workingHours: vendorModel.value.workingHours,
//       isOpen: vendorModel.value.isOpen,
//       onStatusUpdate: (status) {
//         // Update status if it changed
//         if (isOpen.value != status['isOpen']) {
//           print(
//               'DEBUG: Status changed from ${isOpen.value} to ${status['isOpen']}');
//           isOpen.value = status['isOpen'];
//           restaurantStatus.assignAll(status);
//         }
//       },
//       intervalMinutes: 5,
//     );
//   }
//
//   /// **GET RESTAURANT STATUS INFO (LEGACY COMPATIBILITY)**
//   Map<String, dynamic> getRestaurantStatusInfo() {
//     if (restaurantStatus.isEmpty) {
//       // Fallback to old logic if status not yet calculated
//       final statusManager = RestaurantStatusManager();
//       final status = statusManager.getRestaurantStatus(
//         vendorModel.value.workingHours,
//         vendorModel.value.isOpen,
//       );
//       restaurantStatus.assignAll(status);
//       isOpen.value = status['isOpen'];
//     }
//
//     return Map<String, dynamic>.from(restaurantStatus);
//   }
//
//   /// **CHECK IF RESTAURANT ACCEPTS ORDERS**
//   ///
//   /// Uses the failproof system to determine if orders can be accepted
//   bool canAcceptOrders() {
//     return isOpen.value;
//   }
//
//   /// **GET NEXT OPENING TIME**
//   String? getNextOpeningTime() {
//     final status = getRestaurantStatusInfo();
//     return status['nextOpeningTime'];
//   }
//
//   /// **GET STATUS SUMMARY FOR DEBUGGING**
//   String getStatusSummary() {
//     final statusManager = RestaurantStatusManager();
//     return statusManager.getStatusSummary(
//       vendorModel.value.workingHours,
//       vendorModel.value.isOpen,
//     );
//   }
//
//   bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
//     print(startDate);
//     print(endDate);
//     final currentDate = DateTime.now();
//     print(currentDate);
//     return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
//   }
//
//   RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
//   RxList selectedVariants = [].obs;
//   RxList selectedIndexVariants = [].obs;
//   RxList selectedIndexArray = [].obs;
//
//   RxList selectedAddOns = [].obs;
//
//   RxInt quantity = 1.obs;
//
//   calculatePrice(ProductModel productModel) {
//     String mainPrice = "0";
//     String variantPrice = "0";
//     String adOnsPrice = "0";
//
//     if (productModel.itemAttribute != null) {
//       if (productModel.itemAttribute!.variants!
//           .where((element) => element.variantSku == selectedVariants.join('-'))
//           .isNotEmpty) {
//         variantPrice = Constant.productCommissionPrice(
//             vendorModel.value,
//             productModel.itemAttribute!.variants!
//                     .where((element) =>
//                         element.variantSku == selectedVariants.join('-'))
//                     .first
//                     .variantPrice ??
//                 '0');
//       }
//     } else {
//       String price = Constant.productCommissionPrice(
//           vendorModel.value, productModel.price.toString());
//       String disPrice = double.parse(productModel.disPrice.toString()) <= 0
//           ? "0"
//           : Constant.productCommissionPrice(
//               vendorModel.value, productModel.disPrice.toString());
//       if (double.parse(disPrice) <= 0) {
//         variantPrice = price;
//       } else {
//         variantPrice = disPrice;
//       }
//     }
//
//     for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
//       if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true) {
//         adOnsPrice = (double.parse(adOnsPrice.toString()) +
//                 double.parse(Constant.productCommissionPrice(vendorModel.value,
//                     productModel.addOnsPrice![i].toString())))
//             .toString();
//       }
//     }
//     adOnsPrice = (quantity.value * double.parse(adOnsPrice)).toString();
//     mainPrice = ((double.parse(variantPrice.toString()) *
//                 double.parse(quantity.value.toString())) +
//             double.parse(adOnsPrice.toString()))
//         .toString();
//     return mainPrice;
//   }
//
//   getAttributeData() async {
//     await FireStoreUtils.getAttributes().then((value) {
//       if (value != null) {
//         attributesList.value = value;
//       }
//     });
//   }
//
//   addToCart({
//     required ProductModel productModel,
//     required String price,
//     required String discountPrice,
//     required bool isIncrement,
//     required int quantity,
//     VariantInfo? variantInfo,
//   }) async {
//     // **CHECK PROMOTIONAL ITEM LIMIT BEFORE ADDING TO CART (OPTIMIZED)**
//     if (isIncrement) {
//       // **PERFORMANCE FIX: Use cached promotional data instead of Firebase query**
//       final promo = _getCachedPromotionalData(
//         productModel.id ?? '',
//         vendorModel.value.id ?? '',
//       );
//
//       print(
//           'DEBUG: RestaurantDetailsController - Checking promotional item: ${productModel.id}');
//       print('DEBUG: RestaurantDetailsController - Promo data: $promo');
//
//       if (promo != null) {
//         // **PERFORMANCE FIX: Use cached availability check (instant)**
//         final isAllowed = isPromotionalItemQuantityAllowed(
//             productModel.id ?? '', vendorModel.value.id ?? '', quantity);
//
//         if (!isAllowed) {
//           // **PERFORMANCE FIX: Use cached limit (instant)**
//           final limit = getPromotionalItemLimit(
//               productModel.id ?? '', vendorModel.value.id ?? '');
//           ShowToastDialog.showToast(
//               "Maximum $limit items allowed for this promotional offer".tr);
//           return; // Don't add to cart if limit exceeded
//         }
//       } else {
//         print(
//             'DEBUG: RestaurantDetailsController - No promotional data found for product: ${productModel.id}');
//       }
//     }
//
//     CartProductModel cartProductModel = CartProductModel();
//
//     String adOnsPrice = "0";
//     for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
//       if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true &&
//           productModel.addOnsPrice![i] != '0') {
//         adOnsPrice = (double.parse(adOnsPrice.toString()) +
//                 double.parse(Constant.productCommissionPrice(vendorModel.value,
//                     productModel.addOnsPrice![i].toString())))
//             .toString();
//       }
//     }
//
//     if (variantInfo != null) {
//       cartProductModel.id =
//           "${productModel.id!}~${variantInfo.variantId.toString()}";
//       cartProductModel.name = productModel.name!;
//       cartProductModel.photo = productModel.photo!;
//       cartProductModel.categoryId = productModel.categoryID!;
//       cartProductModel.price = price;
//       cartProductModel.discountPrice = discountPrice;
//       cartProductModel.vendorID = vendorModel.value.id;
//       cartProductModel.vendorName = vendorModel.value.title;
//       cartProductModel.quantity = quantity;
//       cartProductModel.variantInfo = variantInfo;
//       cartProductModel.extrasPrice = adOnsPrice;
//       cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
//
//       // Set promoId for promotional items (OPTIMIZED)
//       if (isIncrement) {
//         // **PERFORMANCE FIX: Use cached promotional data instead of Firebase query**
//         final promo = _getCachedPromotionalData(
//           productModel.id ?? '',
//           vendorModel.value.id ?? '',
//         );
//         if (promo != null) {
//           cartProductModel.promoId = promo['product_id'] ?? '';
//           print(
//               'DEBUG: RestaurantDetailsController - Set promoId for variant: ${cartProductModel.promoId}');
//         }
//       }
//     } else {
//       cartProductModel.id = productModel.id!;
//       cartProductModel.name = productModel.name!;
//       cartProductModel.photo = productModel.photo!;
//       cartProductModel.categoryId = productModel.categoryID!;
//       cartProductModel.price = price;
//       cartProductModel.discountPrice = discountPrice;
//       cartProductModel.vendorID = vendorModel.value.id;
//       cartProductModel.vendorName = vendorModel.value.title;
//       cartProductModel.quantity = quantity;
//       cartProductModel.variantInfo = VariantInfo();
//       cartProductModel.extrasPrice = adOnsPrice;
//       cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
//
//       // Set promoId for promotional items
//       if (isIncrement) {
//         final promo = await FireStoreUtils.getActivePromotionForProduct(
//           productId: productModel.id ?? '',
//           restaurantId: vendorModel.value.id ?? '',
//         );
//         if (promo != null) {
//           cartProductModel.promoId = promo['product_id'] ?? '';
//           print(
//               'DEBUG: RestaurantDetailsController - Set promoId: ${cartProductModel.promoId}');
//         }
//       }
//     }
//
//     if (isIncrement) {
//       await cartProvider.addToCart(Get.context!, cartProductModel, quantity);
//     } else {
//       await cartProvider.removeFromCart(cartProductModel, quantity);
//     }
//     log("===> new ${cartItem.length}");
//     update();
//   }
//
//   // Method to scroll to a specific product
//   void scrollToProduct(String productId) {
//     print("DEBUG: scrollToProduct called with productId: $productId");
//     print(
//         "DEBUG: scrollController has clients: ${scrollController.value.hasClients}");
//     print("DEBUG: productList length: ${productList.length}");
//
//     if (scrollController.value.hasClients) {
//       // Find the index of the product in the product list
//       int productIndex = -1;
//       for (int i = 0; i < productList.length; i++) {
//         if (productList[i].id == productId) {
//           productIndex = i;
//           break;
//         }
//       }
//
//       if (productIndex != -1) {
//         // Calculate approximate position (each product card is roughly 120px height)
//         double scrollPosition = productIndex * 120.0;
//
//         // Add some offset for better visibility
//         scrollPosition = scrollPosition - 100.0;
//         if (scrollPosition < 0) scrollPosition = 0;
//
//         scrollController.value.animateTo(
//           scrollPosition,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut,
//         );
//
//         print(
//             "DEBUG: Scrolled to product $productId at position $scrollPosition");
//       } else {
//         print("DEBUG: Product $productId not found in product list");
//       }
//     }
//   }
//
//   // Method to scroll to product after data is loaded
//   void scrollToProductAfterLoad() {
//     if (scrollToProductId != null && shouldScrollToProduct.value) {
//       print("DEBUG: Will scroll to product: $scrollToProductId");
//       // Wait a bit for the UI to be ready
//       Future.delayed(const Duration(milliseconds: 500), () {
//         print("DEBUG: Attempting to scroll to product: $scrollToProductId");
//         scrollToProduct(scrollToProductId!);
//         shouldScrollToProduct.value = false;
//       });
//     }
//   }
//
//   @override
//   void onClose() {
//     try {
//       if (pageController.value.hasClients) {
//         pageController.value.dispose();
//       }
//     } catch (e) {
//       // Ignore disposal errors
//     }
//
//     // Print performance report when controller is closed
//     // PerformanceMonitor.printPerformanceReport();
//
//     super.onClose();
//   }
//
//   /// **CACHE DIAGNOSTICS FOR TESTING**
//   Future<void> _logCacheDiagnostics() async {
//     if (!kDebugMode) return;
//
//     try {
//       final vendorId = vendorModel.value.id;
//       final cacheKey = 'restaurant_products_$vendorId';
//
//       print("🔍 CACHE DIAGNOSTICS:");
//       print("📋 Vendor ID: $vendorId");
//       print("🔑 Cache Key: $cacheKey");
//       print("📊 Products Loaded: ${productList.length}");
//       print(
//           "💾 Cache Status: ${CacheManager.hasCache(cacheKey) ? 'HIT' : 'MISS'}");
//
//       if (CacheManager.hasCache(cacheKey)) {
//         final cachedData = await CacheManager.get<List<dynamic>>(cacheKey);
//         print("📦 Cached Products: ${cachedData?.length ?? 0}");
//         print("⏰ Cache Age: ${CacheManager.getCacheAge(cacheKey)}");
//       }
//
//       print("🔍 END CACHE DIAGNOSTICS");
//     } catch (e) {
//       print("❌ Cache diagnostics error: $e");
//     }
//   }
// }
