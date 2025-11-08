import 'package:customer/constant/constant.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/text_processing_anr_fix.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// **TRIE NODE FOR DICTIONARY-BASED SEARCH**
class TrieNode {
  Map<String, TrieNode> children = {};
  List<dynamic> dataRefs = []; // Can be VendorModel or ProductModel
  bool isEnd = false;
  double relevanceScore = 0.0;
}

// **TRIE SEARCH IMPLEMENTATION**
class TrieSearch {
  final TrieNode root = TrieNode();
  int totalIndexedItems = 0;
  
  void insert(String word, dynamic data, {double relevanceScore = 1.0}) {
    try {
      if (word.isEmpty) return;
      
      TrieNode node = root;
      final lowerWord = word.toLowerCase();
      
      for (var char in lowerWord.split('')) {
        node = node.children.putIfAbsent(char, () => TrieNode());
      }
      
      node.isEnd = true;
      node.dataRefs.add(data);
      node.relevanceScore = relevanceScore;
      totalIndexedItems++;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to insert word "$word" into trie: $e');
      }
      // Log to Crashlytics for production monitoring
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie insert failed');
    }
  }
  
  List<dynamic> search(String prefix, {int maxResults = 50}) {
    try {
      if (prefix.isEmpty) return [];
      
      TrieNode node = root;
      final lowerPrefix = prefix.toLowerCase();
      
      // Navigate to the prefix node
      for (var char in lowerPrefix.split('')) {
        if (!node.children.containsKey(char)) return [];
        node = node.children[char]!;
      }
      
      // Collect all words from this node
      return _collectAllWords(node, maxResults);
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to search prefix "$prefix" in trie: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie search failed');
      return [];
    }
  }
  
  List<dynamic> _collectAllWords(TrieNode node, int maxResults) {
    try {
      List<dynamic> results = [];
      Set<String> seenIds = {}; // Prevent duplicates
      
      void traverse(TrieNode currentNode) {
        if (results.length >= maxResults) return;
        
        if (currentNode.isEnd) {
          for (var data in currentNode.dataRefs) {
            String id = _getId(data);
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              results.add(data);
              if (results.length >= maxResults) return;
            }
          }
        }
        
        // Sort children by relevance for better results
        var sortedChildren = currentNode.children.entries.toList()
          ..sort((a, b) => b.value.relevanceScore.compareTo(a.value.relevanceScore));
        
        for (var entry in sortedChildren) {
          traverse(entry.value);
          if (results.length >= maxResults) return;
        }
      }
      
      traverse(node);
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to collect words from trie: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie word collection failed');
      return [];
    }
  }
  
  String _getId(dynamic data) {
    try {
      if (data is VendorModel) return data.id ?? '';
      if (data is ProductModel) return data.id ?? '';
      return '';
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to get ID from data: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie ID extraction failed');
      return '';
    }
  }
  
  // **AUTO-COMPLETE SUGGESTIONS**
  List<String> getSuggestions(String prefix, {int maxSuggestions = 10}) {
    try {
      if (prefix.isEmpty) return [];
      
      List<String> suggestions = [];
      TrieNode node = root;
      final lowerPrefix = prefix.toLowerCase();
      
      // Navigate to prefix
      for (var char in lowerPrefix.split('')) {
        if (!node.children.containsKey(char)) return suggestions;
        node = node.children[char]!;
      }
      
      // Collect suggestions
      _collectSuggestions(node, lowerPrefix, suggestions, maxSuggestions);
      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to get suggestions for "$prefix": $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie suggestions failed');
      return [];
    }
  }
  
  void _collectSuggestions(TrieNode node, String currentWord, List<String> suggestions, int maxSuggestions) {
    try {
      if (suggestions.length >= maxSuggestions) return;
      
      if (node.isEnd && !suggestions.contains(currentWord)) {
        suggestions.add(currentWord);
      }
      
      for (var entry in node.children.entries) {
        _collectSuggestions(entry.value, currentWord + entry.key, suggestions, maxSuggestions);
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERROR: Failed to collect suggestions: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie suggestion collection failed');
    }
  }
}

// **ISOLATE-BASED SEARCH DATA STRUCTURE**
class SearchData {
  final List<VendorModel> vendors;
  final List<ProductModel> products;
  
  SearchData({required this.vendors, required this.products});
  
  Map<String, dynamic> toJson() => {
    'vendors': vendors.map((v) => v.toJson()).toList(),
    'products': products.map((p) => p.toJson()).toList(),
  };
}

