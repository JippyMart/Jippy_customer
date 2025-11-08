import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/cart_check_out_page/cart_check_out_screen.dart';
import 'package:customer/app/favourite_screens/controller/favourite_controller.dart';
import 'package:customer/app/favourite_screens/favourite_screen.dart';
import 'package:customer/app/home_screen/home_screen.dart';
import 'package:customer/app/home_screen/home_screen_two.dart';
import 'package:customer/app/order_list_screen/order_screen.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/order_controller.dart';
import 'package:customer/utils/app_lifecycle_logger.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {


  // RxList<Widget?> pageList = <Widget?>[].obs;
  //
  // void _updatePageList() {
  //   final bool walletEnabled = Constant.walletSetting ?? false;
  //
  //   pageList.value = walletEnabled
  //       ? [null, null, null, null, null]
  //       : [null, null, null, null];
  // }

  void changeNavbar(int index){
        selectedIndex.value = index;
        print(" changenavbar $index");
  }
  RxBool isCartScreenInitialized = false.obs;
  RxInt selectedIndex = 0.obs;
  RxList<Widget> pageList = <Widget>[].obs;
  RxString currentTheme = "theme_1".obs;
  RxBool isThemeLoading = false.obs;
  RxString themeError = "".obs;
  StreamSubscription<DocumentSnapshot>? _themeSubscription;
  Worker? _themeListener;
  final Map<String, List<Widget>> _pageCache = {};
  // Error recovery variables
  int _retryCount = 0;
  final int _maxRetries = 5;
  @override
  void onInit() {
    getTaxList();
    loadUserData();
    currentTheme.value = Constant.theme;
    _updatePageList();
    _setupThemeListener();
    // ✅ Theme change listener
    _themeListener = ever(currentTheme, (_) {
      print('[DEBUG] Theme changed to: ${currentTheme.value}');
      _updatePageList();
    });

    // ✅ Listen for tab change
    ever<int>(selectedIndex, (index) {
      print('[DEBUG] Tab changed to index: $index');
      _handleTabChange(index);
    });

    super.onInit();
  }

  // @override
  // void onInit() {
  //   getTaxList();
  //   loadUserData();
  //   // Initialize theme and page list
  //   currentTheme.value = Constant.theme;
  //   _updatePageList();
  //
  //   // Set up Firestore listener
  //   _setupThemeListener();
  //
  //   // Listen to local theme changes with proper disposal
  //   _themeListener = ever(currentTheme, (_) {
  //     print('[DEBUG] Theme changed to: ${currentTheme.value}');
  //     _updatePageList();
  //   });
  //
  //   super.onInit();
  // }
  void _handleTabChange(int index) {
    // Assuming your page order: [Home, Favourite, Wallet?, Order, Profile]
    // So OrderScreen index might be 3 if wallet enabled, or 2 if wallet disabled.

    final bool walletEnabled = Constant.walletSetting ?? false;
    final int orderTabIndex = walletEnabled ? 3 : 2;

    if (index == orderTabIndex) {
      print('[DASHBOARD] Order tab opened — refreshing orders...');
      try {
        final orderController = Get.find<OrderController>();
        orderController.getOrder(); // ✅ Fetch orders automatically
      } catch (e) {
        print('[DASHBOARD] Could not refresh orders: $e');
      }
    }
  }

  void _setupThemeListener() {
    try {
      print('[DEBUG] Setting up theme listener...');
      _themeSubscription = FirebaseFirestore.instance
          .collection('settings')
          .doc('home_page_theme')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final newTheme = snapshot.data()!['theme'] as String? ?? 'theme_1';
          if (newTheme != currentTheme.value) {
            print('[DEBUG] Firestore theme update: $newTheme');
            currentTheme.value = newTheme;
            Constant.theme = newTheme;
            themeError.value = ""; // Clear any previous errors
            _retryCount = 0; // Reset retry count on success
          }
        }
      }, onError: (error) {
        print('[ERROR] Theme listener error: $error');
        themeError.value = "Failed to listen to theme changes: $error";
        _handleThemeError();
      });
      print('[DEBUG] Theme listener set up successfully');
    } catch (e) {
      print('[ERROR] Setting up theme listener: $e');
      themeError.value = "Failed to set up theme listener: $e";
      _handleThemeError();
    }
  }

  void _handleThemeError() {
    if (_retryCount < _maxRetries) {
      print('[DEBUG] Theme error occurred, will retry...');
      retryThemeSetup();
    } else {
      print('[ERROR] Max retries reached for theme setup');
      themeError.value =
          "Failed to load theme after $_maxRetries attempts. Please check your connection.";
    }
  }

  void _updatePageList() {
    print('[DEBUG] Updating page list for theme: ${currentTheme.value}');

    // Use null-safe wallet setting
    final bool walletEnabled = Constant.walletSetting ?? false;
    final cacheKey = '${currentTheme.value}_$walletEnabled';

    // Check cache first
    if (_pageCache.containsKey(cacheKey)) {
      print('[DEBUG] Using cached page list for key: $cacheKey');
      pageList.value = _pageCache[cacheKey]!;
      update();
      return;
    }

    // Create new page list
    final List<Widget> newPages;

    if (currentTheme.value == "theme_2") {
      newPages = walletEnabled
          ? [
              const HomeScreen(),
              const FavouriteScreen(),
              const WalletScreen(),
        const CartCheckOutScreen(),
              const OrderScreen(),
            ]
          : [
              const HomeScreen(),
              const FavouriteScreen(),
        const CartCheckOutScreen(),

              const OrderScreen(),
            ];
    } else {
      newPages = walletEnabled
          ? [
              const HomeScreenTwo(),
              const FavouriteScreen(),
              const WalletScreen(),
        const CartCheckOutScreen(),

              const OrderScreen(),
            ]
          : [
              const HomeScreenTwo(),
              const FavouriteScreen(),
        const CartCheckOutScreen(),

              const OrderScreen(),
            ];
    }

    // Cache the new page list
    _pageCache[cacheKey] = newPages;
    print('[DEBUG] Created and cached new page list for key: $cacheKey');

    pageList.value = newPages;
    update();
  }

  // Method to update theme from external changes (called by Firestore listener)
  void updateTheme(String newTheme) {
    if (currentTheme.value != newTheme) {
      print('[DEBUG] External theme update: $newTheme');
      currentTheme.value = newTheme;
      Constant.theme = newTheme;
    }
  }

  // Manual refresh method for theme
  Future<void> refreshTheme() async {
    try {
      isThemeLoading.value = true;
      themeError.value = "";

      print('[DEBUG] Manually refreshing theme...');
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('home_page_theme')
          .get();

      if (doc.exists && doc.data() != null) {
        final newTheme = doc.data()!['theme'] as String? ?? 'theme_1';
        if (newTheme != currentTheme.value) {
          print('[DEBUG] Manual theme refresh: $newTheme');
          currentTheme.value = newTheme;
          Constant.theme = newTheme;
        } else {
          print('[DEBUG] Theme is already up to date: $newTheme');
        }
      } else {
        print('[DEBUG] Theme document not found, using default');
        currentTheme.value = 'theme_1';
        Constant.theme = 'theme_1';
      }
    } catch (e) {
      print('[ERROR] Refreshing theme: $e');
      themeError.value = "Failed to refresh theme: $e";
    } finally {
      isThemeLoading.value = false;
    }
  }

  // Manual test method for theme switching (for debugging)
  void testThemeSwitch() {
    String newTheme = currentTheme.value == "theme_1" ? "theme_2" : "theme_1";
    print(
        '[DEBUG] Manual theme switch test: ${currentTheme.value} -> $newTheme');
    updateTheme(newTheme);
  }

  // Enhanced retry mechanism with exponential backoff
  Future<void> retryThemeSetup() async {
    if (_retryCount >= _maxRetries) {
      print('[ERROR] Max retries reached for theme setup');
      themeError.value =
          "Failed to load theme after $_maxRetries attempts. Please check your connection.";
      _retryCount = 0;
      return;
    }

    _retryCount++;
    final delay = Duration(seconds: pow(2, _retryCount).toInt());
    print(
        '[DEBUG] Retry $_retryCount/$_maxRetries - Next retry in ${delay.inSeconds}s');

    _themeSubscription?.cancel();
    await Future.delayed(delay);
    _setupThemeListener();
  }

  // Clear cache method for memory management
  void clearPageCache() {
    print('[DEBUG] Clearing page cache...');
    _pageCache.clear();
  }

  // Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _pageCache.length,
      'cacheKeys': _pageCache.keys.toList(),
      'retryCount': _retryCount,
      'maxRetries': _maxRetries,
    };
  }

  getTaxList() async {
    try {
      await FireStoreUtils.getTaxList().then(
        (value) {
          if (value != null) {
            Constant.taxList = value;
            print('[DASHBOARD] Tax list loaded: ${value.length} items');
          } else {
            print('[DASHBOARD] Tax list is null');
          }
        },
      );
    } catch (e) {
      print('[DASHBOARD] Error loading tax list: $e');
      // Set empty list to prevent null issues
      Constant.taxList = [];
    }
  }

  Future<void> loadUserData() async {
    try {
      // Load user data if not already loaded
      if (Constant.userModel == null) {
        final userModel =
            await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
        if (userModel != null) {
          Constant.userModel = userModel;
          print(' [DASHBOARD] User model loaded: ${userModel.toJson()}');
          update();
          Get.find<FavouriteController>().refreshDataAfterUserLoaded();
          Get.find<OrderController>().refreshDataAfterUserLoaded();
          await AppLifecycleLogger().logUserProfileLoaded();
        } else {
          print('[DASHBOARD] Failed to load user model');
        }
      } else {
        print(
            '[DASHBOARD] User model already exists: ${Constant.userModel?.toJson()}');
      }

      // Check if user has shipping addresses after loading user data
      await _checkUserShippingAddresses();
    } catch (e) {
      print('[DASHBOARD] Error loading user data: $e');
    }
  }

  /// Check if user has shipping addresses and show alert if none
  Future<void> _checkUserShippingAddresses() async {
    try {
      // Wait longer for the home page to fully load
      print('[DASHBOARD] Waiting for home page to fully load...');
      await Future.delayed(const Duration(milliseconds: 10000));

      // Additional check to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if screen is ready
      if (!_isScreenReady()) {
        print('[DASHBOARD] Screen not ready, retrying in 2 seconds...');
        Future.delayed(const Duration(seconds: 2), () {
          _checkUserShippingAddresses();
        });
        return;
      }

      if (Constant.userModel != null) {
        final hasAddresses = Constant.userModel!.shippingAddress != null &&
            Constant.userModel!.shippingAddress!.isNotEmpty;

        print('[DASHBOARD] Address check - Has addresses: $hasAddresses');
        print(
            '[DASHBOARD] Address check - Shipping addresses: ${Constant.userModel!.shippingAddress}');

        if (!hasAddresses) {
          print(
              '[DASHBOARD] User has no shipping addresses - showing persistent alert');
          _showAddressRequiredAlert();
        } else {
          print('[DASHBOARD] User has addresses - no alert needed');
        }
      } else {
        print('[DASHBOARD] User model is null - cannot check addresses');
      }
    } catch (e) {
      print('[DASHBOARD] Error checking shipping addresses: $e');
    }
  }

  /// Check if the screen is ready to show dialogs
  bool _isScreenReady() {
    try {
      // Check if we have a valid context
      if (Get.context == null) {
        print('[DASHBOARD] No context available');
        return false;
      }

      // Check if there's already a dialog showing
      if (Get.isDialogOpen == true) {
        print('[DASHBOARD] Dialog already open');
        return false;
      }

      // Check if we're in a valid route
      if (Get.currentRoute.isEmpty) {
        print('[DASHBOARD] No current route');
        return false;
      }

      print('[DASHBOARD] Screen is ready');
      return true;
    } catch (e) {
      print('[DASHBOARD] Error checking screen readiness: $e');
      return false;
    }
  }

  /// Show elegant persistent alert dialog for users without addresses
  void _showAddressRequiredAlert() {
    // Prevent multiple dialogs from showing
    if (Get.isDialogOpen == true) {
      print('[DASHBOARD] Dialog already showing, skipping...');
      return;
    }

    print('[DASHBOARD] Showing elegant persistent address required dialog...');

    // Add safety check for context
    try {
      // Ensure we have a valid context
      if (Get.context == null) {
        print('[DASHBOARD] No context available, retrying in 2 seconds...');
        Future.delayed(const Duration(seconds: 2), () {
          _showAddressRequiredAlert();
        });
        return;
      }

      Get.dialog(
        WillPopScope(
          onWillPop: () async =>
              false, // Prevent back button from closing dialog
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 20,
            insetPadding:
                const EdgeInsets.all(16), // Add padding for small screens
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400, // Limit max width for tablets
                maxHeight: MediaQuery.of(Get.context!).size.height *
                    0.8, // Responsive height
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF8F0),
                    Color(0xFFFFF0E6),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with animated icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Animated location icon with glow effect
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF6B35),
                                  Color(0xFFFF8C42),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF6B35).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title with elegant typography
                          const Text(
                            '📍 Address Required',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle
                          Text(
                            'Complete your profile to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Main message with icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B35)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart_rounded,
                                        color: Color(0xFFFF6B35),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'To place orders and enjoy our services, you need to add a delivery address.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2D3436),
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Warning box with elegant design
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFF6B35).withOpacity(0.1),
                                  const Color(0xFFFF8C42).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.info_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'This popup will remain until you add an address to ensure you can receive your orders.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2D3436),
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action button with elegant design
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B35),
                              Color(0xFFFF8C42),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Close dialog
                            // Show address input modal directly
                            _showAddAddressModal();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_location_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add Address',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false, // User cannot dismiss by tapping outside
      ).catchError((error) {
        print('[DASHBOARD] Error showing dialog: $error');
        // Fallback to simple dialog if elegant one fails
        _showFallbackAddressAlert();
      });
    } catch (e) {
      print('[DASHBOARD] Error in _showAddressRequiredAlert: $e');
      // Fallback to simple dialog
      _showFallbackAddressAlert();
    }
  }

  /// Fallback simple alert dialog for compatibility
  void _showFallbackAddressAlert() {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Address Required'),
          content:
              const Text('You need to add a delivery address to place orders.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.snackbar(
                  'Address Required',
                  'You must add an address to continue.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.to(() => const AddressListScreen());
              },
              child: const Text('Add Address'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      print('[DASHBOARD] Even fallback dialog failed: $e');
      // Last resort - just show a snackbar
      Get.snackbar(
        'Address Required',
        'Please add a delivery address to continue using the app.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Show add address modal directly using existing functionality
  void _showAddAddressModal() {
    try {
      // Use the existing add address modal from AddressListScreen
      AddressListScreen.showAddAddressModal(Get.context!);
    } catch (e) {
      print('[DASHBOARD] Error showing add address modal: $e');
      // Fallback to navigation if modal fails
      Get.to(() => const AddressListScreen());
    }
  }

  @override
  void onClose() {
    // Cancel the Firestore subscription
    _themeSubscription?.cancel();
    _themeListener?.dispose(); // Dispose the ever listener
    print('[DEBUG] Theme subscription cancelled');
    super.onClose();
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}
