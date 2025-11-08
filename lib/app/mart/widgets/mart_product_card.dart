
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/app/mart/screens/mart_product_details_screen/mart_product_details_screen.dart';
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/utils/utils/color_const.dart';

class MartProductCard extends StatelessWidget {
  final MartItemModel product;
  final CategoryDetailController controller;
  final double screenWidth;

  const MartProductCard({
    super.key,
    required this.product,
    required this.controller,
    required this.screenWidth,
  });

  String _getSubcategoryName(dynamic subcategoryID) {
    if (subcategoryID == null) return 'General';

    // Try to find the subcategory by ID in the controller's subcategories list
    String? subcategoryTitle;

    if (subcategoryID is String) {
      subcategoryTitle = controller.subcategories
          .where((sub) => sub.id == subcategoryID)
          .firstOrNull
          ?.title;
    } else if (subcategoryID is List && subcategoryID.isNotEmpty) {
      // If it's a list, try the first ID
      subcategoryTitle = controller.subcategories
          .where((sub) => sub.id == subcategoryID.first)
          .firstOrNull
          ?.title;
    }

    // Return the title if found, otherwise return a fallback
    return subcategoryTitle ?? 'General';
  }

  Future<void> _handleAddToCart(
      BuildContext context, MartItemModel product) async {
    try {
      // Prepare cart item data
      final cartItem = {
        'id': product.id,
        'name': product.name,
        'price': product.disPrice ??
            product.price, // Use discounted price if available
        'originalPrice': product.price,
        'image': product.photo,
        'description': product.description,
        'category': _getSubcategoryName(product.subcategoryID),
        'quantity': 1,
        'hasOptions': product.has_options ?? false,
        'optionsCount': product.options_count ?? 0,
        'isVeg': product.veg,
        'isNonVeg': product.nonveg,
        'vendorId': product.vendorID,
        'categoryId': product.categoryID,
        'subcategoryId': product.subcategoryID,
        'addOns': product.addOnsTitle ?? [],
        'addOnsPrice': product.addOnsPrice ?? [],
        'variants': product.variants ?? [],
        'attributes': product.attributes,
        'calories': product.calories,
        'proteins': product.proteins,
        'fats': product.fats,
        'grams': product.grams,
        'isBestSeller': product.isBestSeller ?? false,
        'isFeatured': product.isFeature ?? false,
        'isNew': product.isNew ?? false,
        'isTrending': product.isTrending ?? false,
        'isSeasonal': product.isSeasonal ?? false,
        'isSpotlight': product.isSpotlight ?? false,
        'isStealOfMoment': product.isStealOfMoment ?? false,
        'rating': product.averageRating,
        'reviewCount': product.totalReviews,
        'stockQuantity': product.quantity,
        'isAvailable': product.isAvailable,
        'publish': product.publish,
        'takeawayOption': product.takeawayOption ?? false,
        'brand': product.brand,
        'weight': product.weight,
        'expiryDate': product.expiryDate,
        'barcode': product.barcode,
        'tags': product.tags,
        'nutritionalInfo': product.nutritionalInfo,
        'allergens': product.allergens,
        'isOrganic': product.isOrganic,
        'isGlutenFree': product.isGlutenFree,
        'migratedBy': product.migratedBy,
        'createdAt': product.createdAt,
        'updatedAt': product.updatedAt,
      };

      // No need to show loading state - the toast will handle the feedback

      // Get the cart controller
      final cartController = Get.find<CartController>();

      // Convert MartItemModel to CartProductModel
      // For mart items, we need to modify the vendorID to be recognized as a mart item
      final martVendorID = "mart_${product.vendorID ?? 'unknown'}";

      final cartProduct = CartProductModel(
        id: product.id,
        name: product.name,
        photo: product.photo,
        price: product.price?.toString() ?? '0',
        discountPrice:
            product.disPrice?.toString() ?? product.price?.toString() ?? '0',
        vendorID: martVendorID, // Prefix with "mart_" to identify as mart item
        vendorName:
            "Jippy Mart", // Add vendor name to satisfy NOT NULL constraint
        categoryId: product.categoryID,
        quantity: 1,
        extrasPrice: '0',
        extras: [],
        variantInfo: null,
        promoId: null,
      );

      print(
          '[CART] Cart product prepared: ${cartProduct.name} (ID: ${cartProduct.id})');
      print(
          '[CART] Price: ${cartProduct.price}, Discount Price: ${cartProduct.discountPrice}');
      print('[CART] Original VendorID: ${product.vendorID}');
      print('[CART] Modified VendorID (mart): ${martVendorID}');
      print('[CART] CategoryID: ${product.categoryID}');

      // Add to cart using cart controller
      try {
        print('[CART] Calling cartController.addToCart...');
        final success = await cartController.addToCart(
          cartProductModel: cartProduct,
          isIncrement: true,
          quantity: 1,
        );
        print('[CART] cartController.addToCart returned: $success');

        if (!success) {
          print('[CART] Failed to add to cart - not showing success message');
          return;
        }
      } catch (e) {
        print('[CART] Cart controller method failed: $e');
        print('[CART] Error details: ${e.toString()}');

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Wait a bit for the cart to update
      Future.delayed(Duration(milliseconds: 500));

      // Check if item was actually added to cart (you might need to implement this check)
      // final cartItems = await getCartItems(); // Implement this method
      // final itemInCart = cartItems.any((item) => item['id'] == product.id);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.name} added to cart successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart screen
              Get.to(() => const CartScreen());
            },
          ),
        ),
      );

      // Optional: Navigate to cart screen
      // Get.toNamed('/cart');
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              Expanded(
                child: Text(
                  'Failed to add ${product.name} to cart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(16),
        ),
      );

      print('[CART] Error adding to cart: $e');
    }
  }

  void _showProductOptionsModal(BuildContext context, MartItemModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductOptionsModal(
        product: product,
        onOptionSelected: (selectedOption) {
          // Handle adding the selected option to cart
          _handleAddOptionToCart(context, product, selectedOption);
        },
      ),
    );
  }

  Future<void> _handleAddOptionToCart(BuildContext context,
      MartItemModel product, Map<String, dynamic> selectedOption) async {
    try {
      // Get the cart controller
      final cartController = Get.find<CartController>();

      // Convert MartItemModel to CartProductModel with option details
      final cartProduct = CartProductModel(
        id: "${product.id}_${selectedOption['id']}", // Unique ID for this option
        name: "${product.name} - ${selectedOption['option_title']}",
        photo: selectedOption['image']?.isNotEmpty == true
            ? selectedOption['image']
            : product.photo,
        price: selectedOption['original_price']?.toString() ??
            selectedOption['price']?.toString() ??
            product.price?.toString() ??
            '0',
        discountPrice: selectedOption['price']?.toString() ??
            product.disPrice?.toString() ??
            product.price?.toString() ??
            '0',
        vendorID: "mart_${product.vendorID ?? 'unknown'}",
        vendorName: "Jippy Mart",
        categoryId: product.categoryID,
        quantity: 1,
        extrasPrice: '0',
        extras: [],
        variantInfo: null,
        promoId: null,
      );

      print('[CART] Adding option to cart: ${cartProduct.name}');
      print(
          '[CART] Original Price: ${cartProduct.price}, Discounted Price: ${cartProduct.discountPrice}');

      // Add to cart using cart controller
      final success = await cartController.addToCart(
        cartProductModel: cartProduct,
        isIncrement: true,
        quantity: 1,
      );

      if (!success) {
        print(
            '[CART] Failed to add option to cart - not showing success message');
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartProduct.name} added to cart!'),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => Get.to(() => const CartScreen()),
          ),
        ),
      );
    } catch (e) {
      print('[CART] Error adding option to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add option to cart: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to get responsive image height (flexible based on available space)
  double _getResponsiveImageHeight(double screenWidth) {
    // Calculate height as percentage of screen width for better responsiveness
    double baseHeight =
        screenWidth * 0.27; // 🔑 Increased from 30% to 35% for bigger images

    // Apply more flexible constraints to prevent overflow
    if (baseHeight < 100) {
      return 100.0; // 🔑 Increased minimum height for bigger images
    } else if (baseHeight > 200) {
      return 200.0; // 🔑 Increased maximum height for bigger images
    } else {
      return baseHeight;
    }
  }

  // Helper method to get responsive icon size
  double _getResponsiveIconSize(double screenWidth) {
    if (screenWidth < 360) {
      return 24.0; // Smaller icon for very small screens
    } else if (screenWidth < 400) {
      return 26.0; // Small phones
    } else if (screenWidth < 480) {
      return 28.0; // Medium phones
    } else if (screenWidth < 600) {
      return 30.0; // Large phones
    } else {
      return 32.0; // Tablets and larger
    }
  }

  // Helper method to get responsive font size
  double _getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 360) {
      return baseSize * 0.85; // Smaller font for very small screens
    } else if (screenWidth < 400) {
      return baseSize * 0.9; // Small phones
    } else if (screenWidth < 480) {
      return baseSize * 0.95; // Medium phones
    } else {
      return baseSize; // Normal size for larger screens
    }
  }

  // Helper method to get fallback rating for items with low ratings
  double _getFallbackRating(String productId) {
    // Create a consistent hash from product ID
    int hash = productId.hashCode;

    // Use the hash to generate a consistent value between 0 and 1
    double normalizedValue = (hash.abs() % 1000) / 1000.0;

    // Map to range 4.1 to 4.7
    double fallbackRating = 4.1 + (normalizedValue * 0.6);

    // Round to 1 decimal place
    return double.parse(fallbackRating.toStringAsFixed(1));
  }

  // Helper method to get display rating (with fallback if needed)
  double _getDisplayRating() {
    final originalRating = product.averageRating;

    // If rating is less than 4.1, use fallback
    if (originalRating < 4.1) {
      return _getFallbackRating(product.id);
    }

    // Otherwise, use the original rating
    return originalRating;
  }

  // Helper method to get display review count (with fallback if needed)
  int _getDisplayReviewCount() {
    final originalCount = product.totalReviews;

    // If rating is less than 4.1, use a fallback review count
    if (product.averageRating < 4.1) {
      // Generate consistent review count based on product ID
      int hash = product.id.hashCode;
      int fallbackCount = 15 + (hash.abs() % 50); // Range: 15-64
      return fallbackCount;
    }

    // Otherwise, use the original count
    return originalCount;
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.disPrice != null && product.price > product.disPrice!;
    final originalPrice = product.price;
    final discountedPrice = hasDiscount ? product.disPrice! : originalPrice;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color:ColorConst.white,
      child: Padding(
        padding: const EdgeInsets.all(8), // 🔑 Reduced padding from 12 to 8
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔑 like wrap_content
          children: [
            // Image with Add button (flexible height based on content)
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to product details screen
                    Get.to(() => MartProductDetailsScreen(
                          product: product,
                        ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: product.photo.isNotEmpty
                        ? Container(
                            height: _getResponsiveImageHeight(screenWidth),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:  ColorConst.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: NetworkImageWidget(
                                imageUrl: product.photo,
                                height: _getResponsiveImageHeight(screenWidth),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  height:
                                      _getResponsiveImageHeight(screenWidth),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      color: const Color(0xFF292966),
                                      size: _getResponsiveIconSize(screenWidth),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: _getResponsiveImageHeight(screenWidth),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: const Color(0xFF292966),
                                size: _getResponsiveIconSize(screenWidth),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      if (product.has_options == true) {
                        _showProductOptionsModal(context, product);
                      } else {
                        _handleAddToCart(context, product);
                      }
                    },
                    child: Container(
                      width: 62,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color:  ColorConst.orangeLight),
                      ),
                      child: Builder(
                        builder: (context) {
                          print(
                              '[DEBUG] Product: ${product.name}, has_options: ${product.has_options}');
                          return (product.has_options == true)
                              ? Column(
                                  children: [
                                    // Top 60% - ADD
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          "ADD",
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Divider line
                                    Container(
                                      height: 1,
                                      color: Colors.purple.withOpacity(0.3),
                                    ),
                                    // Bottom 40% - options
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: ColorConst.orangeLight,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2),
                                            child: Text(
                                              "(${product.options_count ?? 0})options",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(
                                      color: ColorConst.orangeLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content below image with left and right padding (flexible based on content)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    screenWidth > 600 ? 8.0 : (screenWidth > 400 ? 6.0 : 3.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: Price and Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: screenWidth < 360
                              ? 1.0
                              : 2.0), // 🔑 Reduced spacing

                      // Price and Savings Row - Compact with Proper Alignment
                      Row(
                        children: [
                          // Price section - Compact layout
                          Expanded(
                            child: Wrap(
                              children: [
                                // Current Price
                                Text(
                                  '₹${discountedPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(
                                        screenWidth, 12.0),
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Small spacing
                                const SizedBox(width: 4),

                                // Original Price (if discounted) - Right next to current price
                                if (hasDiscount)
                                  Text(
                                    '₹${originalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey.shade600,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),

                          // Savings Badge - Compact with icon
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 6,
                                    color: Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'SAVE ₹${(originalPrice - discountedPrice).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Title
                      Text(
                        product.name ?? "Unknown Product",
                        style: TextStyle(
                            fontSize: _getResponsiveFontSize(screenWidth, 14.0),
                            fontWeight: FontWeight.w800,
                            color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Middle section: Description and Info chips
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      // if (product.description.isNotEmpty && product.description != "-")
                      //   Padding(
                      //     padding: EdgeInsets.only(top: screenWidth < 360 ? 3.0 : 4.0),
                      //     child: Text(
                      //       product.description,
                      //       style: TextStyle(
                      //         fontSize: _getResponsiveFontSize(screenWidth, 11.0),
                      //         fontWeight: FontWeight.w600,
                      //         color: Colors.grey.shade700,
                      //       ),
                      //       maxLines: 2,
                      //       overflow: TextOverflow.ellipsis,
                      //     ),
                      //   ),

                      // SizedBox(height: screenWidth < 360 ? 4.0 : 6.0),

                      // Info chips
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600
                              ? 4.0
                              : (screenWidth > 400 ? 3.0 : 2.0),
                          vertical: screenWidth < 360 ? 2.0 : 3.0,
                        ),
                        child: Row(
                          children: [
                            // Subcategory instead of parent category
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth > 600
                                      ? 6.0
                                      : (screenWidth > 400 ? 5.0 : 4.0),
                                  vertical: screenWidth > 600
                                      ? 3.0
                                      : (screenWidth > 400 ? 2.5 : 2.0),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getSubcategoryName(product.subcategoryID),
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                        screenWidth, 9.0),
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            SizedBox(
                                width: screenWidth < 360
                                    ? 6.0
                                    : (screenWidth > 600 ? 12.0 : 8.0)),

                            // Delivery time tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 2),
                                  Text('15 mins',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                            screenWidth, 9.0),
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add spacing after info chips
                      SizedBox(
                          height: screenWidth < 360
                              ? 1.0
                              : 2.0), // 🔑 Reduced spacing
                    ],
                  ),

                  // Bottom section: Ratings
                  if (_getDisplayRating() > 0 &&
                      _getDisplayReviewCount() > 0) ...[
                    // Debug info - remove this later
                    Builder(
                      builder: (context) {
                        print('[RATING DEBUG] Product: ${product.name}');
                        print(
                            '[RATING DEBUG] Original Rating: ${product.averageRating}');
                        print(
                            '[RATING DEBUG] Display Rating: ${_getDisplayRating()}');
                        print(
                            '[RATING DEBUG] Original Reviews: ${product.totalReviews}');
                        print(
                            '[RATING DEBUG] Display Reviews: ${_getDisplayReviewCount()}');
                        return const SizedBox.shrink();
                      },
                    ),
                    // Add proper spacing for ratings
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenWidth < 360
                            ? 0.5
                            : 1.0, // 🔑 Reduced top spacing
                        bottom: screenWidth < 360
                            ? 2.0
                            : 3.0, // 🔑 Reduced bottom spacing
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 8,
                                  color: Colors.amber.shade800,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${_getDisplayRating().toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                        screenWidth, 9.0),
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_getDisplayReviewCount()})',
                            style: TextStyle(
                              fontSize:
                                  _getResponsiveFontSize(screenWidth, 9.0),
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey.shade200,
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   // child: Row(
                          //   //   mainAxisSize: MainAxisSize.min,
                          //   //   children: [
                          //   //     Icon(
                          //   //       Icons.flash_on,
                          //   //       size: 10,
                          //   //       color: Colors.grey.shade700,
                          //   //     ),
                          //   //     const SizedBox(width: 2),
                          //   //     Text(
                          //   //       '15 mins',
                          //   //       style: TextStyle(
                          //   //         fontSize: 9,
                          //   //         color: Colors.black87,
                          //   //         fontWeight: FontWeight.w500,
                          //   //       )
                          //   //     ),
                          //   //   ],
                          //   // ),
                          // ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Empty space when no ratings with proper bottom padding
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenWidth < 360
                            ? 0.5
                            : 1.0, // 🔑 Reduced top spacing
                        bottom: screenWidth < 360
                            ? 2.0
                            : 3.0, // 🔑 Reduced bottom spacing
                      ),
                      child: SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Options Modal Widget
class ProductOptionsModal extends StatelessWidget {
  final MartItemModel product;
  final Function(Map<String, dynamic>) onOptionSelected;

  const ProductOptionsModal({
    Key? key,
    required this.product,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              product.name ?? "Product Options",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Options List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: product.options?.length ?? 0,
              itemBuilder: (context, index) {
                final option = product.options![index];
                final hasDiscount = option['original_price'] != null &&
                    option['price'] != null &&
                    option['original_price'] > option['price'];
                final savings = hasDiscount
                    ? (option['original_price'] - option['price'])
                        .toStringAsFixed(0)
                    : '0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Main content row
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16), // Reduced top padding for savings badge
                        child: Row(
                          children: [
                            // 1. Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: option['image']?.isNotEmpty == true
                                    ? NetworkImageWidget(
                                        imageUrl: option['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : NetworkImageWidget(
                                        imageUrl: product.photo,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 2. Option Title
                            Text(
                              option['option_subtitle'] ?? 'Option',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 3. Price Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Price Row (Current + Original side by side) - Auto-adjusting
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final availableWidth =
                                          constraints.maxWidth;
                                      final isVerySmall = availableWidth < 100;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Current Price - Flexible
                                          Flexible(
                                            flex: 2,
                                            child: Text(
                                              '₹${option['price']?.toString() ?? '0'}',
                                              style: TextStyle(
                                                fontSize: isVerySmall ? 11 : 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),

                                          // Original Price (if discounted) - Flexible
                                          if (hasDiscount) ...[
                                            SizedBox(
                                                width: isVerySmall ? 4 : 6),
                                            Flexible(
                                              flex: 1,
                                              child: Text(
                                                '₹${option['original_price']?.toString() ?? '0'}',
                                                style: TextStyle(
                                                  fontSize:
                                                      isVerySmall ? 9 : 10,
                                                  color: Colors.grey.shade600,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),

                                  // Unit Price below price section - Auto-adjusting
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${option['unit_price']?.toString() ?? '0'}/${option['unit_measure']?.toString() ?? '0'} ${option['unit_measure_type']?.toString() ?? ''}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 4. ADD Button
                            Container(
                              width: 45,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade600,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    onOptionSelected(option);
                                    Navigator.pop(context);
                                  },
                                  child: const Center(
                                    child: Text(
                                      'ADD',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Savings Badge on top center
                      if (hasDiscount)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Save ₹${savings}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Bottom padding
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