// **ISOLATE SEARCH FUNCTION**
Future<List<dynamic>> _searchIsolate(Map<String, dynamic> params) async {
  try {
    final searchData = params['searchData'] as SearchData;
    final query = params['query'] as String;
    
    // Create trie in isolate
    final trie = TrieSearch();
    
    // Index vendors
    for (var vendor in searchData.vendors) {
      if (vendor.title != null) {
        for (var word in _tokenize(vendor.title!)) {
          trie.insert(word, vendor, relevanceScore: 10.0);
        }
      }
    }
    
    // Index products
    for (var product in searchData.products) {
      if (product.name != null) {
        for (var word in _tokenize(product.name!)) {
          trie.insert(word, product, relevanceScore: 8.0);
        }
      }
    }
    
    // Perform search
    return trie.search(query, maxResults: 100);
  } catch (e) {
    print('ERROR: Isolate search failed: $e');
    return [];
  }
}

// **TOKENIZATION UTILITY**
List<String> _tokenize(String text) {
  try {
    return text
        .toLowerCase()
        .split(RegExp(r'[\s\-_.,!?()]+'))
        .where((word) => word.length >= 2)
        .toList();
  } catch (e) {
    print('ERROR: Tokenization failed: $e');
    return [];
  }
}

class SearchScreenController extends GetxController with TextProcessingANRPreventionMixin {
  Timer? _debounceTimer;
  Timer? _suggestionTimer;
  RxBool isSearching = false.obs;
  RxString searchText = ''.obs;
  TextEditingController? _searchTextController;
  bool _isDisposed = false;

  // **TRIE-BASED SEARCH SYSTEM - STATIC FOR PERSISTENCE**
  static final TrieSearch _vendorTrie = TrieSearch();
  static final TrieSearch _productTrie = TrieSearch();
  
  // **AUTO-COMPLETE SUGGESTIONS**
  RxList<String> searchSuggestions = <String>[].obs;
  RxBool showSuggestions = false.obs;
  
  // **OPTIMIZED CACHING SYSTEM - STATIC FOR PERSISTENCE**
  static Map<String, List<ProductModel>> _productCache = {};
  static List<VendorModel> _cachedVendorList = [];
  static List<ProductModel> _cachedProductList = [];
  static DateTime? _lastCacheTime;
  static const Duration cacheExpiry = Duration(minutes: 30); // Extended cache time

  // **PERFORMANCE FLAGS - STATIC FOR PERSISTENCE**
  static bool _productsLoaded = false;
  static bool _isLoadingProducts = false;
  static bool _trieBuilt = false;
  static const int _largeDatasetThreshold = 10000; // Threshold for isolate-based search

  // **BACKEND SEARCH FALLBACK**
  bool _useBackendSearch = false;
  Timer? _backendSearchTimer;

  // **CRITICAL: ANR PREVENTION**
  static const Duration _maxSearchTime = Duration(milliseconds: 500);
  static const Duration _maxLoadTime = Duration(seconds: 10);
  Timer? _searchTimeoutTimer;
  Timer? _loadTimeoutTimer;
  
  // **PERFORMANCE MONITORING**
  static const Duration _performanceThreshold = Duration(milliseconds: 100);
  DateTime? _lastSearchTime;
  int _searchCount = 0;
  int _slowSearchCount = 0;

  // Getter for searchTextController
  TextEditingController get searchTextController {
    if (_isDisposed) {
      _searchTextController = TextEditingController();
      _isDisposed = false;
    }
    _searchTextController ??= TextEditingController();
    return _searchTextController!;
  }

  @override
  void onInit() {
    super.onInit();
    _searchTextController ??= TextEditingController();
    _isDisposed = false;
    getArgument();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _suggestionTimer?.cancel();
    _backendSearchTimer?.cancel();
    _searchTimeoutTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    
    // Log performance metrics
    if (_searchCount > 0) {
      final slowSearchPercentage = (_slowSearchCount / _searchCount) * 100;
      print('PERFORMANCE: Search metrics - Total: $_searchCount, Slow: $_slowSearchCount (${slowSearchPercentage.toStringAsFixed(1)}%)');
    }
    
    super.onClose();
  }



  // **CRITICAL: ANR PREVENTION METHODS**
  void _startSearchTimeout() {
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = Timer(_maxSearchTime, () {
      if (!_isDisposed) {
        print('WARNING: Search operation timed out, stopping search');
        isSearching.value = false;
      }
    });
  }

