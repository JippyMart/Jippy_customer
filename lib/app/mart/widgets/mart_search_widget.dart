import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/mart_search_controller.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/app/mart/widgets/mart_product_card.dart';
import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/app/mart/screens/mart_product_details_screen/mart_product_details_screen.dart';
import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/utils/color_const.dart';

class MartSearchWidget extends StatefulWidget {
  final bool showHistory;
  final bool showCategories;
  final Function(MartItemModel)? onItemTap;
  final Function(MartCategoryModel)? onCategoryTap;
  
  const MartSearchWidget({
    Key? key,
    this.showHistory = true,
    this.showCategories = false, // Changed to false to hide categories by default
    this.onItemTap,
    this.onCategoryTap,
  }) : super(key: key);

  @override
  State<MartSearchWidget> createState() => _MartSearchWidgetState();
}

class _MartSearchWidgetState extends State<MartSearchWidget> {
  late final MartSearchController searchController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // Real-time trending searches data
  final RxList<Map<String, dynamic>> _trendingSearches = <Map<String, dynamic>>[].obs;
  final RxBool _isLoadingTrending = false.obs;
  final RxString _lastUpdated = ''.obs;
  
  // Utility function to remove emojis from text
  String _removeEmojis(String text) {
    // Comprehensive emoji removal regex pattern
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA70}-\u{1FAFF}]',
      unicode: true,
    );
    return text.replaceAll(emojiRegex, '').trim();
  }
  
  // Load trending searches from API
  Future<void> _loadTrendingSearches() async {
    try {
      _isLoadingTrending.value = true;
      
      // Try to get trending searches from API first
      final trendingFromAPI = await _getTrendingSearchesFromAPI();
      
      if (trendingFromAPI.isNotEmpty) {
        _trendingSearches.value = trendingFromAPI;
        _lastUpdated.value = DateTime.now().toString().substring(11, 19); // HH:MM:SS
        print('[MART_SEARCH] ✅ Loaded ${trendingFromAPI.length} trending searches from API');
      } else {
        // Fallback to static data
        _trendingSearches.value = _getStaticTrendingSearches();
        _lastUpdated.value = 'Static';
        print('[MART_SEARCH] ⚠️ Using static trending searches (${_trendingSearches.length} items)');
      }
    } catch (e) {
      print('[MART_SEARCH] ❌ Error loading trending searches: $e');
      // Fallback to static data
      _trendingSearches.value = _getStaticTrendingSearches();
      _lastUpdated.value = 'Static';
    } finally {
      _isLoadingTrending.value = false;
    }
  }
  
  // Get trending searches from API
  Future<List<Map<String, dynamic>>> _getTrendingSearchesFromAPI() async {
    try {
      // Use the search controller to fetch trending searches
      final trendingData = await searchController.getTrendingSearches();
      
      if (trendingData.isNotEmpty) {
        print('[MART_SEARCH] ✅ Loaded ${trendingData.length} trending searches from API');
        return trendingData;
      } else {
        print('[MART_SEARCH] ⚠️ No trending data from API, will use static data');
        return [];
      }
    } catch (e) {
      print('[MART_SEARCH] ❌ API call failed: $e');
      return [];
    }
  }
  
  // Get static trending searches (fallback)
  List<Map<String, dynamic>> _getStaticTrendingSearches() {
    return [
      // Dairy & Eggs
      {'text': '🥛 Milk & Dairy', 'color': Color(0xFF4CAF50), 'category': 'dairy', 'popularity': 95},
      {'text': '🥚 Eggs & Poultry', 'color': Color(0xFF2196F3), 'category': 'dairy', 'popularity': 88},
      {'text': '🧀 Cheese & Spreads', 'color': Color(0xFFE91E63), 'category': 'dairy', 'popularity': 82},
      {'text': '🍦 Ice Cream & Desserts', 'color': Color(0xFF9C27B0), 'category': 'dairy', 'popularity': 75},
      {'text': '🥛 Yogurt & Probiotics', 'color': Color(0xFF4CAF50), 'category': 'dairy', 'popularity': 70},
      {'text': '🧈 Butter & Ghee', 'color': Color(0xFFFF9800), 'category': 'dairy', 'popularity': 68},
      
      // Fresh Produce
      {'text': '🍎 Fresh Fruits', 'color': Color(0xFF4CAF50), 'category': 'produce', 'popularity': 92},
      {'text': '🥕 Vegetables', 'color': Color(0xFF8BC34A), 'category': 'produce', 'popularity': 90},
      {'text': '🍌 Organic Products', 'color': Color(0xFFFF5722), 'category': 'produce', 'popularity': 85},
      {'text': '🥬 Leafy Greens', 'color': Color(0xFF4CAF50), 'category': 'produce', 'popularity': 78},
      {'text': '🍅 Tomatoes & Onions', 'color': Color(0xFFE91E63), 'category': 'produce', 'popularity': 80},
      {'text': '🥔 Root Vegetables', 'color': Color(0xFF8BC34A), 'category': 'produce', 'popularity': 72},
      {'text': '🍇 Berries & Grapes', 'color': Color(0xFF9C27B0), 'category': 'produce', 'popularity': 65},
      {'text': '🥒 Cucumbers & Peppers', 'color': Color(0xFF4CAF50), 'category': 'produce', 'popularity': 70},
      
      // Bakery & Grains
      {'text': '🍞 Bread & Bakery', 'color': Color(0xFFFF9800), 'category': 'bakery', 'popularity': 87},
      {'text': '🍰 Cakes & Pastries', 'color': Color(0xFFE91E63), 'category': 'bakery', 'popularity': 73},
      {'text': '🥖 Artisan Breads', 'color': Color(0xFFFF9800), 'category': 'bakery', 'popularity': 60},
      {'text': '🍪 Cookies & Biscuits', 'color': Color(0xFF9C27B0), 'category': 'bakery', 'popularity': 68},
      {'text': '🌾 Rice & Grains', 'color': Color(0xFF8BC34A), 'category': 'grains', 'popularity': 85},
      {'text': '🍝 Pasta & Noodles', 'color': Color(0xFFFF5722), 'category': 'grains', 'popularity': 75},
      {'text': '🌽 Corn & Cereals', 'color': Color(0xFFFF9800), 'category': 'grains', 'popularity': 70},
      
      // Meat & Seafood
      {'text': '🥩 Fresh Meat', 'color': Color(0xFFE91E63), 'category': 'meat', 'popularity': 82},
      {'text': '🐟 Fish & Seafood', 'color': Color(0xFF2196F3), 'category': 'seafood', 'popularity': 78},
      {'text': '🍗 Chicken & Poultry', 'color': Color(0xFF4CAF50), 'category': 'meat', 'popularity': 85},
      {'text': '🥓 Bacon & Sausages', 'color': Color(0xFFE91E63), 'category': 'meat', 'popularity': 65},
      {'text': '🦐 Shrimp & Prawns', 'color': Color(0xFF2196F3), 'category': 'seafood', 'popularity': 60},
      
      // Beverages
      {'text': '🥤 Soft Drinks', 'color': Color(0xFF2196F3), 'category': 'beverages', 'popularity': 80},
      {'text': '☕ Coffee & Tea', 'color': Color(0xFF8BC34A), 'category': 'beverages', 'popularity': 88},
      {'text': '🧃 Juices & Smoothies', 'color': Color(0xFF4CAF50), 'category': 'beverages', 'popularity': 75},
      {'text': '💧 Water & Hydration', 'color': Color(0xFF2196F3), 'category': 'beverages', 'popularity': 90},
      {'text': '🍺 Beer & Wine', 'color': Color(0xFF9C27B0), 'category': 'beverages', 'popularity': 55},
      {'text': '🥛 Energy Drinks', 'color': Color(0xFFFF5722), 'category': 'beverages', 'popularity': 62},
      
      // Snacks & Confectionery
      {'text': '🍿 Popcorn & Chips', 'color': Color(0xFFFF9800), 'category': 'snacks', 'popularity': 78},
      {'text': '🍫 Chocolate & Candy', 'color': Color(0xFF8BC34A), 'category': 'snacks', 'popularity': 85},
      {'text': '🥜 Nuts & Dried Fruits', 'color': Color(0xFF9C27B0), 'category': 'snacks', 'popularity': 70},
      {'text': '🍪 Healthy Snacks', 'color': Color(0xFF4CAF50), 'category': 'snacks', 'popularity': 72},
      {'text': '🍭 Gummies & Chews', 'color': Color(0xFFE91E63), 'category': 'snacks', 'popularity': 65},
      
      // Household & Personal Care
      {'text': '🧴 Cleaning Supplies', 'color': Color(0xFF9C27B0), 'category': 'household', 'popularity': 80},
      {'text': '🧼 Personal Care', 'color': Color(0xFF2196F3), 'category': 'personal', 'popularity': 75},
      {'text': '🧻 Paper Products', 'color': Color(0xFF4CAF50), 'category': 'household', 'popularity': 85},
      {'text': '🦷 Oral Care', 'color': Color(0xFFE91E63), 'category': 'personal', 'popularity': 78},
      {'text': '🧴 Laundry & Detergents', 'color': Color(0xFF9C27B0), 'category': 'household', 'popularity': 82},
      {'text': '🛁 Bath & Body', 'color': Color(0xFF2196F3), 'category': 'personal', 'popularity': 70},
      
      // Baby & Kids
      {'text': '🍼 Baby Food & Formula', 'color': Color(0xFF4CAF50), 'category': 'baby', 'popularity': 68},
      {'text': '🧸 Baby Care Products', 'color': Color(0xFFE91E63), 'category': 'baby', 'popularity': 65},
      {'text': '🍭 Kids Snacks', 'color': Color(0xFFFF9800), 'category': 'kids', 'popularity': 72},
      
      // Health & Wellness
      {'text': '💊 Vitamins & Supplements', 'color': Color(0xFF4CAF50), 'category': 'health', 'popularity': 75},
      {'text': '🌿 Herbal & Natural', 'color': Color(0xFF8BC34A), 'category': 'health', 'popularity': 70},
      {'text': '🏃‍♂️ Sports Nutrition', 'color': Color(0xFF2196F3), 'category': 'health', 'popularity': 60},
      
      // Frozen & Ready-to-Eat
      {'text': '🧊 Frozen Foods', 'color': Color(0xFF2196F3), 'category': 'frozen', 'popularity': 78},
      {'text': '🍕 Ready-to-Eat Meals', 'color': Color(0xFFE91E63), 'category': 'ready', 'popularity': 80},
      {'text': '🥟 Frozen Snacks', 'color': Color(0xFF9C27B0), 'category': 'frozen', 'popularity': 65},
    ];
  }
  
  @override
  void initState() {
    super.initState();
    try {
      searchController = Get.find<MartSearchController>();
    } catch (e) {
      // If controller not found, create it
      searchController = Get.put(MartSearchController());
    }
    
    _textController.addListener(_onSearchChanged);
    
    // Load trending searches on initialization
    _loadTrendingSearches();
  }
  
  @override
  void dispose() {
    _textController.removeListener(_onSearchChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = _textController.text.trim();
    if (query.isNotEmpty) {
      searchController.searchAll(query);
    } else {
      searchController.clearResults();
    }
  }
  
  void _onItemTap(MartItemModel item) {
    if (widget.onItemTap != null) {
      widget.onItemTap!(item);
    } else {
      // Default navigation to product details
      Get.to(() => MartProductDetailsScreen(product: item));
    }
  }
  
  void _onCategoryTap(MartCategoryModel category) {
    if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(category);
    } else {
      // Default navigation to category detail
      Get.to(() => const MartCategoryDetailScreen(), arguments: {
        'categoryId': category.id ?? '',
        'categoryName': category.title ?? 'Category',
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),
        
        // Search Results
        Expanded(
          child: GetX<MartSearchController>(
            builder: (controller) {
              if (controller.isLoading.value) {
                return _buildLoadingWidget();
              }
              
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorWidget();
              }
              
              if (controller.searchQuery.value.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildSearchResults();
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            MartTheme.grayVeryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: MartTheme.brandGreen.withOpacity(0.3)),
        boxShadow: MartTheme.cardShadow,
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: '${MartEmojis.cart} Search products, categories...',
          hintStyle: TextStyle(
            color: MartTheme.grayMedium,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConst.martPrimary,
              // gradient: MartTheme.brandGradient,
              borderRadius: BorderRadius.circular(MartTheme.cardRadius),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
          suffixIcon: _textController.text.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MartTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MartTheme.buttonRadius),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: MartTheme.red),
                    onPressed: () {
                      _textController.clear();
                      searchController.clearResults();
                    },
                  ),
                )
              : const SizedBox.shrink(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            searchController.searchAll(value.trim());
          }
        },
      ),
    );
  }
  
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated mart emoji loader
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.4),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: MartTheme.greenVeryLight, // Use mart theme green very light
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🛒',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          ),
          const SizedBox(height: 24),
          
          // Animated loading text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Column(
                  children: [
                    Text(
                      '🔍 Searching Products...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Finding the best deals for you!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Animated progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 200)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Search Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            searchController.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                searchController.searchAll(_textController.text.trim());
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message with animation
          // _buildWelcomeMessage(),
          // const SizedBox(height: 24),
          
          // Trending searches
          _buildTrendingSearches(),
          const SizedBox(height: 24),
          
          // Popular categories
          _buildPopularCategories(),
          const SizedBox(height: 24),
          
          // Search history
          if (widget.showHistory) _buildSearchHistory(),
        ],
      ),
    );
  }
  
  // Widget _buildWelcomeMessage() {
  //   return TweenAnimationBuilder<double>(
  //     duration: const Duration(milliseconds: 1000),
  //     tween: Tween(begin: 0.0, end: 1.0),
  //     builder: (context, value, child) {
  //       return Transform.translate(
  //         offset: Offset(0, 20 * (1 - value)),
  //         child: Opacity(
  //           opacity: value,
  //           child: Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: [
  //                   const Color(0xFF4CAF50).withValues(alpha: 0.1),
  //                   const Color(0xFF2196F3).withValues(alpha: 0.1),
  //                 ],
  //               ),
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(
  //                 color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
  //               ),
  //             ),
  //             child: Column(
  //               children: [
  //                 const Text(
  //                   '🛒',
  //                   style: TextStyle(fontSize: 48),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   'Welcome to Jippy Mart!',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: const Color(0xFF4CAF50),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   'Search for your favorite products and discover amazing deals',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey[600],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  
  Widget _buildTrendingSearches() {
    return Obx(() {
      if (_isLoadingTrending.value) {
        return _buildTrendingSearchesLoading();
      }
      
      if (_trendingSearches.isEmpty) {
        return const SizedBox.shrink();
      }
      
      // Sort by popularity and take top 40
      final sortedSearches = List<Map<String, dynamic>>.from(_trendingSearches)
        ..sort((a, b) => (b['popularity'] ?? 0).compareTo(a['popularity'] ?? 0));
      
      final topSearches = sortedSearches.take(40).toList();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔑 Simplified header without suggestions count and reload button
          const Text(
            '🔥 Trending Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          _buildTrendingSearchesGrid(topSearches),
        ],
      );
    });
  }
  
  Widget _buildTrendingSearchesLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '🔥 Loading Trending Searches...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(
                        width: 80,
                        height: 16,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildTrendingSearchesGrid(List<Map<String, dynamic>> searches) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = 16.0;
        final spacing = 8.0; // 🔑 Reduced spacing for tighter layout
        
        // 🔑 Calculate responsive grid columns - ensure at least 2 horizontally
        final availableWidth = screenWidth - (horizontalPadding * 2);
        final minItemWidth = 120.0; // Minimum width for each chip
        final maxColumns = (availableWidth / minItemWidth).floor();
        final crossAxisCount = (maxColumns < 2) ? 2 : maxColumns; // 🔑 Ensure at least 2 columns
        
        final itemWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        
        return GridView.builder(
          padding: EdgeInsets.only(top: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemWidth / 45, // 🔑 Reduced height for smaller boxes
          ),
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final search = searches[index];
            final popularity = search['popularity'] ?? 0;
        
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: GestureDetector(
                      onTap: () {
                        final cleanText = _removeEmojis(search['text'] as String);
                        _textController.text = cleanText;
                        searchController.searchAll(cleanText);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (search['color'] as Color).withValues(alpha: 0.1),
                              (search['color'] as Color).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (search['color'] as Color).withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (search['color'] as Color).withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            search['text'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: search['color'] as Color,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildSearchHistory() {
    return GetX<MartSearchController>(
      builder: (controller) {
        if (controller.searchHistory.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                '🕒 Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchController.searchHistory.length,
              itemBuilder: (context, index) {
                final query = searchController.searchHistory[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.history, color: Colors.white, size: 16),
                            ),
                            title: Text(
                              query,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                onPressed: () => searchController.removeFromHistory(query),
                              ),
                            ),
                            onTap: () {
                              final cleanText = _removeEmojis(query);
                              _textController.text = cleanText;
                              searchController.searchAll(cleanText);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildPopularCategories() {
    // This would typically come from an API or be predefined
    final popularCategories = [
      'Fruits & Vegetables',
      'Dairy & Eggs',
      'Meat & Seafood',
      'Bakery',
      'Beverages',
      'Snacks',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Popular Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCategories.map((category) {
            return InkWell(
              onTap: () {
                final cleanText = _removeEmojis(category);
                _textController.text = cleanText;
                searchController.searchAll(cleanText);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildSearchResults() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          if (widget.showCategories && searchController.categoryResults.isNotEmpty)
            _buildCategoriesSection(),
          
          // Items Section
          if (searchController.searchResults.isNotEmpty)
            _buildItemsSection(),
          
          // Load More Button
          if (searchController.hasMoreItems.value)
            _buildLoadMoreButton(),
          
          // No Results
          if (searchController.categoryResults.isEmpty && 
              searchController.searchResults.isEmpty)
            _buildNoResultsWidget(),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchController.categoryResults.length,
          itemBuilder: (context, index) {
            final category = searchController.categoryResults[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: category.photo != null 
                    ? NetworkImage(category.photo!) 
                    : null,
                child: category.photo == null 
                    ? const Icon(Icons.category) 
                    : null,
              ),
              title: Text(category.title ?? ''),
              subtitle: Text(category.description ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _onCategoryTap(category),
            );
          },
        ),
        const Divider(),
      ],
    );
  }
  
  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Products (${searchController.searchResults.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
         LayoutBuilder(
           builder: (context, constraints) {
             final screenWidth = MediaQuery.of(context).size.width;
             final isTablet = screenWidth > 768;
             final isLargePhone = screenWidth > 400;
             
             final crossAxisCount = isTablet ? 3 : 2;
             final spacing = isTablet ? 12.0 : (isLargePhone ? 8.0 : 4.0);
             final horizontalPadding = isTablet ? 16.0 : (isLargePhone ? 8.0 : 4.0);
             
             // Calculate dynamic aspect ratio based on available space and card content
             final availableWidth = constraints.maxWidth - (horizontalPadding * 2) - (spacing * (crossAxisCount - 1));
             final cardWidth = availableWidth / crossAxisCount;
             // More flexible aspect ratio to accommodate content-based card heights
             final aspectRatio = isTablet ? 0.7 : (isLargePhone ? 0.65 : 0.6);
             
             // 🔑 Use Wrap instead of GridView to allow flexible heights
             return Padding(
               padding: EdgeInsets.only(
                 left: horizontalPadding,
                 right: horizontalPadding,
                 bottom: MediaQuery.of(context).padding.bottom + 16,
               ),
               child: Wrap(
                 alignment: WrapAlignment.start,
                 crossAxisAlignment: WrapCrossAlignment.start,
                 spacing: spacing,
                 runSpacing: spacing,
                 children: searchController.searchResults.map((item) {
                   try {
                     return SizedBox(
                       width: cardWidth,
                       child: MartProductCard(
                         product: item,
                         screenWidth: MediaQuery.of(context).size.width,
                         controller: Get.find<CategoryDetailController>(),
                       ),
                     );
                   } catch (e) {
                     // Fallback: Initialize controller if not found
                     final controller = Get.put(CategoryDetailController());
                     return SizedBox(
                       width: cardWidth,
                       child: MartProductCard(
                         product: item,
                         screenWidth: MediaQuery.of(context).size.width,
                         controller: controller,
                       ),
                     );
                   }
                 }).toList(),
               ),
             );
           },
         ),
      ],
    );
  }
  
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GetX<MartSearchController>(
        builder: (controller) {
          return ElevatedButton(
            onPressed: controller.isLoading.value 
                ? null 
                : () => controller.loadMoreItems(),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load More'),
          );
        },
      ),
    );
  }
  
  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
