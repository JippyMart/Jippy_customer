
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/models/mart_subcategory_model.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/app/mart/widgets/mart_product_card.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/utils/color_const.dart';

class MartCategoryDetailScreen extends StatelessWidget {
  const MartCategoryDetailScreen({super.key});
  
  // Get appropriate icon for the subcategory
  IconData _getCategoryIcon(String categoryTitle) {
    final title = categoryTitle.toLowerCase();
    
    if (title.contains('veggie') || title.contains('vegetable')) {
      return Icons.eco;
    } else if (title.contains('spice')) {
      return Icons.local_dining;
    } else if (title.contains('oil')) {
      return Icons.opacity;
    } else if (title.contains('dal') || title.contains('pulse')) {
      return Icons.grain;
    } else if (title.contains('rice')) {
      return Icons.grain;
    } else if (title.contains('atta') || title.contains('flour')) {
      return Icons.grain;
    } else if (title.contains('fruit')) {
      return Icons.apple;
    } else if (title.contains('milk') || title.contains('dairy')) {
      return Icons.local_drink;
    } else if (title.contains('bread') || title.contains('bakery')) {
      return Icons.local_dining;
    } else {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryDetailController());
    return Scaffold(
backgroundColor: ColorConst.white,
      body: Column(
        children: [
          _buildHeader(context, controller),
          _buildFilterChips(controller),
          Flexible(
            child: Row(
              children: [
                _buildCategorySidebar(controller),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft, // 🔑 Ensure content starts from top-left
                    child: _buildProductContent(controller),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CategoryDetailController controller) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration:  BoxDecoration(
        color:
        ColorConst.martPrimary,
        // MartTheme.jippyMartButton, // Use jippyMartButton color
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with back button, title, and search
          Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Text(
                  controller.categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  Widget _buildFilterChips(CategoryDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 🔑 Reduced from 8 to 4
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          // All items filter
          _buildFilterChip(
            controller,
            'All',
            Icons.all_inclusive,
            null,
            isDefault: true,
          ),

          const SizedBox(width: 6), // 🔑 Reduced from 8 to 6

          // Best sellers filter
          _buildFilterChip(
            controller,
            'Best Sellers',
            Icons.star,
            'best_sellers',
          ),

          const SizedBox(width: 6), // 🔑 Reduced from 8 to 6

          // Featured filter
          _buildFilterChip(
            controller,
            'Featured',
            Icons.featured_play_list,
            'featured',
          ),

          const SizedBox(width: 6), // 🔑 Reduced from 8 to 6

          // New items filter
          _buildFilterChip(
            controller,
            'New',
            Icons.new_releases,
            'new',
          ),

          const SizedBox(width: 8),

          // Trending filter
          _buildFilterChip(
            controller,
            'Trending',
            Icons.trending_up,
            'trending',
          ),

          const SizedBox(width: 8),

          // Seasonal filter
          _buildFilterChip(
            controller,
            'Seasonal',
            Icons.local_florist,
            'seasonal',
          ),

          const SizedBox(width: 8),

          // Spotlight filter
          _buildFilterChip(
            controller,
            'Spotlight',
            Icons.highlight,
            'spotlight',
          ),

          const SizedBox(width: 8),

          // Steal of moment filter
          _buildFilterChip(
            controller,
            'Steal Deal',
            Icons.local_offer,
            'steal_of_moment',
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFilterChip(
    CategoryDetailController controller,
    String label,
    IconData icon,
    String? filterType, {
    bool isDefault = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filterType;

      return GestureDetector(
        onTap: () {
          controller.selectFilter(filterType);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? MartTheme.jippyMartButton : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? MartTheme.jippyMartButton : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategorySidebar(CategoryDetailController controller) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: ColorConst.white, // Reusable home screen background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoadingSubcategories.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF292966)),
            ),
          );
        }

        if (controller.subcategories.isEmpty) {
          return const Center(
            child: Text(
              'No categories',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4), // 🔑 Reduced from 8 to 4
          itemCount: controller.subcategories.length,
          itemBuilder: (context, index) {
            final category = controller.subcategories[index];

            return Obx(() {
              final isSelected = controller.selectedSubCategoryId.value == category.id;
              return _buildCategoryItem(category, isSelected, controller);
            });
          },
        );
      }),
    );
  }

  Widget _buildCategoryItem(
    MartSubcategoryModel category,
    bool isSelected,
    CategoryDetailController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.selectSubCategory(category.id ?? ''),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 🔑 Reduced vertical from 8 to 4
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1FBEa), // #f1fbea - top color
              Color(0xFF00998a), // #e4f7d4 - bottom color
            ],
            stops: [0.0, 1.0], // Full gradient from top to bottom
          ) : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            // left: BorderSide(
            //   color: isSelected ? const Color(0xFF292966) : Colors.transparent,
            //   width: 3,
            // ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category icon
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF292966) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Obx(() {
                  final validImageUrl = category.getValidImageUrlWithParentFallback(controller.parentCategoryImageUrl.value);
                  final hasValidPhoto = validImageUrl.isNotEmpty;
                  print('[CATEGORY DETAIL UI] 📸 Category: ${category.title}, ValidImageUrl: $validImageUrl, HasValidPhoto: $hasValidPhoto');

                  if (hasValidPhoto) {
                    return NetworkImageWidget(
                      imageUrl: validImageUrl,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                                              errorWidget: Icon(
                          _getCategoryIcon(category.title ?? ''),
                          color: isSelected ? Colors.white : const Color(0xFF292966),
                          size: 22,
                        ),
                    );
                  } else {
                    return Icon(
                      _getCategoryIcon(category.title ?? ''),
                      color: isSelected ? Colors.white : const Color(0xFF292966),
                      size: 22,
                    );
                  }
                }),
              ),
            ),

            const SizedBox(height: 6),

            // Category name
            Text(
              category.title ?? 'Unknown Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent(CategoryDetailController controller) {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF292966),),
          ),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF292966),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.testFirestoreEndpoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Test Firestore'),
              ),
            ],
          ),
        );
      }

      // Use StreamBuilder for real-time product updates
      return StreamBuilder<QuerySnapshot>(
        stream: _buildProductStream(controller),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF292966)),
              ),
            );
          }

          final products = snapshot.data?.docs ?? [];
          
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try selecting a different category or filter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isTablet = screenWidth > 600;
                final isLargePhone = screenWidth > 400;
                
                final crossAxisCount = isTablet ? 3 : 2;
                final spacing = isTablet ? 12.0 : (isLargePhone ? 8.0 : 4.0);
                final horizontalPadding = isTablet ? 16.0 : (isLargePhone ? 8.0 : 4.0);
                
                // 🔑 Auto-adjustable layout using Wrap for truly flexible card heights
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: horizontalPadding, 
                    right: horizontalPadding, 
                    bottom: MediaQuery.of(context).padding.bottom + 8, // 🔑 Reduced from 16 to 8
                    top: 4 // 🔑 Added small top padding instead of 0
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start, // 🔑 Ensure products start from the left
                    crossAxisAlignment: WrapCrossAlignment.start, // 🔑 Ensure products start from the top
                    runAlignment: WrapAlignment.start, // 🔑 Ensure runs start from the top
                    spacing: spacing,
                    runSpacing: spacing,
                    children: products.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Transform the data to match the expected format
                      final transformedData = Map<String, dynamic>.from(data);
                      
                      // Add document ID
                      transformedData['id'] = doc.id;
                      
                      // Handle array fields that might be null
                      if (transformedData['addOnsPrice'] == null) transformedData['addOnsPrice'] = [];
                      if (transformedData['addOnsTitle'] == null) transformedData['addOnsTitle'] = [];
                      if (transformedData['options'] == null) transformedData['options'] = [];
                      if (transformedData['photos'] == null) transformedData['photos'] = [];
                      // Updated: subcategoryID is now a string, not an array
                      if (transformedData['subcategoryID'] == null) transformedData['subcategoryID'] = '';
                      if (transformedData['product_specification'] == null) transformedData['product_specification'] = {};
                      
                      // Handle numeric fields that might be strings (this fixes the rating issue)
                      if (transformedData['reviewCount'] is String) {
                        transformedData['reviewCount'] = int.tryParse(transformedData['reviewCount']) ?? 0;
                      }
                      if (transformedData['reviewSum'] is String) {
                        transformedData['reviewSum'] = double.tryParse(transformedData['reviewSum']) ?? 0.0;
                      }
                      
                      // Handle other numeric fields that might be strings
                      if (transformedData['price'] is String) {
                        transformedData['price'] = double.tryParse(transformedData['price']) ?? 0.0;
                      }
                      if (transformedData['disPrice'] is String) {
                        transformedData['disPrice'] = double.tryParse(transformedData['disPrice']) ?? 0.0;
                      }
                      if (transformedData['quantity'] is String) {
                        transformedData['quantity'] = int.tryParse(transformedData['quantity']) ?? 0;
                      }
                      if (transformedData['calories'] is String) {
                        transformedData['calories'] = int.tryParse(transformedData['calories']) ?? 0;
                      }
                      if (transformedData['proteins'] is String) {
                        transformedData['proteins'] = double.tryParse(transformedData['proteins']) ?? 0.0;
                      }
                      if (transformedData['fats'] is String) {
                        transformedData['fats'] = double.tryParse(transformedData['fats']) ?? 0.0;
                      }
                      if (transformedData['grams'] is String) {
                        transformedData['grams'] = double.tryParse(transformedData['grams']) ?? 0.0;
                      }
                      if (transformedData['options_count'] is String) {
                        transformedData['options_count'] = int.tryParse(transformedData['options_count']) ?? 0;
                      }
                      
                      // Handle boolean fields that might be null
                      if (transformedData['has_options'] == null) transformedData['has_options'] = false;
                      if (transformedData['isAvailable'] == null) transformedData['isAvailable'] = true;
                      if (transformedData['isBestSeller'] == null) transformedData['isBestSeller'] = false;
                      if (transformedData['isFeature'] == null) transformedData['isFeature'] = false;
                      if (transformedData['isNew'] == null) transformedData['isNew'] = false;
                      if (transformedData['isSeasonal'] == null) transformedData['isSeasonal'] = false;
                      if (transformedData['isSpotlight'] == null) transformedData['isSpotlight'] = false;
                      if (transformedData['isStealOfMoment'] == null) transformedData['isStealOfMoment'] = false;
                      if (transformedData['isTrending'] == null) transformedData['isTrending'] = false;
                      if (transformedData['veg'] == null) transformedData['veg'] = true;
                      if (transformedData['nonveg'] == null) transformedData['nonveg'] = false;
                      if (transformedData['takeawayOption'] == null) transformedData['takeawayOption'] = false;
                      if (transformedData['publish'] == null) transformedData['publish'] = true;
                      
                      final product = MartItemModel.fromJson(transformedData);
                      
                      // Debug: Log rating information
                      print('[CATEGORY DETAIL] 📊 Product: ${product.name}');
                      print('[CATEGORY DETAIL] 📊 Review Count: ${product.reviewCount} (type: ${product.reviewCount.runtimeType})');
                      print('[CATEGORY DETAIL] 📊 Review Sum: ${product.reviewSum} (type: ${product.reviewSum.runtimeType})');
                      print('[CATEGORY DETAIL] 📊 Average Rating: ${product.averageRating}');
                      print('[CATEGORY DETAIL] 📊 Total Reviews: ${product.totalReviews}');
                      
                      // Calculate card width based on screen size and crossAxisCount
                      final cardWidth = (screenWidth - horizontalPadding * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;
                      
                      // Using MartProductCard with calculated width for proper sizing
                      return SizedBox(
                        width: cardWidth,
                        child: MartProductCard(
                          product: product, 
                          controller: controller,
                          screenWidth: screenWidth,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }

  Stream<QuerySnapshot> _buildProductStream(CategoryDetailController controller) {
    Query query = FirebaseFirestore.instance
        .collection('mart_items')
        .where('publish', isEqualTo: true);

    // Handle special category cases (trending, featured, sections)
    if (controller.categoryId == 'trending') {
      // For trending category, filter by isTrending = true
      query = query.where('isTrending', isEqualTo: true);
      print('[PRODUCT STREAM] 🔥 Special case: Trending items');
    } else if (controller.categoryId == 'featured') {
      // For featured category, filter by isFeature = true
      query = query.where('isFeature', isEqualTo: true);
      print('[PRODUCT STREAM] ⭐ Special case: Featured items');
    } else if (controller.categoryId.startsWith('section_') && controller.sectionName.isNotEmpty) {
      // For section-based navigation, filter by section field
      query = query.where('section', isEqualTo: controller.sectionName);
      print('[PRODUCT STREAM] 📂 Section-based: ${controller.sectionName}');
    } else if (controller.categoryId.isNotEmpty) {
      // For regular categories, filter by categoryID
      query = query.where('categoryID', isEqualTo: controller.categoryId);
      print('[PRODUCT STREAM] 📂 Regular category: ${controller.categoryId}');
    }

    // Apply subcategory filter - only for regular categories (not trending, featured, or sections)
    if (controller.categoryId != 'trending' && 
        controller.categoryId != 'featured' &&
        !controller.categoryId.startsWith('section_') &&
        controller.selectedSubCategoryId.value.isNotEmpty && 
        controller.selectedSubCategoryId.value != controller.categoryId) {
      // If a specific subcategory is selected, filter by it
      // Updated: subcategoryID is now a string, not an array
      query = query.where('subcategoryID', isEqualTo: controller.selectedSubCategoryId.value);
      print('[PRODUCT STREAM] 🏷️ Subcategory filter: ${controller.selectedSubCategoryId.value}');
    }

    // Apply additional filters based on selectedFilter
    if (controller.selectedFilter.value.isNotEmpty) {
      switch (controller.selectedFilter.value) {
        case 'trending':
          if (controller.categoryId != 'trending') {
            query = query.where('isTrending', isEqualTo: true);
          }
          break;
        case 'featured':
          if (controller.categoryId != 'featured') {
            query = query.where('isFeature', isEqualTo: true);
          }
          break;
        case 'best_sellers':
          query = query.where('isBestSeller', isEqualTo: true);
          break;
        case 'new':
          query = query.where('isNew', isEqualTo: true);
          break;
        case 'on_sale':
          query = query.where('disPrice', isGreaterThan: 0);
          break;
      }
      print('[PRODUCT STREAM] 🎯 Additional filter: ${controller.selectedFilter.value}');
    }

    // Apply search filter if available
    if (controller.searchQuery.value.isNotEmpty) {
      // Note: Firestore doesn't support text search, so we'll filter client-side
      // For now, we'll load all items and filter in the UI
      print('[PRODUCT STREAM] 🔍 Search query: ${controller.searchQuery.value}');
    }

    print('[PRODUCT STREAM] 🔍 Building query with:');
    print('[PRODUCT STREAM]   - Category ID: ${controller.categoryId}');
    print('[PRODUCT STREAM]   - Selected Subcategory: ${controller.selectedSubCategoryId.value}');
    print('[PRODUCT STREAM]   - Filter: ${controller.selectedFilter.value}');
    print('[PRODUCT STREAM]   - Search: ${controller.searchQuery.value}');
    print('[PRODUCT STREAM] 🔍 Query structure updated for new Firestore model');

    return query.snapshots();
  }

}

// OLD CODE - COMMENTED OUT - Using MartProductCard instead
// class ProductCard extends StatelessWidget {
//   final MartItemModel product;
//   final CategoryDetailController controller;
//   final double screenWidth;

//   const ProductCard({
//     super.key,
//     required this.product,
//     required this.controller,
//     required this.screenWidth,
//   });

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // String _getSubcategoryName(dynamic subcategoryID) {
  //   if (subcategoryID == null) return 'General';
    
  //   // Try to find the subcategory by ID in the controller's subcategories list
  //   String? subcategoryTitle;
    
  //   if (subcategoryID is String) {
  //     subcategoryTitle = controller.subcategories
  //         .where((sub) => sub.id == subcategoryID)
  //         .firstOrNull
  //         ?.title;
  //   } else if (subcategoryID is List && subcategoryID.isNotEmpty) {
  //     // If it's a list, try the first ID
  //     subcategoryTitle = controller.subcategories
  //         .where((sub) => sub.id == subcategoryID.first)
  //         .firstOrNull
  //         ?.title;
  //   }
    
  //   // Return the title if found, otherwise return a fallback
  //   return subcategoryTitle ?? 'General';
  // }

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // void _handleAddToCart(BuildContext context, MartItemModel product) {
  //   try {
  //     // Prepare cart item data
  //     final cartItem = {
  //       'id': product.id,
  //       'name': product.name,
  //       'price': product.disPrice ?? product.price, // Use discounted price if available
  //       'originalPrice': product.price,
  //       'image': product.photo,
  //       'description': product.description,
  //       'category': _getSubcategoryName(product.subcategoryID),
  //       'quantity': 1,
  //       'hasOptions': product.has_options ?? false,
  //       'optionsCount': product.options_count ?? 0,
  //       'isVeg': product.veg,
  //       'isNonVeg': product.nonveg,
  //       'vendorId': product.vendorID,
  //       'categoryId': product.categoryID,
  //       'subcategoryId': product.subcategoryID,
  //       'addOns': product.addOnsTitle ?? [],
  //       'addOnsPrice': product.addOnsPrice ?? [],
  //       'variants': product.variants ?? [],
  //       'attributes': product.attributes,
  //       'calories': product.calories,
  //       'proteins': product.proteins,
  //       'fats': product.fats,
  //       'grams': product.grams,
  //       'isBestSeller': product.isBestSeller ?? false,
  //       'isFeatured': product.isFeature ?? false,
  //       'isNew': product.isNew ?? false,
  //       'isTrending': product.isTrending ?? false,
  //       'isSeasonal': product.isSeasonal ?? false,
  //       'isSpotlight': product.isSpotlight ?? false,
  //       'isStealOfMoment': product.isStealOfMoment ?? false,
  //       'rating': product.averageRating,
  //       'reviewCount': product.totalReviews,
  //       'stockQuantity': product.quantity,
  //       'isAvailable': product.isAvailable,
  //       'publish': product.publish,
  //       'takeawayOption': product.takeawayOption ?? false,
  //       'brand': product.brand,
  //       'weight': product.weight,
  //       'expiryDate': product.expiryDate,
  //       'barcode': product.barcode,
  //       'tags': product.tags,
  //       'nutritionalInfo': product.nutritionalInfo,
  //       'allergens': product.allergens,
  //       'isOrganic': product.isOrganic,
  //       'isGlutenFree': product.isGlutenFree,
  //       'migratedBy': product.migratedBy,
  //       'createdAt': product.createdAt,
  //       'updatedAt': product.updatedAt,
  //     };

      // OLD CODE - COMMENTED OUT - Using MartProductCard instead
      // // Show loading state
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         SizedBox(
      //           width: 20,
      //           height: 20,
      //           child: CircularProgressIndicator(
      //             strokeWidth: 2,
      //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //           ),
      //         ),
      //         SizedBox(width: 8),
      //         Text('Adding to cart...'),
      //       ],
      //     ),
      //     backgroundColor: Colors.blue.shade600,
      //     duration: Duration(seconds: 1),
      //   ),
      // );

      // // Get the cart controller
      // final cartController = Get.find<CartController>();
      
      // // Convert MartItemModel to CartProductModel
      // // For mart items, we need to modify the vendorID to be recognized as a mart item
      // final martVendorID = "mart_${product.vendorID ?? 'unknown'}";
      
      // final cartProduct = CartProductModel(
      //   id: product.id,
      //   name: product.name,
      //   photo: product.photo,
      //   price: product.price?.toString() ?? '0',
      //   discountPrice: product.disPrice?.toString() ?? product.price?.toString() ?? '0',
      //   vendorID: martVendorID, // Prefix with "mart_" to identify as mart item
      //   vendorName: "Jippy Mart", // Add vendor name to satisfy NOT NULL constraint
      //   categoryId: product.categoryID,
      //   quantity: 1,
      //   extrasPrice: '0',
      //   extras: [],
      //   variantInfo: null,
      //   promoId: null,
      // );

      // print('[CART] Cart product prepared: ${cartProduct.name} (ID: ${cartProduct.id})');
      // print('[CART] Price: ${cartProduct.price}, Discount Price: ${cartProduct.discountPrice}');
      // print('[CART] Original VendorID: ${product.vendorID}');
      // print('[CART] Modified VendorID (mart): ${martVendorID}');
      // print('[CART] CategoryID: ${product.categoryID}');

      // // Add to cart using cart controller
      // try {
      //   print('[CART] Calling cartController.addToCart...');
      //   cartController.addToCart(
      //     cartProductModel: cartProduct,
      //     isIncrement: true,
      //     quantity: 1,
      //   );
      //   print('[CART] Successfully called cartController.addToCart');
        
      // } catch (e) {
      //   print('[CART] Cart controller method failed: $e');
      //   print('[CART] Error details: ${e.toString()}');
        
      //   // Show error message
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to add to cart: ${e.toString()}'),
      //       backgroundColor: Colors.red.shade600,
      //       duration: Duration(seconds: 3),
      //     ),
      //   );
      //   return;
      // }

      // // Wait a bit for the cart to update
      // Future.delayed(Duration(milliseconds: 500));
      
      // // Check if item was actually added to cart (you might need to implement this check)
      // // final cartItems = await getCartItems(); // Implement this method
      // // final itemInCart = cartItems.any((item) => item['id'] == product.id);
      
      // // Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         Icon(Icons.check_circle, color: Colors.white, size: 20),
      //         SizedBox(width: 8),
      //         Expanded(
      //           child: Text(
      //             '${product.name} added to cart successfully!',
      //             style: TextStyle(color: Colors.white),
      //           ),
      //         ),
      //       ],
      //     ),
      //     backgroundColor: Colors.green.shade600,
      //     duration: Duration(seconds: 2),
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     margin: EdgeInsets.all(16),
      //     action: SnackBarAction(
      //       label: 'View Cart',
      //       textColor: Colors.white,
      //       onPressed: () {
      //         // Navigate to cart screen
      //         // Get.toNamed('/cart');
      //         print('[CART] Navigate to cart screen');
      //       },
      //     ),
      //   ),
      // );

      // // Optional: Navigate to cart screen
      // // Get.toNamed('/cart');

      // } catch (e) {
      //   // Show error message if something goes wrong
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Row(
      //         children: [
      //           Icon(Icons.error, color: Colors.white, size: 20),
      //           SizedBox(width: 8),
      //           Expanded(
      //             child: Text(
      //               'Failed to add ${product.name} to cart',
      //               style: TextStyle(color: 20),
      //             ),
      //           ),
      //         ],
      //       ),
      //       backgroundColor: Colors.red.shade600,
      //       duration: Duration(seconds: 3),
      //       behavior: SnackBarBehavior.floating,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //       margin: EdgeInsets.all(16),
      //     ),
      //   );
        
      //   print('[CART] Error adding to cart: $e');
      // }
  // }

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // void _showProductOptionsModal(BuildContext context, MartItemModel product) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => ProductOptionsModal(
  //       product: product,
  //       onOptionSelected: (selectedOption) {
  //         // Handle adding the selected option to cart
  //         _handleAddOptionToCart(context, product, selectedOption);
  //       },
  //     ),
  //   );
  // }

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // void _handleAddOptionToCart(BuildContext context, MartItemModel product, Map<String, dynamic> selectedOption) {
  //   try {
  //     // Get the cart controller
  //     final cartController = Get.find<CartController>();
      
  //     // Convert MartItemModel to CartProductModel with option details
  //     final cartProduct = CartProductModel(
  //       id: "${product.id}_${selectedOption['id']}", // Unique ID for this option
  //       name: "${product.name} - ${selectedOption['option_title']}",
  //       photo: selectedOption['image']?.isNotEmpty == true ? selectedOption['image'] : product.photo,
  //       price: selectedOption['price']?.toString() ?? product.price?.toString() ?? '0',
  //       discountPrice: selectedOption['original_price']?.toString() ?? selectedOption['price']?.toString() ?? product.disPrice?.toString() ?? product.price?.toString() ?? '0',
  //       vendorID: "mart_${product.vendorID ?? 'unknown'}",
  //       vendorID: "mart_${product.vendorID ?? 'unknown'}",
  //       vendorName: "Jippy Mart",
  //       categoryId: product.categoryID,
  //       quantity: 1,
  //       extrasPrice: '0',
  //       extras: [],
  //       variantInfo: null,
  //       promoId: null,
  //     );

  //     print('[CART] Adding option to cart: ${cartProduct.name}');
  //     print('[CART] Option Price: ${cartProduct.price}, Original Price: ${cartProduct.discountPrice}');

  //     // Add to cart using cart controller
  //     cartController.addToCart(
  //       cartProductModel: cartProduct,
  //       isIncrement: true,
  //       quantity: 1,
  //     );

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${cartProduct.name} added to cart!'),
  //         backgroundColor: Colors.green.shade600,
  //         duration: Duration(seconds: 2),
  //         action: SnackBarAction(
  //           label: 'View Cart',
  //           textColor: Colors.white,
  //           onPressed: () => Get.toNamed('/cart'),
  //         ),
  //       ),
  //     );

  //   } catch (e) {
  //     print('[CART] Error adding option to cart: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         content: Text('Failed to add option to cart: ${e.toString()}'),
  //         backgroundColor: Colors.red.shade600,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // @override
  // Widget build(BuildContext context) {
  //   final hasDiscount = product.disPrice != null && product.price > product.disPrice!;
  //   final originalPrice = product.price;
  //   final discountedPrice = hasDiscount ? product.disPrice! : originalPrice;

  //   return Card(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       elevation: 2,
  //       color: Colors.white,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Image with Add button
  //           Stack(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(10),
  //                 child: product.photo.isNotEmpty
  //                     ? Container(
  //                         height: screenWidth > 600 ? 140.0 : (screenWidth > 400 ? 135.0 : 128.0),
  //                         width: double.infinity,
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFFF8F8FF),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(10),
  //                           child: NetworkImageWidget(
  //                             imageUrl: product.photo,
  //                             height: screenWidth > 600 ? 140.0 : (screenWidth > 400 ? 135.0 : 128.0),
  //                             width: double.infinity,
  //                             fit: BoxFit.cover,
  //                             errorWidget: Container(
  //                               height: screenWidth > 600 ? 140.0 : (screenWidth > 400 ? 135.0 : 128.0),
  //                               width: double.infinity,
  //                               decoration: BoxDecoration(
  //                                 color: const Color(0xFFF8F8FF),
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               child: const Center(
  //                                 child: Icon(
  //                                   Icons.image,
  //                                   color: Color(0xFF292966),
  //                                   size: 30,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       )
  //                     : Container(
  //                         height: 105,
  //                         width: double.infinity,
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFFF8F8FF),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: const Center(
  //                           child: Icon(
  //                             Icons.image,
  //                             size: 28,
  //                           ),
  //                         ),
  //                       ),
  //               ),
  //               Positioned(
  //                 bottom: 4,
  //                 right: 4,
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     if (product.has_options == true) {
  //                       _showProductOptionsModal(context, product);
  //                     } else {
  //                       _handleAddToCart(context, product);
  //                     }
  //                   },
  //                   child: Container(
  //                     width: 62,
  //                     height: 32,
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(color: Colors.purple),
  //                     ),
  //                     child: Builder(
  //                       builder: (context) {
  //                         print('[DEBUG] Product: ${product.name}, has_options: ${product.has_options}');
  //                         return (product.has_options == true)
  //                         ? Column(
  //                             children: [
  //                               // Top 60% - ADD
  //                               Expanded(
  //                                 flex: 3,
  //                                 child: Center(
  //                                   child: Text(
  //                                     "ADD",
  //                                     style: TextStyle(
  //                                       color: Colors.purple,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 10,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               // Divider line
  //                               Container(
  //                                 height: 1,
  //                                 color: Colors.purple.withOpacity(0.3),
  //                               ),
  //                               // Bottom 40% - options
  //                               Expanded(
  //                                 flex: 2,
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.purple.shade100,
  //                                     borderRadius: const BorderRadius.only(
  //                                       bottomLeft: Radius.circular(8),
  //                                       bottomRight: Radius.circular(8),
  //                                     ),
  //                                   ),
  //                                   child: Center(
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.only(bottom: 2),
  //                                       child: Text(
  //                                         "(${product.options_count ?? 0})options",
  //                                         style: TextStyle(
  //                                           color: Colors.grey.shade700,
  //                                           fontWeight: FontWeight.w900,
  //                                           fontSize: 8,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )
  //                         : Center(
  //                             child: Text(
  //                               "ADD",
  //                               style: TextStyle(
  //                                 color: Colors.purple,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 10,
  //                               ),
  //                             ),
  //                           );
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),

  //           // Content below image with left and right padding
  //           Padding(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: screenWidth > 600 ? 8.0 : (screenWidth > 400 ? 6.0 : 3.0),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const SizedBox(height: 1),

  //                 // Price and Savings Row
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Current Price
  //                     Text(
  //                       '₹${discountedPrice.toStringAsFixed(0)}',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold, 
  //                         fontSize: screenWidth > 600 ? 14.0 : (screenWidth : 400 ? 13.0 : 12.0),
  //                         color: Colors.black87,
  //                       ),
  //                     ),
  //                     // Original Price (if discounted)
                     
  //                     if (hasDiscount)
  //                       Text(
  //                         '₹${originalPrice.toStringAsFixed(0)}',
  //                         style: TextStyle(
  //                           fontSize: 10,
  //                           color: Colors.grey.shade600,
  //                           decoration: TextDecoration.lineThrough,
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //               // Savings Badge
  //               if (hasDiscount)
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
  //                   decoration: BoxDecoration(
  //                     // color: Colors.green.shade100,
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.local_offer,
  //                         size: 6,
  //                         color: Colors.green.shade800,
  //                       ),
  //                       const SizedBox(width: 2),
  //                       Text(
  //                         'SAVE ₹${(originalPrice - discountedPrice).toStringAsFixed(0)}',
  //                         style: TextStyle(
  //                           fontSize: 8,
  //                           color: Colors.green.shade800,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //             ],
  //           ),

  //           // Title
  //           Text(
  //             product.name ?? "Unknown Product",
  //             style: TextStyle(
  //             fontSize: screenWidth > 600 ? 16.0 : (screenWidth > 400 ? 15.0 : 14.0),
  //             fontWeight: FontWeight.w800,
  //             color: Colors.grey
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),

  //         // Description
  //         if (product.description.isNotEmpty && product.description != "-")
  //           Padding(
  //             padding: const EdgeInsets.only(top: 0),
  //             child: Text(
  //               product.description,
  //               style: const TextStyle(
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w400,
  //                 color: Colors.grey,
  //               ),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),

  //         SizedBox(height: screenWidth > 600 ? 3.0 : (screenWidth > 400 ? 2.0 : 1.0)),

  //         // Info chips
  //         Padding(
  //           padding: EdgeInsets.symmetric(
  //             horizontal: screenWidth > 600 ? 4.0 : (screenWidth > 400 ? 3.0 : 2.0),
  //             vertical: screenWidth > 600 ? 2.0 : (screenWidth > 400 ? 1.5 : 1.0),
  //           ),
  //           child: Wrap(
  //             spacing: screenWidth > 600 ? 24.0 : (screenWidth > 400 ? 22.0 : 20.0),
  //             children: [
  //             // Subcategory instead of parent category
  //             Container(
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: screenWidth > 600 ? 6.0 : (screenWidth > 400 ? 5.0 : 4.0),
  //                 vertical: screenWidth > 600 ? 3.0 : (screenWidth > 400 ? 2.5 : 2.0),
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.blue.shade100,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 _getSubcategoryName(product.subcategoryID),
  //                 style: TextStyle(
  //                   fontSize: 9, 
  //                   color: Colors.blue.shade800,
  //                   fontWeight: FontWeight.w500,
  //                 )
  //               ),
  //             ),

  //           ],
  //             ),
  //           ),

  //         const SizedBox(height: 4),

  //         // Ratings Row (bottom)
  //         if (product.averageRating > 0 && product.totalReviews > 0)
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(
  //                       Icons.star,
  //                       size: 8,
  //                       color: Colors.amber.shade800,
  //                     ),
  //                     const SizedBox(width: 2),
  //                     Text(
  //                       '${product.averageRating.toStringAsFixed(1)}',
  //                       style: TextStyle(
  //                         fontSize: 9,
  //                         color: Colors.amber.shade800,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 4),
  //               Text(
  //                 '(${product.totalReviews})',
  //                 style: TextStyle(
  //                   fontSize: 9,
  //                   color: Colors.grey.shade700,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade200,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(
  //                       Icons.flash_on,
  //                       size: 10,
  //                       color: Colors.grey.shade700,
  //                     ),
  //                     const SizedBox(width: 8),
  //                       Text(
  //                         '15 mins',
  //                         style: TextStyle(
  //                           fontSize: 9,
  //                           color: Colors.black87,
  //                           fontWeight: FontWeight.w500,
  //                         )
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  // );
  // }
  // } // Closing brace for ProductCard class

// OLD CODE - COMMENTED OUT - Using MartProductCard instead
// // Product Options Modal Widget
// class ProductOptionsModal extends StatelessWidget {
//   final MartItemModel product;
//   final Function(Map<String, dynamic>) onOptionSelected;

//   const ProductOptionsModal({
//     Key? key,
//     required this.product,
//     required this.onOptionSelected,
//   }) : super(key: key);

  // OLD CODE - COMMENTED OUT - Using MartProductCard instead
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Handle bar
  //         Container(
  //           margin: const EdgeInsets.only(top: 8),
  //           width: 40,
  //           height: 4,
  //           decoration: BoxDecoration(
  //             color: Colors.grey.shade300,
  //             borderRadius: BorderRadius.circular(2),
  //           ),
  //         ),
          
  //         // Title
  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Text(
  //             product.name ?? "Product Options",
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black87,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),

  //       // Options List
  //       Flexible(
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           padding: const EdgeInsets.symmetric(horizontal: 20),
  //           itemCount: product.options?.length ?? 0,
  //           itemBuilder: (context, index) {
  //             final option = product.options![index];
  //             final hasDiscount = option['original_price'] != null && 
  //                                option['price'] != null &&
  //                                option['original_price'] > option['price'];
  //             final savings = hasDiscount 
  //                 ? (option['original_price'] - option['price']).toStringAsFixed(0)
  //                 : '0';

  //             return Container(
  //               margin: const EdgeInsets.only(bottom: 12),
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: Colors.grey.shade200),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.shade200,
  //                     blurRadius: 2,
  //                     offset: const Offset(0, 1),
  //                   ),
  //                 ],
  //               ),
  //               child: Stack(
  //                 children: [
  //                   // Main content row
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 16), // Reduced top padding for savings badge
  //                     child: Row(
  //                       children: [
  //                         // 1. Product Image
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(6),
  //                           child: Container(
  //                             width: 50,
  //                             height: 50,
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey.shade100,
  //                               borderRadius: BorderRadius.circular(6),
  //                             ),
  //                             child: option['image']?.isNotEmpty == true
  //                                 ? NetworkImageWidget(
  //                                     imageUrl: option['image'],
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   )
  //                                 : NetworkImageWidget(
  //                                     imageUrl: product.photo,
  //                                     width: 50,
  //                                     height: 50,
  //                                     fit: BoxFit.cover,
  //                                   ),
  //                             ),
  //                           ),
                            
  //                           const SizedBox(width: 8),
                            
  //                           // 2. Option Title
  //                           Text(
  //                             option['option_title'] ?? 'Option',
  //                             style: const TextStyle(
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.w600,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
                            
  //                           const SizedBox(width: 8),
                            
  //                                                     // 3. Price Section
  //                           Expanded(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.center,
  //                               children: [
  //                                 // Price Row (Current + Original side by side)
  //                                 Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     // Current Price
  //                                     Text(
  //                                       '₹${option['price']?.toString() ?? '0'}',
  //                                       style: const TextStyle(
  //                                         fontSize: 14,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Colors.black87,
  //                                       ),
  //                                     ),
                                      
  //                                       // Original Price (if discounted) - beside current price
  //                                       if (hasDiscount) ...[
  //                                         const SizedBox(width: 8),
  //                                         Text(
  //                                           '₹${option['original_price']?.toString() ?? '0'}',
  //                                           style: TextStyle(
  //                                             fontSize: 12,
  //                                             color: Colors.grey.shade600,
  //                                             decoration: TextDecoration.lineThrough,
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ],
  //                                   ),
                                  
  //                                   // Unit Price below price section
  //                                   const SizedBox(height: 2),
  //                                   Text(
  //                                     '₹${option['unit_price']?.toString() ?? '0'}/${option['unit_measure']?.toString() ?? '0'} ${option['unit_measure_type']?.toString() ?? ''}',
  //                                     style: TextStyle(
  //                                       fontSize: 10,
  //                                       color: Colors.green.shade600,
  //                                       fontWeight: FontWeight.w900,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
                            
  //                             const SizedBox(width: 8),
                            
  //                             // 4. ADD Button
  //                             Container(
  //                                 width: 45,
  //                                 height: 30,
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.white,
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   border: Border.all(
  //                                     color: Colors.red.shade600,
  //                                     width: 1,
  //                                   ),
  //                                 ),
  //                               child: Material(
  //                                 color: Colors.transparent,
  //                                 child: InkWell(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   onTap: () {
  //                                     onOptionSelected(option);
  //                                     Navigator.pop(context);
  //                                   },
  //                                   child: const Center(
  //                                     child: Text(
  //                                       'ADD',
  //                                       textColor: Colors.red,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 10,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
                      
  //                       // Savings Badge on top center
  //                       if (hasDiscount)
  //                         Positioned(
  //                           top: 0,
  //                           left: 0,
  //                           right: 0,
  //                           child: Center(
  //                                                           child: Container(
  //                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
  //                             decoration: BoxDecoration(
  //                               color: Colors.green.shade600,
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                             child: Text(
  //                               'Save ₹${savings}',
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 10,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
          
  //           // Bottom padding
  //           const SizedBox(height: 40),
  //         ],
  //       ),
  //     );
  //   }
  // }