  void _startLoadTimeout() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(_maxLoadTime, () {
      if (!_isDisposed) {
        print('WARNING: Product loading timed out, stopping load');
        _isLoadingProducts = false;
        isLoading.value = false;
      }
    });
  }

  void _cancelTimeouts() {
    _searchTimeoutTimer?.cancel();
    _loadTimeoutTimer?.cancel();
  }

  RxBool isLoading = true.obs;
  RxList<VendorModel> vendorList = <VendorModel>[].obs;
  RxList<VendorModel> vendorSearchList = <VendorModel>[].obs;

  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<ProductModel> productSearchList = <ProductModel>[].obs;

  // **OPTIMIZED CACHE VALIDATION**
  bool _isCacheValid() {
    return _lastCacheTime != null && 
           DateTime.now().difference(_lastCacheTime!) < cacheExpiry;
  }

  void _updateCacheTime() {
    _lastCacheTime = DateTime.now();
  }

  getArgument() async {
    if (_isDisposed) return;
    
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorList.value = argumentData['vendorList'];
      _cachedVendorList = List.from(vendorList);
      
      // Build vendor trie immediately
      _buildVendorTrie();
      
      productList.clear();
    }
    isLoading.value = false;

    // Load products immediately for comprehensive search
    _loadProductsImmediately();
  }

  // **IMMEDIATE PRODUCT LOADING FOR COMPREHENSIVE SEARCH**
  Future<void> _loadProductsImmediately() async {
    if (_isDisposed || _productsLoaded || _isLoadingProducts) return;
    
    _isLoadingProducts = true;
    print("DEBUG: Starting immediate product loading for comprehensive search...");
    
    // **CRITICAL: Start timeout to prevent ANR**
    _startLoadTimeout();
    
    try {
      // Check if we have cached products
      if (_isCacheValid() && _cachedProductList.isNotEmpty) {
        print("DEBUG: Using cached products: ${_cachedProductList.length}");
        productList.addAll(_cachedProductList);
        _buildProductTrie();
        _productsLoaded = true;
        _isLoadingProducts = false;
        _cancelTimeouts(); // Cancel timeout since we succeeded
        return;
      }

      // Clear cache if expired
      _productCache.clear();
      _cachedProductList.clear();

      // Load products from all vendors
      print("DEBUG: Loading products from ${_cachedVendorList.length} vendors...");
      for (var vendor in _cachedVendorList) {
        if (_isDisposed) return;
        
        try {
          print("DEBUG: Loading products for vendor: ${vendor.title} (ID: ${vendor.id})");
          // **CRITICAL: Add timeout for each vendor request**
          final products = await FireStoreUtils.getProductByVendorId(vendor.id.toString())
              .timeout(const Duration(seconds: 5), onTimeout: () {
            print("WARNING: Timeout loading products for vendor ${vendor.title}");
            return <ProductModel>[];
          });
          
          List<ProductModel> filteredProducts;
          if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && vendor.subscriptionPlan != null) {
            if (vendor.subscriptionPlan?.itemLimit == '-1') {
              filteredProducts = products;
            } else {
              int selectedProduct = products.length < int.parse(vendor.subscriptionPlan?.itemLimit ?? '0') 
                  ? (products.isEmpty ? 0 : products.length) 
                  : int.parse(vendor.subscriptionPlan?.itemLimit ?? '0');
              filteredProducts = products.sublist(0, selectedProduct);
            }
          } else {
            filteredProducts = products;
          }
          
          print("DEBUG: Found ${products.length} products for vendor ${vendor.title}");
          print("DEBUG: Added ${filteredProducts.length} products from vendor ${vendor.title}");
          
          if (!_isDisposed) {
            productList.addAll(filteredProducts);
            _productCache[vendor.id.toString()] = filteredProducts;
            print("DEBUG: Product list now has ${productList.length} items after adding ${filteredProducts.length} from ${vendor.title}");
          }
        } catch (e) {
          print("ERROR: Failed to load products for vendor ${vendor.id}: $e");
        }
      }

      // Build product trie after loading
      if (!_isDisposed) {
        print("DEBUG: About to build trie. Product list has ${productList.length} items");
        if (productList.isNotEmpty) {
          _buildProductTrie();
          _cachedProductList = List.from(productList);
          _updateCacheTime();
          _productsLoaded = true;
          _isLoadingProducts = false;
          _cancelTimeouts(); // Cancel timeout since we succeeded
          print("DEBUG: Successfully loaded ${productList.length} products and built trie");
          
          // **DEBUG: Check cached data state after loading**
          debugCachedData();
        } else {
          print("ERROR: Product list is empty when trying to build trie!");
          _isLoadingProducts = false;
          _cancelTimeouts();
        }
      }
    } catch (e) {
      print("ERROR: Failed to load products: $e");
      _isLoadingProducts = false;
      _cancelTimeouts();
    }
  }

  // **BUILD VENDOR TRIE**
  void _buildVendorTrie() {
    print("DEBUG: Building vendor trie...");
    int indexedVendors = 0;
    
    try {
      for (var vendor in _cachedVendorList) {
        // Index vendor title with high relevance
        if (vendor.title != null) {
          for (var word in _tokenize(vendor.title!)) {
            _vendorTrie.insert(word, vendor, relevanceScore: 10.0);
          }
        }
        
        // Index vendor location with medium relevance
        if (vendor.location != null) {
          for (var word in _tokenize(vendor.location!)) {
            _vendorTrie.insert(word, vendor, relevanceScore: 5.0);
          }
        }
        
        // Index vendor description with lower relevance
        if (vendor.description != null) {
          for (var word in _tokenize(vendor.description!)) {
            _vendorTrie.insert(word, vendor, relevanceScore: 2.0);
          }
        }
        
        // Index vendor categories
        if (vendor.categoryTitle != null) {
          for (var category in vendor.categoryTitle!) {
            for (var word in _tokenize(category.toString())) {
              _vendorTrie.insert(word, vendor, relevanceScore: 7.0);
            }
          }
        }
        
        indexedVendors++;
      }
      
      print("DEBUG: Built vendor trie for $indexedVendors vendors");
    } catch (e) {
      print("ERROR: Failed to build vendor trie: $e");
      print("ERROR: Stack trace: ${StackTrace.current}");
    }
  }

  // **BUILD PRODUCT TRIE**
  void _buildProductTrie() {
    print("DEBUG: Starting to build product trie...");
    print("DEBUG: Number of products to index: ${_cachedProductList.length}");
    
    int indexedProducts = 0;
    int totalWordsIndexed = 0;
    
    try {
      for (var product in _cachedProductList) {
        try {
          int wordsForThisProduct = 0;
          
          // Index product name with highest relevance
          if (product.name != null) {
            var nameWords = _tokenize(product.name!);
            for (var word in nameWords) {
              _productTrie.insert(word, product, relevanceScore: 10.0);
              wordsForThisProduct++;
            }
            if (nameWords.isNotEmpty) {
              print("DEBUG: Indexed product '${product.name}' with words: $nameWords");
            }
          }
          
          // Index product description with medium relevance
          if (product.description != null) {
            var descWords = _tokenize(product.description!);
            for (var word in descWords) {
              _productTrie.insert(word, product, relevanceScore: 3.0);
              wordsForThisProduct++;
            }
          }
          
          // Index product category with high relevance
          if (product.categoryID != null) {
            var catWords = _tokenize(product.categoryID!);
            for (var word in catWords) {
              _productTrie.insert(word, product, relevanceScore: 8.0);
              wordsForThisProduct++;
            }
          }
          
          // Index product attributes if available
          if (product.itemAttribute != null && product.itemAttribute!.attributes != null) {
            try {
              for (var attribute in product.itemAttribute!.attributes!) {
                if (attribute.attributeId != null) {
                  var attrWords = _tokenize(attribute.attributeId!);
                  for (var word in attrWords) {
                    _productTrie.insert(word, product, relevanceScore: 6.0);
                    wordsForThisProduct++;
                  }
                }
                
                if (attribute.attributeOptions != null) {
                  for (var option in attribute.attributeOptions!) {
                    var optionWords = _tokenize(option.toString());
                    for (var word in optionWords) {
                      _productTrie.insert(word, product, relevanceScore: 5.0);
                      wordsForThisProduct++;
                    }
                  }
                }
              }
            } catch (e) {
              print("ERROR: Failed to index product ${product.id} attributes: $e");
            }
          }
          
          totalWordsIndexed += wordsForThisProduct;
          indexedProducts++;
          
          // Log every 100th product for debugging
          if (indexedProducts % 100 == 0) {
            print("DEBUG: Indexed $indexedProducts products so far...");
          }
        } catch (e) {
          print("ERROR: Failed to index product ${product.id}: $e");
        }
      }
      
      print("DEBUG: Built product trie for $indexedProducts products");
      print("DEBUG: Total words indexed: $totalWordsIndexed");
      print("DEBUG: Product trie total indexed items: ${_productTrie.totalIndexedItems}");
      
      // Test the trie immediately with various searches
      var testResults = _productTrie.search("test");
      print("DEBUG: Product trie test search 'test' returned ${testResults.length} results");
      
      var pizzaResults = _productTrie.search("pizza");
      print("DEBUG: Product trie test search 'pizza' returned ${pizzaResults.length} results");
      
      var biryaniResults = _productTrie.search("biryani");
      print("DEBUG: Product trie test search 'biryani' returned ${biryaniResults.length} results");
      
      _trieBuilt = true;
    } catch (e) {
      print("ERROR: Failed to build product trie: $e");
      print("ERROR: Stack trace: ${StackTrace.current}");
    }
  }

  // **ADVANCED TOKENIZATION**
  List<String> _tokenize(String text) {
    if (text.isEmpty) return [];
    
    return text.toLowerCase()
        .split(RegExp(r'[\s\-_.,!?()]+'))
        .where((word) => word.length >= 2)
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  // **CLEAN SEARCH TEXT HANDLER**
  void onSearchTextChanged(String text) {
    try {
      if (_isDisposed) return;
      
      final cleaned = text.trim();
      searchText.value = cleaned;
      
      // Clear results if empty
      if (cleaned.isEmpty) {
        _clearSearchResults();
        return;
      }

      // Show suggestions while typing
      _updateSearchSuggestions(cleaned);
      
      // Perform search with debounce
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (!_isDisposed && searchText.value == cleaned) {
          isSearching.value = true;
          _performSimpleSearch(cleaned);
        }
      });
      
    } catch (e) {
      print('❌ Search text change failed: $e');
      if (!_isDisposed) {
        isSearching.value = false;
      }
    }
  }

  // **ENHANCED SEARCH FUNCTION**
  void _performSimpleSearch(String query) {
    try {
      print("🔍 Searching for: '$query'");
      print("📊 Available data - Restaurants: ${_cachedVendorList.length}, Products: ${_cachedProductList.length}");
      
      final queryLower = query.toLowerCase().trim();
      if (queryLower.isEmpty) {
        _clearSearchResults();
        return;
      }
      
      List<VendorModel> vendorResults = [];
      List<ProductModel> productResults = [];
      
      // Search restaurants
      print("🏪 Searching restaurants...");
      for (var vendor in _cachedVendorList) {
        if (vendor.title?.toLowerCase().contains(queryLower) == true ||
            vendor.location?.toLowerCase().contains(queryLower) == true) {
          vendorResults.add(vendor);
          print("✅ Restaurant match: ${vendor.title}");
        }
      }
      
      // Enhanced product search
      print("🍽️ Searching products...");
      for (var product in _cachedProductList) {
        bool matches = false;
        String matchReason = "";
        
        // Check product name
        if (product.name?.toLowerCase().contains(queryLower) == true) {
          matches = true;
          matchReason = "name";
        }
        
        // Check product description
        if (!matches && product.description?.toLowerCase().contains(queryLower) == true) {
          matches = true;
          matchReason = "description";
        }
        
        // Check category ID
        if (!matches && product.categoryID?.toLowerCase().contains(queryLower) == true) {
          matches = true;
          matchReason = "category";
        }
        
        // Check add-ons (if available)
        if (!matches && product.addOnsTitle != null && product.addOnsTitle!.isNotEmpty) {
          for (var addon in product.addOnsTitle!) {
            if (addon.toString().toLowerCase().contains(queryLower)) {
              matches = true;
              matchReason = "addon: $addon";
              break;
            }
          }
        }
        
        // Check product specification (if available)
        if (!matches && product.productSpecification != null) {
          for (var key in product.productSpecification!.keys) {
            if (key.toLowerCase().contains(queryLower) ||
                product.productSpecification![key].toString().toLowerCase().contains(queryLower)) {
              matches = true;
              matchReason = "specification: $key";
              break;
            }
          }
        }
        
        // Check if it's vegetarian/non-vegetarian
        if (!matches) {
          if (queryLower.contains('veg') && product.veg == true) {
            matches = true;
            matchReason = "vegetarian";
          } else if (queryLower.contains('nonveg') && product.nonveg == true) {
            matches = true;
            matchReason = "non-vegetarian";
          }
        }
        
        if (matches) {
          productResults.add(product);
          print("✅ Product match: ${product.name} (by $matchReason)");
        }
      }
      
      print("📈 Search Results - Restaurants: ${vendorResults.length}, Products: ${productResults.length}");
      
      // Debug: Show sample products if no matches
      if (productResults.isEmpty && _cachedProductList.isNotEmpty) {
        print("🔍 No product matches found. Sample products:");
        for (int i = 0; i < _cachedProductList.take(5).length; i++) {
          var product = _cachedProductList[i];
          print("   - ${product.name} (${product.description})");
        }
      }
      
      // Update UI
      if (!_isDisposed) {
        vendorSearchList.value = vendorResults;
        productSearchList.value = productResults;
        isSearching.value = false;
        showSuggestions.value = false; // Hide suggestions when showing results
        print("🎯 UI Updated - Vendor list: ${vendorSearchList.length}, Product list: ${productSearchList.length}");
      }
      
    } catch (e) {
      print("❌ Search failed: $e");
      if (!_isDisposed) {
        isSearching.value = false;
      }
    }
  }

  // **PERFORM TRIE SEARCH WITH PERFORMANCE MONITORING**
  void _performTrieSearch(String cleaned) {
    try {
      final searchStartTime = DateTime.now();
      
      print("DEBUG: Searching vendor trie for: '$cleaned'");
      final vendorMatches = _vendorTrie.search(cleaned);
      print("DEBUG: Vendor trie search returned: ${vendorMatches.length} results");
      
      print("DEBUG: Searching product trie for: '$cleaned'");
      final productMatches = _productTrie.search(cleaned);
      print("DEBUG: Product trie search returned: ${productMatches.length} results");
      
      // Debug: Check what products are in the trie
      if (productMatches.isEmpty) {
        print("DEBUG: No products found in trie search, checking trie contents...");
        print("DEBUG: Product trie total indexed items: ${_productTrie.totalIndexedItems}");
        print("DEBUG: Cached product list length: ${_cachedProductList.length}");
        
        // Test with a simple search
        var testSearch = _productTrie.search("test");
        print("DEBUG: Test search 'test' returned: ${testSearch.length} results");
        
        // Check if any products contain the search term
        var productsWithTerm = _cachedProductList.where((p) => 
          p.name?.toLowerCase().contains(cleaned.toLowerCase()) == true ||
          p.description?.toLowerCase().contains(cleaned.toLowerCase()) == true
        ).toList();
        print("DEBUG: Products containing '$cleaned': ${productsWithTerm.length}");
        
        if (productsWithTerm.isNotEmpty) {
          print("DEBUG: Sample products with '$cleaned':");
          for (int i = 0; i < productsWithTerm.take(3).length; i++) {
            print("DEBUG: - ${productsWithTerm[i].name} (${productsWithTerm[i].description})");
          }
        } else {
          // Show some sample products to verify they exist
          print("DEBUG: Sample products in cache (first 3):");
          for (int i = 0; i < _cachedProductList.take(3).length; i++) {
            var product = _cachedProductList[i];
            print("DEBUG: - ${product.name} (${product.description})");
          }
        }
      }
      
      // Fallback: If trie search returns no products, try direct search
      List<ProductModel> finalProductMatches = productMatches.cast<ProductModel>().toList();
      if (finalProductMatches.isEmpty && _cachedProductList.isNotEmpty) {
        print("DEBUG: Trie search returned no products, trying direct search...");
        finalProductMatches = _performDirectProductSearch(cleaned);
        print("DEBUG: Direct search returned: ${finalProductMatches.length} products");
      }
      
      print("DEBUG: Final search results - Vendors: ${vendorMatches.length}, Products: ${finalProductMatches.length}");

      // Convert to proper types and remove duplicates
      final uniqueVendors = vendorMatches.cast<VendorModel>().toSet().toList();
      final uniqueProducts = finalProductMatches.toSet().toList();

      // Sort by relevance (prefix matches first)
      final sortedVendors = _sortByRelevance(uniqueVendors, cleaned, (v) => v.title ?? '');
      final sortedProducts = _sortByRelevance(uniqueProducts, cleaned, (p) => p.name ?? '');

      // Update results
      if (!_isDisposed) {
        print("DEBUG: Updating UI with ${sortedVendors.length} vendors and ${sortedProducts.length} products");
        vendorSearchList.value = sortedVendors;
        productSearchList.value = sortedProducts;
        isSearching.value = false;
        _cancelTimeouts();
        
        // **PERFORMANCE MONITORING**
        _recordSearchPerformance(searchStartTime);
      }
    } catch (e) {
      print("ERROR: Trie search failed: $e");
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Trie search failed');
      if (!_isDisposed) {
        isSearching.value = false;
        _cancelTimeouts();
      }
    }
  }

  // **ISOLATE-BASED SEARCH FOR LARGE DATASETS**
  void _performIsolateSearch(String cleaned) async {
    try {
      final searchStartTime = DateTime.now();
      
      print("DEBUG: Performing isolate search for: '$cleaned'");
      
      // Prepare search data
      final searchData = SearchData(
        vendors: _cachedVendorList,
        products: _cachedProductList,
      );
      
      // Perform search in isolate
      final results = await compute(_searchIsolate, {'searchData': searchData, 'query': cleaned});
      
      // Process results
      final vendorMatches = results.whereType<VendorModel>().toList();
      final productMatches = results.whereType<ProductModel>().toList();
      
      print("DEBUG: Isolate search returned - Vendors: ${vendorMatches.length}, Products: ${productMatches.length}");
      
      // Update UI safely
      if (!_isDisposed) {
        vendorSearchList.value = vendorMatches;
        productSearchList.value = productMatches;
        isSearching.value = false;
        _cancelTimeouts();
        
        // **PERFORMANCE MONITORING**
        _recordSearchPerformance(searchStartTime);
      }
    } catch (e) {
      print("ERROR: Isolate search failed: $e");
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Isolate search failed');
      
      // Fallback to local search
      _performTrieSearch(cleaned);
    }
  }

  // **PERFORMANCE MONITORING**
  void _recordSearchPerformance([DateTime? searchStartTime]) {
    try {
      final endTime = DateTime.now();
      final startTime = searchStartTime ?? _lastSearchTime ?? endTime;
      final duration = endTime.difference(startTime);
      
      if (duration > _performanceThreshold) {
        _slowSearchCount++;
        print('PERFORMANCE: Slow search detected - ${duration.inMilliseconds}ms');
        
        // Log to Crashlytics for monitoring
        FirebaseCrashlytics.instance.log('Slow search: ${duration.inMilliseconds}ms');
      }
      
      print('PERFORMANCE: Search completed in ${duration.inMilliseconds}ms');
    } catch (e) {
      print('ERROR: Failed to record search performance: $e');
    }
  }

  // **DIRECT PRODUCT SEARCH (FALLBACK METHOD)**
  List<ProductModel> _performDirectProductSearch(String searchQuery) {
    List<ProductModel> matches = [];
    
    try {
      print("DEBUG: Performing direct product search for: '$searchQuery'");
      print("DEBUG: Searching through ${_cachedProductList.length} cached products");
      
      final query = searchQuery.toLowerCase();
      
      for (var product in _cachedProductList) {
        bool productMatches = false;
        
        // Check product name (highest priority)
        if (product.name != null && product.name!.toLowerCase().contains(query)) {
          productMatches = true;
          print("DEBUG: Product '${product.name}' matches by name");
        }
        
        // Check product description
        if (!productMatches && product.description != null && product.description!.toLowerCase().contains(query)) {
          productMatches = true;
          print("DEBUG: Product '${product.name}' matches by description");
        }
        
        // Check product category
        if (!productMatches && product.categoryID != null && product.categoryID!.toLowerCase().contains(query)) {
          productMatches = true;
          print("DEBUG: Product '${product.name}' matches by category");
        }
        

        
        if (productMatches) {
          matches.add(product);
        }
      }
      
      print("DEBUG: Direct search found ${matches.length} matching products");
      
      // If no matches found, try partial matching
      if (matches.isEmpty && query.length >= 3) {
        print("DEBUG: No exact matches, trying partial matching...");
        for (var product in _cachedProductList) {
          if (product.name != null && 
              product.name!.toLowerCase().split(' ').any((word) => word.startsWith(query))) {
            matches.add(product);
            print("DEBUG: Partial match found: ${product.name}");
          }
        }
        print("DEBUG: Partial matching found ${matches.length} additional products");
      }
      
    } catch (e) {
      print("ERROR: Direct product search failed: $e");
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Direct product search failed');
    }
    
    return matches;
  }

  // **ENHANCED SUGGESTIONS**
  void _updateSearchSuggestions(String query) {
    if (_isDisposed || query.length < 2) {
      showSuggestions.value = false;
      return;
    }
    
    try {
      List<String> suggestions = [];
      final queryLower = query.toLowerCase();
      
      // Get restaurant suggestions
      for (var vendor in _cachedVendorList.take(10)) {
        if (vendor.title?.toLowerCase().contains(queryLower) == true) {
          suggestions.add(vendor.title!);
        }
      }
      
      // Get product suggestions (enhanced)
      for (var product in _cachedProductList.take(30)) {
        // Check product name
        if (product.name?.toLowerCase().contains(queryLower) == true) {
          suggestions.add(product.name!);
        }
        // Check product description
        else if (product.description?.toLowerCase().contains(queryLower) == true) {
          suggestions.add(product.name!); // Add product name for description matches
        }
        // Check category
        else if (product.categoryID?.toLowerCase().contains(queryLower) == true) {
          suggestions.add(product.name!); // Add product name for category matches
        }
        // Check add-ons
        else if (product.addOnsTitle != null && product.addOnsTitle!.isNotEmpty) {
          for (var addon in product.addOnsTitle!) {
            if (addon.toString().toLowerCase().contains(queryLower)) {
              suggestions.add(product.name!);
              break;
            }
          }
        }
      }
      
      // Remove duplicates and limit
      suggestions = suggestions.toSet().take(8).toList();
      
      print("💡 Generated ${suggestions.length} suggestions: $suggestions");
      
      if (!_isDisposed) {
        searchSuggestions.value = suggestions;
        showSuggestions.value = suggestions.isNotEmpty;
      }
    } catch (e) {
      print("❌ Suggestions failed: $e");
    }
  }

  // **BACKEND SEARCH FALLBACK**
  void _performBackendSearch(String query) {
    if (_isDisposed || !_useBackendSearch) return;
    
    // This would integrate with your backend API for complex searches
    // For now, we'll just log it
    print("DEBUG: Backend search fallback for query: '$query'");
  }



  // **RELEVANCE-BASED SORTING**
  List<T> _sortByRelevance<T>(List<T> items, String searchQuery, String Function(T) getter) {
    return items..sort((a, b) {
      final aVal = getter(a).toLowerCase();
      final bVal = getter(b).toLowerCase();
      final query = searchQuery.toLowerCase();
      
      // Priority 1: Exact matches
      final aExact = aVal == query;
      final bExact = bVal == query;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      
      // Priority 2: Starts with query
      final aStarts = aVal.startsWith(query);
      final bStarts = bVal.startsWith(query);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      
      // Priority 3: Contains query
      final aContains = aVal.contains(query);
      final bContains = bVal.contains(query);
      if (aContains && !bContains) return -1;
      if (!aContains && bContains) return 1;
      
      // Priority 4: Alphabetical order
      return aVal.compareTo(bVal);
    });
  }

  // **CLEAR SEARCH RESULTS**
  void _clearSearchResults() {
    if (!_isDisposed) {
      vendorSearchList.clear();
      productSearchList.clear();
      searchSuggestions.clear();
      showSuggestions.value = false;
      isSearching.value = false;
    }
  }

  // **TEST SEARCH FUNCTIONALITY**
  void testSearch(String query) {
    print("DEBUG: Testing search with query: '$query'");
    print("DEBUG: Cached products: ${_cachedProductList.length}");
    print("DEBUG: Product trie items: ${_productTrie.totalIndexedItems}");
    
    // Test trie search
    var trieResults = _productTrie.search(query);
    print("DEBUG: Trie search results: ${trieResults.length}");
    
    // Test direct search
    var directResults = _performDirectProductSearch(query);
    print("DEBUG: Direct search results: ${directResults.length}");
    
    // Show sample results
    if (directResults.isNotEmpty) {
      print("DEBUG: Sample products found:");
      for (int i = 0; i < directResults.take(3).length; i++) {
        print("DEBUG: - ${directResults[i].name} (${directResults[i].description})");
      }
    }
  }

  // **DEBUG: CHECK CACHED DATA STATE**
  void debugCachedData() {
    print("=== DEBUG CACHED DATA STATE ===");
    print("DEBUG: _cachedVendorList.length = ${_cachedVendorList.length}");
    print("DEBUG: _cachedProductList.length = ${_cachedProductList.length}");
    print("DEBUG: _productsLoaded = $_productsLoaded");
    print("DEBUG: _isLoadingProducts = $_isLoadingProducts");
    print("DEBUG: _trieBuilt = $_trieBuilt");
    print("DEBUG: _lastCacheTime = $_lastCacheTime");
    print("DEBUG: _isCacheValid() = ${_isCacheValid()}");
    print("DEBUG: _vendorTrie.totalIndexedItems = ${_vendorTrie.totalIndexedItems}");
    print("DEBUG: _productTrie.totalIndexedItems = ${_productTrie.totalIndexedItems}");
    
    if (_cachedProductList.isNotEmpty) {
      print("DEBUG: Sample products in cache:");
      for (int i = 0; i < _cachedProductList.take(3).length; i++) {
        var product = _cachedProductList[i];
        print("DEBUG: - ${product.name} (${product.description})");
      }
    }
    print("=== END DEBUG CACHED DATA STATE ===");
  }

  // **SELECT SUGGESTION**
  void selectSuggestion(String suggestion) {
    if (_isDisposed) return;
    
    print("🎯 Selected suggestion: '$suggestion'");
    
    searchTextController.text = suggestion;
    searchText.value = suggestion;
    showSuggestions.value = false;
    searchSuggestions.clear();
    
    // Perform search immediately
    isSearching.value = true;
    _performSimpleSearch(suggestion);
  }

  // **CLEAR SEARCH**
  void clearSearch() {
    if (_isDisposed) return;
    
    searchTextController.clear();
    searchText.value = '';
    _clearSearchResults();
  }

  // **MANUAL PRODUCT LOADING FOR TESTING**
  Future<void> forceLoadProducts() async {
    print("DEBUG: Force loading products...");
    _productsLoaded = false;
    _isLoadingProducts = false;
    await _loadProductsImmediately();
  }

  // **DEBUG PRODUCT DATA**
  void debugProductData() {
    print("=== PRODUCT DATA DEBUG ===");
    print("Products loaded: $_productsLoaded");
    print("Is loading products: $_isLoadingProducts");
    print("Cached product count: ${_cachedProductList.length}");
    print("Product list count: ${productList.length}");
    
    if (_cachedProductList.isNotEmpty) {
      print("Sample products:");
      for (int i = 0; i < _cachedProductList.take(5).length; i++) {
        var product = _cachedProductList[i];
        print("  ${i + 1}. ${product.name}");
        print("     Description: ${product.description}");
        print("     Category: ${product.categoryID}");
        print("     Add-ons: ${product.addOnsTitle}");
        print("     Veg: ${product.veg}, Non-veg: ${product.nonveg}");
      }
    } else {
      print("❌ No products in cache!");
    }
    print("=== END PRODUCT DATA DEBUG ===");
  }

  // **FORCE SEARCH WITH DEBUG**
  void forceSearchWithDebug(String query) {
    print("🔧 Force search with debug for: '$query'");
    debugProductData();
    _performSimpleSearch(query);
  }
}

