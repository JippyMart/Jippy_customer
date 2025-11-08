
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/cart_screen/widget/cart_build_delivery_ui.dart';
import 'package:customer/app/cart_screen/widget/cart_product_details_image_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer/utils/utils/image_const.dart';
import 'package:provider/provider.dart';

// Cart theme enum for different color schemes

class CartCheckOutScreen extends StatefulWidget {
  final bool hideBackButton;
  final String? source; // 'food' or 'mart' or null for auto-detect
  final bool isFromMartNavigation; // true if accessed from mart navigation tabs

  const CartCheckOutScreen(
      {super.key,
        this.hideBackButton = false,
        this.source,
        this.isFromMartNavigation = false});

  @override
  State<CartCheckOutScreen> createState() => _CartCheckOutScreenState();
}

class _CartCheckOutScreenState extends State<CartCheckOutScreen> {
   late CartController controller;

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
      controller = Get.put(CartController(), permanent: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 6), () {
        _refreshCartData();
      });
      });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        _refreshCartData();
      });
    });
  }
  void _refreshCartData() {
    print('DEBUG: Refreshing cart data...');
    controller.forceRefreshCart();
    if (controller.selectedAddress.value == null) {
      // Trigger address initialization by calling the public method
      controller.initializeAddress();
    }
    // Ensure payment method is set correctly based on order total
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.checkAndUpdatePaymentMethod();
    });
  }

  // Get theme colors based on cart theme
  CartThemeColors _getThemeColors(CartTheme theme) {
    switch (theme) {
      case CartTheme.mart:
        return CartThemeColors(
          primary: MartTheme.jippyMartButton,
          primaryDark: const Color(0xFF005A52),
          accent: const Color(0xFF00A896),
          surface: Colors.white,
          onSurface: Colors.black87,
        );
      case CartTheme.food:
        return CartThemeColors(
          primary: const Color(0xFFFF6B35),
          primaryDark: const Color(0xFFE55A2B),
          accent: const Color(0xFFFF8A65),
          surface: AppThemeData.surface,
          onSurface: Colors.black87,
        );
      case CartTheme.mixed:
        return CartThemeColors(
          primary: const Color(0xFFFF6B35),
          primaryDark: const Color(0xFFE55A2B),
          accent: const Color(0xFFFF8A65),
          surface: AppThemeData.surface,
          onSurface: Colors.black87,
        );
    }
  }

  // Determine cart theme based on source and content
  CartTheme _getCartTheme() {
    // If source is explicitly provided, use it
    if (widget.source != null) {
      if (widget.source == 'mart') {
        return CartTheme.mart;
      } else if (widget.source == 'food') {
        return CartTheme.food;
      }
    }

    // Auto-detect based on cart content
    bool hasMartItems = cartItem.any((item) =>
    item.vendorID?.contains('mart') == true ||
        item.vendorID?.startsWith('demo_') == true ||
        item.vendorID?.contains('vendor') == true);

    bool hasFoodItems = cartItem.any((item) =>
    !(item.vendorID?.contains('mart') == true ||
        item.vendorID?.startsWith('demo_') == true ||
        item.vendorID?.contains('vendor') == true));

    if (hasMartItems && !hasFoodItems) {
      return CartTheme.mart;
    } else if (hasFoodItems && !hasMartItems) {
      return CartTheme.food;
    } else {
      return CartTheme.mixed; // Both food and mart items
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final cartTheme = _getCartTheme();
    final themeColors = _getThemeColors(cartTheme);
    return  GetX<CartController>(builder: (controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.checkAndUpdatePaymentMethod();
      });
      return WillPopScope(
        onWillPop: () async {
          if (controller.isGlobalLocked.value) {
            ShowToastDialog.showToast("Please wait, payment is processing...");
            return false; // prevent back navigation
          }
          return true;
        },
        child: Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : themeColors.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : themeColors.primary,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: !widget.hideBackButton,
              centerTitle: true,
              title: Text(
              'Cart',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                // Debug buttons removed - methods not available in current version
              ],
            ),
            body:cartItem.isEmpty? Center(
              child: Text(
                    "No Available Items",
                textAlign:
                TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData
                      .semiBold,
                  color: themeChange
                      .getThem()
                      ? AppThemeData
                      .primary300
                      : AppThemeData
                      .primary300,
                  fontSize: 16,
                ),
              ),
            ): Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConst.backgroundImage,
                  ),
                  fit: BoxFit.cover, // can use contain, fill, repeat
                ),
              ),
              child: Column(
                children: [
                  cartProductDetailsImageWidget(
                    themeChange,
                    controller,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : SafeArea(
                  child: Container(
                                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20), topRight: Radius.circular(20),),),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: RoundedButtonFill(
                    textColor: AppThemeData.surface,
                    isEnabled: true,
                    title:  "Check Out".tr,
                    height: 5,
                    color: AppThemeData.primary300,
                    fontSizes: 16,
                        // onPress: () async {
                        //   await Get.to(() => const CartScreen())?.then((_) {
                        //     _refreshCartData();
                        //   });
                        // }
                      onPress: () async {
                      Get.to(() => const CartScreen());
                      }
                            ),
                  ),
                ),),
      );
    });
  }
}
