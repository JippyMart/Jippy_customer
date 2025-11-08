import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/controllers/swiggy_search_controller.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/widgets/app_loading_widget.dart';
import 'package:customer/utils/restaurant_status_utils.dart';

class SwiggySearchScreen extends StatefulWidget {
  const SwiggySearchScreen({Key? key}) : super(key: key);

  @override
  State<SwiggySearchScreen> createState() => _SwiggySearchScreenState();
}

class _SwiggySearchScreenState extends State<SwiggySearchScreen> {
  final SwiggySearchController controller = Get.put(SwiggySearchController());
  final TextEditingController searchController = TextEditingController();
  final CartProvider cartProvider = CartProvider();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.grey900
          : AppThemeData.grey50,
      appBar: _buildAppBar(themeChange),
      body: _buildBody(themeChange),
    );
  }

  PreferredSizeWidget _buildAppBar(DarkThemeProvider themeChange) {
    return AppBar(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.grey900
          : AppThemeData.grey50,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: themeChange.getThem()
              ? AppThemeData.grey50
              : AppThemeData.grey900,
        ),
        onPressed: () => Get.back(),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppThemeData.grey800
              : AppThemeData.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: controller.onSearchTextChanged,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              controller.performSearch(value.trim());
            }
          },
          style: TextStyle(
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search for restaurants, dishes, or cuisines",
            hintStyle: TextStyle(
              color: AppThemeData.grey400,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppThemeData.grey400,
              size: 20,
            ),
            suffixIcon: Obx(() {
              if (controller.searchText.value.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppThemeData.grey400,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                    controller.clearSearch();
                  },
                );
              }
              return const SizedBox.shrink();
            }),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DarkThemeProvider themeChange) {
    return Obx(() {
      // Show loading state
      if (controller.isLoadingData.value) {
        return _buildLoadingState(themeChange);
      }

      // Show suggestions while typing
      if (controller.showSuggestions.value && controller.searchSuggestions.isNotEmpty) {
        return _buildSuggestionsList(themeChange);
      }

      // Show search results
      if (controller.hasSearched.value) {
        return _buildSearchResults(themeChange);
      }

      // Show initial state (recent + trending)
      return _buildInitialState(themeChange);
    });
  }

  Widget _buildLoadingState(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // **ANIMATED FOOD ICONS**
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating background circle
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * 3.14159,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemeData.primary300.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Restart animation
                  },
                ),

                // Pulsing center icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.8, end: 1.2),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppThemeData.primary300,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeData.primary300.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Restart animation
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // **ANIMATED LOADING TEXT**
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Column(
                  children: [
                    Text(
                      "🍽️ Preparing Your Food Journey",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Loading delicious restaurants & dishes...",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeData.grey400,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // **PROGRESS INDICATOR WITH DOTS**
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
                      color: AppThemeData.primary300.withOpacity(value),
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

          const SizedBox(height: 32),

          // **FUN FACTS ROTATION**
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              final facts = [
                "🍕 Did you know? Pizza was invented in Naples, Italy!",
                "🍜 Ramen noodles were originally Chinese, not Japanese!",
                "🌮 Tacos are eaten 4.5 billion times per year in the US!",
                "🍔 The first hamburger was created in 1900!",
                "🍰 Chocolate cake is the most popular dessert worldwide!",
                "🥘 Biryani has over 50 different regional variations!",
                "🍣 Sushi means 'sour rice' in Japanese!",
                "🌶️ Spicy food can actually cool you down!",
              ];

              final currentFact = facts[(DateTime.now().millisecondsSinceEpoch ~/ 3000) % facts.length];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeData.primary100.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemeData.primary300.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  currentFact,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemeData.grey600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
// **CLEAR RECENT SEARCHES METHOD**
  void _clearRecentSearches(themeChange) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Clear Recent Searches?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
            ),
          ),
          content: Text(
            "This will remove all your recent search history. This action cannot be undone.",
            style: TextStyle(
              color: AppThemeData.grey400,
            ),
          ),
          backgroundColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppThemeData.grey400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.clearRecentSearches();
                Navigator.pop(context);
                Get.snackbar(
                  "Cleared",
                  "Recent searches have been cleared",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppThemeData.success500,
                  colorText: AppThemeData.grey50,
                );
              },
              child: Text(
                "Clear",
                style: TextStyle(
                  color: AppThemeData.danger500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildInitialState(DarkThemeProvider themeChange) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (controller.recentSearches.isNotEmpty) ...[
            _buildRecentSearchesHeader(themeChange), // Updated header with clear button
            const SizedBox(height: 16),
            _buildRecentSearches(themeChange),
            const SizedBox(height: 32),
          ],

          // Trending Searches
          if (controller.trendingSearches.isNotEmpty) ...[
            _buildSectionHeader("🔥 Trending Now", themeChange),
            const SizedBox(height: 16),
            _buildTrendingSearches(themeChange),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
  // **RECENT SEARCHES HEADER WITH CLEAR BUTTON**
  Widget _buildRecentSearchesHeader(DarkThemeProvider themeChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Searches",
          style: TextStyle(
            fontFamily: AppThemeData.semiBold,
            fontSize: 20,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            letterSpacing: 0.3,
          ),
        ),
        // **CLEAR BUTTON**
        GestureDetector(
          onTap:()=> _clearRecentSearches(themeChange),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeChange.getThem()
                  ? AppThemeData.grey700
                  : AppThemeData.grey200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear_all,
                  color: AppThemeData.grey500,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "Clear",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemeData.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // Widget _buildInitialState(DarkThemeProvider themeChange) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Recent Searches
  //         if (controller.recentSearches.isNotEmpty) ...[
  //           _buildSectionHeader("Recent Searches", themeChange),
  //           const SizedBox(height: 16),
  //           _buildRecentSearches(themeChange),
  //           const SizedBox(height: 32),
  //         ],
  //
  //         // Trending Searches
  //         if (controller.trendingSearches.isNotEmpty) ...[
  //           _buildSectionHeader("🔥 Trending Now", themeChange),
  //           const SizedBox(height: 16),
  //           _buildTrendingSearches(themeChange),
  //           const SizedBox(height: 16),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSuggestionsList(DarkThemeProvider themeChange) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchSuggestions.length,
      itemBuilder: (context, index) {
        String suggestion = controller.searchSuggestions[index];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.grey800
                        : AppThemeData.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemeData.grey200,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppThemeData.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getSearchEmoji(suggestion),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    title: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppThemeData.grey400,
                      size: 16,
                    ),
                    onTap: () {
                      searchController.text = suggestion;
                      controller.selectSuggestion(suggestion);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(DarkThemeProvider themeChange) {
    return Obx(() {
      // Show loading indicator when searching
      if (controller.isSearching.value) {
        return const SearchLoadingWidget();
      }

      // Show "No results found" when search has no results
      if (controller.restaurantResults.isEmpty &&
          controller.productResults.isEmpty &&
          controller.categoryResults.isEmpty) {
        return _buildNoResults(themeChange);
      }

      // Show search results
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results summary
            _buildResultsSummary(themeChange),
            const SizedBox(height: 20),

            // Categories section - TEMPORARILY HIDDEN
            // if (controller.categoryResults.isNotEmpty) ...[
            //   _buildSectionHeader("📂 Categories (${controller.categoryResults.length})", themeChange),
            //   const SizedBox(height: 12),
            //   _buildCategoriesList(themeChange),
            //   const SizedBox(height: 24),
            // ],

            // Products section (Show first - users want dishes first)
            if (controller.productResults.isNotEmpty) ...[
              _buildSectionHeader("🍕 Dishes (${controller.productResults.length})", themeChange),
              const SizedBox(height: 12),
              _buildProductsList(themeChange),
              const SizedBox(height: 24),
            ],

            // Restaurants section (Show second)
            if (controller.restaurantResults.isNotEmpty) ...[
              _buildSectionHeader("🍴 Restaurants (${controller.restaurantResults.length})", themeChange),
              const SizedBox(height: 12),
              _buildRestaurantsList(themeChange),
            ],

            // Load More Button
            if (controller.hasMoreResults.value) ...[
              const SizedBox(height: 20),
              _buildLoadMoreButton(themeChange),
            ] else ...[
              // Creative "No more results" message
              const SizedBox(height: 20),
              _buildNoMoreResultsMessage(themeChange),
            ],

            // Loading indicator for pagination
            if (controller.isLoadingMore.value) ...[
              const SizedBox(height: 20),
              _buildLoadingIndicator(themeChange),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildNoResults(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppThemeData.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: TextStyle(
              fontSize: 18,
              fontFamily: AppThemeData.semiBold,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try different keywords or check spelling",
            style: TextStyle(
              color: AppThemeData.grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSummary(DarkThemeProvider themeChange) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppThemeData.primary300,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Found ${controller.restaurantResults.length + controller.productResults.length} results for \"${controller.searchText.value}\"",
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeData.primary300,
                  fontFamily: AppThemeData.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Debug information
          Text(
            "Products: ${controller.productResults.length} | Restaurants: ${controller.restaurantResults.length}",
            style: TextStyle(
              fontSize: 12,
              color: AppThemeData.primary400,
            ),
          ),
          const SizedBox(height: 4),
          // Pagination info
          Text(
            "Showing ${controller.currentResultCount.value} of ${controller.totalAvailableResults.value} results",
            style: TextStyle(
              fontSize: 12,
              color: AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppThemeData.semiBold,
          fontSize: 20,
          color: themeChange.getThem()
              ? AppThemeData.grey50
              : AppThemeData.grey900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRecentSearches(DarkThemeProvider themeChange) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.recentSearches.asMap().entries.map((entry) {
        int index = entry.key;
        String search = entry.value;
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: _buildCreativeSearchChip(
                  search: search,
                  isRecent: true,
                  themeChange: themeChange,
                  index: index,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrendingSearches(DarkThemeProvider themeChange) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.trendingSearches.asMap().entries.map((entry) {
        int index = entry.key;
        String trend = entry.value;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 120)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: _buildCreativeSearchChip(
                  search: trend,
                  isRecent: false,
                  themeChange: themeChange,
                  index: index,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCreativeSearchChip({
    required String search,
    required bool isRecent,
    required DarkThemeProvider themeChange,
    required int index,
  }) {
    // Get appropriate emoji and colors based on search term
    String emoji = _getSearchEmoji(search);
    Color primaryColor = isRecent ? AppThemeData.primary300 : AppThemeData.warning300;
    Color backgroundColor = isRecent ? AppThemeData.primary50 : AppThemeData.warning50;
    Color borderColor = isRecent ? AppThemeData.primary200 : AppThemeData.warning200;
    return GestureDetector(
      onTap: () {
        searchController.text = search;
        controller.search(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor.withOpacity(0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **EMOJI ICON**
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // **SEARCH TEXT**
            Text(
              search,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(width: 4),

            // **TRENDING INDICATOR** (for trending items)
            if (!isRecent) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSearchEmoji(String search) {
    final lowerSearch = search.toLowerCase();

    // Food categories
    if (lowerSearch.contains('pizza')) return '🍕';
    if (lowerSearch.contains('biryani')) return '🍛';
    if (lowerSearch.contains('burger')) return '🍔';
    if (lowerSearch.contains('coffee')) return '☕';
    if (lowerSearch.contains('ice cream')) return '🍦';
    if (lowerSearch.contains('chicken')) return '🍗';
    if (lowerSearch.contains('pasta')) return '🍝';
    if (lowerSearch.contains('sushi')) return '🍣';
    if (lowerSearch.contains('taco')) return '🌮';
    if (lowerSearch.contains('sandwich')) return '🥪';
    if (lowerSearch.contains('salad')) return '🥗';
    if (lowerSearch.contains('soup')) return '🍲';
    if (lowerSearch.contains('noodles')) return '🍜';
    if (lowerSearch.contains('rice')) return '🍚';
    if (lowerSearch.contains('bread')) return '🍞';
    if (lowerSearch.contains('cake')) return '🍰';
    if (lowerSearch.contains('dessert')) return '🍮';
    if (lowerSearch.contains('sweet')) return '🍭';
    if (lowerSearch.contains('spicy')) return '🌶️';
    if (lowerSearch.contains('healthy')) return '🥑';
    if (lowerSearch.contains('vegetarian') || lowerSearch.contains('veg')) return '🥬';

    // Cuisines
    if (lowerSearch.contains('chinese')) return '🥢';
    if (lowerSearch.contains('italian')) return '🍝';
    if (lowerSearch.contains('indian')) return '🍛';
    if (lowerSearch.contains('mexican')) return '🌮';
    if (lowerSearch.contains('japanese')) return '🍣';
    if (lowerSearch.contains('thai')) return '🍜';
    if (lowerSearch.contains('korean')) return '🥘';
    if (lowerSearch.contains('american')) return '🍔';
    if (lowerSearch.contains('fast food')) return '🍟';

    // General food terms
    if (lowerSearch.contains('food')) return '🍽️';
    if (lowerSearch.contains('restaurant')) return '🍴';
    if (lowerSearch.contains('meal')) return '🍽️';
    if (lowerSearch.contains('lunch')) return '🍱';
    if (lowerSearch.contains('dinner')) return '🍽️';
    if (lowerSearch.contains('breakfast')) return '🥞';
    if (lowerSearch.contains('snack')) return '🍿';

    // Default emoji based on first letter
    switch (lowerSearch[0]) {
      case 'a': return '🍎';
      case 'b': return '🍌';
      case 'c': return '🍒';
      case 'd': return '🍩';
      case 'e': return '🥚';
      case 'f': return '🍓';
      case 'g': return '🍇';
      case 'h': return '🍯';
      case 'i': return '🍦';
      case 'j': return '🍊';
      case 'k': return '🥝';
      case 'l': return '🍋';
      case 'm': return '🥭';
      case 'n': return '🥜';
      case 'o': return '🍊';
      case 'p': return '🍑';
      case 'q': return '🥒';
      case 'r': return '🍓';
      case 's': return '🍓';
      case 't': return '🍅';
      case 'u': return '🍇';
      case 'v': return '🥕';
      case 'w': return '🍉';
      case 'x': return '🍇';
      case 'y': return '🍋';
      case 'z': return '🥒';
      default: return '🍽️';
    }
  }

  Widget _buildRestaurantsList(DarkThemeProvider themeChange) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.restaurantResults.length,
      itemBuilder: (context, index) {
        VendorModel restaurant = controller.restaurantResults[index];
        return _buildRestaurantCard(restaurant, themeChange);
      },
    );
  }

  Widget _buildCategoriesList(DarkThemeProvider themeChange) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.categoryResults.length,
      itemBuilder: (context, index) {
        VendorCategoryModel category = controller.categoryResults[index];
        return _buildCategoryCard(category, themeChange);
      },
    );
  }

  Widget _buildProductsList(DarkThemeProvider themeChange) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.productResults.length,
      itemBuilder: (context, index) {
        ProductModel product = controller.productResults[index];
        return _buildProductCard(product, themeChange);
      },
    );
  }

  Widget _buildLoadMoreButton(DarkThemeProvider themeChange) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          controller.loadMoreResults();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeData.primary500,
          foregroundColor: AppThemeData.grey50,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Load More Results",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppThemeData.grey50,
          ),
        ),
      ),
    );
  }

  Widget _buildNoMoreResultsMessage(DarkThemeProvider themeChange) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 20, // Above safe area
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Creative icon
            Icon(
              Icons.search_off_rounded,
              size: 32,
              color: themeChange.getThem()
                  ? AppThemeData.grey400
                  : AppThemeData.grey500,
            ),
            const SizedBox(height: 16),

            // Main message
            Text(
              "🎯 That's all we found!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeChange.getThem()
                    ? AppThemeData.grey300
                    : AppThemeData.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              "No more results available for your search",
              style: TextStyle(
                fontSize: 14,
                color: themeChange.getThem()
                    ? AppThemeData.grey400
                    : AppThemeData.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(DarkThemeProvider themeChange) {
    return const AppLoadingWidget(
      title: "⏳ Loading more results...",
      icon: Icons.refresh,
      size: 40,
      showDots: false,
      showFunFact: false,
    );
  }

  Widget _buildCategoryCard(VendorCategoryModel category, DarkThemeProvider themeChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeChange.getThem()
          ? AppThemeData.grey800
          : AppThemeData.grey50,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppThemeData.secondary100,
          child: category.photo != null && category.photo!.isNotEmpty
              ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: category.photo!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(
                Icons.category,
                color: AppThemeData.secondary300,
                size: 20,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.category,
                color: AppThemeData.secondary300,
                size: 20,
              ),
            ),
          )
              : Icon(
            Icons.category,
            color: AppThemeData.secondary300,
            size: 20,
          ),
        ),
        title: Text(
          category.title ?? 'Category',
          style: TextStyle(
            fontFamily: AppThemeData.semiBold,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
          ),
        ),
        subtitle: Text(
          category.description ?? 'Category description',
          style: TextStyle(
            color: AppThemeData.grey400,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppThemeData.grey400,
          size: 16,
        ),
        onTap: () {
          // Navigate to category or show category info
          Get.snackbar(
            "Category",
            "Category: ${category.title}",
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(VendorModel restaurant, DarkThemeProvider themeChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: themeChange.getThem()
          ? AppThemeData.grey800
          : AppThemeData.grey50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: !RestaurantStatusUtils.canAcceptOrders(restaurant)
            ? () {
                // Show closed message
                final status = RestaurantStatusUtils.getRestaurantStatus(restaurant);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(status['reason']),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            : () {
                Get.to(() => const RestaurantDetailsScreen(),
                    arguments: {"vendorModel": restaurant});
              },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **RESTAURANT IMAGE**
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.photo ?? '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppThemeData.grey200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppThemeData.grey200,
                      child: const Icon(Icons.restaurant, size: 50),
                    ),
                  ),
                ),

                // **STATUS OVERLAY**
                Positioned(
                  top: 12,
                  left: 12,
                  child: RestaurantStatusUtils.getStatusWidget(restaurant),
                ),

                // **FAVORITE BUTTON**
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),

                // **RATING & DISTANCE OVERLAY**
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.5 (12)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Distance
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '0.5 km',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // **RESTAURANT DETAILS**
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name
                  Text(
                    restaurant.title ?? 'Restaurant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Text(
                    restaurant.location ?? 'Location not available',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemeData.grey400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cuisine Type (if available)
                  if (restaurant.categoryTitle != null && restaurant.categoryTitle!.isNotEmpty)
                    Text(
                      restaurant.categoryTitle!.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeData.primary300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, DarkThemeProvider themeChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeChange.getThem()
          ? AppThemeData.grey800
          : AppThemeData.grey50,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppThemeData.warning100,
          child: product.photo != null && product.photo!.isNotEmpty
              ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: product.photo!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(
                Icons.fastfood,
                color: AppThemeData.warning300,
                size: 20,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.fastfood,
                color: AppThemeData.warning300,
                size: 20,
              ),
            ),
          )
              : Icon(
            Icons.fastfood,
            color: AppThemeData.warning300,
            size: 20,
          ),
        ),
        title: Text(
          product.name ?? 'Product',
          style: TextStyle(
            fontFamily: AppThemeData.semiBold,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
          ),
        ),
        subtitle: Text(
          product.description ?? 'Description not available',
          style: TextStyle(
            color: AppThemeData.grey400,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (product.disPrice != null && product.disPrice!.isNotEmpty && product.disPrice != "0")
              Text(
                "₹${product.disPrice}",
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: AppThemeData.primary300,
                  fontSize: 16,
                ),
              )
            else
              Text(
                "₹${product.price ?? '0'}",
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: AppThemeData.primary300,
                  fontSize: 16,
                ),
              ),
            // Text(
            //   "₹${product.disPrice ?? '0'}",
            //   style: TextStyle(
            //     fontFamily: AppThemeData.semiBold,
            //     color: AppThemeData.primary300,
            //     fontSize: 16,
            //   ),
            // ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppThemeData.grey400,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          // Show product details bottom sheet
          _showProductDetailsBottomSheet(context, product);
        },
      ),
    );
  }

  // **PRODUCT DETAILS BOTTOM SHEET**
  void _showProductDetailsBottomSheet(BuildContext context, ProductModel productModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: _buildSimpleProductDetails(productModel),
      ),
    );
  }

  // **ENHANCED PRODUCT DETAILS VIEW**
  Widget _buildSimpleProductDetails(ProductModel product) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // **HANDLE BAR**
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppThemeData.grey400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // **HEADER**
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Product Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
              ],
            ),
          ),

          // **CONTENT**
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **PRODUCT IMAGE**
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: product.photo ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: AppThemeData.grey200,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: AppThemeData.grey200,
                          child: const Icon(Icons.fastfood, size: 50),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // **PRODUCT NAME**
                  Text(
                    product.name ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // **PRODUCT DESCRIPTION**
                  if (product.description != null && product.description!.isNotEmpty)
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // **COMBINED RESTAURANT & PRICE CARD**
                  if (product.vendorID != null)
                    FutureBuilder<VendorModel?>(
                      future: _getVendorDetails(product.vendorID!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final vendor = snapshot.data!;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // **LEFT COLUMN - RESTAURANT INFO**
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "From Restaurant",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          // **RESTAURANT LOGO**
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: vendor.photo ?? '',
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                height: 50,
                                                width: 50,
                                                color: AppThemeData.grey200,
                                                child: const Icon(Icons.restaurant, size: 25),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                height: 50,
                                                width: 50,
                                                color: AppThemeData.grey200,
                                                child: const Icon(Icons.restaurant, size: 25),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // **RESTAURANT INFO**
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vendor.title ?? 'Unknown Restaurant',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 16,
                                                      color: AppThemeData.warning400,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _calculateRating(product.reviewsSum, product.reviewsCount),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // **RIGHT COLUMN - PRICE INFO**
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Price",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // **DISCOUNT PRICE (if available)**
                                      if (product.disPrice != null && product.disPrice!.isNotEmpty && product.disPrice != "0")
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "₹${product.disPrice}",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: AppThemeData.success500,
                                              ),
                                            ),
                                            Text(
                                              "₹${product.price ?? '0'}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                decoration: TextDecoration.lineThrough,
                                                color: AppThemeData.grey500,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                      // **REGULAR PRICE**
                                        Text(
                                          "₹${product.price ?? '0'}",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppThemeData.warning500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  const SizedBox(height: 20),

                  // **ACTION BUTTONS**
                  Column(
                    children: [
                      // **GO TO RESTAURANT BUTTON**
                      if (product.vendorID != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final vendor = await _getVendorDetails(product.vendorID!);
                              if (vendor != null) {
                                Navigator.pop(context); // Close product details
                                Get.to(() => const RestaurantDetailsScreen(),
                                    arguments: {"vendorModel": vendor});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Go to Restaurant",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (product.vendorID != null) const SizedBox(height: 12),

                      // **ADD TO CART BUTTON**
                      FutureBuilder<VendorModel?>(
                        future: _getVendorDetails(product.vendorID ?? ''),
                        builder: (context, vendorSnapshot) {
                          bool isLoadingVendor = vendorSnapshot.connectionState == ConnectionState.waiting;
                          bool canAcceptOrders = false;
                          String buttonText = "Loading...".tr;
                          String statusReason = "";
                          
                          if (vendorSnapshot.hasData && vendorSnapshot.data != null) {
                            final vendor = vendorSnapshot.data!;
                            canAcceptOrders = RestaurantStatusUtils.canAcceptOrders(vendor);
                            final status = RestaurantStatusUtils.getRestaurantStatus(vendor);
                            statusReason = status['reason'];
                            
                            // Check both restaurant status and product availability
                            if (canAcceptOrders && (product.isAvailable ?? true)) {
                              buttonText = "Add to Cart".tr;
                            } else if (!canAcceptOrders) {
                              buttonText = "Restaurant is closed".tr;
                            } else if (!(product.isAvailable ?? true)) {
                              buttonText = "Product unavailable".tr;
                            }
                          } else if (!isLoadingVendor) {
                            buttonText = "Restaurant unavailable".tr;
                          }
                          
                          print('DEBUG: Swiggy Search - Vendor: ${vendorSnapshot.data?.title}');
                          print('DEBUG: Swiggy Search - Can accept orders: $canAcceptOrders');
                          print('DEBUG: Swiggy Search - Status reason: $statusReason');
                          
                          // Determine if button should be enabled
                          bool isButtonEnabled = canAcceptOrders && (product.isAvailable ?? true) && !isLoadingVendor;
                          
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? () async {
                                await _addToCart(product);
                              } : () {
                                // Show detailed status message when restaurant is closed or product unavailable
                                if (!isLoadingVendor && vendorSnapshot.hasData && vendorSnapshot.data != null) {
                                  String message;
                                  if (!canAcceptOrders) {
                                    final status = RestaurantStatusUtils.getRestaurantStatus(vendorSnapshot.data!);
                                    message = status['reason'];
                                  } else if (!(product.isAvailable ?? true)) {
                                    message = "This product is currently unavailable".tr;
                                  } else {
                                    message = "Unable to add to cart".tr;
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isButtonEnabled 
                                    ? const Color(0xFFFF5200) 
                                    : AppThemeData.grey400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isButtonEnabled 
                                      ? AppThemeData.grey50 
                                      : AppThemeData.grey600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // **GET VENDOR DETAILS**
  Future<VendorModel?> _getVendorDetails(String vendorID) async {
    try {
      return await FireStoreUtils.getVendorById(vendorID);
    } catch (e) {
      print("Error getting vendor details: $e");
      return null;
    }
  }

  // **CALCULATE RATING**
  String _calculateRating(num? reviewsSum, num? reviewsCount) {
    if (reviewsSum == null || reviewsCount == null || reviewsCount == 0) {
      return "No rating";
    }
    final rating = reviewsSum / reviewsCount;
    return rating.toStringAsFixed(1);
  }

  // **ADD TO CART FUNCTIONALITY**
  Future<void> _addToCart(ProductModel product) async {
    // Store context before async operations
    final currentContext = context;
    
    try {
      // Get vendor details for vendor name
      final vendor = await _getVendorDetails(product.vendorID ?? '');

      // Determine final price and discount price
      String finalPrice = product.price ?? '0';
      String finalDiscountPrice = '0';

      // If there's a discount price, use it as the final price
      if (product.disPrice != null && product.disPrice!.isNotEmpty && product.disPrice != "0") {
        finalDiscountPrice = product.disPrice!;
        finalPrice = product.price ?? '0'; // Keep original price for reference
      }

      // Create CartProductModel
      CartProductModel cartProductModel = CartProductModel(
        id: product.id,
        categoryId: product.categoryID,
        name: product.name,
        photo: product.photo,
        price: finalPrice,
        discountPrice: finalDiscountPrice,
        vendorID: product.vendorID,
        vendorName: vendor?.title ?? 'Unknown Restaurant',
        quantity: 1,
        extrasPrice: "0",
        extras: null,
        variantInfo: null,
        promoId: null,
      );

      // Add to cart using CartProvider
      await cartProvider.addToCart(currentContext, cartProductModel, 1);

      // Show success message
      Get.snackbar(
        "Added to Cart",
        "${product.name} has been added to your cart",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeData.success500,
        colorText: AppThemeData.grey50,
        duration: const Duration(seconds: 2),
      );

      // Close the product details modal
      Navigator.pop(currentContext);

    } catch (e) {
      print("Error adding to cart: $e");

      // Show error message
      Get.snackbar(
        "Error",
        "Failed to add item to cart. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeData.danger500,
        colorText: AppThemeData.grey50,
        duration: const Duration(seconds: 3),
      );
    }
  }
}













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:customer/themes/app_them_data.dart';
// import 'package:customer/controllers/swiggy_search_controller.dart';
// import 'package:customer/utils/dark_theme_provider.dart';
// import 'package:customer/utils/fire_store_utils.dart';
// import 'package:customer/models/product_model.dart';
// import 'package:customer/models/vendor_model.dart';
// import 'package:customer/models/vendor_category_model.dart';
// import 'package:customer/models/cart_product_model.dart';
// import 'package:customer/services/cart_provider.dart';
// import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
//
// class SwiggySearchScreen extends StatefulWidget {
//   const SwiggySearchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SwiggySearchScreen> createState() => _SwiggySearchScreenState();
// }
//
// class _SwiggySearchScreenState extends State<SwiggySearchScreen> {
//   final SwiggySearchController controller = Get.put(SwiggySearchController());
//   final TextEditingController searchController = TextEditingController();
//   final CartProvider cartProvider = CartProvider();
//   final FocusNode searchFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     // Auto-focus search field
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       searchFocusNode.requestFocus();
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     searchFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     return Scaffold(
//       backgroundColor: themeChange.getThem()
//           ? AppThemeData.grey900
//           : AppThemeData.grey50,
//       appBar: _buildAppBar(themeChange),
//       body: _buildBody(themeChange),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(DarkThemeProvider themeChange) {
//     return AppBar(
//       backgroundColor: themeChange.getThem()
//           ? AppThemeData.grey900
//           : AppThemeData.grey50,
//       elevation: 0,
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios,
//           color: themeChange.getThem()
//               ? AppThemeData.grey50
//               : AppThemeData.grey900,
//         ),
//         onPressed: () => Get.back(),
//       ),
//       title: Container(
//         height: 40,
//         decoration: BoxDecoration(
//           color: themeChange.getThem()
//               ? AppThemeData.grey800
//               : AppThemeData.grey100,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: TextField(
//           controller: searchController,
//           focusNode: searchFocusNode,
//           onChanged: controller.onSearchTextChanged,
//           onSubmitted: (value) {
//             if (value.trim().isNotEmpty) {
//               controller.performSearch(value.trim());
//             }
//           },
//           style: TextStyle(
//             color: themeChange.getThem()
//                 ? AppThemeData.grey50
//                 : AppThemeData.grey900,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             hintText: "Search for restaurants, dishes, or cuisines",
//             hintStyle: TextStyle(
//               color: AppThemeData.grey400,
//               fontSize: 16,
//             ),
//             prefixIcon: Icon(
//               Icons.search,
//               color: AppThemeData.grey400,
//               size: 20,
//             ),
//             suffixIcon: Obx(() {
//               if (controller.searchText.value.isNotEmpty) {
//                 return IconButton(
//                   icon: Icon(
//                     Icons.clear,
//                     color: AppThemeData.grey400,
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     searchController.clear();
//                     controller.clearSearch();
//                   },
//                 );
//               }
//               return const SizedBox.shrink();
//             }),
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody(DarkThemeProvider themeChange) {
//     return Obx(() {
//       // Show loading state
//       if (controller.isLoadingData.value) {
//         return _buildLoadingState(themeChange);
//       }
//
//       // Show suggestions while typing
//       if (controller.showSuggestions.value && controller.searchSuggestions.isNotEmpty) {
//         return _buildSuggestionsList(themeChange);
//       }
//
//       // Show search results
//       if (controller.hasSearched.value) {
//         return _buildSearchResults(themeChange);
//       }
//
//       // Show initial state (recent + trending)
//       return _buildInitialState(themeChange);
//     });
//   }
//
//   Widget _buildLoadingState(DarkThemeProvider themeChange) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // **ANIMATED FOOD ICONS**
//           SizedBox(
//             height: 120,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Rotating background circle
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(seconds: 2),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   builder: (context, value, child) {
//                     return Transform.rotate(
//                       angle: value * 2 * 3.14159,
//                       child: Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: AppThemeData.primary300.withOpacity(0.3),
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   onEnd: () {
//                     // Restart animation
//                   },
//                 ),
//
//                 // Pulsing center icon
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 1500),
//                   tween: Tween(begin: 0.8, end: 1.2),
//                   builder: (context, value, child) {
//                     return Transform.scale(
//                       scale: value,
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: AppThemeData.primary300,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppThemeData.primary300.withOpacity(0.3),
//                               blurRadius: 20,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.restaurant_menu,
//                           color: Colors.white,
//                           size: 25,
//                         ),
//                       ),
//                     );
//                   },
//                   onEnd: () {
//                     // Restart animation
//                   },
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 32),
//
//           // **ANIMATED LOADING TEXT**
//           TweenAnimationBuilder<double>(
//             duration: const Duration(milliseconds: 2000),
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               return Opacity(
//                 opacity: value,
//                 child: Column(
//                   children: [
//                     Text(
//                       "🍽️ Preparing Your Food Journey",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: themeChange.getThem()
//                             ? AppThemeData.grey50
//                             : AppThemeData.grey900,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Loading delicious restaurants & dishes...",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppThemeData.grey400,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//
//           const SizedBox(height: 24),
//
//           // **PROGRESS INDICATOR WITH DOTS**
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(3, (index) {
//               return TweenAnimationBuilder<double>(
//                 duration: Duration(milliseconds: 600 + (index * 200)),
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 builder: (context, value, child) {
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: AppThemeData.primary300.withOpacity(value),
//                       shape: BoxShape.circle,
//                     ),
//                   );
//                 },
//                 onEnd: () {
//                   // Restart animation
//                 },
//               );
//             }),
//           ),
//
//           const SizedBox(height: 32),
//
//           // **FUN FACTS ROTATION**
//           TweenAnimationBuilder<double>(
//             duration: const Duration(seconds: 3),
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               final facts = [
//                 "🍕 Did you know? Pizza was invented in Naples, Italy!",
//                 "🍜 Ramen noodles were originally Chinese, not Japanese!",
//                 "🌮 Tacos are eaten 4.5 billion times per year in the US!",
//                 "🍔 The first hamburger was created in 1900!",
//                 "🍰 Chocolate cake is the most popular dessert worldwide!",
//                 "🥘 Biryani has over 50 different regional variations!",
//                 "🍣 Sushi means 'sour rice' in Japanese!",
//                 "🌶️ Spicy food can actually cool you down!",
//               ];
//
//               final currentFact = facts[(DateTime.now().millisecondsSinceEpoch ~/ 3000) % facts.length];
//
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 32),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppThemeData.primary100.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppThemeData.primary300.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   currentFact,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppThemeData.grey600,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInitialState(DarkThemeProvider themeChange) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Recent Searches
//           if (controller.recentSearches.isNotEmpty) ...[
//             _buildSectionHeader("Recent Searches", themeChange),
//             const SizedBox(height: 16),
//             _buildRecentSearches(themeChange),
//             const SizedBox(height: 32),
//           ],
//
//           // Trending Searches
//           if (controller.trendingSearches.isNotEmpty) ...[
//             _buildSectionHeader("🔥 Trending Now", themeChange),
//             const SizedBox(height: 16),
//             _buildTrendingSearches(themeChange),
//             const SizedBox(height: 16),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuggestionsList(DarkThemeProvider themeChange) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: controller.searchSuggestions.length,
//       itemBuilder: (context, index) {
//         String suggestion = controller.searchSuggestions[index];
//
//         return TweenAnimationBuilder<double>(
//           duration: Duration(milliseconds: 200 + (index * 50)),
//           tween: Tween(begin: 0.0, end: 1.0),
//           builder: (context, value, child) {
//             return Transform.translate(
//               offset: Offset(0, 20 * (1 - value)),
//               child: Opacity(
//                 opacity: value,
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     color: themeChange.getThem()
//                         ? AppThemeData.grey800
//                         : AppThemeData.grey50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: AppThemeData.grey200,
//                       width: 1,
//                     ),
//                   ),
//                   child: ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: AppThemeData.primary100,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getSearchEmoji(suggestion),
//                           style: const TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       suggestion,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: themeChange.getThem()
//                             ? AppThemeData.grey50
//                             : AppThemeData.grey900,
//                       ),
//                     ),
//                     trailing: Icon(
//                       Icons.arrow_forward_ios,
//                       color: AppThemeData.grey400,
//                       size: 16,
//                     ),
//                     onTap: () {
//                       searchController.text = suggestion;
//                       controller.selectSuggestion(suggestion);
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildSearchResults(DarkThemeProvider themeChange) {
//     return Obx(() {
//       // Show loading indicator when searching
//       if (controller.isSearching.value) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // **ANIMATED SEARCH ICON**
//               TweenAnimationBuilder<double>(
//                 duration: const Duration(milliseconds: 1000),
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 builder: (context, value, child) {
//                   return Transform.scale(
//                     scale: 0.8 + (0.2 * value),
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: AppThemeData.primary300,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppThemeData.primary300.withOpacity(0.3),
//                             blurRadius: 15,
//                             spreadRadius: 3,
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.search,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   );
//                 },
//                 onEnd: () {
//                   // Restart animation
//                 },
//               ),
//
//               const SizedBox(height: 24),
//
//               // **SEARCHING TEXT WITH EMOJI**
//               TweenAnimationBuilder<double>(
//                 duration: const Duration(milliseconds: 1500),
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 builder: (context, value, child) {
//                   return Opacity(
//                     opacity: value,
//                     child: Column(
//                       children: [
//                         Text(
//                           "🔍 Finding Your Perfect Match",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: themeChange.getThem()
//                                 ? AppThemeData.grey50
//                                 : AppThemeData.grey900,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Searching through thousands of options...",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: AppThemeData.grey400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               // **ANIMATED DOTS**
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(3, (index) {
//                   return TweenAnimationBuilder<double>(
//                     duration: Duration(milliseconds: 800 + (index * 300)),
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     builder: (context, value, child) {
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 3),
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: AppThemeData.primary300.withOpacity(0.3 + (0.7 * value)),
//                           shape: BoxShape.circle,
//                         ),
//                       );
//                     },
//                     onEnd: () {
//                       // Restart animation
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         );
//       }
//
//       // Show "No results found" when search has no results
//       if (controller.restaurantResults.isEmpty &&
//           controller.productResults.isEmpty &&
//           controller.categoryResults.isEmpty) {
//         return _buildNoResults(themeChange);
//       }
//
//       // Show search results
//       return SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Results summary
//             _buildResultsSummary(themeChange),
//             const SizedBox(height: 20),
//
//             // Categories section - TEMPORARILY HIDDEN
//             // if (controller.categoryResults.isNotEmpty) ...[
//             //   _buildSectionHeader("📂 Categories (${controller.categoryResults.length})", themeChange),
//             //   const SizedBox(height: 12),
//             //   _buildCategoriesList(themeChange),
//             //   const SizedBox(height: 24),
//             // ],
//
//             // Products section (Show first - users want dishes first)
//             if (controller.productResults.isNotEmpty) ...[
//               _buildSectionHeader("🍕 Dishes (${controller.productResults.length})", themeChange),
//               const SizedBox(height: 12),
//               _buildProductsList(themeChange),
//               const SizedBox(height: 24),
//             ],
//
//             // Restaurants section (Show second)
//             if (controller.restaurantResults.isNotEmpty) ...[
//               _buildSectionHeader("🍴 Restaurants (${controller.restaurantResults.length})", themeChange),
//               const SizedBox(height: 12),
//               _buildRestaurantsList(themeChange),
//             ],
//
//             // Load More Button
//             if (controller.hasMoreResults.value) ...[
//               const SizedBox(height: 20),
//               _buildLoadMoreButton(themeChange),
//             ] else ...[
//               // Debug: Show why button is not visible
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppThemeData.grey200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   "Debug: hasMoreResults = ${controller.hasMoreResults.value}",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppThemeData.grey600,
//                   ),
//                 ),
//               ),
//             ],
//
//             // Loading indicator for pagination
//             if (controller.isLoadingMore.value) ...[
//               const SizedBox(height: 20),
//               _buildLoadingIndicator(themeChange),
//             ],
//           ],
//         ),
//       );
//     });
//   }
//
//   Widget _buildNoResults(DarkThemeProvider themeChange) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 64,
//             color: AppThemeData.grey400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "No results found",
//             style: TextStyle(
//               fontSize: 18,
//               fontFamily: AppThemeData.semiBold,
//               color: themeChange.getThem()
//                   ? AppThemeData.grey50
//                   : AppThemeData.grey900,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Try different keywords or check spelling",
//             style: TextStyle(
//               color: AppThemeData.grey400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResultsSummary(DarkThemeProvider themeChange) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppThemeData.primary50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.search,
//                 color: AppThemeData.primary300,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 "Found ${controller.restaurantResults.length + controller.productResults.length} results for \"${controller.searchText.value}\"",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppThemeData.primary300,
//                   fontFamily: AppThemeData.semiBold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           // Debug information
//           Text(
//             "Products: ${controller.productResults.length} | Restaurants: ${controller.restaurantResults.length}",
//             style: TextStyle(
//               fontSize: 12,
//               color: AppThemeData.primary400,
//             ),
//           ),
//           const SizedBox(height: 4),
//           // Pagination info
//           Text(
//             "Showing ${controller.currentResultCount.value} of ${controller.totalAvailableResults.value} results",
//             style: TextStyle(
//               fontSize: 12,
//               color: AppThemeData.grey500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, DarkThemeProvider themeChange) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontFamily: AppThemeData.semiBold,
//           fontSize: 20,
//           color: themeChange.getThem()
//               ? AppThemeData.grey50
//               : AppThemeData.grey900,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRecentSearches(DarkThemeProvider themeChange) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: controller.recentSearches.asMap().entries.map((entry) {
//         int index = entry.key;
//         String search = entry.value;
//
//         return TweenAnimationBuilder<double>(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           tween: Tween(begin: 0.0, end: 1.0),
//           builder: (context, value, child) {
//             return Transform.scale(
//               scale: 0.8 + (0.2 * value),
//               child: Opacity(
//                 opacity: value,
//                 child: _buildCreativeSearchChip(
//                   search: search,
//                   isRecent: true,
//                   themeChange: themeChange,
//                   index: index,
//                 ),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildTrendingSearches(DarkThemeProvider themeChange) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: controller.trendingSearches.asMap().entries.map((entry) {
//         int index = entry.key;
//         String trend = entry.value;
//
//         return TweenAnimationBuilder<double>(
//           duration: Duration(milliseconds: 400 + (index * 120)),
//           tween: Tween(begin: 0.0, end: 1.0),
//           builder: (context, value, child) {
//             return Transform.scale(
//               scale: 0.8 + (0.2 * value),
//               child: Opacity(
//                 opacity: value,
//                 child: _buildCreativeSearchChip(
//                   search: trend,
//                   isRecent: false,
//                   themeChange: themeChange,
//                   index: index,
//                 ),
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildCreativeSearchChip({
//     required String search,
//     required bool isRecent,
//     required DarkThemeProvider themeChange,
//     required int index,
//   }) {
//     // Get appropriate emoji and colors based on search term
//     String emoji = _getSearchEmoji(search);
//     Color primaryColor = isRecent ? AppThemeData.primary300 : AppThemeData.warning300;
//     Color backgroundColor = isRecent ? AppThemeData.primary50 : AppThemeData.warning50;
//     Color borderColor = isRecent ? AppThemeData.primary200 : AppThemeData.warning200;
//
//     return GestureDetector(
//       onTap: () {
//         searchController.text = search;
//         controller.search(search);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               backgroundColor,
//               backgroundColor.withOpacity(0.8),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: borderColor.withOpacity(0.6),
//             width: 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: primaryColor.withOpacity(0.12),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//               spreadRadius: 0.5,
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // **EMOJI ICON**
//             Container(
//               width: 22,
//               height: 22,
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.15),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: primaryColor.withOpacity(0.2),
//                   width: 0.5,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   emoji,
//                   style: const TextStyle(fontSize: 11),
//                 ),
//               ),
//             ),
//
//             const SizedBox(width: 8),
//
//             // **SEARCH TEXT**
//             Text(
//               search,
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.2,
//               ),
//             ),
//
//             const SizedBox(width: 4),
//
//             // **TRENDING INDICATOR** (for trending items)
//             if (!isRecent) ...[
//               Container(
//                 width: 5,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.red.withOpacity(0.3),
//                       blurRadius: 2,
//                       spreadRadius: 0.5,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getSearchEmoji(String search) {
//     final lowerSearch = search.toLowerCase();
//
//     // Food categories
//     if (lowerSearch.contains('pizza')) return '🍕';
//     if (lowerSearch.contains('biryani')) return '🍛';
//     if (lowerSearch.contains('burger')) return '🍔';
//     if (lowerSearch.contains('coffee')) return '☕';
//     if (lowerSearch.contains('ice cream')) return '🍦';
//     if (lowerSearch.contains('chicken')) return '🍗';
//     if (lowerSearch.contains('pasta')) return '🍝';
//     if (lowerSearch.contains('sushi')) return '🍣';
//     if (lowerSearch.contains('taco')) return '🌮';
//     if (lowerSearch.contains('sandwich')) return '🥪';
//     if (lowerSearch.contains('salad')) return '🥗';
//     if (lowerSearch.contains('soup')) return '🍲';
//     if (lowerSearch.contains('noodles')) return '🍜';
//     if (lowerSearch.contains('rice')) return '🍚';
//     if (lowerSearch.contains('bread')) return '🍞';
//     if (lowerSearch.contains('cake')) return '🍰';
//     if (lowerSearch.contains('dessert')) return '🍮';
//     if (lowerSearch.contains('sweet')) return '🍭';
//     if (lowerSearch.contains('spicy')) return '🌶️';
//     if (lowerSearch.contains('healthy')) return '🥑';
//     if (lowerSearch.contains('vegetarian') || lowerSearch.contains('veg')) return '🥬';
//
//     // Cuisines
//     if (lowerSearch.contains('chinese')) return '🥢';
//     if (lowerSearch.contains('italian')) return '🍝';
//     if (lowerSearch.contains('indian')) return '🍛';
//     if (lowerSearch.contains('mexican')) return '🌮';
//     if (lowerSearch.contains('japanese')) return '🍣';
//     if (lowerSearch.contains('thai')) return '🍜';
//     if (lowerSearch.contains('korean')) return '🥘';
//     if (lowerSearch.contains('american')) return '🍔';
//     if (lowerSearch.contains('fast food')) return '🍟';
//
//     // General food terms
//     if (lowerSearch.contains('food')) return '🍽️';
//     if (lowerSearch.contains('restaurant')) return '🍴';
//     if (lowerSearch.contains('meal')) return '🍽️';
//     if (lowerSearch.contains('lunch')) return '🍱';
//     if (lowerSearch.contains('dinner')) return '🍽️';
//     if (lowerSearch.contains('breakfast')) return '🥞';
//     if (lowerSearch.contains('snack')) return '🍿';
//
//     // Default emoji based on first letter
//     switch (lowerSearch[0]) {
//       case 'a': return '🍎';
//       case 'b': return '🍌';
//       case 'c': return '🍒';
//       case 'd': return '🍩';
//       case 'e': return '🥚';
//       case 'f': return '🍓';
//       case 'g': return '🍇';
//       case 'h': return '🍯';
//       case 'i': return '🍦';
//       case 'j': return '🍊';
//       case 'k': return '🥝';
//       case 'l': return '🍋';
//       case 'm': return '🥭';
//       case 'n': return '🥜';
//       case 'o': return '🍊';
//       case 'p': return '🍑';
//       case 'q': return '🥒';
//       case 'r': return '🍓';
//       case 's': return '🍓';
//       case 't': return '🍅';
//       case 'u': return '🍇';
//       case 'v': return '🥕';
//       case 'w': return '🍉';
//       case 'x': return '🍇';
//       case 'y': return '🍋';
//       case 'z': return '🥒';
//       default: return '🍽️';
//     }
//   }
//
//   Widget _buildRestaurantsList(DarkThemeProvider themeChange) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: controller.restaurantResults.length,
//       itemBuilder: (context, index) {
//         VendorModel restaurant = controller.restaurantResults[index];
//         return _buildRestaurantCard(restaurant, themeChange);
//       },
//     );
//   }
//
//   Widget _buildCategoriesList(DarkThemeProvider themeChange) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: controller.categoryResults.length,
//       itemBuilder: (context, index) {
//         VendorCategoryModel category = controller.categoryResults[index];
//         return _buildCategoryCard(category, themeChange);
//       },
//     );
//   }
//
//   Widget _buildProductsList(DarkThemeProvider themeChange) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: controller.productResults.length,
//       itemBuilder: (context, index) {
//         ProductModel product = controller.productResults[index];
//         return _buildProductCard(product, themeChange);
//       },
//     );
//   }
//
//   Widget _buildLoadMoreButton(DarkThemeProvider themeChange) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           controller.loadMoreResults();
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppThemeData.primary500,
//           foregroundColor: AppThemeData.grey50,
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           "Load More Results",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppThemeData.grey50,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingIndicator(DarkThemeProvider themeChange) {
//     return Center(
//       child: Column(
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.primary500),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             "Loading more results...",
//             style: TextStyle(
//               fontSize: 14,
//               color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoryCard(VendorCategoryModel category, DarkThemeProvider themeChange) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       color: themeChange.getThem()
//           ? AppThemeData.grey800
//           : AppThemeData.grey50,
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundColor: AppThemeData.secondary100,
//           child: category.photo != null && category.photo!.isNotEmpty
//               ? ClipOval(
//                   child: CachedNetworkImage(
//                     imageUrl: category.photo!,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Icon(
//                       Icons.category,
//                       color: AppThemeData.secondary300,
//                       size: 20,
//                     ),
//                     errorWidget: (context, url, error) => Icon(
//                       Icons.category,
//                       color: AppThemeData.secondary300,
//                       size: 20,
//                     ),
//                   ),
//                 )
//               : Icon(
//                   Icons.category,
//                   color: AppThemeData.secondary300,
//                   size: 20,
//                 ),
//         ),
//         title: Text(
//           category.title ?? 'Category',
//           style: TextStyle(
//             fontFamily: AppThemeData.semiBold,
//             color: themeChange.getThem()
//                 ? AppThemeData.grey50
//                 : AppThemeData.grey900,
//           ),
//         ),
//         subtitle: Text(
//           category.description ?? 'Category description',
//           style: TextStyle(
//             color: AppThemeData.grey400,
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           color: AppThemeData.grey400,
//           size: 16,
//         ),
//         onTap: () {
//           // Navigate to category or show category info
//           Get.snackbar(
//             "Category",
//             "Category: ${category.title}",
//             snackPosition: SnackPosition.BOTTOM,
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildRestaurantCard(VendorModel restaurant, DarkThemeProvider themeChange) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       color: themeChange.getThem()
//           ? AppThemeData.grey800
//           : AppThemeData.grey50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () {
//           Get.to(() => const RestaurantDetailsScreen(),
//               arguments: {"vendorModel": restaurant});
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // **RESTAURANT IMAGE**
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   child: CachedNetworkImage(
//                     imageUrl: restaurant.photo ?? '',
//                     height: 180,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(
//                       height: 180,
//                       color: AppThemeData.grey200,
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       height: 180,
//                       color: AppThemeData.grey200,
//                       child: const Icon(Icons.restaurant, size: 50),
//                     ),
//                   ),
//                 ),
//
//                 // **STATUS OVERLAY**
//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                         const SizedBox(width: 4),
//                         const Text(
//                           'Open',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // **FAVORITE BUTTON**
//                 Positioned(
//                   top: 12,
//                   right: 12,
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.favorite_border,
//                       color: Colors.grey,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//
//                 // **RATING & DISTANCE OVERLAY**
//                 Positioned(
//                   bottom: 12,
//                   right: 12,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // Rating
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               color: Colors.white,
//                               size: 12,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               '4.5 (12)',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       // Distance
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: Colors.purple,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               color: Colors.white,
//                               size: 12,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               '0.5 km',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // **RESTAURANT DETAILS**
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant Name
//                   Text(
//                     restaurant.title ?? 'Restaurant',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: themeChange.getThem()
//                           ? AppThemeData.grey50
//                           : AppThemeData.grey900,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//
//                   // Location
//                   Text(
//                     restaurant.location ?? 'Location not available',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppThemeData.grey400,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Cuisine Type (if available)
//                   if (restaurant.categoryTitle != null && restaurant.categoryTitle!.isNotEmpty)
//                     Text(
//                       restaurant.categoryTitle!.join(', '),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppThemeData.primary300,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductCard(ProductModel product, DarkThemeProvider themeChange) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       color: themeChange.getThem()
//           ? AppThemeData.grey800
//           : AppThemeData.grey50,
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundColor: AppThemeData.warning100,
//           child: product.photo != null && product.photo!.isNotEmpty
//               ? ClipOval(
//                   child: CachedNetworkImage(
//                     imageUrl: product.photo!,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Icon(
//                       Icons.fastfood,
//                       color: AppThemeData.warning300,
//                       size: 20,
//                     ),
//                     errorWidget: (context, url, error) => Icon(
//                       Icons.fastfood,
//                       color: AppThemeData.warning300,
//                       size: 20,
//                     ),
//                   ),
//                 )
//               : Icon(
//                   Icons.fastfood,
//                   color: AppThemeData.warning300,
//                   size: 20,
//                 ),
//         ),
//         title: Text(
//           product.name ?? 'Product',
//           style: TextStyle(
//             fontFamily: AppThemeData.semiBold,
//             color: themeChange.getThem()
//                 ? AppThemeData.grey50
//                 : AppThemeData.grey900,
//           ),
//         ),
//         subtitle: Text(
//           product.description ?? 'Description not available',
//           style: TextStyle(
//             color: AppThemeData.grey400,
//           ),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               "₹${product.price ?? '0'}",
//               style: TextStyle(
//                 fontFamily: AppThemeData.semiBold,
//                 color: AppThemeData.primary300,
//                 fontSize: 16,
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: AppThemeData.grey400,
//               size: 16,
//             ),
//           ],
//         ),
//         onTap: () {
//           // Show product details bottom sheet
//           _showProductDetailsBottomSheet(context, product);
//         },
//       ),
//     );
//   }
//
//   // **PRODUCT DETAILS BOTTOM SHEET**
//   void _showProductDetailsBottomSheet(BuildContext context, ProductModel productModel) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(30),
//         ),
//       ),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       builder: (context) => FractionallySizedBox(
//         heightFactor: 0.85,
//         child: _buildSimpleProductDetails(productModel),
//       ),
//     );
//   }
//
//   // **ENHANCED PRODUCT DETAILS VIEW**
//   Widget _buildSimpleProductDetails(ProductModel product) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           // **HANDLE BAR**
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: AppThemeData.grey400,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           // **HEADER**
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     "Product Details",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(
//                     Icons.close,
//                     color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // **CONTENT**
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // **PRODUCT IMAGE**
//                   Center(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: CachedNetworkImage(
//                         imageUrl: product.photo ?? '',
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Container(
//                           height: 200,
//                           color: AppThemeData.grey200,
//                           child: const Center(child: CircularProgressIndicator()),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           height: 200,
//                           color: AppThemeData.grey200,
//                           child: const Icon(Icons.fastfood, size: 50),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // **PRODUCT NAME**
//                   Text(
//                     product.name ?? 'Unknown Product',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // **PRODUCT DESCRIPTION**
//                   if (product.description != null && product.description!.isNotEmpty)
//                     Text(
//                       product.description!,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
//                       ),
//                     ),
//
//                   const SizedBox(height: 20),
//
//                   // **COMBINED RESTAURANT & PRICE CARD**
//                   if (product.vendorID != null)
//                     FutureBuilder<VendorModel?>(
//                       future: _getVendorDetails(product.vendorID!),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData && snapshot.data != null) {
//                           final vendor = snapshot.data!;
//                           return Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // **LEFT COLUMN - RESTAURANT INFO**
//                                 Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "From Restaurant",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         children: [
//                                           // **RESTAURANT LOGO**
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.circular(8),
//                                             child: CachedNetworkImage(
//                                               imageUrl: vendor.photo ?? '',
//                                               height: 50,
//                                               width: 50,
//                                               fit: BoxFit.cover,
//                                               placeholder: (context, url) => Container(
//                                                 height: 50,
//                                                 width: 50,
//                                                 color: AppThemeData.grey200,
//                                                 child: const Icon(Icons.restaurant, size: 25),
//                                               ),
//                                               errorWidget: (context, url, error) => Container(
//                                                 height: 50,
//                                                 width: 50,
//                                                 color: AppThemeData.grey200,
//                                                 child: const Icon(Icons.restaurant, size: 25),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           // **RESTAURANT INFO**
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   vendor.title ?? 'Unknown Restaurant',
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       Icons.star,
//                                                       size: 16,
//                                                       color: AppThemeData.warning400,
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       _calculateRating(product.reviewsSum, product.reviewsCount),
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 const SizedBox(width: 20),
//
//                                 // **RIGHT COLUMN - PRICE INFO**
//                                 Expanded(
//                                   flex: 1,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         "Price",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       // **DISCOUNT PRICE (if available)**
//                                       if (product.disPrice != null && product.disPrice!.isNotEmpty && product.disPrice != "0")
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.end,
//                                           children: [
//                                             Text(
//                                               "₹${product.disPrice}",
//                                               style: TextStyle(
//                                                 fontSize: 24,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: AppThemeData.success500,
//                                               ),
//                                             ),
//                                             Text(
//                                               "₹${product.price ?? '0'}",
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 decoration: TextDecoration.lineThrough,
//                                                 color: AppThemeData.grey500,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       else
//                                         // **REGULAR PRICE**
//                                         Text(
//                                           "₹${product.price ?? '0'}",
//                                           style: TextStyle(
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppThemeData.warning500,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//
//                   const SizedBox(height: 20),
//
//                   // **ACTION BUTTONS**
//                   Column(
//                     children: [
//                       // **GO TO RESTAURANT BUTTON**
//                       if (product.vendorID != null)
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               final vendor = await _getVendorDetails(product.vendorID!);
//                               if (vendor != null) {
//                                 Navigator.pop(context); // Close product details
//                                 Get.to(() => const RestaurantDetailsScreen(),
//                                     arguments: {"vendorModel": vendor});
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.restaurant,
//                                   color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Go to Restaurant",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                       if (product.vendorID != null) const SizedBox(height: 12),
//
//                       // **ADD TO CART BUTTON**
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await _addToCart(product);
//                           },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFFF5200),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           child: Text(
//
//                             "Add to Cart",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: AppThemeData.grey50,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // **GET VENDOR DETAILS**
//   Future<VendorModel?> _getVendorDetails(String vendorID) async {
//     try {
//       return await FireStoreUtils.getVendorById(vendorID);
//     } catch (e) {
//       print("Error getting vendor details: $e");
//       return null;
//     }
//   }
//
//   // **CALCULATE RATING**
//   String _calculateRating(num? reviewsSum, num? reviewsCount) {
//     if (reviewsSum == null || reviewsCount == null || reviewsCount == 0) {
//       return "No rating";
//     }
//     final rating = reviewsSum / reviewsCount;
//     return rating.toStringAsFixed(1);
//   }
//
//   // **ADD TO CART FUNCTIONALITY**
//   Future<void> _addToCart(ProductModel product) async {
//     try {
//       // Get vendor details for vendor name
//       final vendor = await _getVendorDetails(product.vendorID ?? '');
//
//       // Determine final price and discount price
//       String finalPrice = product.price ?? '0';
//       String finalDiscountPrice = '0';
//
//       // If there's a discount price, use it as the final price
//       if (product.disPrice != null && product.disPrice!.isNotEmpty && product.disPrice != "0") {
//         finalDiscountPrice = product.disPrice!;
//         finalPrice = product.price ?? '0'; // Keep original price for reference
//       }
//
//       // Create CartProductModel
//       CartProductModel cartProductModel = CartProductModel(
//         id: product.id,
//         categoryId: product.categoryID,
//         name: product.name,
//         photo: product.photo,
//         price: finalPrice,
//         discountPrice: finalDiscountPrice,
//         vendorID: product.vendorID,
//         vendorName: vendor?.title ?? 'Unknown Restaurant',
//         quantity: 1,
//         extrasPrice: "0",
//         extras: null,
//         variantInfo: null,
//         promoId: null,
//       );
//
//       // Add to cart using CartProvider
//       await cartProvider.addToCart(context, cartProductModel, 1);
//
//       // Show success message
//       Get.snackbar(
//         "Added to Cart",
//         "${product.name} has been added to your cart",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppThemeData.success500,
//         colorText: AppThemeData.grey50,
//         duration: const Duration(seconds: 2),
//       );
//
//       // Close the product details modal
//       Navigator.pop(context);
//
//     } catch (e) {
//       print("Error adding to cart: $e");
//
//       // Show error message
//       Get.snackbar(
//         "Error",
//         "Failed to add item to cart. Please try again.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppThemeData.danger500,
//         colorText: AppThemeData.grey50,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }
// }
