import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/themes/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartProvider with ChangeNotifier {
  final _cartStreamController = StreamController<List<CartProductModel>>.broadcast();
  List<CartProductModel> _cartItems = [];

  Stream<List<CartProductModel>> get cartStream => _cartStreamController.stream;

  CartProvider() {
    initCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initCart();
    });
  }

  Future<void> initCart() async {
    if (kDebugMode) {
      print('DEBUG: CartProvider _initCart() called');
    }
    _cartItems = await DatabaseHelper.instance.fetchCartProducts();
    if (kDebugMode) {
      print('DEBUG: CartProvider - Fetched ${_cartItems.length} items from database');
    }
    // Sync with global cartItem list
    cartItem.clear();
    cartItem.addAll(_cartItems);
    if (kDebugMode) {
      print('DEBUG: CartProvider - Synced ${cartItem.length} items to global cartItem');
    }
    // Force stream update
    _cartStreamController.sink.add(_cartItems);
    notifyListeners();
    print('DEBUG: CartProvider - Stream updated with ${_cartItems.length} items');
  }

  Future<bool> addToCart(BuildContext context, CartProductModel product, int quantity) async {
    print('DEBUG: CartProvider addToCart called');
    print('DEBUG: Cart Provider - Product: ${product.name}');
    print('DEBUG: Cart Provider - Price: ${product.price}');
    print('DEBUG: Cart Provider - DiscountPrice: ${product.discountPrice}');
    print('DEBUG: Cart Provider - PromoId: ${product.promoId}');
    await _saveLocationForTaxCalculation();
    _cartItems = await DatabaseHelper.instance.fetchCartProducts();
    print('DEBUG: CartProvider - Fetched ${_cartItems.length} items from database');
    print('DEBUG: CartProvider - Cart items: ${_cartItems.map((item) => '${item.name} (${item.vendorID})').toList()}');
    if ((_cartItems.where((item) => item.id == product.id)).isNotEmpty) {
      var index = _cartItems.indexWhere((item) => item.id == product.id);
      _cartItems[index].quantity = quantity;
      // Update price information for promotional items
      _cartItems[index].price = product.price;
      _cartItems[index].discountPrice = product.discountPrice;
      _cartItems[index].promoId = product.promoId;
      if (product.extras != null || product.extras!.isNotEmpty) {
        _cartItems[index].extras = product.extras;
        _cartItems[index].extrasPrice = product.extrasPrice;
      } else {
        _cartItems[index].extras = [];
        _cartItems[index].extrasPrice = "0";
      }
      await DatabaseHelper.instance.updateCartProduct(_cartItems[index]);
      notifyListeners();
    } else {
      // Check if this is a mart item (vendorID starts with "demo_" or contains "mart")
      bool isMartItem = product.vendorID?.startsWith("demo_") == true || 
                       product.vendorID?.contains("mart") == true ||
                       product.vendorID?.contains("vendor") == true;
      
      // Check if cart has any existing items
      // bool cartHasItems = _cartItems.isNotEmpty; // Not used in current logic
      
      // Check if cart has food items (non-mart items)
      bool cartHasFoodItems = _cartItems.any((item) => 
          !(item.vendorID?.startsWith("demo_") == true || 
            item.vendorID?.contains("mart") == true ||
            item.vendorID?.contains("vendor") == true));
      // 1. Cart is empty, OR
      // 2. Adding mart item and cart only has mart items, OR
      // 3. Adding food item and cart only has food items from same vendor
      if (_cartItems.isEmpty || 
          (isMartItem && !cartHasFoodItems) ||
          (!isMartItem && cartHasFoodItems && _cartItems.every((item) => item.vendorID == product.vendorID))) {
        product.quantity = quantity;
        await DatabaseHelper.instance.insertCartProduct(product);
        _cartItems.add(product);
      } else {
        if (isMartItem && cartHasFoodItems) {
          ShowToastDialog.showToast("You can't add mart items when you have food items in cart".tr);
        } else if (!isMartItem && cartHasFoodItems) {
          // Show dialog to ask if user wants to replace cart items
          // ignore: use_build_context_synchronously
          _showRestaurantConflictDialog(context, product, quantity);
          return false; // Return false immediately, dialog will handle the rest
        } else {
          ShowToastDialog.showToast("You can't add food items when you have mart items in cart".tr);
        }
        return false;
      }
    }
    
    // Force refresh cart data and notify listeners
    await  initCart();
    print('DEBUG: CartProvider - Cart updated, total items: ${_cartItems.length}');
    notifyListeners();
    return true;
  }

  /// Save current location data for tax calculation
  Future<void> _saveLocationForTaxCalculation() async {
    try {
      // Check if location is available
      if (Constant.selectedLocation.location?.latitude != null && 
          Constant.selectedLocation.location?.longitude != null) {
        
        // Save location data to preferences for cart calculation
        await Preferences.setString(Preferences.selectedLocationLat, 
            Constant.selectedLocation.location!.latitude.toString());
        await Preferences.setString(Preferences.selectedLocationLng, 
            Constant.selectedLocation.location!.longitude.toString());
        await Preferences.setString(Preferences.selectedLocationAddress, 
            Constant.selectedLocation.address ?? '');
        await Preferences.setString(Preferences.selectedLocationAddressAs, 
            Constant.selectedLocation.addressAs ?? '');
        
        print('DEBUG: CartProvider - Location saved for tax calculation: ${Constant.selectedLocation.location!.latitude}, ${Constant.selectedLocation.location!.longitude}');
      } else {
        print('DEBUG: CartProvider - No location available to save for tax calculation');
      }
    } catch (e) {
      print('DEBUG: CartProvider - Error saving location for tax calculation: $e');
    }
  }


  /// Returns true if any cart item is a promo item (for COD restriction)
  Future<bool> cartContainsPromoItem() async {
    final cartItems = await DatabaseHelper.instance.fetchCartProducts();
    return cartItems.any((item) => item.promoId != null && item.promoId!.isNotEmpty);
  }

  Future<void> removeFromCart(CartProductModel product, int quantity) async {
    print('DEBUG: CartProvider removeFromCart called for: ${product.name}, quantity: $quantity');
    _cartItems = await DatabaseHelper.instance.fetchCartProducts();
    var index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity = quantity;
      if (_cartItems[index].quantity == 0) {
        await DatabaseHelper.instance.deleteCartProduct(product.id!);
        _cartItems.removeAt(index);
        print('DEBUG: CartProvider - Item removed from cart, remaining items: ${_cartItems.length}');
        notifyListeners();
      } else {
        await DatabaseHelper.instance.updateCartProduct(_cartItems[index]);
        print('DEBUG: CartProvider - Item quantity updated to: $quantity');
      }
    }
    notifyListeners();
    await initCart();
    print('DEBUG: CartProvider - Stream updated after removeFromCart');
  }

  // New method to remove item by product ID
  Future<void> removeFromCartById(String productId) async {
    print('DEBUG: CartProvider removeFromCartById called for: $productId');
    _cartItems = await DatabaseHelper.instance.fetchCartProducts();
    var index = _cartItems.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      await DatabaseHelper.instance.deleteCartProduct(productId);
      _cartItems.removeAt(index);
      print('DEBUG: CartProvider - Item removed, remaining items: ${_cartItems.length}');
    }
    await initCart();
    print('DEBUG: CartProvider - Stream updated after removal');
  }

  // New method to update item quantity by product ID
  Future<void> updateCartItemQuantity(String productId, int newQuantity) async {
    print('DEBUG: CartProvider updateCartItemQuantity called for: $productId, quantity: $newQuantity');
    _cartItems = await DatabaseHelper.instance.fetchCartProducts();
    var index = _cartItems.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        await DatabaseHelper.instance.deleteCartProduct(productId);
        _cartItems.removeAt(index);
        print('DEBUG: CartProvider - Item removed due to quantity 0');
      } else {
        _cartItems[index].quantity = newQuantity;
        await DatabaseHelper.instance.updateCartProduct(_cartItems[index]);
        print('DEBUG: CartProvider - Item quantity updated to: $newQuantity');
      }
    }
    await initCart();
    print('DEBUG: CartProvider - Stream updated after quantity change');
  }

  Future<void> clearDatabase() async {
    _cartItems.clear();
    cartItem.clear();
    await DatabaseHelper.instance.deleteAllCartProducts();
    _cartStreamController.sink.add(_cartItems);
    notifyListeners();
  }

  // Method to manually refresh cart from database
  Future<void> refreshCart() async {
    print('DEBUG: CartProvider refreshCart() called');
    await initCart();
  }

  // Method to force stream update
  void forceStreamUpdate() {
    print('DEBUG: CartProvider forceStreamUpdate() called');
    _cartStreamController.sink.add(_cartItems);
  }

  // Method to check cart persistence
  Future<void> checkCartPersistence() async {
    print('DEBUG: CartProvider checkCartPersistence() called');
    final dbItems = await DatabaseHelper.instance.fetchCartProducts();
    print('DEBUG: CartProvider - Database has ${dbItems.length} items');
    print('DEBUG: CartProvider - Memory has ${_cartItems.length} items');
    print('DEBUG: CartProvider - Global cartItem has ${cartItem.length} items');
    
    if (dbItems.length != _cartItems.length) {
      print('DEBUG: CartProvider - Syncing cart with database...');
      await initCart();
    }
  }

  // Show dialog when trying to add items from different restaurants
  void _showRestaurantConflictDialog(BuildContext context, CartProductModel product, int quantity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(
          title: "Different Restaurant".tr,
          descriptions: "You have items from a different restaurant in your cart. Do you want to replace them with items from this restaurant?".tr,
          positiveString: "Replace".tr,
          negativeString: "Cancel".tr,
          positiveClick: () async {
            // Clear existing cart items
            await DatabaseHelper.instance.deleteAllCartProducts();
            _cartItems.clear();
            // Add the new item
            product.quantity = quantity;
            await DatabaseHelper.instance.insertCartProduct(product);
            _cartItems.add(product);
            await initCart();
            Get.back(); // Close dialog
            ShowToastDialog.showToast("Cart updated with new restaurant items".tr);
          },
          negativeClick: () {
            Get.back(); // Close dialog
          },
          img: null,
        );
      },
    );
  }
}
