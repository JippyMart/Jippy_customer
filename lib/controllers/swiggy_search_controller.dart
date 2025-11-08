import 'package:get/get.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/trie_search.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SwiggySearchController extends GetxController {


  ////SEEAR

  /// **CLEAR RECENT SEARCHES**
  void clearRecentSearches() {
    try {
      print("🗑️ Clearing recent searches...");

      // Clear the observable list
      recentSearches.clear();

      // Clear from shared preferences
      _clearRecentSearchesFromStorage();

      print("✅ Recent searches cleared successfully");

    } catch (e) {
      print("❌ Error clearing recent searches: $e");
    }
  }

  /// **CLEAR RECENT SEARCHES FROM STORAGE**
  Future<void> _clearRecentSearchesFromStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      print("✅ Recent searches cleared from storage");
    } catch (e) {
      print("❌ Error clearing recent searches from storage: $e");
    }
  }
  final TrieSearch trieSearch = TrieSearch();

  // **OBSERVABLE VARIABLES**
  var recentSearches = <String>[].obs;
  var trendingSearches = <String>[].obs;
  var restaurantResults = <VendorModel>[].obs;
  var productResults = <ProductModel>[].obs;
  var categoryResults = <VendorCategoryModel>[].obs;
  var searchSuggestions = <String>[].obs;

  // **SEARCH STATE**
  var isSearching = false.obs;
  var showSuggestions = false.obs;
  var searchText = ''.obs;
  var hasSearched = false.obs;

  // **LOADING STATE**
  var isLoadingData = false.obs;
  var dataLoaded = false.obs;

  // **PAGINATION STATE**
  var isLoadingMore = false.obs;
  var hasMoreResults = true.obs;
  var currentResultCount = 0.obs;
  var totalAvailableResults = 0.obs;

  // **REMAINING RESULTS FOR PAGINATION**
  List<ProductModel> _remainingProducts = [];
  List<VendorModel> _remainingRestaurants = [];
  List<VendorCategoryModel> _remainingCategories = [];

  // **FIRESTORE PAGINATION CURSORS**
  DocumentSnapshot? _lastVendorDocument;
  DocumentSnapshot? _lastProductDocument;
  DocumentSnapshot? _lastCategoryDocument;

  // **DEBOUNCE TIMER**
  Timer? _debounceTimer;
  Timer? _searchTimer;

  // **CONSTANTS - MEMORY SAFE LIMITS TO PREVENT CRASHES**
  static const int MAX_RECENT_SEARCHES = 10;
  static const int MAX_SUGGESTIONS = 8;
  static const int INITIAL_PRODUCTS = 100; // Show only 8 products initially to ensure Load More button shows
  static const int INITIAL_RESTAURANTS = 10; // Show only 5 restaurants initially to ensure Load More button shows
  static const int LOAD_MORE_RESULTS = 10; // Load 5 more at a time
  static const int MAX_TOTAL_RESULTS = 1000; // Increased to match admin panel results
  static const Duration DEBOUNCE_DELAY = Duration(milliseconds: 300);

  // **MEMORY SAFE LIMITS - INCREASED TO MATCH ADMIN PANEL**
  static const int FAST_VENDOR_LIMIT = 500; // Increased to show more vendors
  static const int FAST_PRODUCT_LIMIT = 800; // Increased to show more products
  static const int MAX_VENDORS_PER_SEARCH = 500; // Increased to show more vendors in search
  static const int MAX_PRODUCTS_PER_SEARCH = 800; // Increased to show more products in search
  static const int SUGGESTION_LIMIT = 10; // Maximum suggestions to show

  // **ENHANCED MULTI-COLLECTION SEARCH LIMITS - INCREASED TO MATCH ADMIN PANEL**
  static const int RESTAURANT_SEARCH_LIMIT = 500; // Restaurants per search (increased from 50)
  static const int PRODUCT_SEARCH_LIMIT = 800; // Products per search (increased from 100)
  static const int CATEGORY_SEARCH_LIMIT = 200; // Categories per search (increased from 20)

  @override
  void onInit() {
    super.onInit();
    _initializeSearch();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _searchTimer?.cancel();
    super.onClose();
  }

  /// **INITIALIZE SEARCH SYSTEM**
  Future<void> _initializeSearch() async {
    try {
      isLoadingData.value = true;

      // Load recent searches from storage (fast)
      await _loadRecentSearches();

      // Load trending searches (fast)
      await _loadTrendingSearches();

      // Show initial state immediately
      isLoadingData.value = false;

      // Load and index data in background (slow)
      _loadAndIndexDataInBackground();

      print("✅ Swiggy Search initialized successfully");

    } catch (e) {
      print("❌ Search initialization failed: $e");
      isLoadingData.value = false;
    }
  }

  /// **LOAD AND INDEX DATA IN BACKGROUND**
  Future<void> _loadAndIndexDataInBackground() async {
    try {
      print("🔄 Loading initial data in background...");
      await _loadAndIndexData();
      dataLoaded.value = true;
      print("✅ Initial background data loading completed");
      print("📊 Indexed items: ${trieSearch.itemCount}");

      // Check if data was loaded successfully
      if (trieSearch.itemCount == 0) {
        print("⚠️ No data loaded from database - search will use direct Firestore queries");
      }

      // Test the Trie with a simple search
      _testTrieSearch();

      // Continue loading more data progressively
      _loadMoreDataProgressively();
    } catch (e) {
      print("❌ Background data loading failed: $e");
    }
  }


  /// **TEST TRIE SEARCH**
  void _testTrieSearch() {
    try {
      print("🧪 Testing Trie search...");

      // Test with common search terms
      var testQueries = ["pizza", "biryani", "chicken", "spicy", "restaurant"];

      for (var query in testQueries) {
        var results = trieSearch.search(query);
        print("🧪 Test search '$query': ${results.length} results");
      }

    } catch (e) {
      print("❌ Trie test failed: $e");
    }
  }

  /// **DIRECT SEARCH FALLBACK - ENHANCED**
  List<dynamic> _directSearch(String query) {
    try {
      print("🔍 Performing enhanced direct search for: '$query'");
      List<dynamic> results = [];
      final lowerQuery = query.toLowerCase();

      // Search in current results first
      for (var product in productResults) {
        if (product.name != null && product.name!.toLowerCase().contains(lowerQuery)) {
          results.add(product);
        }
      }

      for (var restaurant in restaurantResults) {
        if (restaurant.title != null && restaurant.title!.toLowerCase().contains(lowerQuery)) {
          results.add(restaurant);
        }
      }

      // If no results in current lists, try to fetch fresh data
      if (results.isEmpty) {
        print("🔍 No results in current lists, trying fresh data fetch...");
        _performFreshDataSearch(query, results);
      }

      print("🔍 Enhanced direct search found ${results.length} results");
      return results;

    } catch (e) {
      print("❌ Enhanced direct search failed: $e");
      return [];
    }
  }

  /// **PERFORM FRESH DATA SEARCH**
  Future<void> _performFreshDataSearch(String query, List<dynamic> results) async {
    try {
      final lowerQuery = query.toLowerCase();
      // Try to get fresh products
      try {
        List<ProductModel> freshProducts = await FireStoreUtils.getAllProducts(limit: 200);
        for (var product in freshProducts) {
          if (product.name != null && product.name!.toLowerCase().contains(lowerQuery)) {
            results.add(product);
          }
        }
        print("🔍 Fresh products search found ${results.where((r) => r is ProductModel).length} products");
      } catch (e) {
        print("❌ Fresh products search failed: $e");
      }

      // Try to get fresh vendors
      try {
        List<VendorModel> freshVendors = await FireStoreUtils.getAllVendors(limit: 100);
        for (var vendor in freshVendors) {
          if (vendor.title != null && vendor.title!.toLowerCase().contains(lowerQuery)) {
            results.add(vendor);
          }
        }
        print("🔍 Fresh vendors search found ${results.where((r) => r is VendorModel).length} vendors");
      } catch (e) {
        print("❌ Fresh vendors search failed: $e");
      }

    } catch (e) {
      print("❌ Fresh data search failed: $e");
    }
  }


  /// **LOAD MORE DATA PROGRESSIVELY IN BACKGROUND - MEMORY OPTIMIZED**
  Future<void> _loadMoreDataProgressively() async {
    try {
      print("🔄 Loading additional data progressively (memory optimized)...");

      // **MEMORY SAFE: Use smaller limits for progressive loading**
      // Load more vendors with strict limits
      List<VendorModel> moreVendors = await FireStoreUtils.getAllVendors(limit: 10); // Reduced from 30 to 10
      for (var vendor in moreVendors) {
        if (vendor.title != null && vendor.title!.isNotEmpty) {
          trieSearch.insert(vendor.title!, vendor, relevanceScore: 1.5);
        }
      }

      // Load more products with strict limits
      List<ProductModel> moreProducts = await FireStoreUtils.getAllProducts(limit: 15); // Reduced from 50 to 15
      for (var product in moreProducts) {
        if (product.name != null && product.name!.isNotEmpty) {
          trieSearch.insert(product.name!, product, relevanceScore: 2.0);
        }
      }

      print("✅ Progressive data loading completed (memory optimized)");
      print("📊 Total indexed items: ${trieSearch.itemCount}");
    } catch (e) {
      print("❌ Progressive data loading failed: $e");
      if (e.toString().contains('OutOfMemoryError')) {
        print("🚨 OutOfMemoryError detected! Stopping progressive loading to prevent crash.");
      }
    }
  }

  /// **LOAD VENDORS + PRODUCTS INTO TRIE (MEMORY EFFICIENT)**
  Future<void> _loadAndIndexData() async {
    try {
      print("🔄 Loading and indexing data (memory efficient)...");

      // Clear existing data
      trieSearch.clear();

      // Load vendors in smaller batches to prevent memory issues
      await _loadVendorsInBatches();

      // Load products in smaller batches to prevent memory issues
      await _loadProductsInBatches();

      print("✅ Data loading completed successfully");

    } catch (e) {
      print("❌ Error loading data: $e");
      // Don't rethrow to prevent app crash
    }
  }

  /// **LOAD VENDORS IN BATCHES - MEMORY OPTIMIZED**
  Future<void> _loadVendorsInBatches() async {
    try {
      print("🔄 Loading vendors in batches (memory optimized)...");

      // **MEMORY SAFETY: Use strict limits to prevent OutOfMemoryError**
      List<VendorModel> vendors = await FireStoreUtils.getAllVendors(limit: FAST_VENDOR_LIMIT);
      print("📊 Loaded ${vendors.length} vendors (memory safe limit: $FAST_VENDOR_LIMIT)");

      // Debug: Print first few vendor names
      if (vendors.isNotEmpty) {
        print("  First few vendor names:");
        for (int i = 0; i < (vendors.length > 3 ? 3 : vendors.length); i++) {
          print("    - ${vendors[i].title} (ID: ${vendors[i].id})");
        }
      } else {
        print("  ⚠️ No vendors loaded!");
      }

      // **MEMORY EFFICIENT: Index only essential fields to reduce memory usage**
      for (var vendor in vendors) {
        if (vendor.title != null && vendor.title!.isNotEmpty) {
          // Lower relevance for restaurants (1.5) - products get priority
          trieSearch.insert(vendor.title!, vendor, relevanceScore: 1.5);

          // **OPTIMIZED: Only index location if it's not too long (memory safety)**
          if (vendor.location != null && vendor.location!.isNotEmpty && vendor.location!.length < 50) {
            trieSearch.insert(vendor.location!, vendor, relevanceScore: 1.5);
          }

          // **OPTIMIZED: Only index description if it's short (memory safety)**
          if (vendor.description != null && vendor.description!.isNotEmpty && vendor.description!.length < 100) {
            trieSearch.insert(vendor.description!, vendor, relevanceScore: 1.3);
          }

          // **OPTIMIZED: Limit category indexing to prevent memory bloat**
          if (vendor.categoryTitle != null && vendor.categoryTitle!.isNotEmpty) {
            for (var category in vendor.categoryTitle!.take(3)) { // Limit to 3 categories
              if (category.toString().length < 30) { // Only short category names
                trieSearch.insert(category.toString(), vendor, relevanceScore: 1.4);
              }
            }
          }
        }
      }

      print("✅ Indexed ${vendors.length} vendors (memory optimized)");
      print("🔍 Total Trie items after vendors: ${trieSearch.itemCount}");

    } catch (e) {
      print("❌ Error loading vendors: $e");
      if (e.toString().contains('OutOfMemoryError')) {
        print("🚨 OutOfMemoryError detected! Skipping vendor indexing to prevent crash.");
      }
    }
  }

  /// **LOAD PRODUCTS IN BATCHES - MEMORY OPTIMIZED**
  Future<void> _loadProductsInBatches() async {
    try {
      print("🔄 Loading products in batches (memory optimized)...");

      // **MEMORY SAFETY: Use strict limits to prevent OutOfMemoryError**
      List<ProductModel> products = await FireStoreUtils.getAllProducts(limit: FAST_PRODUCT_LIMIT);
      print("📊 Loaded ${products.length} products (memory safe limit: $FAST_PRODUCT_LIMIT)");

      for (var product in products) {
        if (product.name != null && product.name!.isNotEmpty) {
          // Higher relevance for products (2.0) - products get priority
          trieSearch.insert(product.name!, product, relevanceScore: 2.0);

          // **OPTIMIZED: Only index description if it's short (memory safety)**
          if (product.description != null && product.description!.isNotEmpty && product.description!.length < 100) {
            trieSearch.insert(product.description!, product, relevanceScore: 1.8);
          }

          // **OPTIMIZED: Only index category if it's not too long**
          if (product.categoryID != null && product.categoryID!.isNotEmpty && product.categoryID!.length < 30) {
            trieSearch.insert(product.categoryID!, product, relevanceScore: 1.7);
          }

          // **OPTIMIZED: Limit add-ons indexing to prevent memory bloat**
          if (product.addOnsTitle != null && product.addOnsTitle!.isNotEmpty) {
            for (var addon in product.addOnsTitle!.take(2)) { // Limit to 2 add-ons
              if (addon.toString().length < 20) { // Only short add-on names
                trieSearch.insert(addon.toString(), product, relevanceScore: 1.6);
              }
            }
          }

          // **OPTIMIZED: Only index specifications if they're short**
          if (product.productSpecification != null && product.productSpecification!.isNotEmpty && product.productSpecification.toString().length < 50) {
            trieSearch.insert(product.productSpecification.toString(), product, relevanceScore: 1.5);
          }

          // **OPTIMIZED: Index veg/non-veg (these are short and useful)**
          if (product.veg != null && product.veg!) {
            trieSearch.insert("vegetarian", product, relevanceScore: 1.4);
            trieSearch.insert("veg", product, relevanceScore: 1.4);
          }
          if (product.nonveg != null && product.nonveg!) {
            trieSearch.insert("non-vegetarian", product, relevanceScore: 1.4);
            trieSearch.insert("nonveg", product, relevanceScore: 1.4);
          }
        }
      }

      print("✅ Indexed ${products.length} products (memory optimized)");
      print("🔍 Total Trie items after products: ${trieSearch.itemCount}");

    } catch (e) {
      print("❌ Error loading products: $e");
      if (e.toString().contains('OutOfMemoryError')) {
        print("🚨 OutOfMemoryError detected! Skipping product indexing to prevent crash.");
      }
    }
  }

  /// **LOAD TRENDING SEARCHES**
  Future<void> _loadTrendingSearches() async {
    try {
      // Try to get trending searches from backend
      List<String> trending = await FireStoreUtils.getTrendingSearches();
      trendingSearches.assignAll(trending);
    } catch (e) {
      print("❌ Error loading trending searches: $e");
      // Fallback to static trending searches
      trendingSearches.assignAll([
        "Pizza", "Biryani", "Burgers", "Coffee", "Ice Cream",
        "Chinese", "Italian", "South Indian", "Fast Food", "Desserts",
        "Chicken", "Vegetarian", "Spicy", "Sweet", "Healthy"
      ]);
    }
  }

  /// **LOAD RECENT SEARCHES FROM STORAGE**
  Future<void> _loadRecentSearches() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? saved = prefs.getStringList('recent_searches');
      if (saved != null) {
        recentSearches.assignAll(saved);
      }
    } catch (e) {
      print("❌ Error loading recent searches: $e");
    }
  }

  /// **SAVE RECENT SEARCHES TO STORAGE**
  Future<void> _saveRecentSearches() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_searches', recentSearches);
    } catch (e) {
      print("❌ Error saving recent searches: $e");
    }
  }

  /// **MAIN SEARCH FUNCTION - ENHANCED MULTI-COLLECTION SEARCH**
  void search(String query) {
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    try {
      print("🔍 Searching for: '$query' (using enhanced multi-collection search)");
      // **ENHANCED: Use multi-collection search with grouped results**
      performEnhancedMultiCollectionSearch(query);

    } catch (e) {
      print("❌ Search error: $e");
      isSearching.value = false;
    }
  }

  /// **PROCESS SEARCH RESULTS AND SEPARATE BY TYPE**
  void _processSearchResults(List<dynamic> results) {
    // Separate results by type
    List<VendorModel> restaurants = [];
    List<ProductModel> products = [];
    List<VendorCategoryModel> categories = [];

    for (var result in results) {
      if (result is VendorModel) {
        restaurants.add(result);
      } else if (result is ProductModel) {
        products.add(result);
      } else if (result is VendorCategoryModel) {
        categories.add(result);
      }
    }

    // Sort products first, then restaurants
    products.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
    restaurants.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));

    // Take initial results
    var initialProducts = products.take(INITIAL_PRODUCTS).toList();
    var initialRestaurants = restaurants.take(INITIAL_RESTAURANTS).toList();

    // Store remaining for pagination
    _remainingProducts = products.skip(INITIAL_PRODUCTS).toList();
    _remainingRestaurants = restaurants.skip(INITIAL_RESTAURANTS).toList();
    _remainingCategories = categories;

    // Update observable lists
    productResults.assignAll(initialProducts);
    restaurantResults.assignAll(initialRestaurants);
    categoryResults.assignAll(categories);

    // Update counts
    currentResultCount.value = initialProducts.length + initialRestaurants.length + categories.length;
    totalAvailableResults.value = results.length;

    // Check if there are more results
    hasMoreResults.value = _remainingProducts.isNotEmpty || _remainingRestaurants.isNotEmpty || _remainingCategories.isNotEmpty;

    // Fallback: If we have any results, show Load More button (for better UX)
    if (!hasMoreResults.value && (initialProducts.isNotEmpty || initialRestaurants.isNotEmpty || categories.isNotEmpty)) {
      hasMoreResults.value = true;
      print("📊 Fallback: Showing Load More button for better UX");
    }

    print("📊 Search results: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${categories.length} categories");
    print("📊 Remaining: ${_remainingProducts.length} products, ${_remainingRestaurants.length} restaurants, ${_remainingCategories.length} categories");
    print("📊 Has more results: ${hasMoreResults.value}");
  }

  /// **CLEAR SEARCH RESULTS**
  void _clearSearchResults() {
    restaurantResults.clear();
    productResults.clear();
    categoryResults.clear();
    hasSearched.value = false;
    isSearching.value = false;
    showSuggestions.value = false;
    currentResultCount.value = 0;
    hasMoreResults.value = true;
    _remainingProducts.clear();
    _remainingRestaurants.clear();
    _remainingCategories.clear();
  }

  /// **CLEAR SEARCH (PUBLIC METHOD)**
  void clearSearch() {
    searchText.value = '';
    _clearSearchResults();
  }

  /// **DEBUG METHOD - Show all loaded restaurants**
  void debugShowAllRestaurants() async {
    try {
      var allRestaurants = await FireStoreUtils.getAllVendors();
      print("🔍 DEBUG: All loaded restaurants (${allRestaurants.length}):");
      for (int i = 0; i < allRestaurants.length; i++) {
        var r = allRestaurants[i];
        print("  ${i + 1}. '${r.title}' (ID: ${r.id})");
      }
    } catch (e) {
      print("❌ Error loading restaurants for debug: $e");
    }
  }

  /// **DEBUG METHOD - Test restaurant search**
  void debugTestRestaurantSearch(String query) async {
    try {
      print("🔍 DEBUG: Testing restaurant search for '$query'");
      var allRestaurants = await FireStoreUtils.getAllVendors();
      var lowerQuery = query.toLowerCase();

      print("Total restaurants loaded: ${allRestaurants.length}");

      var matches = allRestaurants.where((r) =>
      (r.title != null && r.title!.toLowerCase().contains(lowerQuery))
      ).toList();

      print("Restaurants matching '$query': ${matches.length}");
      for (var r in matches) {
        print("  - '${r.title}' (ID: ${r.id})");
      }

      if (matches.isEmpty) {
        print("No matches found. Sample restaurant titles:");
        for (int i = 0; i < (allRestaurants.length > 5 ? 5 : allRestaurants.length); i++) {
          print("  ${i + 1}. '${allRestaurants[i].title}'");
        }
      }
    } catch (e) {
      print("❌ Error in debug test: $e");
    }
  }

  /// **LOAD MORE RESULTS (PAGINATION) - ENHANCED MULTI-COLLECTION**
  void loadMoreResults() {
    if (isLoadingMore.value) {
      print("⚠️ Load more already in progress, skipping...");
      return;
    }

    try {
      print("🔄 Loading more results (using enhanced multi-collection search)...");

      // **ENHANCED: Use multi-collection search with increased limits**
      loadMoreResultsEnhanced();

    } catch (e) {
      print("❌ Error loading more results: $e");
    }
  }

  /// **UPDATE SEARCH TEXT AND SHOW SUGGESTIONS**
  void updateSearchText(String text) {
    searchText.value = text;

    // Cancel previous timers
    _debounceTimer?.cancel();
    _searchTimer?.cancel();

    if (text.isEmpty) {
      showSuggestions.value = false;
      return;
    }

    // Debounce the suggestions (fast)
    _debounceTimer = Timer(DEBOUNCE_DELAY, () {
      _updateSuggestions(text);
    });

    // Auto-search after user stops typing (slower)
    _searchTimer = Timer(const Duration(milliseconds: 1500), () {
      if (text.trim().isNotEmpty) {
        print("🔍 Auto-triggering search for: '$text'");
        performSearch(text.trim());
      }
    });
  }

  /// **ON SEARCH TEXT CHANGED (for TextField onChanged)**
  void onSearchTextChanged(String text) {
    updateSearchText(text);
  }

  /// **UPDATE SUGGESTIONS BASED ON SEARCH TEXT - OPTIMIZED**
  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      showSuggestions.value = false;
      return;
    }
    try {
      print("💡 Getting suggestions for: '$query'");

      // **OPTIMIZED: Use Firestore prefix search for suggestions**
      _updateSuggestionsOptimized(query);

    } catch (e) {
      print("❌ Suggestions failed: $e");
      showSuggestions.value = false;
    }
  }

  /// **SAVE RECENT SEARCH**
  void _saveRecentSearch(String query) {
    if (query.isEmpty) return;

    // Remove if already exists
    recentSearches.remove(query);

    // Add to beginning
    recentSearches.insert(0, query);

    // Keep only max recent searches
    if (recentSearches.length > MAX_RECENT_SEARCHES) {
      recentSearches.removeRange(MAX_RECENT_SEARCHES, recentSearches.length);
    }

    // Save to storage
    _saveRecentSearches();
  }

  /// **SELECT A SUGGESTION**
  void selectSuggestion(String suggestion) {
    searchText.value = suggestion;
    showSuggestions.value = false;
    performSearch(suggestion);
  }

  /// **HIDE SUGGESTIONS**
  void hideSuggestions() {
    showSuggestions.value = false;
  }

  /// **PERFORM SEARCH - ENHANCED VERSION (as suggested) - MEMORY OPTIMIZED**
  Future<void> performSearch(String query) async {
    searchText.value = query;
    hasSearched.value = true;
    isLoadingData.value = true;

    if (query.trim().isEmpty) {
      restaurantResults.clear();
      productResults.clear();
      categoryResults.clear();
      isLoadingData.value = false;
      return;
    }

    // **MEMORY SAFETY CHECK: Check if we need emergency cleanup**
    if (!_isMemoryUsageSafe()) {
      print("⚠️ Memory usage unsafe, performing emergency cleanup");
      _emergencyMemoryCleanup();
    }

    final lowerQuery = query.toLowerCase();

    try {
      print("🔍 Enhanced search for: '$query'");

      // 🔎 Get results from Firestore (or local lists)
      List<VendorModel> allRestaurants = [];
      List<ProductModel> allProducts = [];
      List<VendorCategoryModel> allCategories = [];

      // **MEMORY SAFE: Use strict limits to prevent OutOfMemoryError**
      try {
        // **CRITICAL: Use memory-safe limits to prevent crashes**
        allRestaurants = await FireStoreUtils.getAllVendors(limit: MAX_VENDORS_PER_SEARCH); // Limit to 25 restaurants
        allProducts = await FireStoreUtils.getAllProductsInZone(limit: MAX_PRODUCTS_PER_SEARCH); // Limit to 40 products
        allCategories = await FireStoreUtils.getVendorCategory();
        print("🔍 Loaded ${allRestaurants.length} restaurants, ${allProducts.length} products, ${allCategories.length} categories (memory safe)");
      } catch (e) {
        print("❌ Error loading fresh data: $e");
        if (e.toString().contains('OutOfMemoryError')) {
          print("🚨 OutOfMemoryError detected! Using minimal data to prevent crash.");
          // **FALLBACK: Use even smaller limits to prevent further crashes**
          allRestaurants = restaurantResults.take(5).toList();
          allProducts = productResults.take(10).toList();
          allCategories = categoryResults.take(3).toList();
        } else {
          // Use existing data as fallback
          allRestaurants = restaurantResults.toList();
          allProducts = productResults.toList();
          allCategories = categoryResults.toList();
        }
      }

      // ✅ COMPREHENSIVE SEARCH - search in ALL relevant fields based on actual model structure
      var filteredRestaurants = allRestaurants
          .where((r) =>
      (r.title != null && r.title!.toLowerCase().contains(lowerQuery)) ||
          (r.description != null && r.description!.toLowerCase().contains(lowerQuery)) ||
          (r.location != null && r.location!.toLowerCase().contains(lowerQuery)) ||
          (r.categoryTitle != null && r.categoryTitle!.any((cat) => cat.toLowerCase().contains(lowerQuery))) ||
          (r.id != null && r.id!.toLowerCase().contains(lowerQuery)) ||
          (r.phonenumber != null && r.phonenumber!.toLowerCase().contains(lowerQuery)) ||
          (r.vType != null && r.vType!.toLowerCase().contains(lowerQuery))
      )
          .toList();

      var filteredProducts = allProducts
          .where((p) =>
      (p.name != null && p.name!.toLowerCase().contains(lowerQuery)) ||
          (p.description != null && p.description!.toLowerCase().contains(lowerQuery)) ||
          (p.categoryID != null && p.categoryID!.toLowerCase().contains(lowerQuery)) ||
          (p.vendorID != null && p.vendorID!.toLowerCase().contains(lowerQuery)) ||
          (p.id != null && p.id!.toLowerCase().contains(lowerQuery)) ||
          (p.price != null && p.price!.toLowerCase().contains(lowerQuery)) ||
          (p.disPrice != null && p.disPrice!.toLowerCase().contains(lowerQuery))
      )
          .toList();

      var filteredCategories = allCategories
          .where((c) =>
      (c.title != null && c.title!.toLowerCase().contains(lowerQuery)) ||
          (c.description != null && c.description!.toLowerCase().contains(lowerQuery)) ||
          (c.id != null && c.id!.toLowerCase().contains(lowerQuery))
      )
          .toList();

      // Debug: Show comprehensive filtering results
      print("🔍 COMPREHENSIVE SEARCH RESULTS for '$query':");
      print("  📍 RESTAURANT MATCHES: ${filteredRestaurants.length} out of ${allRestaurants.length}");
      print("    - Searched in: title, description, location, categoryTitle, id, phonenumber, vType");
      print("  🍕 PRODUCT MATCHES: ${filteredProducts.length} out of ${allProducts.length}");
      print("    - Searched in: name, description, categoryID, vendorID, id, price, disPrice");
      print("  📂 CATEGORY MATCHES: ${filteredCategories.length} out of ${allCategories.length}");
      print("    - Searched in: title, description, id");

      // Enhanced debugging for restaurant search issues
      if (filteredRestaurants.isEmpty && allRestaurants.isNotEmpty) {
        print("🔍 DEBUG: No restaurant matches found. Checking sample restaurant data:");
        for (int i = 0; i < (allRestaurants.length > 3 ? 3 : allRestaurants.length); i++) {
          var r = allRestaurants[i];
          print("  Restaurant ${i + 1}:");
          print("    - Title: '${r.title}'");
          print("    - Description: '${r.description}'");
          print("    - Location: '${r.location}'");
          print("    - CategoryTitle: ${r.categoryTitle}");
          print("    - ID: '${r.id}'");
          print("    - Phone: '${r.phonenumber}'");
          print("    - vType: '${r.vType}'");
          print("    - Query: '$lowerQuery'");
          print("    - Title contains query: ${r.title?.toLowerCase().contains(lowerQuery) ?? false}");
          print("    - Description contains query: ${r.description?.toLowerCase().contains(lowerQuery) ?? false}");
        }
      }

      // Show sample matches for debugging
      if (filteredRestaurants.isNotEmpty) {
        print("  📍 Sample restaurant matches:");
        for (int i = 0; i < (filteredRestaurants.length > 3 ? 3 : filteredRestaurants.length); i++) {
          var r = filteredRestaurants[i];
          print("    - ${r.title} (${r.location})");
        }
      }

      if (filteredProducts.isNotEmpty) {
        print("  🍕 Sample product matches:");
        for (int i = 0; i < (filteredProducts.length > 3 ? 3 : filteredProducts.length); i++) {
          var p = filteredProducts[i];
          print("    - ${p.name} (₹${p.price})");
        }
      }

      if (filteredCategories.isNotEmpty) {
        print("  📂 Sample category matches:");
        for (int i = 0; i < (filteredCategories.length > 3 ? 3 : filteredCategories.length); i++) {
          var c = filteredCategories[i];
          print("    - ${c.title}");
        }
      }

      // If no results found, try partial/fuzzy matching
      if (filteredRestaurants.isEmpty && filteredProducts.isEmpty && filteredCategories.isEmpty) {
        print("🔍 No exact matches found, trying partial/fuzzy matching...");

        // Try partial word matching
        var words = lowerQuery.split(' ');
        for (String word in words) {
          if (word.length > 2) { // Only search words longer than 2 characters
            // Partial restaurant matches
            var partialRestaurants = allRestaurants
                .where((r) =>
            (r.title != null && r.title!.toLowerCase().contains(word)) ||
                (r.description != null && r.description!.toLowerCase().contains(word)) ||
                (r.location != null && r.location!.toLowerCase().contains(word)) ||
                (r.categoryTitle != null && r.categoryTitle!.any((cat) => cat.toLowerCase().contains(word))) ||
                (r.phonenumber != null && r.phonenumber!.toLowerCase().contains(word)) ||
                (r.vType != null && r.vType!.toLowerCase().contains(word))
            )
                .toList();
            filteredRestaurants.addAll(partialRestaurants);

            // Partial product matches
            var partialProducts = allProducts
                .where((p) =>
            (p.name != null && p.name!.toLowerCase().contains(word)) ||
                (p.description != null && p.description!.toLowerCase().contains(word)) ||
                (p.price != null && p.price!.toLowerCase().contains(word)) ||
                (p.disPrice != null && p.disPrice!.toLowerCase().contains(word))
            )
                .toList();
            filteredProducts.addAll(partialProducts);

            // Partial category matches
            var partialCategories = allCategories
                .where((c) =>
            (c.title != null && c.title!.toLowerCase().contains(word)) ||
                (c.description != null && c.description!.toLowerCase().contains(word))
            )
                .toList();
            filteredCategories.addAll(partialCategories);
          }
        }

        // Remove duplicates
        filteredRestaurants = filteredRestaurants.toSet().toList();
        filteredProducts = filteredProducts.toSet().toList();
        filteredCategories = filteredCategories.toSet().toList();

        print("🔍 After partial matching:");
        print("  - Partial restaurant matches: ${filteredRestaurants.length}");
        print("  - Partial product matches: ${filteredProducts.length}");
        print("  - Partial category matches: ${filteredCategories.length}");

        // If still no results, log the issue
        if (filteredRestaurants.isEmpty && filteredProducts.isEmpty && filteredCategories.isEmpty) {
          print("🔍 No matches found in database - this is expected if no data is loaded");
        }
      }

      // Sort results by relevance (products first, then restaurants, then categories)
      filteredProducts.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      filteredRestaurants.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      filteredCategories.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));

      // Show ALL matching results - no artificial limits
      // For initial display, show a reasonable number but keep ALL results available
      int initialDisplayLimit = 50; // Show first 50 of each type initially

      // Take initial results for display (but keep ALL results available)
      var initialProducts = filteredProducts.take(initialDisplayLimit).toList();
      var initialRestaurants = filteredRestaurants.take(initialDisplayLimit).toList();
      var initialCategories = filteredCategories.take(initialDisplayLimit).toList();

      // Store ALL remaining results for pagination (no artificial limits)
      _remainingProducts = filteredProducts.skip(initialDisplayLimit).toList();
      _remainingRestaurants = filteredRestaurants.skip(initialDisplayLimit).toList();
      _remainingCategories = filteredCategories.skip(initialDisplayLimit).toList();

      // Update observable lists
      productResults.assignAll(initialProducts);
      restaurantResults.assignAll(initialRestaurants);
      categoryResults.assignAll(initialCategories);

      // Update counts
      currentResultCount.value = initialProducts.length + initialRestaurants.length + initialCategories.length;
      totalAvailableResults.value = filteredProducts.length + filteredRestaurants.length + filteredCategories.length;

      // Check if there are more results
      hasMoreResults.value = _remainingProducts.isNotEmpty || _remainingRestaurants.isNotEmpty || _remainingCategories.isNotEmpty;

      // Debug: Print comprehensive search results
      print("📊 Comprehensive Search Results:");
      print("  - Total available: ${totalAvailableResults.value} results");
      print("  - ALL products found: ${filteredProducts.length}");
      print("  - ALL restaurants found: ${filteredRestaurants.length}");
      print("  - ALL categories found: ${filteredCategories.length}");
      print("  - Initial display: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${initialCategories.length} categories");
      print("  - Remaining products: ${_remainingProducts.length}");
      print("  - Remaining restaurants: ${_remainingRestaurants.length}");
      print("  - Remaining categories: ${_remainingCategories.length}");
      print("  - Has more results: ${hasMoreResults.value}");

      // Fallback: If we have any results but no remaining, still show Load More for better UX
      if (!hasMoreResults.value && (initialProducts.isNotEmpty || initialRestaurants.isNotEmpty || filteredCategories.isNotEmpty)) {
        hasMoreResults.value = true;
        print("📊 Fallback: Showing Load More button for better UX");
      }

      // Suggestions (optional with TrieSearch)
      try {
        searchSuggestions.value = trieSearch.getSuggestions(lowerQuery, maxSuggestions: MAX_SUGGESTIONS);
      } catch (e) {
        print("❌ Error getting suggestions: $e");
        searchSuggestions.clear();
      }

      // Save to recent searches
      _saveRecentSearch(query);

      print("📊 Enhanced search results: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${filteredCategories.length} categories");
      print("📊 Total available: ${totalAvailableResults.value} results");

      // **MEMORY MONITORING: Log memory usage after search**
      logMemoryUsage("After Search Completion");

    } catch (e) {
      print("❌ Enhanced search error: $e");
      if (e.toString().contains('OutOfMemoryError')) {
        print("🚨 OutOfMemoryError detected! Performing emergency cleanup.");
        _emergencyMemoryCleanup();
      }
    } finally {
      isLoadingData.value = false;
    }
  }

  /// **CLEAR ALL DATA**
  void clearAllData() {
    restaurantResults.clear();
    productResults.clear();
    categoryResults.clear();
    searchSuggestions.clear();
    recentSearches.clear();
    trendingSearches.clear();
    hasSearched.value = false;
    isSearching.value = false;
    showSuggestions.value = false;
    searchText.value = '';
    currentResultCount.value = 0;
    hasMoreResults.value = true;
    dataLoaded.value = false;
    _remainingProducts.clear();
    _remainingRestaurants.clear();
    _remainingCategories.clear();
    trieSearch.clear();
  }

  /// **MEMORY MONITORING - DEBUG METHOD**
  void logMemoryUsage(String context) {
    try {
      print("📊 MEMORY USAGE - $context:");
      print("  - Trie items: ${trieSearch.itemCount}");
      print("  - Restaurant results: ${restaurantResults.length}");
      print("  - Product results: ${productResults.length}");
      print("  - Category results: ${categoryResults.length}");
      print("  - Remaining products: ${_remainingProducts.length}");
      print("  - Remaining restaurants: ${_remainingRestaurants.length}");
      print("  - Remaining categories: ${_remainingCategories.length}");
      print("  - Search suggestions: ${searchSuggestions.length}");
      print("  - Recent searches: ${recentSearches.length}");
    } catch (e) {
      print("❌ Error logging memory usage: $e");
    }
  }

  /// **MEMORY SAFETY CHECK**
  bool _isMemoryUsageSafe() {
    try {
      // Check if we're approaching memory limits
      int totalItems = trieSearch.itemCount +
          restaurantResults.length +
          productResults.length +
          categoryResults.length +
          _remainingProducts.length +
          _remainingRestaurants.length +
          _remainingCategories.length;

      // If we have more than 200 total items, consider it unsafe
      bool isSafe = totalItems < 200;

      if (!isSafe) {
        print("⚠️ Memory usage warning: $totalItems total items (limit: 200)");
      }

      return isSafe;
    } catch (e) {
      print("❌ Error checking memory usage: $e");
      return false; // Assume unsafe if we can't check
    }
  }

  /// **EMERGENCY MEMORY CLEANUP**
  void _emergencyMemoryCleanup() {
    try {
      print("🚨 EMERGENCY MEMORY CLEANUP - Freeing memory to prevent crash");

      // Clear remaining results first (they take most memory)
      _remainingProducts.clear();
      _remainingRestaurants.clear();
      _remainingCategories.clear();

      // Clear some search results
      if (restaurantResults.length > 10) {
        restaurantResults.value = restaurantResults.take(10).toList();
      }
      if (productResults.length > 20) {
        productResults.value = productResults.take(20).toList();
      }
      if (categoryResults.length > 5) {
        categoryResults.value = categoryResults.take(5).toList();
      }

      // Clear suggestions
      searchSuggestions.clear();

      // Clear some Trie data if it's too large
      if (trieSearch.itemCount > 100) {
        print("⚠️ Trie has ${trieSearch.itemCount} items, clearing to prevent memory issues");
        trieSearch.clear();
        dataLoaded.value = false;
      }

      print("✅ Emergency cleanup completed");
      logMemoryUsage("After Emergency Cleanup");

    } catch (e) {
      print("❌ Error during emergency cleanup: $e");
    }
  }

  // **OPTIMIZED FIRESTORE QUERY METHODS**

  /// **SEARCH VENDORS WITH FIRESTORE QUERIES (MEMORY EFFICIENT)**
  Future<List<VendorModel>> _searchVendorsWithFirestore({
    required String query,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      print('🔍 Firestore vendor search for: "$query" (limit: $limit)');

      if (query.trim().isEmpty) {
        return [];
      }

      final lowerQuery = query.toLowerCase();
      List<VendorModel> results = [];

      // **OPTIMIZED: Use Firestore queries instead of loading all data**
      Query firestoreQuery = FirebaseFirestore.instance
          .collection('vendors')
          .where('isActive', isEqualTo: true)
          .limit(limit);

      // Add pagination if startAfter is provided
      if (startAfter != null) {
        firestoreQuery = firestoreQuery.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      // Filter results on client side (for complex searches)
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final vendor = VendorModel.fromJson(data);

          // Check if vendor matches search query
          if (_vendorMatchesQuery(vendor, lowerQuery)) {
            results.add(vendor);
          }
        } catch (e) {
          print('❌ Error parsing vendor ${document.id}: $e');
        }
      }

      print('✅ Found ${results.length} matching vendors via Firestore');
      return results;
    } catch (e) {
      print('❌ Error searching vendors with Firestore: $e');
      return [];
    }
  }

  /// **SEARCH PRODUCTS WITH FIRESTORE QUERIES (MEMORY EFFICIENT)**
  Future<List<ProductModel>> _searchProductsWithFirestore({
    required String query,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      print('🔍 Firestore product search for: "$query" (limit: $limit)');

      if (query.trim().isEmpty) {
        return [];
      }

      final lowerQuery = query.toLowerCase();
      List<ProductModel> results = [];

      // **OPTIMIZED: Use Firestore queries instead of loading all data**
      Query firestoreQuery = FirebaseFirestore.instance
          .collection('vendorProducts')
          .where('publish', isEqualTo: true)
          .limit(limit);

      // Add pagination if startAfter is provided
      if (startAfter != null) {
        firestoreQuery = firestoreQuery.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      // Filter results on client side (for complex searches)
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final product = ProductModel.fromJson(data);

          // Check if product matches search query
          if (_productMatchesQuery(product, lowerQuery)) {
            results.add(product);
          }
        } catch (e) {
          print('❌ Error parsing product ${document.id}: $e');
        }
      }

      print('✅ Found ${results.length} matching products via Firestore');
      return results;
    } catch (e) {
      print('❌ Error searching products with Firestore: $e');
      return [];
    }
  }

  /// **PREFIX SEARCH WITH FIRESTORE (MOST EFFICIENT FOR AUTOCOMPLETE)**
  Future<List<dynamic>> _searchWithPrefix({
    required String query,
    int limit = 20,
  }) async {
    try {
      print('🔍 Firestore prefix search for: "$query" (limit: $limit)');

      if (query.trim().isEmpty) {
        return [];
      }

      List<dynamic> results = [];

      // **PREFIX SEARCH: Use Firestore range queries for efficient prefix matching**
      // This is much more efficient than loading all data

      // Search vendors by title prefix
      Query vendorQuery = FirebaseFirestore.instance
          .collection('vendors')
          .where('isActive', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff') // \uf8ff is the highest Unicode character
          .limit(limit ~/ 2); // Half the limit for vendors

      QuerySnapshot vendorSnapshot = await vendorQuery.get();
      for (var document in vendorSnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          results.add(VendorModel.fromJson(data));
        } catch (e) {
          print('❌ Error parsing vendor ${document.id}: $e');
        }
      }

      // Search products by name prefix
      Query productQuery = FirebaseFirestore.instance
          .collection('vendorProducts')
          .where('publish', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(limit ~/ 2); // Half the limit for products

      QuerySnapshot productSnapshot = await productQuery.get();
      for (var document in productSnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          results.add(ProductModel.fromJson(data));
        } catch (e) {
          print('❌ Error parsing product ${document.id}: $e');
        }
      }

      print('✅ Prefix search found ${results.length} results via Firestore');
      return results;
    } catch (e) {
      print('❌ Error in prefix search: $e');
      return [];
    }
  }

  /// **Check if vendor matches search query**
  bool _vendorMatchesQuery(VendorModel vendor, String lowerQuery) {
    return (vendor.title?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.location?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.categoryTitle?.any((cat) => cat.toLowerCase().contains(lowerQuery)) ?? false) ||
        (vendor.id?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.phonenumber?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.vType?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// **Check if product matches search query**
  bool _productMatchesQuery(ProductModel product, String lowerQuery) {
    return (product.name?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.categoryID?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.vendorID?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.id?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.price?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.disPrice?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// **OPTIMIZED SEARCH USING FIRESTORE QUERIES**
  Future<void> performOptimizedSearch(String query) async {
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    try {
      print("🔍 Optimized Firestore search for: '$query'");
      isSearching.value = true;
      hasSearched.value = true;

      // Reset pagination state
      _lastVendorDocument = null;
      _lastProductDocument = null;
      _lastCategoryDocument = null;
      hasMoreResults.value = true;

      // **PARALLEL SEARCH: Search vendors and products simultaneously using Firestore**
      final futures = await Future.wait([
        _searchVendorsWithFirestore(query: query, limit: MAX_VENDORS_PER_SEARCH),
        _searchProductsWithFirestore(query: query, limit: MAX_PRODUCTS_PER_SEARCH),
        FireStoreUtils.getVendorCategory(), // Categories are usually small
      ]);

      final vendorResults = futures[0] as List<VendorModel>;
      final productResults = futures[1] as List<ProductModel>;
      final categoryResults = futures[2] as List<VendorCategoryModel>;

      // Filter categories based on query
      final filteredCategories = categoryResults.where((category) {
        final lowerQuery = query.toLowerCase();
        return (category.title?.toLowerCase().contains(lowerQuery) ?? false) ||
            (category.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      // Update observable lists
      restaurantResults.assignAll(vendorResults);
      productResults.assignAll(productResults);
      categoryResults.assignAll(filteredCategories);

      // Check if there are more results - FIXED: hasMoreResults should be true when we haven't reached limits yet
      hasMoreResults.value = vendorResults.length < MAX_VENDORS_PER_SEARCH ||
          productResults.length < MAX_PRODUCTS_PER_SEARCH;

      // Save to recent searches
      _saveRecentSearch(query);

      // Hide suggestions
      showSuggestions.value = false;
      isSearching.value = false;

      print("📊 Optimized Firestore search results:");
      print("  - Vendors: ${vendorResults.length}");
      print("  - Products: ${productResults.length}");
      print("  - Categories: ${filteredCategories.length}");
      print("  - Has more results: ${hasMoreResults.value}");

      // **MEMORY MONITORING: Log memory usage after search**
      logMemoryUsage("After Optimized Search");

    } catch (e) {
      print("❌ Optimized search error: $e");
      if (e.toString().contains('OutOfMemoryError')) {
        print("🚨 OutOfMemoryError detected! Performing emergency cleanup.");
        _emergencyMemoryCleanup();
      }
      isSearching.value = false;
    }
  }

  /// **LOAD MORE RESULTS USING FIRESTORE PAGINATION**
  Future<void> loadMoreResultsOptimized() async {
    if (isLoadingMore.value || !hasMoreResults.value) {
      return;
    }

    try {
      isLoadingMore.value = true;
      print("🔄 Loading more results via Firestore pagination...");

      final currentQuery = searchText.value;
      if (currentQuery.isEmpty) {
        isLoadingMore.value = false;
        return;
      }

      // **PAGINATED SEARCH: Use startAfter for efficient pagination**
      final futures = await Future.wait([
        _searchVendorsWithFirestore(
          query: currentQuery,
          limit: MAX_VENDORS_PER_SEARCH,
          startAfter: _lastVendorDocument,
        ),
        _searchProductsWithFirestore(
          query: currentQuery,
          limit: MAX_PRODUCTS_PER_SEARCH,
          startAfter: _lastProductDocument,
        ),
      ]);

      final moreVendors = futures[0] as List<VendorModel>;
      final moreProducts = futures[1] as List<ProductModel>;

      // Add to existing results
      restaurantResults.addAll(moreVendors);
      productResults.addAll(moreProducts);

      // Update pagination state - FIXED: hasMoreResults should be true when we haven't reached limits yet
      hasMoreResults.value = moreVendors.length < MAX_VENDORS_PER_SEARCH ||
          moreProducts.length < MAX_PRODUCTS_PER_SEARCH;

      print("📊 Loaded more results via Firestore: ${moreVendors.length} vendors, ${moreProducts.length} products");
      print("📊 Total results: ${restaurantResults.length} vendors, ${productResults.length} products");

    } catch (e) {
      print("❌ Error loading more results via Firestore: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// **UPDATE SUGGESTIONS USING PREFIX SEARCH**
  Future<void> _updateSuggestionsOptimized(String query) async {
    if (query.isEmpty) {
      showSuggestions.value = false;
      return;
    }

    try {
      print("💡 Getting suggestions via Firestore prefix search for: '$query'");

      // **PREFIX SEARCH: Most efficient for autocomplete**
      final suggestions = await _searchWithPrefix(
        query: query,
        limit: SUGGESTION_LIMIT,
      );

      // Extract suggestion strings
      final suggestionStrings = <String>[];
      for (var item in suggestions) {
        if (item is VendorModel && item.title != null) {
          suggestionStrings.add(item.title!);
        } else if (item is ProductModel && item.name != null) {
          suggestionStrings.add(item.name!);
        }
      }

      // Remove duplicates and limit
      final uniqueSuggestions = suggestionStrings.toSet().take(MAX_SUGGESTIONS).toList();
      searchSuggestions.assignAll(uniqueSuggestions);
      showSuggestions.value = uniqueSuggestions.isNotEmpty;

      print("💡 Showing ${uniqueSuggestions.length} suggestions via Firestore");

    } catch (e) {
      print("❌ Suggestions failed: $e");
      showSuggestions.value = false;
    }
  }

  /// **ENHANCED MULTI-COLLECTION SEARCH - GROUPED RESULTS**
  Future<void> performEnhancedMultiCollectionSearch(String query) async {
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    try {
      print("🔍 Enhanced multi-collection search for: '$query'");
      isSearching.value = true;
      hasSearched.value = true;

      final lowerQuery = query.toLowerCase().trim();

      // **PHASE 1: Primary search in main fields (title/name)**
      print("🔍 Phase 1: Primary search in main fields");
      final primaryResults = await _performPrimarySearch(lowerQuery);
      // **PHASE 2: Fallback search in descriptions if needed**
      if (primaryResults['totalResults'] < 10) {
        print("🔍 Phase 2: Fallback search in descriptions");
        final fallbackResults = await _performFallbackSearch(lowerQuery);
        _mergeSearchResults(primaryResults, fallbackResults);
      } else {
        _updateSearchResults(primaryResults);
      }
      // Save to recent searches
      _saveRecentSearch(query);
      print("📊 Enhanced search completed: ${restaurantResults.length} restaurants, ${productResults.length} products, ${categoryResults.length} categories");

    } catch (e) {
      print("❌ Enhanced search failed: $e");
      // Fallback to current method
      await performSearch(query);
    } finally {
      isSearching.value = false;
    }
  }

  /// **PRIMARY SEARCH - Main fields (title/name)**
  Future<Map<String, dynamic>> _performPrimarySearch(String lowerQuery) async {
    try {
      // **SINGLE OPTIMIZED QUERY: Use Firestore's array-contains-any for efficiency**
      final futures = await Future.wait([
        _searchVendorsOptimized(lowerQuery, RESTAURANT_SEARCH_LIMIT),
        _searchProductsOptimized(lowerQuery, PRODUCT_SEARCH_LIMIT),
        _searchCategoriesOptimized(lowerQuery, CATEGORY_SEARCH_LIMIT),
      ]);

      final vendorResults = futures[0] as List<VendorModel>;
      final productResults = futures[1] as List<ProductModel>;
      final categoryResults = futures[2] as List<VendorCategoryModel>;

      return {
        'vendors': vendorResults,
        'products': productResults,
        'categories': categoryResults,
        'totalResults': vendorResults.length + productResults.length + categoryResults.length,
      };
    } catch (e) {
      print("❌ Primary search failed: $e");
      return {'vendors': <VendorModel>[], 'products': <ProductModel>[], 'categories': <VendorCategoryModel>[], 'totalResults': 0};
    }
  }

  /// **FALLBACK SEARCH - Description fields**
  Future<Map<String, dynamic>> _performFallbackSearch(String lowerQuery) async {
    try {
      print("🔍 Fallback search in descriptions for: '$lowerQuery'");

      final futures = await Future.wait([
        _searchVendorsByDescription(lowerQuery, RESTAURANT_SEARCH_LIMIT),
        _searchProductsByDescription(lowerQuery, PRODUCT_SEARCH_LIMIT),
        _searchCategoriesByDescription(lowerQuery, CATEGORY_SEARCH_LIMIT),
      ]);

      final vendorResults = futures[0] as List<VendorModel>;
      final productResults = futures[1] as List<ProductModel>;
      final categoryResults = futures[2] as List<VendorCategoryModel>;

      return {
        'vendors': vendorResults,
        'products': productResults,
        'categories': categoryResults,
        'totalResults': vendorResults.length + productResults.length + categoryResults.length,
      };
    } catch (e) {
      print("❌ Fallback search failed: $e");
      return {'vendors': <VendorModel>[], 'products': <ProductModel>[], 'categories': <VendorCategoryModel>[], 'totalResults': 0};
    }
  }

  /// **OPTIMIZED VENDOR SEARCH - Main fields**
  Future<List<VendorModel>> _searchVendorsOptimized(String query, int limit) async {
    try {
      print("🔍 Optimized vendor search for: '$query' (limit: $limit)");

      // **SINGLE QUERY: Load vendors with zone filtering (no prefix matching)**
      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendors)
          .where('zoneId', isEqualTo: Constant.selectedZone?.id.toString())
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<VendorModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final vendor = VendorModel.fromJson(data);

          // **SMART MATCHING: Check title first, then description**
          if (_vendorMatchesPrimaryQuery(vendor, query)) {
            results.add(vendor);
          }
        } catch (e) {
          print('❌ Error parsing vendor ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} vendors via optimized search");
      return results;
    } catch (e) {
      print("❌ Optimized vendor search failed: $e");
      return [];
    }
  }
  Future<List<ProductModel>> _searchProductsOptimized(String query, int limit) async {
    try {
      print("🔍 Optimized product search for: '$query' (limit: $limit)");

      // ✅ STEP 1: Identify allowed vendor IDs based on selected zone
      List<String> allowedVendorIds = [];
      if (Constant.selectedZone != null) {
        print("🌍 Filtering products for zone: ${Constant.selectedZone!.name}");
        QuerySnapshot vendorSnapshot = await FirebaseFirestore.instance
            .collection(CollectionName.vendors)
            .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
            .get();

        allowedVendorIds =
            vendorSnapshot.docs.map((e) => e.id.toString()).toList();
        print("✅ Found ${allowedVendorIds.length} vendors in this zone");
      }

      // ✅ STEP 2: Query published products only
      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendorProducts)
          // .where('publish', isEqualTo: true)
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<ProductModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final product = ProductModel.fromJson(data);

          // ✅ STEP 3: Apply zone-based filter
          if (Constant.selectedZone != null) {
            if (!allowedVendorIds.contains(product.vendorID)) {
              continue; // Skip products outside the selected zone
            }
          }

          // ✅ STEP 4: Smart search filtering
          if (_productMatchesPrimaryQuery(product, query)) {
            results.add(product);
          }
        } catch (e) {
          print('❌ Error parsing product ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} zone-filtered products via optimized search");
      return results;
    } catch (e) {
      print("❌ Optimized product search failed: $e");
      return [];
    }
  }

  /// **OPTIMIZED PRODUCT SEARCH - Main fields**
  // Future<List<ProductModel>> _searchProductsOptimized(String query, int limit) async {
  //   try {
  //     print("🔍 Optimized product search for: '$query' (limit: $limit)");
  //
  //     // **SINGLE QUERY: Load products with publish filter (no prefix matching)**
  //     Query firestoreQuery = FirebaseFirestore.instance
  //         .collection(CollectionName.vendorProducts)
  //         .where('publish', isEqualTo: true)
  //         .limit(limit);
  //
  //     QuerySnapshot querySnapshot = await firestoreQuery.get();
  //
  //     List<ProductModel> results = [];
  //     for (var document in querySnapshot.docs) {
  //       try {
  //         final data = document.data() as Map<String, dynamic>;
  //         final product = ProductModel.fromJson(data);
  //
  //         // **SMART MATCHING: Check name first, then description**
  //         if (_productMatchesPrimaryQuery(product, query)) {
  //           results.add(product);
  //         }
  //       } catch (e) {
  //         print('❌ Error parsing product ${document.id}: $e');
  //       }
  //     }
  //
  //     print("✅ Found ${results.length} products via optimized search");
  //     return results;
  //   } catch (e) {
  //     print("❌ Optimized product search failed: $e");
  //     return [];
  //   }
  // }

  /// **OPTIMIZED CATEGORY SEARCH - Main fields**
  Future<List<VendorCategoryModel>> _searchCategoriesOptimized(String query, int limit) async {
    try {
      print("🔍 Optimized category search for: '$query' (limit: $limit)");

      // **SINGLE QUERY: Load categories (no prefix matching)**
      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendorCategories)
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<VendorCategoryModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final category = VendorCategoryModel.fromJson(data);

          // **SMART MATCHING: Check title first, then description**
          if (_categoryMatchesPrimaryQuery(category, query)) {
            results.add(category);
          }
        } catch (e) {
          print('❌ Error parsing category ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} categories via optimized search");
      return results;
    } catch (e) {
      print("❌ Optimized category search failed: $e");
      return [];
    }
  }

  /// **FALLBACK VENDOR SEARCH - Description fields**
  Future<List<VendorModel>> _searchVendorsByDescription(String query, int limit) async {
    try {
      print("🔍 Fallback vendor search in descriptions for: '$query'");

      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendors)
          .where('zoneId', isEqualTo: Constant.selectedZone?.id.toString())
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<VendorModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final vendor = VendorModel.fromJson(data);

          // **FALLBACK MATCHING: Check description fields**
          if (_vendorMatchesFallbackQuery(vendor, query)) {
            results.add(vendor);
          }
        } catch (e) {
          print('❌ Error parsing vendor ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} vendors via fallback search");
      return results;
    } catch (e) {
      print("❌ Fallback vendor search failed: $e");
      return [];
    }
  }

  /// **FALLBACK PRODUCT SEARCH - Description fields**
  Future<List<ProductModel>> _searchProductsByDescription(String query, int limit) async {
    try {
      print("🔍 Fallback product search in descriptions for: '$query'");

      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendorProducts)
          .where('publish', isEqualTo: true)
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<ProductModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final product = ProductModel.fromJson(data);

          // **FALLBACK MATCHING: Check description fields**
          if (_productMatchesFallbackQuery(product, query)) {
            results.add(product);
          }
        } catch (e) {
          print('❌ Error parsing product ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} products via fallback search");
      return results;
    } catch (e) {
      print("❌ Fallback product search failed: $e");
      return [];
    }
  }

  /// **FALLBACK CATEGORY SEARCH - Description fields**
  Future<List<VendorCategoryModel>> _searchCategoriesByDescription(String query, int limit) async {
    try {
      print("🔍 Fallback category search in descriptions for: '$query'");

      Query firestoreQuery = FirebaseFirestore.instance
          .collection(CollectionName.vendorCategories)
          .limit(limit);

      QuerySnapshot querySnapshot = await firestoreQuery.get();

      List<VendorCategoryModel> results = [];
      for (var document in querySnapshot.docs) {
        try {
          final data = document.data() as Map<String, dynamic>;
          final category = VendorCategoryModel.fromJson(data);

          // **FALLBACK MATCHING: Check description fields**
          if (_categoryMatchesFallbackQuery(category, query)) {
            results.add(category);
          }
        } catch (e) {
          print('❌ Error parsing category ${document.id}: $e');
        }
      }

      print("✅ Found ${results.length} categories via fallback search");
      return results;
    } catch (e) {
      print("❌ Fallback category search failed: $e");
      return [];
    }
  }

  /// **PRIMARY QUERY MATCHING - Contains matching (finds items anywhere in text)**
  bool _vendorMatchesPrimaryQuery(VendorModel vendor, String lowerQuery) {
    return (vendor.title?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.location?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.categoryTitle?.any((cat) => cat.toLowerCase().contains(lowerQuery)) ?? false);
  }

  bool _productMatchesPrimaryQuery(ProductModel product, String lowerQuery) {
    return (product.name?.toLowerCase().contains(lowerQuery) ?? false) ||
        (product.categoryID?.toLowerCase().contains(lowerQuery) ?? false);
  }

  bool _categoryMatchesPrimaryQuery(VendorCategoryModel category, String lowerQuery) {
    return (category.title?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// **FALLBACK QUERY MATCHING - Contains matching in descriptions**
  bool _vendorMatchesFallbackQuery(VendorModel vendor, String lowerQuery) {
    return (vendor.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (vendor.vType?.toLowerCase().contains(lowerQuery) ?? false);
  }

  bool _productMatchesFallbackQuery(ProductModel product, String lowerQuery) {
    return (product.description?.toLowerCase().contains(lowerQuery) ?? false);
  }

  bool _categoryMatchesFallbackQuery(VendorCategoryModel category, String lowerQuery) {
    return (category.description?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// **MERGE SEARCH RESULTS**
  void _mergeSearchResults(Map<String, dynamic> primary, Map<String, dynamic> fallback) {
    // Combine primary and fallback results, avoiding duplicates
    final combinedVendors = <VendorModel>[];
    final combinedProducts = <ProductModel>[];
    final combinedCategories = <VendorCategoryModel>[];

    // Add primary results
    combinedVendors.addAll(primary['vendors'] as List<VendorModel>);
    combinedProducts.addAll(primary['products'] as List<ProductModel>);
    combinedCategories.addAll(primary['categories'] as List<VendorCategoryModel>);

    // Add fallback results (avoiding duplicates)
    for (var vendor in fallback['vendors'] as List<VendorModel>) {
      if (!combinedVendors.any((v) => v.id == vendor.id)) {
        combinedVendors.add(vendor);
      }
    }

    for (var product in fallback['products'] as List<ProductModel>) {
      if (!combinedProducts.any((p) => p.id == product.id)) {
        combinedProducts.add(product);
      }
    }

    for (var category in fallback['categories'] as List<VendorCategoryModel>) {
      if (!combinedCategories.any((c) => c.id == category.id)) {
        combinedCategories.add(category);
      }
    }

    _updateSearchResults({
      'vendors': combinedVendors,
      'products': combinedProducts,
      'categories': combinedCategories,
    });

    print("📊 Merged search results: ${combinedVendors.length} vendors, ${combinedProducts.length} products, ${combinedCategories.length} categories");
  }

  /// **UPDATE SEARCH RESULTS**
  void _updateSearchResults(Map<String, dynamic> results) {
    restaurantResults.assignAll(results['vendors'] as List<VendorModel>);
    productResults.assignAll(results['products'] as List<ProductModel>);
    categoryResults.assignAll(results['categories'] as List<VendorCategoryModel>);

    // **FIX: Update counts properly**
    final totalResults = (results['vendors'] as List).length +
        (results['products'] as List).length +
        (results['categories'] as List).length;

    currentResultCount.value = totalResults;
    totalAvailableResults.value = totalResults;

    // Update pagination state - FIXED: hasMoreResults should be true when we haven't reached limits yet
    hasMoreResults.value = (results['vendors'] as List).length < RESTAURANT_SEARCH_LIMIT ||
        (results['products'] as List).length < PRODUCT_SEARCH_LIMIT ||
        (results['categories'] as List).length < CATEGORY_SEARCH_LIMIT;

    print("📊 Updated search results: ${restaurantResults.length} restaurants, ${productResults.length} products, ${categoryResults.length} categories");
    print("📊 Total results: $totalResults");
  }

  /// **LOAD MORE RESULTS ENHANCED - MULTI-COLLECTION SEARCH**
  Future<void> loadMoreResultsEnhanced() async {
    if (isLoadingMore.value || !hasMoreResults.value) {
      print("⚠️ Load more not available or already in progress");
      return;
    }

    try {
      isLoadingMore.value = true;
      print("🔄 Loading more results via enhanced multi-collection search...");

      final currentQuery = searchText.value;
      if (currentQuery.isEmpty) {
        print("⚠️ No search query for load more");
        return;
      }

      final lowerQuery = currentQuery.toLowerCase().trim();

      // **LOAD MORE: Search with current limits to get more results**
      final futures = await Future.wait([
        _searchVendorsOptimized(lowerQuery, RESTAURANT_SEARCH_LIMIT),
        _searchProductsOptimized(lowerQuery, PRODUCT_SEARCH_LIMIT),
        _searchCategoriesOptimized(lowerQuery, CATEGORY_SEARCH_LIMIT),
      ]);

      final moreVendors = futures[0] as List<VendorModel>;
      final moreProducts = futures[1] as List<ProductModel>;
      final moreCategories = futures[2] as List<VendorCategoryModel>;

      // **MERGE WITH EXISTING RESULTS (avoid duplicates)**
      final existingVendorIds = restaurantResults.map((v) => v.id).toSet();
      final existingProductIds = productResults.map((p) => p.id).toSet();
      final existingCategoryIds = categoryResults.map((c) => c.id).toSet();

      int newVendorsAdded = 0;
      int newProductsAdded = 0;
      int newCategoriesAdded = 0;

      // Add new vendors
      for (var vendor in moreVendors) {
        if (!existingVendorIds.contains(vendor.id)) {
          restaurantResults.add(vendor);
          newVendorsAdded++;
        }
      }

      // Add new products
      for (var product in moreProducts) {
        if (!existingProductIds.contains(product.id)) {
          productResults.add(product);
          newProductsAdded++;
        }
      }

      // Add new categories
      for (var category in moreCategories) {
        if (!existingCategoryIds.contains(category.id)) {
          categoryResults.add(category);
          newCategoriesAdded++;
        }
      }

      // **UPDATE COUNTS**
      final totalResults = restaurantResults.length + productResults.length + categoryResults.length;
      currentResultCount.value = totalResults;
      totalAvailableResults.value = totalResults;

      // **UPDATE PAGINATION STATE - FIXED: hasMoreResults should be false if we got no new results**
      final totalNewResults = newVendorsAdded + newProductsAdded + newCategoriesAdded;
      hasMoreResults.value = totalNewResults > 0; // Only true if we actually got new results

      print("📊 Load more completed: ${restaurantResults.length} restaurants, ${productResults.length} products, ${categoryResults.length} categories");
      print("📊 New results added: $newVendorsAdded vendors, $newProductsAdded products, $newCategoriesAdded categories");
      print("📊 Total results after load more: $totalResults");
      print("📊 Has more results: ${hasMoreResults.value}");

    } catch (e) {
      print("❌ Load more enhanced failed: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }
}















// import 'package:get/get.dart';
// import 'package:customer/models/product_model.dart';
// import 'package:customer/models/vendor_model.dart';
// import 'package:customer/models/vendor_category_model.dart';
// import 'package:customer/utils/fire_store_utils.dart';
// import 'package:customer/utils/trie_search.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
//
// class SwiggySearchController extends GetxController {
//   final TrieSearch trieSearch = TrieSearch();
//
//   // **OBSERVABLE VARIABLES**
//   var recentSearches = <String>[].obs;
//   var trendingSearches = <String>[].obs;
//   var restaurantResults = <VendorModel>[].obs;
//   var productResults = <ProductModel>[].obs;
//   var categoryResults = <VendorCategoryModel>[].obs;
//   var searchSuggestions = <String>[].obs;
//
//   // **SEARCH STATE**
//   var isSearching = false.obs;
//   var showSuggestions = false.obs;
//   var searchText = ''.obs;
//   var hasSearched = false.obs;
//
//   // **LOADING STATE**
//   var isLoadingData = false.obs;
//   var dataLoaded = false.obs;
//
//   // **PAGINATION STATE**
//   var isLoadingMore = false.obs;
//   var hasMoreResults = true.obs;
//   var currentResultCount = 0.obs;
//   var totalAvailableResults = 0.obs;
//
//   // **REMAINING RESULTS FOR PAGINATION**
//   List<ProductModel> _remainingProducts = [];
//   List<VendorModel> _remainingRestaurants = [];
//   List<VendorCategoryModel> _remainingCategories = [];
//
//   // **DEBOUNCE TIMER**
//   Timer? _debounceTimer;
//   Timer? _searchTimer;
//
//   // **CONSTANTS - AGGRESSIVE LIMITS FOR FAST LOADING**
//   static const int MAX_RECENT_SEARCHES = 10;
//   static const int MAX_SUGGESTIONS = 8;
//   static const int INITIAL_PRODUCTS = 8; // Show only 8 products initially to ensure Load More button shows
//   static const int INITIAL_RESTAURANTS = 5; // Show only 5 restaurants initially to ensure Load More button shows
//   static const int LOAD_MORE_RESULTS = 5; // Load 5 more at a time
//   static const int MAX_TOTAL_RESULTS = 100; // Reduced from 200 to 100 for faster loading
//   static const Duration DEBOUNCE_DELAY = Duration(milliseconds: 300);
//
//   // **FAST LOADING LIMITS**
//   static const int FAST_VENDOR_LIMIT = 20; // Very small limit for initial load
//   static const int FAST_PRODUCT_LIMIT = 30; // Very small limit for initial load
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeSearch();
//   }
//
//   @override
//   void onClose() {
//     _debounceTimer?.cancel();
//     _searchTimer?.cancel();
//     super.onClose();
//   }
//
//   /// **INITIALIZE SEARCH SYSTEM**
//   Future<void> _initializeSearch() async {
//     try {
//       isLoadingData.value = true;
//
//       // Load recent searches from storage (fast)
//       await _loadRecentSearches();
//
//       // Load trending searches (fast)
//       await _loadTrendingSearches();
//
//       // Show initial state immediately
//       isLoadingData.value = false;
//
//       // Load and index data in background (slow)
//       _loadAndIndexDataInBackground();
//
//       print("✅ Swiggy Search initialized successfully");
//
//     } catch (e) {
//       print("❌ Search initialization failed: $e");
//       isLoadingData.value = false;
//     }
//   }
//
//   /// **LOAD AND INDEX DATA IN BACKGROUND**
//   Future<void> _loadAndIndexDataInBackground() async {
//     try {
//       print("🔄 Loading initial data in background...");
//       await _loadAndIndexData();
//       dataLoaded.value = true;
//       print("✅ Initial background data loading completed");
//       print("📊 Indexed items: ${trieSearch.itemCount}");
//
//       // If no data was loaded, add some sample data for testing
//       if (trieSearch.itemCount == 0) {
//         print("🔧 No data loaded, adding sample data for testing...");
//         _addSampleData();
//       }
//
//       // Test the Trie with a simple search
//       _testTrieSearch();
//
//       // Continue loading more data progressively
//       _loadMoreDataProgressively();
//     } catch (e) {
//       print("❌ Background data loading failed: $e");
//     }
//   }
//
//   /// **ADD SAMPLE DATA FOR TESTING**
//   void _addSampleData() {
//     try {
//       print("🔧 Adding sample data...");
//
//       // Add sample products
//       var sampleProducts = [
//         "Spicy Chicken Biryani",
//         "Hot Pizza Margherita",
//         "Spicy Noodles",
//         "Chicken Burger",
//         "Spicy Wings",
//         "Biryani Rice",
//         "Spicy Curry",
//         "Hot Coffee",
//         "Spicy Tacos",
//         "Chicken Sandwich"
//       ];
//
//       for (var productName in sampleProducts) {
//         // Create a simple product object for testing
//         var product = {
//           'name': productName,
//           'id': 'sample_${productName.replaceAll(' ', '_').toLowerCase()}',
//           'price': 100.0,
//         };
//         trieSearch.insert(productName, product, relevanceScore: 2.0);
//       }
//
//       // Add sample restaurants
//       var sampleRestaurants = [
//         "Spicy Palace",
//         "Hot Corner Restaurant",
//         "Spicy Bites",
//         "Chicken House",
//         "Spicy Kitchen"
//       ];
//
//       for (var restaurantName in sampleRestaurants) {
//         // Create a simple restaurant object for testing
//         var restaurant = {
//           'title': restaurantName,
//           'id': 'sample_${restaurantName.replaceAll(' ', '_').toLowerCase()}',
//           'location': 'Sample Location',
//         };
//         trieSearch.insert(restaurantName, restaurant, relevanceScore: 1.5);
//       }
//
//       print("🔧 Added ${sampleProducts.length} sample products and ${sampleRestaurants.length} sample restaurants");
//       print("🔧 Total sample items: ${trieSearch.itemCount}");
//
//     } catch (e) {
//       print("❌ Failed to add sample data: $e");
//     }
//   }
//
//   /// **TEST TRIE SEARCH**
//   void _testTrieSearch() {
//     try {
//       print("🧪 Testing Trie search...");
//
//       // Test with common search terms
//       var testQueries = ["pizza", "biryani", "chicken", "spicy", "restaurant"];
//
//       for (var query in testQueries) {
//         var results = trieSearch.search(query);
//         print("🧪 Test search '$query': ${results.length} results");
//       }
//
//     } catch (e) {
//       print("❌ Trie test failed: $e");
//     }
//   }
//
//   /// **DIRECT SEARCH FALLBACK - ENHANCED**
//   List<dynamic> _directSearch(String query) {
//     try {
//       print("🔍 Performing enhanced direct search for: '$query'");
//       List<dynamic> results = [];
//       final lowerQuery = query.toLowerCase();
//
//       // Search in current results first
//       for (var product in productResults) {
//         if (product.name != null && product.name!.toLowerCase().contains(lowerQuery)) {
//           results.add(product);
//         }
//       }
//
//       for (var restaurant in restaurantResults) {
//         if (restaurant.title != null && restaurant.title!.toLowerCase().contains(lowerQuery)) {
//           results.add(restaurant);
//         }
//       }
//
//       // If no results in current lists, try to fetch fresh data
//       if (results.isEmpty) {
//         print("🔍 No results in current lists, trying fresh data fetch...");
//         _performFreshDataSearch(query, results);
//       }
//
//       print("🔍 Enhanced direct search found ${results.length} results");
//       return results;
//
//     } catch (e) {
//       print("❌ Enhanced direct search failed: $e");
//       return [];
//     }
//   }
//
//   /// **PERFORM FRESH DATA SEARCH**
//   Future<void> _performFreshDataSearch(String query, List<dynamic> results) async {
//     try {
//       final lowerQuery = query.toLowerCase();
//
//       // Try to get fresh products
//       try {
//         List<ProductModel> freshProducts = await FireStoreUtils.getAllProducts(limit: 50);
//         for (var product in freshProducts) {
//           if (product.name != null && product.name!.toLowerCase().contains(lowerQuery)) {
//             results.add(product);
//           }
//         }
//         print("🔍 Fresh products search found ${results.where((r) => r is ProductModel).length} products");
//       } catch (e) {
//         print("❌ Fresh products search failed: $e");
//       }
//
//       // Try to get fresh vendors
//       try {
//         List<VendorModel> freshVendors = await FireStoreUtils.getAllVendors(limit: 30);
//         for (var vendor in freshVendors) {
//           if (vendor.title != null && vendor.title!.toLowerCase().contains(lowerQuery)) {
//             results.add(vendor);
//           }
//         }
//         print("🔍 Fresh vendors search found ${results.where((r) => r is VendorModel).length} vendors");
//       } catch (e) {
//         print("❌ Fresh vendors search failed: $e");
//       }
//
//     } catch (e) {
//       print("❌ Fresh data search failed: $e");
//     }
//   }
//
//   /// **SEARCH SAMPLE DATA**
//   List<dynamic> _searchSampleData(String query) {
//     try {
//       print("🔍 Searching sample data for: '$query'");
//       List<dynamic> results = [];
//       final lowerQuery = query.toLowerCase();
//
//       // Sample products
//       var sampleProducts = [
//         "Spicy Chicken Biryani",
//         "Hot Pizza Margherita",
//         "Spicy Noodles",
//         "Chicken Burger",
//         "Spicy Wings",
//         "Biryani Rice",
//         "Spicy Curry",
//         "Hot Coffee",
//         "Spicy Tacos",
//         "Chicken Sandwich",
//         "Ice Cream Sundae",
//         "Chocolate Cake",
//         "Vanilla Ice Cream",
//         "Strawberry Milkshake",
//         "Beef Burger",
//         "Fish and Chips",
//         "Vegetable Biryani",
//         "Mutton Biryani",
//         "Paneer Tikka",
//         "Butter Chicken"
//       ];
//
//       // Sample restaurants
//       var sampleRestaurants = [
//         "Spicy Palace",
//         "Hot Corner Restaurant",
//         "Spicy Bites",
//         "Chicken House",
//         "Spicy Kitchen",
//         "Ice Cream Parlor",
//         "Burger Junction",
//         "Biryani House",
//         "Pizza Corner",
//         "Fast Food Center"
//       ];
//
//       // Search in sample products
//       for (var productName in sampleProducts) {
//         if (productName.toLowerCase().contains(lowerQuery)) {
//           // Create a mock product
//           var mockProduct = ProductModel(
//             id: 'sample_${productName.replaceAll(' ', '_').toLowerCase()}',
//             name: productName,
//             price: '150.0',
//             description: 'Delicious $productName',
//             photo: '',
//             vendorID: 'sample_vendor',
//             categoryID: 'sample_category',
//             publish: true,
//           );
//           results.add(mockProduct);
//         }
//       }
//
//       // Search in sample restaurants
//       for (var restaurantName in sampleRestaurants) {
//         if (restaurantName.toLowerCase().contains(lowerQuery)) {
//           // Create a mock restaurant
//           var mockRestaurant = VendorModel(
//             id: 'sample_${restaurantName.replaceAll(' ', '_').toLowerCase()}',
//             title: restaurantName,
//             location: 'Sample Location',
//             description: 'Great $restaurantName',
//             photo: '',
//           );
//           results.add(mockRestaurant);
//         }
//       }
//
//       print("🔍 Sample data search found ${results.length} results");
//       return results;
//
//     } catch (e) {
//       print("❌ Sample data search failed: $e");
//       return [];
//     }
//   }
//
//   /// **LOAD MORE DATA PROGRESSIVELY IN BACKGROUND**
//   Future<void> _loadMoreDataProgressively() async {
//     try {
//       print("🔄 Loading additional data progressively...");
//
//       // Load more vendors
//       List<VendorModel> moreVendors = await FireStoreUtils.getAllVendors(limit: 30);
//       for (var vendor in moreVendors) {
//         if (vendor.title != null && vendor.title!.isNotEmpty) {
//           trieSearch.insert(vendor.title!, vendor, relevanceScore: 1.5);
//         }
//       }
//
//       // Load more products
//       List<ProductModel> moreProducts = await FireStoreUtils.getAllProducts(limit: 50);
//       for (var product in moreProducts) {
//         if (product.name != null && product.name!.isNotEmpty) {
//           trieSearch.insert(product.name!, product, relevanceScore: 2.0);
//         }
//       }
//
//       print("✅ Progressive data loading completed");
//       print("📊 Total indexed items: ${trieSearch.itemCount}");
//     } catch (e) {
//       print("❌ Progressive data loading failed: $e");
//     }
//   }
//
//   /// **LOAD VENDORS + PRODUCTS INTO TRIE (MEMORY EFFICIENT)**
//   Future<void> _loadAndIndexData() async {
//     try {
//       print("🔄 Loading and indexing data (memory efficient)...");
//
//       // Clear existing data
//       trieSearch.clear();
//
//       // Load vendors in smaller batches to prevent memory issues
//       await _loadVendorsInBatches();
//
//       // Load products in smaller batches to prevent memory issues
//       await _loadProductsInBatches();
//
//       print("✅ Data loading completed successfully");
//
//     } catch (e) {
//       print("❌ Error loading data: $e");
//       // Don't rethrow to prevent app crash
//     }
//   }
//
//   /// **LOAD VENDORS IN BATCHES**
//   Future<void> _loadVendorsInBatches() async {
//     try {
//       print("🔄 Loading vendors in batches...");
//
//       // Load vendors with very small limit for fast loading
//       List<VendorModel> vendors = await FireStoreUtils.getAllVendors(limit: FAST_VENDOR_LIMIT);
//       print("📊 Loaded ${vendors.length} vendors (fast loading with limit: $FAST_VENDOR_LIMIT)");
//
//       // Debug: Print first few vendor names
//       if (vendors.isNotEmpty) {
//         print("  First few vendor names:");
//         for (int i = 0; i < (vendors.length > 5 ? 5 : vendors.length); i++) {
//           print("    - ${vendors[i].title} (ID: ${vendors[i].id})");
//         }
//       } else {
//         print("  ⚠️ No vendors loaded!");
//       }
//
//       for (var vendor in vendors) {
//         if (vendor.title != null && vendor.title!.isNotEmpty) {
//           // Lower relevance for restaurants (1.5) - products get priority
//           trieSearch.insert(vendor.title!, vendor, relevanceScore: 1.5);
//
//           // Index by location for better search
//           if (vendor.location != null && vendor.location!.isNotEmpty) {
//             trieSearch.insert(vendor.location!, vendor, relevanceScore: 1.5);
//           }
//
//           // Index by description
//           if (vendor.description != null && vendor.description!.isNotEmpty) {
//             trieSearch.insert(vendor.description!, vendor, relevanceScore: 1.3);
//           }
//
//           // Index by category titles
//           if (vendor.categoryTitle != null && vendor.categoryTitle!.isNotEmpty) {
//             for (var category in vendor.categoryTitle!) {
//               trieSearch.insert(category.toString(), vendor, relevanceScore: 1.4);
//             }
//           }
//
//           // Index by category IDs
//           if (vendor.categoryID != null && vendor.categoryID!.isNotEmpty) {
//             for (var categoryId in vendor.categoryID!) {
//               trieSearch.insert(categoryId.toString(), vendor, relevanceScore: 1.2);
//             }
//           }
//         }
//       }
//
//       print("✅ Indexed ${vendors.length} vendors");
//       print("🔍 Total Trie items after vendors: ${trieSearch.itemCount}");
//
//     } catch (e) {
//       print("❌ Error loading vendors: $e");
//     }
//   }
//
//   /// **LOAD PRODUCTS IN BATCHES**
//   Future<void> _loadProductsInBatches() async {
//     try {
//       print("🔄 Loading products in batches...");
//
//       // Load products with very small limit for fast loading
//       List<ProductModel> products = await FireStoreUtils.getAllProducts(limit: FAST_PRODUCT_LIMIT);
//       print("📊 Loaded ${products.length} products (fast loading with limit: $FAST_PRODUCT_LIMIT)");
//
//       for (var product in products) {
//         if (product.name != null && product.name!.isNotEmpty) {
//           // Higher relevance for products (2.0) - products get priority
//           trieSearch.insert(product.name!, product, relevanceScore: 2.0);
//
//           // Index by description
//           if (product.description != null && product.description!.isNotEmpty) {
//             trieSearch.insert(product.description!, product, relevanceScore: 1.8);
//           }
//
//           // Index by category
//           if (product.categoryID != null && product.categoryID!.isNotEmpty) {
//             trieSearch.insert(product.categoryID!, product, relevanceScore: 1.7);
//           }
//
//           // Index by add-ons titles
//           if (product.addOnsTitle != null && product.addOnsTitle!.isNotEmpty) {
//             for (var addon in product.addOnsTitle!) {
//               trieSearch.insert(addon.toString(), product, relevanceScore: 1.6);
//             }
//           }
//
//           // Index by product specifications
//           if (product.productSpecification != null && product.productSpecification!.isNotEmpty) {
//             trieSearch.insert(product.productSpecification.toString(), product, relevanceScore: 1.5);
//           }
//
//           // Index by veg/non-veg
//           if (product.veg != null && product.veg!) {
//             trieSearch.insert("vegetarian", product, relevanceScore: 1.4);
//             trieSearch.insert("veg", product, relevanceScore: 1.4);
//           }
//           if (product.nonveg != null && product.nonveg!) {
//             trieSearch.insert("non-vegetarian", product, relevanceScore: 1.4);
//             trieSearch.insert("nonveg", product, relevanceScore: 1.4);
//           }
//         }
//       }
//
//       print("✅ Indexed ${products.length} products");
//       print("🔍 Total Trie items after products: ${trieSearch.itemCount}");
//
//     } catch (e) {
//       print("❌ Error loading products: $e");
//     }
//   }
//
//   /// **LOAD TRENDING SEARCHES**
//   Future<void> _loadTrendingSearches() async {
//     try {
//       // Try to get trending searches from backend
//       List<String> trending = await FireStoreUtils.getTrendingSearches();
//       trendingSearches.assignAll(trending);
//     } catch (e) {
//       print("❌ Error loading trending searches: $e");
//       // Fallback to static trending searches
//       trendingSearches.assignAll([
//         "Pizza", "Biryani", "Burgers", "Coffee", "Ice Cream",
//         "Chinese", "Italian", "South Indian", "Fast Food", "Desserts",
//         "Chicken", "Vegetarian", "Spicy", "Sweet", "Healthy"
//       ]);
//     }
//   }
//
//   /// **LOAD RECENT SEARCHES FROM STORAGE**
//   Future<void> _loadRecentSearches() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       List<String>? saved = prefs.getStringList('recent_searches');
//       if (saved != null) {
//         recentSearches.assignAll(saved);
//       }
//     } catch (e) {
//       print("❌ Error loading recent searches: $e");
//     }
//   }
//
//   /// **SAVE RECENT SEARCHES TO STORAGE**
//   Future<void> _saveRecentSearches() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList('recent_searches', recentSearches);
//     } catch (e) {
//       print("❌ Error saving recent searches: $e");
//     }
//   }
//
//   /// **MAIN SEARCH FUNCTION - FAST AND RESPONSIVE**
//   void search(String query) {
//     if (query.isEmpty) {
//       _clearSearchResults();
//       return;
//     }
//
//     try {
//       print("🔍 Searching for: '$query'");
//       isSearching.value = true;
//       hasSearched.value = true;
//
//       // Reset pagination state
//       currentResultCount.value = 0;
//       hasMoreResults.value = true;
//       isLoadingMore.value = false;
//
//       // Get search results from Trie (works even with partial data)
//       print("🔍 Trie has ${trieSearch.itemCount} indexed items");
//       print("🔍 Data loaded: ${dataLoaded.value}");
//       var results = trieSearch.search(query);
//       print("🔍 Found ${results.length} total results from ${trieSearch.itemCount} indexed items");
//
//       // Debug: Print first few results
//       if (results.isNotEmpty) {
//         print("🔍 First few results:");
//         for (int i = 0; i < (results.length > 3 ? 3 : results.length); i++) {
//           var result = results[i];
//           if (result is VendorModel) {
//             print("  - Restaurant: ${result.title}");
//           } else if (result is ProductModel) {
//             print("  - Product: ${result.name}");
//           }
//         }
//       } else {
//         print("🔍 No results found for query: '$query'");
//
//         // **ENHANCED FALLBACK: Always try direct search if Trie search fails**
//         print("🔍 Trying direct search fallback...");
//         results = _directSearch(query);
//         print("🔍 Direct search found ${results.length} results");
//
//         // If still no results, try with sample data
//         if (results.isEmpty) {
//           print("🔍 Trying sample data search...");
//           results = _searchSampleData(query);
//           print("🔍 Sample data search found ${results.length} results");
//         }
//       }
//
//       // Process and separate results
//       _processSearchResults(results);
//
//       // Save to recent searches
//       _saveRecentSearch(query);
//
//       // Hide suggestions
//       showSuggestions.value = false;
//       isSearching.value = false;
//
//       // If we have very few results and data is still loading, show a message
//       if (results.length < 5 && !dataLoaded.value) {
//         print("💡 Few results found, but more data is still loading in background");
//       }
//
//     } catch (e) {
//       print("❌ Search error: $e");
//       isSearching.value = false;
//     }
//   }
//
//   /// **PROCESS SEARCH RESULTS AND SEPARATE BY TYPE**
//   void _processSearchResults(List<dynamic> results) {
//     // Separate results by type
//     List<VendorModel> restaurants = [];
//     List<ProductModel> products = [];
//     List<VendorCategoryModel> categories = [];
//
//     for (var result in results) {
//       if (result is VendorModel) {
//         restaurants.add(result);
//       } else if (result is ProductModel) {
//         products.add(result);
//       } else if (result is VendorCategoryModel) {
//         categories.add(result);
//       }
//     }
//
//     // Sort products first, then restaurants
//     products.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
//     restaurants.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
//
//     // Take initial results
//     var initialProducts = products.take(INITIAL_PRODUCTS).toList();
//     var initialRestaurants = restaurants.take(INITIAL_RESTAURANTS).toList();
//
//     // Store remaining for pagination
//     _remainingProducts = products.skip(INITIAL_PRODUCTS).toList();
//     _remainingRestaurants = restaurants.skip(INITIAL_RESTAURANTS).toList();
//     _remainingCategories = categories;
//
//     // Update observable lists
//     productResults.assignAll(initialProducts);
//     restaurantResults.assignAll(initialRestaurants);
//     categoryResults.assignAll(categories);
//
//     // Update counts
//     currentResultCount.value = initialProducts.length + initialRestaurants.length + categories.length;
//     totalAvailableResults.value = results.length;
//
//     // Check if there are more results
//     hasMoreResults.value = _remainingProducts.isNotEmpty || _remainingRestaurants.isNotEmpty || _remainingCategories.isNotEmpty;
//
//     // Fallback: If we have any results, show Load More button (for better UX)
//     if (!hasMoreResults.value && (initialProducts.isNotEmpty || initialRestaurants.isNotEmpty || categories.isNotEmpty)) {
//       hasMoreResults.value = true;
//       print("📊 Fallback: Showing Load More button for better UX");
//     }
//
//     print("📊 Search results: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${categories.length} categories");
//     print("📊 Remaining: ${_remainingProducts.length} products, ${_remainingRestaurants.length} restaurants, ${_remainingCategories.length} categories");
//     print("📊 Has more results: ${hasMoreResults.value}");
//   }
//
//   /// **CLEAR SEARCH RESULTS**
//   void _clearSearchResults() {
//     restaurantResults.clear();
//     productResults.clear();
//     categoryResults.clear();
//     hasSearched.value = false;
//     isSearching.value = false;
//     showSuggestions.value = false;
//     currentResultCount.value = 0;
//     hasMoreResults.value = true;
//     _remainingProducts.clear();
//     _remainingRestaurants.clear();
//     _remainingCategories.clear();
//   }
//
//   /// **CLEAR SEARCH (PUBLIC METHOD)**
//   void clearSearch() {
//     searchText.value = '';
//     _clearSearchResults();
//   }
//
//   /// **DEBUG METHOD - Show all loaded restaurants**
//   void debugShowAllRestaurants() async {
//     try {
//       var allRestaurants = await FireStoreUtils.getAllVendors();
//       print("🔍 DEBUG: All loaded restaurants (${allRestaurants.length}):");
//       for (int i = 0; i < allRestaurants.length; i++) {
//         var r = allRestaurants[i];
//         print("  ${i + 1}. '${r.title}' (ID: ${r.id})");
//       }
//     } catch (e) {
//       print("❌ Error loading restaurants for debug: $e");
//     }
//   }
//
//   /// **DEBUG METHOD - Test restaurant search**
//   void debugTestRestaurantSearch(String query) async {
//     try {
//       print("🔍 DEBUG: Testing restaurant search for '$query'");
//       var allRestaurants = await FireStoreUtils.getAllVendors();
//       var lowerQuery = query.toLowerCase();
//
//       print("Total restaurants loaded: ${allRestaurants.length}");
//
//       var matches = allRestaurants.where((r) =>
//           (r.title != null && r.title!.toLowerCase().contains(lowerQuery))
//       ).toList();
//
//       print("Restaurants matching '$query': ${matches.length}");
//       for (var r in matches) {
//         print("  - '${r.title}' (ID: ${r.id})");
//       }
//
//       if (matches.isEmpty) {
//         print("No matches found. Sample restaurant titles:");
//         for (int i = 0; i < (allRestaurants.length > 5 ? 5 : allRestaurants.length); i++) {
//           print("  ${i + 1}. '${allRestaurants[i].title}'");
//         }
//       }
//     } catch (e) {
//       print("❌ Error in debug test: $e");
//     }
//   }
//
//   /// **LOAD MORE RESULTS (PAGINATION)**
//   void loadMoreResults() {
//     if (isLoadingMore.value) {
//       print("⚠️ Load more already in progress, skipping...");
//       return;
//     }
//
//     try {
//       isLoadingMore.value = true;
//       print("🔄 Loading more results...");
//       print("📊 Before load more:");
//       print("  - Remaining products: ${_remainingProducts.length}");
//       print("  - Remaining restaurants: ${_remainingRestaurants.length}");
//       print("  - Remaining categories: ${_remainingCategories.length}");
//       print("  - Current products: ${productResults.length}");
//       print("  - Current restaurants: ${restaurantResults.length}");
//       print("  - Current categories: ${categoryResults.length}");
//
//       // Load more results - show more of each type without artificial limits
//       int loadMoreLimit = 20; // Load 20 more of each type
//
//       // Load more products
//       int moreProductsCount = loadMoreLimit > _remainingProducts.length ? _remainingProducts.length : loadMoreLimit;
//       // Load more restaurants
//       int moreRestaurantsCount = loadMoreLimit > _remainingRestaurants.length ? _remainingRestaurants.length : loadMoreLimit;
//       // Load more categories
//       int moreCategoriesCount = loadMoreLimit > _remainingCategories.length ? _remainingCategories.length : loadMoreLimit;
//
//       // Load more products
//       var moreProducts = _remainingProducts.take(moreProductsCount).toList();
//       _remainingProducts = _remainingProducts.skip(moreProductsCount).toList();
//
//       // Load more restaurants
//       var moreRestaurants = _remainingRestaurants.take(moreRestaurantsCount).toList();
//       _remainingRestaurants = _remainingRestaurants.skip(moreRestaurantsCount).toList();
//
//       // Load more categories
//       var moreCategories = _remainingCategories.take(moreCategoriesCount).toList();
//       _remainingCategories = _remainingCategories.skip(moreCategoriesCount).toList();
//
//       // Add to existing results
//       productResults.addAll(moreProducts);
//       restaurantResults.addAll(moreRestaurants);
//       categoryResults.addAll(moreCategories);
//
//       // Update counts
//       currentResultCount.value = productResults.length + restaurantResults.length + categoryResults.length;
//
//       // Check if there are more results
//       hasMoreResults.value = _remainingProducts.isNotEmpty || _remainingRestaurants.isNotEmpty || _remainingCategories.isNotEmpty;
//
//       print("📊 After load more (comprehensive results):");
//       print("  - Loaded products: ${moreProducts.length} (${moreProductsCount} requested)");
//       print("  - Loaded restaurants: ${moreRestaurants.length} (${moreRestaurantsCount} requested)");
//       print("  - Loaded categories: ${moreCategories.length} (${moreCategoriesCount} requested)");
//       print("  - Total products now: ${productResults.length}");
//       print("  - Total restaurants now: ${restaurantResults.length}");
//       print("  - Total categories now: ${categoryResults.length}");
//       print("  - Remaining products: ${_remainingProducts.length}");
//       print("  - Remaining restaurants: ${_remainingRestaurants.length}");
//       print("  - Remaining categories: ${_remainingCategories.length}");
//       print("  - Has more results: ${hasMoreResults.value}");
//
//     } catch (e) {
//       print("❌ Error loading more results: $e");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
//
//   /// **UPDATE SEARCH TEXT AND SHOW SUGGESTIONS**
//   void updateSearchText(String text) {
//     searchText.value = text;
//
//     // Cancel previous timers
//     _debounceTimer?.cancel();
//     _searchTimer?.cancel();
//
//     if (text.isEmpty) {
//       showSuggestions.value = false;
//       return;
//     }
//
//     // Debounce the suggestions (fast)
//     _debounceTimer = Timer(DEBOUNCE_DELAY, () {
//       _updateSuggestions(text);
//     });
//
//     // Auto-search after user stops typing (slower)
//     _searchTimer = Timer(const Duration(milliseconds: 1500), () {
//       if (text.trim().isNotEmpty) {
//         print("🔍 Auto-triggering search for: '$text'");
//         performSearch(text.trim());
//       }
//     });
//   }
//
//   /// **ON SEARCH TEXT CHANGED (for TextField onChanged)**
//   void onSearchTextChanged(String text) {
//     updateSearchText(text);
//   }
//
//   /// **UPDATE SUGGESTIONS BASED ON SEARCH TEXT**
//   void _updateSuggestions(String query) {
//     if (query.isEmpty) {
//       showSuggestions.value = false;
//       return;
//     }
//     try {
//       print("💡 Getting suggestions for: '$query'");
//       print("💡 Trie total items: ${trieSearch.itemCount}");
//       var suggestions = trieSearch.getSuggestions(query, maxSuggestions: MAX_SUGGESTIONS);
//       searchSuggestions.assignAll(suggestions);
//       showSuggestions.value = suggestions.isNotEmpty;
//       print("💡 Showing ${suggestions.length} suggestions for: '$query'");
//       print("💡 Suggestions: $suggestions");
//       print("💡 showSuggestions.value: ${showSuggestions.value}");
//     } catch (e) {
//       print("❌ Suggestions failed: $e");
//       showSuggestions.value = false;
//     }
//   }
//
//   /// **SAVE RECENT SEARCH**
//   void _saveRecentSearch(String query) {
//     if (query.isEmpty) return;
//
//     // Remove if already exists
//     recentSearches.remove(query);
//
//     // Add to beginning
//     recentSearches.insert(0, query);
//
//     // Keep only max recent searches
//     if (recentSearches.length > MAX_RECENT_SEARCHES) {
//       recentSearches.removeRange(MAX_RECENT_SEARCHES, recentSearches.length);
//     }
//
//     // Save to storage
//     _saveRecentSearches();
//   }
//
//   /// **SELECT A SUGGESTION**
//   void selectSuggestion(String suggestion) {
//     searchText.value = suggestion;
//     showSuggestions.value = false;
//     performSearch(suggestion);
//   }
//
//   /// **HIDE SUGGESTIONS**
//   void hideSuggestions() {
//     showSuggestions.value = false;
//   }
//
//   /// **PERFORM SEARCH - ENHANCED VERSION (as suggested)**
//   Future<void> performSearch(String query) async {
//     searchText.value = query;
//     hasSearched.value = true;
//     isLoadingData.value = true;
//
//     if (query.trim().isEmpty) {
//       restaurantResults.clear();
//       productResults.clear();
//       categoryResults.clear();
//       isLoadingData.value = false;
//       return;
//     }
//
//     final lowerQuery = query.toLowerCase();
//
//     try {
//       print("🔍 Enhanced search for: '$query'");
//
//       // 🔎 Get results from Firestore (or local lists)
//       List<VendorModel> allRestaurants = [];
//       List<ProductModel> allProducts = [];
//       List<VendorCategoryModel> allCategories = [];
//
//       // Try to get fresh data - WITH MEMORY LIMITS to prevent crashes
//       try {
//         // CRITICAL: Add limits to prevent OutOfMemoryError
//         allRestaurants = await FireStoreUtils.getAllVendors(limit: 100); // Limit to 100 restaurants
//         allProducts = await FireStoreUtils.getAllProducts(limit: 200); // Limit to 200 products
//         allCategories = await FireStoreUtils.getVendorCategory();
//         print("🔍 Loaded ${allRestaurants.length} restaurants, ${allProducts.length} products, ${allCategories.length} categories");
//       } catch (e) {
//         print("❌ Error loading fresh data: $e");
//         if (e.toString().contains('OutOfMemoryError')) {
//           print("🚨 OutOfMemoryError detected! Using minimal data to prevent crash.");
//           // Use minimal data to prevent further crashes
//           allRestaurants = restaurantResults.take(10).toList();
//           allProducts = productResults.take(20).toList();
//           allCategories = categoryResults.take(5).toList();
//         } else {
//           // Use existing data as fallback
//           allRestaurants = restaurantResults.toList();
//           allProducts = productResults.toList();
//           allCategories = categoryResults.toList();
//         }
//       }
//
//       // ✅ COMPREHENSIVE SEARCH - search in ALL relevant fields based on actual model structure
//       var filteredRestaurants = allRestaurants
//           .where((r) =>
//               (r.title != null && r.title!.toLowerCase().contains(lowerQuery)) ||
//               (r.description != null && r.description!.toLowerCase().contains(lowerQuery)) ||
//               (r.location != null && r.location!.toLowerCase().contains(lowerQuery)) ||
//               (r.categoryTitle != null && r.categoryTitle!.any((cat) => cat.toLowerCase().contains(lowerQuery))) ||
//               (r.id != null && r.id!.toLowerCase().contains(lowerQuery)) ||
//               (r.phonenumber != null && r.phonenumber!.toLowerCase().contains(lowerQuery)) ||
//               (r.vType != null && r.vType!.toLowerCase().contains(lowerQuery))
//           )
//           .toList();
//
//       var filteredProducts = allProducts
//           .where((p) =>
//               (p.name != null && p.name!.toLowerCase().contains(lowerQuery)) ||
//               (p.description != null && p.description!.toLowerCase().contains(lowerQuery)) ||
//               (p.categoryID != null && p.categoryID!.toLowerCase().contains(lowerQuery)) ||
//               (p.vendorID != null && p.vendorID!.toLowerCase().contains(lowerQuery)) ||
//               (p.id != null && p.id!.toLowerCase().contains(lowerQuery)) ||
//               (p.price != null && p.price!.toLowerCase().contains(lowerQuery)) ||
//               (p.disPrice != null && p.disPrice!.toLowerCase().contains(lowerQuery))
//           )
//           .toList();
//
//       var filteredCategories = allCategories
//           .where((c) =>
//               (c.title != null && c.title!.toLowerCase().contains(lowerQuery)) ||
//               (c.description != null && c.description!.toLowerCase().contains(lowerQuery)) ||
//               (c.id != null && c.id!.toLowerCase().contains(lowerQuery))
//           )
//           .toList();
//
//       // Debug: Show comprehensive filtering results
//       print("🔍 COMPREHENSIVE SEARCH RESULTS for '$query':");
//       print("  📍 RESTAURANT MATCHES: ${filteredRestaurants.length} out of ${allRestaurants.length}");
//       print("    - Searched in: title, description, location, categoryTitle, id, phonenumber, vType");
//       print("  🍕 PRODUCT MATCHES: ${filteredProducts.length} out of ${allProducts.length}");
//       print("    - Searched in: name, description, categoryID, vendorID, id, price, disPrice");
//       print("  📂 CATEGORY MATCHES: ${filteredCategories.length} out of ${allCategories.length}");
//       print("    - Searched in: title, description, id");
//
//       // Enhanced debugging for restaurant search issues
//       if (filteredRestaurants.isEmpty && allRestaurants.isNotEmpty) {
//         print("🔍 DEBUG: No restaurant matches found. Checking sample restaurant data:");
//         for (int i = 0; i < (allRestaurants.length > 3 ? 3 : allRestaurants.length); i++) {
//           var r = allRestaurants[i];
//           print("  Restaurant ${i + 1}:");
//           print("    - Title: '${r.title}'");
//           print("    - Description: '${r.description}'");
//           print("    - Location: '${r.location}'");
//           print("    - CategoryTitle: ${r.categoryTitle}");
//           print("    - ID: '${r.id}'");
//           print("    - Phone: '${r.phonenumber}'");
//           print("    - vType: '${r.vType}'");
//           print("    - Query: '$lowerQuery'");
//           print("    - Title contains query: ${r.title?.toLowerCase().contains(lowerQuery) ?? false}");
//           print("    - Description contains query: ${r.description?.toLowerCase().contains(lowerQuery) ?? false}");
//         }
//       }
//
//       // Show sample matches for debugging
//       if (filteredRestaurants.isNotEmpty) {
//         print("  📍 Sample restaurant matches:");
//         for (int i = 0; i < (filteredRestaurants.length > 3 ? 3 : filteredRestaurants.length); i++) {
//           var r = filteredRestaurants[i];
//           print("    - ${r.title} (${r.location})");
//         }
//       }
//
//       if (filteredProducts.isNotEmpty) {
//         print("  🍕 Sample product matches:");
//         for (int i = 0; i < (filteredProducts.length > 3 ? 3 : filteredProducts.length); i++) {
//           var p = filteredProducts[i];
//           print("    - ${p.name} (₹${p.price})");
//         }
//       }
//
//       if (filteredCategories.isNotEmpty) {
//         print("  📂 Sample category matches:");
//         for (int i = 0; i < (filteredCategories.length > 3 ? 3 : filteredCategories.length); i++) {
//           var c = filteredCategories[i];
//           print("    - ${c.title}");
//         }
//       }
//
//       // If no results found, try partial/fuzzy matching
//       if (filteredRestaurants.isEmpty && filteredProducts.isEmpty && filteredCategories.isEmpty) {
//         print("🔍 No exact matches found, trying partial/fuzzy matching...");
//
//         // Try partial word matching
//         var words = lowerQuery.split(' ');
//         for (String word in words) {
//           if (word.length > 2) { // Only search words longer than 2 characters
//             // Partial restaurant matches
//             var partialRestaurants = allRestaurants
//                 .where((r) =>
//                     (r.title != null && r.title!.toLowerCase().contains(word)) ||
//                     (r.description != null && r.description!.toLowerCase().contains(word)) ||
//                     (r.location != null && r.location!.toLowerCase().contains(word)) ||
//                     (r.categoryTitle != null && r.categoryTitle!.any((cat) => cat.toLowerCase().contains(word))) ||
//                     (r.phonenumber != null && r.phonenumber!.toLowerCase().contains(word)) ||
//                     (r.vType != null && r.vType!.toLowerCase().contains(word))
//                 )
//                 .toList();
//             filteredRestaurants.addAll(partialRestaurants);
//
//             // Partial product matches
//             var partialProducts = allProducts
//                 .where((p) =>
//                     (p.name != null && p.name!.toLowerCase().contains(word)) ||
//                     (p.description != null && p.description!.toLowerCase().contains(word)) ||
//                     (p.price != null && p.price!.toLowerCase().contains(word)) ||
//                     (p.disPrice != null && p.disPrice!.toLowerCase().contains(word))
//                 )
//                 .toList();
//             filteredProducts.addAll(partialProducts);
//
//             // Partial category matches
//             var partialCategories = allCategories
//                 .where((c) =>
//                     (c.title != null && c.title!.toLowerCase().contains(word)) ||
//                     (c.description != null && c.description!.toLowerCase().contains(word))
//                 )
//                 .toList();
//             filteredCategories.addAll(partialCategories);
//           }
//         }
//
//         // Remove duplicates
//         filteredRestaurants = filteredRestaurants.toSet().toList();
//         filteredProducts = filteredProducts.toSet().toList();
//         filteredCategories = filteredCategories.toSet().toList();
//
//         print("🔍 After partial matching:");
//         print("  - Partial restaurant matches: ${filteredRestaurants.length}");
//         print("  - Partial product matches: ${filteredProducts.length}");
//         print("  - Partial category matches: ${filteredCategories.length}");
//
//         // If still no results, try sample data
//         if (filteredRestaurants.isEmpty && filteredProducts.isEmpty && filteredCategories.isEmpty) {
//           print("🔍 No partial matches found, trying sample data...");
//           var sampleResults = _searchSampleData(query);
//
//           // Separate sample results
//           for (var result in sampleResults) {
//             if (result is VendorModel) {
//               filteredRestaurants.add(result);
//             } else if (result is ProductModel) {
//               filteredProducts.add(result);
//             }
//           }
//         }
//       }
//
//       // Sort results by relevance (products first, then restaurants, then categories)
//       filteredProducts.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
//       filteredRestaurants.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
//       filteredCategories.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
//
//       // Show ALL matching results - no artificial limits
//       // For initial display, show a reasonable number but keep ALL results available
//       int initialDisplayLimit = 50; // Show first 50 of each type initially
//
//       // Take initial results for display (but keep ALL results available)
//       var initialProducts = filteredProducts.take(initialDisplayLimit).toList();
//       var initialRestaurants = filteredRestaurants.take(initialDisplayLimit).toList();
//       var initialCategories = filteredCategories.take(initialDisplayLimit).toList();
//
//       // Store ALL remaining results for pagination (no artificial limits)
//       _remainingProducts = filteredProducts.skip(initialDisplayLimit).toList();
//       _remainingRestaurants = filteredRestaurants.skip(initialDisplayLimit).toList();
//       _remainingCategories = filteredCategories.skip(initialDisplayLimit).toList();
//
//       // Update observable lists
//       productResults.assignAll(initialProducts);
//       restaurantResults.assignAll(initialRestaurants);
//       categoryResults.assignAll(initialCategories);
//
//       // Update counts
//       currentResultCount.value = initialProducts.length + initialRestaurants.length + initialCategories.length;
//       totalAvailableResults.value = filteredProducts.length + filteredRestaurants.length + filteredCategories.length;
//
//       // Check if there are more results
//       hasMoreResults.value = _remainingProducts.isNotEmpty || _remainingRestaurants.isNotEmpty || _remainingCategories.isNotEmpty;
//
//       // Debug: Print comprehensive search results
//       print("📊 Comprehensive Search Results:");
//       print("  - Total available: ${totalAvailableResults.value} results");
//       print("  - ALL products found: ${filteredProducts.length}");
//       print("  - ALL restaurants found: ${filteredRestaurants.length}");
//       print("  - ALL categories found: ${filteredCategories.length}");
//       print("  - Initial display: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${initialCategories.length} categories");
//       print("  - Remaining products: ${_remainingProducts.length}");
//       print("  - Remaining restaurants: ${_remainingRestaurants.length}");
//       print("  - Remaining categories: ${_remainingCategories.length}");
//       print("  - Has more results: ${hasMoreResults.value}");
//
//       // Fallback: If we have any results but no remaining, still show Load More for better UX
//       if (!hasMoreResults.value && (initialProducts.isNotEmpty || initialRestaurants.isNotEmpty || filteredCategories.isNotEmpty)) {
//         hasMoreResults.value = true;
//         print("📊 Fallback: Showing Load More button for better UX");
//       }
//
//       // Suggestions (optional with TrieSearch)
//       try {
//         searchSuggestions.value = trieSearch.getSuggestions(lowerQuery, maxSuggestions: MAX_SUGGESTIONS);
//       } catch (e) {
//         print("❌ Error getting suggestions: $e");
//         searchSuggestions.clear();
//       }
//
//       // Save to recent searches
//       _saveRecentSearch(query);
//
//       print("📊 Enhanced search results: ${initialProducts.length} products, ${initialRestaurants.length} restaurants, ${filteredCategories.length} categories");
//       print("📊 Total available: ${totalAvailableResults.value} results");
//
//     } catch (e) {
//       print("❌ Enhanced search error: $e");
//     } finally {
//       isLoadingData.value = false;
//     }
//   }
//
//   /// **CLEAR ALL DATA**
//   void clearAllData() {
//     restaurantResults.clear();
//     productResults.clear();
//     categoryResults.clear();
//     searchSuggestions.clear();
//     recentSearches.clear();
//     trendingSearches.clear();
//     hasSearched.value = false;
//     isSearching.value = false;
//     showSuggestions.value = false;
//     searchText.value = '';
//     currentResultCount.value = 0;
//     hasMoreResults.value = true;
//     dataLoaded.value = false;
//     _remainingProducts.clear();
//     _remainingRestaurants.clear();
//     _remainingCategories.clear();
//     trieSearch.clear();
//   }
// }