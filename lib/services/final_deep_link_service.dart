import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/mart/screens/mart_categories_screen/mart_categories_screen.dart';
import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/app/mart/screens/mart_navigation_screen/mart_navigation_screen.dart';
import 'package:customer/app/mart/screens/mart_product_details_screen/mart_product_details_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/app/dash_board_screens/controller/dash_board_controller.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/services/global_deeplink_handler.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/mart_zone_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../app/category_service/category__service_screen.dart';
import '../controllers/cart_controller.dart';

// Global flag to prevent duplicate deep link processing
bool _globalDeepLinkProcessed = false;

class FinalDeepLinkService {
  // Singleton pattern
  static final FinalDeepLinkService _instance =
      FinalDeepLinkService._internal();
  factory FinalDeepLinkService() => _instance;
  FinalDeepLinkService._internal();

  static const EventChannel _eventChannel = EventChannel('deep_link_events');
  static const MethodChannel _methodChannel =
      MethodChannel('deep_link_methods');

  StreamSubscription? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;
  String? _pendingDeepLink; // Added to store pending deep link
  bool _hasProcessedDeepLink = false; // Flag to prevent duplicate processing

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) {
      log('🔗 [FLUTTER] DeepLinkService already initialized, skipping...');
      print(
          '🔗 [FLUTTER] PRINT TEST - DeepLinkService already initialized, skipping...');
      return; // Prevent multiple subscriptions
    }

    _initialized = true;
    _navigatorKey = navigatorKey;
    log('🚀 [FLUTTER] DeepLinkService INIT started - Singleton pattern');
    print(
        '🚀 [FLUTTER] PRINT TEST - DeepLinkService INIT started - Singleton pattern');
    log('🔗 [FLUTTER] Navigator key set: ✅');
    print('🔗 [FLUTTER] PRINT TEST - Navigator key set: ✅');

    // 1) Listen to event stream (real-time links) - persistent subscription
    log('🔗 [FLUTTER] Setting up persistent event channel listener...');
    print('🔗 [FLUTTER] PRINT TEST - Setting up event channel listener...');
    _sub = _eventChannel.receiveBroadcastStream().listen((dynamic link) {
      if (link != null) {
        final String url = link as String;
        log('🔗 [FLUTTER] Received link from Android (event): $url');
        print(
            '🔗 [FLUTTER] PRINT TEST - Received link from Android (event): $url');
        _handleLink(url);
      }
    }, onError: (error) {
      log('❌ [FLUTTER] Deep link stream error: $error');
      print('❌ [FLUTTER] PRINT TEST - Deep link stream error: $error');
    });

    // 2) Also query initial link (fallback if stream did not get cold-start link)
    log('🔗 [FLUTTER] Querying initial link...');
    await _getInitialLink();

    log('🔗 [FINAL DEEP LINK SERVICE] ✅ Singleton initialized successfully');
  }

  Future<void> _getInitialLink() async {
    try {
      log('🔗 [FINAL DEEP LINK SERVICE] Calling getInitialLink method...');
      print('🔗 [FLUTTER] PRINT TEST - Calling getInitialLink method...');
      final String? initial =
          await _methodChannel.invokeMethod<String>('getInitialLink');
      if (initial != null) {
        log('🔗 [FLUTTER] Initial link from Android: $initial');
        print('🔗 [FLUTTER] PRINT TEST - Initial link from Android: $initial');
        _handleLink(initial);
      } else {
        log('🔗 [FLUTTER] No initial deep link');
        print('🔗 [FLUTTER] PRINT TEST - No initial deep link');
      }
    } on PlatformException catch (e) {
      log('❌ [FLUTTER] getInitialLink failed: $e');
      print('❌ [FLUTTER] PRINT TEST - getInitialLink failed: $e');
    }
  }

//changed here true
  void _handleLink(String url) async {
    print('🔥🔥🔥 [FLUTTER] _handleLink() called with URL: $url');
    print('🔥🔥🔥 [FLUTTER] ===== DEEP LINK RECEIVED =====');
    print('🔥🔥🔥 [FLUTTER] URL: $url');
    print('🔥🔥🔥 [FLUTTER] Timestamp: ${DateTime.now()}');

    // Reset the processing flags for new deep links
    _hasProcessedDeepLink = false;
    _globalDeepLinkProcessed = false;
    print('🔥🔥🔥 [FLUTTER] Reset processing flags for new deep link: $url');

    // Check if we've already processed a deep link to prevent duplicates
    if (_hasProcessedDeepLink) {
      print(
          '🔥🔥🔥 [FLUTTER] Deep link already processed, ignoring duplicate: $url');
      return;
    }

    // Mark as processed immediately to prevent duplicate calls
    _hasProcessedDeepLink = true;

    // Store the deep link for processing when user is logged in
    print(
        '🔥🔥🔥 [FLUTTER] Storing deep link for processing after login: $url');
    _pendingDeepLink = url;
    print(
        '🔥🔥🔥 [FLUTTER] Deep link stored successfully. _pendingDeepLink: $_pendingDeepLink');

    // Check if user is already logged in
    final isLoggedIn = await _checkUserLoginStatus();

    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty && pathSegments[0] == 'catering') {
      await Future.delayed(Duration(seconds: 2));
      print('🔗 [GLOBAL_DEEPLINK] Catering link clicked, navigating...');
      _navigateToCatering();
    }
    // if (pathSegments.isNotEmpty && pathSegments[0] == 'catering') {
    //   print('🔗 [GLOBAL_DEEPLINK] Catering link clicked, navigating...');
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _navigateToCatering();
    //   });
    // }

    if (isLoggedIn) {
      print(
          '🔥🔥🔥 [FLUTTER] User is logged in, processing deep link immediately');

      // **FIXED: Call GlobalDeeplinkHandler.storeDeeplink() to process the deep link**
      print(
          '🔥🔥🔥 [FLUTTER] Calling GlobalDeeplinkHandler.storeDeeplink() with URL: $url');

      // **SIMPLE TEST: Direct call to GlobalDeeplinkHandler**
      try {
        print(
            '🔥🔥🔥 [FLUTTER] TEST: About to call GlobalDeeplinkHandler.storeDeeplink()');
        GlobalDeeplinkHandler.instance.storeDeeplink(url);
        print(
            '🔥🔥🔥 [FLUTTER] TEST: ✅ Successfully called GlobalDeeplinkHandler.storeDeeplink()');
      } catch (e) {
        print(
            '🔥🔥🔥 [FLUTTER] TEST: ❌ Error calling GlobalDeeplinkHandler.storeDeeplink(): $e');
      }

      _newSimpleDeepLinkHandler(url);
    } else {
      print(
          '🔥🔥🔥 [FLUTTER] User not logged in, deep link will be processed after login');
    }
  }

  /// Check if user is logged in
  Future<bool> _checkUserLoginStatus() async {
    try {
      // Check if user is authenticated by checking Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      print('🔍 [FLUTTER] User login status: $isLoggedIn (UID: ${user?.uid})');
      return isLoggedIn;
    } catch (e) {
      print('❌ [FLUTTER] Error checking login status: $e');
      return false;
    }
  }

  /// Process pending deep link after user login
  void processPendingDeepLinkAfterLogin() {
    print('🔥🔥🔥 [FLUTTER] processPendingDeepLinkAfterLogin() called');
    print('🔥🔥🔥 [FLUTTER] _pendingDeepLink: $_pendingDeepLink');
    print(
        '🔥🔥🔥 [FLUTTER] _pendingDeepLink != null: ${_pendingDeepLink != null}');
    print(
        '🔥🔥🔥 [FLUTTER] _pendingDeepLink!.isNotEmpty: ${_pendingDeepLink?.isNotEmpty ?? false}');

    if (_pendingDeepLink != null && _pendingDeepLink!.isNotEmpty) {
      print(
          '🔥🔥🔥 [FLUTTER] Processing pending deep link after login: $_pendingDeepLink');

      // **FIXED: Call GlobalDeeplinkHandler.storeDeeplink() to process the pending deep link**
      print(
          '🔥🔥🔥 [FLUTTER] Calling GlobalDeeplinkHandler.storeDeeplink() with pending URL: $_pendingDeepLink');
      GlobalDeeplinkHandler.instance.storeDeeplink(_pendingDeepLink!);

      _newSimpleDeepLinkHandler(_pendingDeepLink!);
      _pendingDeepLink = null; // Clear after processing
    } else {
      print('🔥🔥🔥 [FLUTTER] No pending deep link to process');
    }
  }

  // Navigation helper methods
  void _navigateToProduct(String productId) async {
    try {
      log('🔍 [FLUTTER] Loading product details for: $productId');
      print(
          '🔍 [FLUTTER] PRINT TEST - Loading product details for: $productId');

      // Add a small delay to ensure app is fully loaded
      await Future.delayed(Duration(milliseconds: 500));
      print('🔍 [FLUTTER] DEBUG - Delay completed, proceeding with navigation');

      // Check if MartController is available
      if (!Get.isRegistered<MartController>()) {
        log('⚠️ [FLUTTER] MartController not available, navigating to mart home');
        print(
            '⚠️ [FLUTTER] PRINT TEST - MartController not available, navigating to mart home');
        _navigateToMartHome();
        return;
      }

      // Get MartController instance
      final martController = Get.find<MartController>();

      // Ensure CartController is available for product details screen
      if (!Get.isRegistered<CartController>()) {
        log('⚠️ [FLUTTER] CartController not available, initializing...');
        print(
            '⚠️ [FLUTTER] PRINT TEST - CartController not available, initializing...');
        Get.put(CartController(), permanent: true);
      }

      // Load product details
      final product = await martController.getProductById(productId);

      if (product != null) {
        log('✅ [FLUTTER] Product found: ${product.name}');
        print('✅ [FLUTTER] PRINT TEST - Product found: ${product.name}');

        // Navigate to product details screen using GlobalDeeplinkHandler navigator key
        print(
            '🔍 [FLUTTER] DEBUG - Navigator key state: ${GlobalDeeplinkHandler.navigatorKey.currentState}');
        print(
            '🔍 [FLUTTER] DEBUG - Navigator key mounted: ${GlobalDeeplinkHandler.navigatorKey.currentState?.mounted}');

        // Use GetX navigation instead of navigator key
        print(
            '🔍 [FLUTTER] DEBUG - Using GetX navigation to product details...');
        try {
          Get.to(() => MartProductDetailsScreen(product: product));
          log('🎯 [FLUTTER] Successfully navigated to product details using GetX');
          print(
              '🎯 [FLUTTER] PRINT TEST - Successfully navigated to product details using GetX');
        } catch (e) {
          print('❌ [FLUTTER] DEBUG - GetX navigation failed: $e');
          // Fallback: try with navigator key after delay
          Future.delayed(Duration(seconds: 2), () {
            if (GlobalDeeplinkHandler.navigatorKey.currentState != null) {
              print(
                  '🔍 [FLUTTER] DEBUG - Fallback: Navigator key available, attempting navigation...');
              GlobalDeeplinkHandler.navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) =>
                      MartProductDetailsScreen(product: product),
                ),
              );
              print(
                  '✅ [FLUTTER] PRINT TEST - Successfully navigated to product details (fallback)');
            } else {
              print(
                  '❌ [FLUTTER] DEBUG - Fallback failed: Navigator state still null');
            }
          });
        }
      } else {
        log('❌ [FLUTTER] Product not found: $productId');
        print('❌ [FLUTTER] PRINT TEST - Product not found: $productId');
        _navigateToMartHome();
      }
    } catch (e) {
      log('❌ [FLUTTER] Error loading product: $e');
      print('❌ [FLUTTER] PRINT TEST - Error loading product: $e');
      _navigateToMartHome();
    }
  }

  /// **NEW: Navigate to restaurant with actual data**
  void _navigateToRestaurantWithData(String restaurantId) async {
    try {
      print('🔥 [NEW HANDLER] ===== RESTAURANT DEEP LINK NAVIGATION =====');
      print('🔥 [NEW HANDLER] Restaurant ID: $restaurantId');

      // Import FireStoreUtils for fetching restaurant data
      final restaurant = await FireStoreUtils.getVendorById(restaurantId);

      if (restaurant != null) {
        print('🔥 [NEW HANDLER] ✅ Restaurant found: ${restaurant.title}');
        print('🔥 [NEW HANDLER] Restaurant ID: ${restaurant.id}');
        print(
            '🔥 [NEW HANDLER] Restaurant Status: ${restaurant.isOpen == true ? "OPEN" : "CLOSED"}');

        // Wait briefly for app to be ready
        print('🔥 [NEW HANDLER] Waiting briefly for app to be ready...');
        await Future.delayed(Duration(milliseconds: 500));

        // Navigate to restaurant details with actual data
        print('🔥 [NEW HANDLER] Navigating to restaurant details with data...');
        // Use GetX navigation with restaurant data
        Get.to(() => const RestaurantDetailsScreen(), arguments: {
          'vendorModel': restaurant,
        });
        print(
            '🔥✅ [NEW HANDLER] Successfully navigated to restaurant details with data!');
      } else {
        print('❌ [NEW HANDLER] Restaurant not found: $restaurantId');
        print('🔍 [NEW HANDLER] This could mean:');
        print('🔍 [NEW HANDLER] 1. Restaurant ID is incorrect');
        print('🔍 [NEW HANDLER] 2. Restaurant doesn\'t exist in database');
        print('🔍 [NEW HANDLER] 3. Restaurant is not published/available');
        print('🔍 [NEW HANDLER] Redirecting to dashboard...');

        // Navigate to dashboard instead of showing nothing
        _navigateToDashboard();
      }
    } catch (e) {
      print('❌ [NEW HANDLER] Error navigating to restaurant: $e');
      print('🔍 [NEW HANDLER] Redirecting to dashboard due to error...');

      // Navigate to dashboard on error
      _navigateToDashboard();
    }
  }

  /// **NEW: Navigate to category with actual data**
  void _navigateToCategoryWithData(String categoryId) async {
    try {
      print('🔥 [NEW HANDLER] ===== CATEGORY DEEP LINK NAVIGATION =====');
      print('🔥 [NEW HANDLER] Category ID: $categoryId');

      // **FIXED: Fetch actual category name from Firestore**
      print('🔥 [NEW HANDLER] 🔍 Fetching category data for ID: $categoryId');

      // Use direct Firestore query to get category by ID
      final categoryDoc = await FirebaseFirestore.instance
          .collection('mart_categories')
          .doc(categoryId)
          .get();

      MartCategoryModel? category;
      if (categoryDoc.exists) {
        final data = categoryDoc.data()!;
        data['id'] = categoryDoc.id;
        category = MartCategoryModel.fromJson(data);
      }

      if (category != null) {
        print('🔥 [NEW HANDLER] ✅ Found category: ${category.title}');
        print(
            '🔥 [NEW HANDLER] Category Status: ${category.publish == true ? "PUBLISHED" : "UNPUBLISHED"}');

        // Wait briefly for app to be ready
        print('🔥 [NEW HANDLER] Waiting briefly for app to be ready...');
        await Future.delayed(Duration(milliseconds: 500));

        // Navigate to specific category detail screen with actual category name
        print(
            '🔥 [NEW HANDLER] Navigating to specific category detail screen...');
        Get.to(() => const MartCategoryDetailScreen(), arguments: {
          'categoryId': categoryId,
          'categoryName':
              category.title ?? 'Category', // Use actual category title
        });
        print(
            '🔥✅ [NEW HANDLER] Successfully navigated to specific category detail screen!');
      } else {
        print('❌ [NEW HANDLER] Category not found for ID: $categoryId');
        print('🔍 [NEW HANDLER] Redirecting to dashboard...');
        _navigateToDashboard();
      }
    } catch (e) {
      print('❌ [NEW HANDLER] Error navigating to category: $e');
      print('🔍 [NEW HANDLER] Redirecting to dashboard due to error...');

      // Navigate to dashboard on error
      _navigateToDashboard();
    }
  }

  void _navigateToCategory(String categoryPath) {
    try {
      log('🔍 [FLUTTER] Navigating to category: $categoryPath');
      print('🔍 [FLUTTER] PRINT TEST - Navigating to category: $categoryPath');

      // Navigate to mart categories screen using GlobalDeeplinkHandler navigator key
      GlobalDeeplinkHandler.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const MartCategoriesScreen(),
        ),
      );
      log('🎯 [FLUTTER] Successfully navigated to categories');
      print('🎯 [FLUTTER] PRINT TEST - Successfully navigated to categories');
    } catch (e) {
      log('❌ [FLUTTER] Error navigating to category: $e');
      print('❌ [FLUTTER] PRINT TEST - Error navigating to category: $e');
      _navigateToMartHome();
    }
  }

  void _navigateToMartHome() async {
    try {
      print(
          '\n🔗 [DEEP_LINK_SERVICE] ===== DEEP LINK MART NAVIGATION STARTED =====');
      log('🔍 [FLUTTER] Navigating to mart home via deep link');
      print('🔍 [FLUTTER] PRINT TEST - Navigating to mart home via deep link');
      print(
          '📍 [DEEP_LINK_SERVICE] Current Zone: ${Constant.selectedZone?.id ?? "NULL"} (${Constant.selectedZone?.name ?? "NULL"})');
      print(
          '📍 [DEEP_LINK_SERVICE] User Location: ${Constant.selectedLocation.location?.latitude ?? "NULL"}, ${Constant.selectedLocation.location?.longitude ?? "NULL"}');

      // Check if mart is available in current zone
      final isMartAvailable =
          await MartZoneUtils.isMartAvailableInCurrentZone();

      if (isMartAvailable) {
        print(
            '✅ [DEEP_LINK_SERVICE] Mart is available - Navigating to MartNavigationScreen');
        print(
            '🎯 [DEEP_LINK_SERVICE] Navigation: Deep Link -> MartNavigationScreen');
        // Navigate to mart navigation screen using GlobalDeeplinkHandler navigator key
        GlobalDeeplinkHandler.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const MartNavigationScreen(),
          ),
        );
        log('🎯 [FLUTTER] Successfully navigated to mart home');
        print('🎯 [FLUTTER] PRINT TEST - Successfully navigated to mart home');
        print(
            '✅ [DEEP_LINK_SERVICE] Deep link navigation completed successfully');
      } else {
        print(
            '❌ [DEEP_LINK_SERVICE] Mart not available - Redirecting to dashboard');
        // Show coming soon message for zones without mart
        log('⚠️ [FLUTTER] Mart not available in current zone: ${Constant.selectedZone?.id}');
        print(
            '⚠️ [FLUTTER] PRINT TEST - Mart not available in current zone: ${Constant.selectedZone?.id}');
        print(
            '🎯 [DEEP_LINK_SERVICE] Navigation: Deep Link -> Dashboard (fallback)');
        _navigateToDashboard();
      }

      print(
          '🔗 [DEEP_LINK_SERVICE] ===== DEEP LINK MART NAVIGATION COMPLETED =====\n');
    } catch (e) {
      print('❌ [DEEP_LINK_SERVICE] Error navigating to mart home: $e');
      log('❌ [FLUTTER] Error navigating to mart home: $e');
      print('❌ [FLUTTER] PRINT TEST - Error navigating to mart home: $e');
      print(
          '🎯 [DEEP_LINK_SERVICE] Navigation: Deep Link -> Dashboard (error fallback)');
      _navigateToDashboard();
      print(
          '🔗 [DEEP_LINK_SERVICE] ===== DEEP LINK MART NAVIGATION COMPLETED (ERROR) =====\n');
    }
  }

  void _navigateToDashboard() {
    try {
      log('🔍 [FLUTTER] Navigating to dashboard');
      print('🔍 [FLUTTER] PRINT TEST - Navigating to dashboard');

      // Navigate to dashboard screen using GlobalDeeplinkHandler navigator key
      GlobalDeeplinkHandler.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const DashBoardScreen(),
        ),
      );
      log('🎯 [FLUTTER] Successfully navigated to dashboard');
      print('🎯 [FLUTTER] PRINT TEST - Successfully navigated to dashboard');
    } catch (e) {
      log('❌ [FLUTTER] Error navigating to dashboard: $e');
      print('❌ [FLUTTER] PRINT TEST - Error navigating to dashboard: $e');
    }
  }

  void _navigateToCateringService() {
    try {
      GlobalDeeplinkHandler.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => CateringServiceScreen(),
        ),
      );
      log('❌ [FLUTTER] Error navigating to categoriesservice : ');
    } catch (e) {
      log('❌ [FLUTTER] Error navigating to dashboard: $e');
      print('❌ [FLUTTER] PRINT TEST - Error navigating to dashboard: $e');
    }
  }

  void dispose() {
    log('🔗 [FINAL DEEP LINK SERVICE] Disposing...');
    _sub?.cancel();
    _sub = null;
    _initialized = false;
    _pendingDeepLink = null;
    _hasProcessedDeepLink = false;
  }

  void clearLastProcessedLink() {
    _pendingDeepLink = null;
    _hasProcessedDeepLink = false;
    _globalDeepLinkProcessed = false;
    print('🔥🔥🔥 [FLUTTER] Cleared all deep link processing flags');
  }

  /// Force reset all deep link processing flags (for new deep links)
  void resetForNewDeepLink() {
    _hasProcessedDeepLink = false;
    _globalDeepLinkProcessed = false;
    _pendingDeepLink = null;
    print('🔥🔥🔥 [FLUTTER] Reset all flags for new deep link processing');
  }

  void _waitForNavigator() {
    // Check every 100ms if Navigator is available
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (GlobalDeeplinkHandler.navigatorKey.currentState != null) {
        timer.cancel();
        print(
            '🔗 [FLUTTER] Navigator is now available, processing pending deep link...');
        _processPendingDeepLink();
      }
    });
  }

  void _processPendingDeepLink() {
    if (_pendingDeepLink == null) {
      print('🔗 [FLUTTER] No pending deep link to process');
      return;
    }

    if (_hasProcessedDeepLink) {
      print(
          '🔗 [FLUTTER] Deep link already processed — skipping duplicate processing');
      _pendingDeepLink = null; // Clear the pending link
      return;
    }

    final url = _pendingDeepLink!;
    print('🔗 [FLUTTER] Processing pending deep link: $url');

    // Use the new safe navigation approach
    _tryProcessLink(url);
  }

  void _tryProcessLink(String url) {
    // Make sure we only navigate once
    if (_hasProcessedDeepLink) {
      print('🔗 [FLUTTER] Deep link already processed, ignoring');
      return;
    }

    DashBoardController? dashboardController;
    try {
      dashboardController = Get.find<DashBoardController>();
      print('✅ [FLUTTER] DashboardController found and ready');
    } catch (e) {
      print(
          '⏳ [FLUTTER] DashboardController not ready yet, retrying in 500ms...');
      Future.delayed(Duration(milliseconds: 500), () => _tryProcessLink(url));
      return;
    }

    // Check if dashboard is ready (you can add your own ready check here)
    print(
        '🔗 [FLUTTER] Dashboard controller found, proceeding with navigation...');

    _hasProcessedDeepLink = true; // Mark as processed to prevent duplicates
    _pendingDeepLink = null; // Clear the pending link

    // Extract product ID and navigate
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty && pathSegments[0] == 'product') {
      final productId = pathSegments.length > 1 ? pathSegments[1] : null;
      if (productId != null) {
        _simpleNavigateToProduct(productId);
      }
    }
  }

  void _simpleNavigateToProduct(String productId) async {
    print('🔍 [FLUTTER] Starting SIMPLE navigation for product: $productId');

    // Wait 5 seconds to ensure everything is ready
    print(
        '🔍 [FLUTTER] DEBUG - Waiting 5 seconds for everything to be ready...');
    await Future.delayed(Duration(seconds: 5));

    print('🔍 [FLUTTER] DEBUG - Attempting SIMPLE navigation...');

    // Use the simplest possible navigation - NO GetX dependencies
    try {
      if (GlobalDeeplinkHandler.navigatorKey.currentState != null) {
        print(
            '🔍 [FLUTTER] DEBUG - Navigator available, pushing SIMPLE route...');

        // Navigate to the simplest possible screen
        GlobalDeeplinkHandler.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Deep Link Success!'),
                backgroundColor: Colors.green,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 100, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      'DEEP LINK WORKING! ✅',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Product ID: $productId',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Product ID: $productId',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Navigation successful! 🎉',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        print(
            '✅ [FLUTTER] PRINT TEST - Successfully navigated to SIMPLE product screen');
      } else {
        print('❌ [FLUTTER] PRINT TEST - Navigator key is null');
      }
    } catch (e) {
      print('❌ [FLUTTER] Error in SIMPLE navigation: $e');
    }
  }

  void _newSimpleDeepLinkHandler(String url) async {
    print('🔥 [NEW HANDLER] NEW SIMPLE Deep Link Handler started for: $url');

    // Wait for Navigator to be available
    int attempts = 0;
    while (GlobalDeeplinkHandler.navigatorKey.currentState == null &&
        attempts < 100) {
      print('🔥 [NEW HANDLER] Waiting for Navigator... attempt $attempts');
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
    }

    if (GlobalDeeplinkHandler.navigatorKey.currentState == null) {
      print('❌ [NEW HANDLER] Navigator not available after 10 seconds');
      return;
    }

    // Wait additional 10 seconds for app to be fully ready
    print(
        '🔥 [NEW HANDLER] Navigator ready, waiting 10 seconds for app to load...');
    await Future.delayed(Duration(seconds: 5));

    // Extract product ID from URL
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    String? productId;

    print('🔥 [NEW HANDLER] ===== DEEP LINK URL PARSING =====');
    print('🔥 [NEW HANDLER] Original URL: $url');
    print('🔥 [NEW HANDLER] Parsed URI: $uri');
    print('🔥 [NEW HANDLER] URI Scheme: ${uri.scheme}');
    print('🔥 [NEW HANDLER] URI Host: ${uri.host}');
    print('🔥 [NEW HANDLER] URI Path: ${uri.path}');
    print('🔥 [NEW HANDLER] Path segments: $pathSegments');
    print('🔥 [NEW HANDLER] Path segments count: ${pathSegments.length}');
    print('🔥 categoriesservice ');

    // Handle different URL formats
    if (uri.scheme == 'jippymart') {
      // Custom scheme: jippymart://product/123 or jippymart://restaurant/123
      if (pathSegments.isNotEmpty) {
        if (pathSegments.length >= 2 && pathSegments[0] == 'product') {
          // Format: jippymart://product/123
          productId = pathSegments[1];
          print(
              '🔥 [NEW HANDLER] Custom scheme with product prefix - Product ID: $productId');
        } else if (pathSegments.length >= 2 &&
            pathSegments[0] == 'restaurant') {
          // Format: jippymart://restaurant/123
          final restaurantId = pathSegments[1];
          print(
              '🔥 [NEW HANDLER] Custom scheme with restaurant prefix - Restaurant ID: $restaurantId');
          _navigateToRestaurantWithData(restaurantId);
          return;
        }
        if (pathSegments.isNotEmpty && pathSegments[0] == 'catering') {
          // print('🔗 [GLOBAL_DEEPLINK] Catering link clicked, navigating...');
          // _navigateToCatering();
          return;
        }
        // else if (pathSegments.length >= 2 && pathSegments[0] == 'catering') {
        //   // Format: jippymart://restaurant/123
        //   final restaurantId = pathSegments[1];
        //   print(
        //       '🔥 [NEW HANDLER] Custom scheme with restaurant prefix - Restaurant ID: $restaurantId');
        //   _navigateToCateringService();
        //   return;
        // }
        else {
          // Format: jippymart://123 (direct product ID)
          productId = pathSegments[0];
          print(
              '🔥 [NEW HANDLER] Custom scheme direct - Product ID: $productId');
        }
      }
      // categories
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      // HTTPS scheme: https://jippymart.in/product/123 or https://jippymart.in/restaurant/123
      if (pathSegments.length >= 2 && pathSegments[0] == 'product') {
        productId = pathSegments[1];
        print('🔥 [NEW HANDLER] HTTPS scheme - Product ID: $productId');
      } else if (pathSegments.length >= 2 && pathSegments[0] == 'restaurant') {
        final restaurantId = pathSegments[1];
        print('🔥 [NEW HANDLER] HTTPS scheme - Restaurant ID: $restaurantId');
        _navigateToRestaurantWithData(restaurantId);
        return;
      } else if (pathSegments.length >= 2 && pathSegments[0] == 'restaurants') {
        final restaurantId = pathSegments[1];
        print(
            '🔥 [NEW HANDLER] HTTPS scheme (plural) - Restaurant ID: $restaurantId');
        _navigateToRestaurantWithData(restaurantId);
        return;
      } else if (pathSegments.length >= 2 && pathSegments[0] == 'category') {
        final categoryId = pathSegments[1];
        print('🔥 [NEW HANDLER] HTTPS scheme - Category ID: $categoryId');
        _navigateToCategoryWithData(categoryId);
        return;
      } else if (pathSegments.length >= 2 && pathSegments[0] == 'categories') {
        final categoryId = pathSegments[1];
        print('🔥 ¸ $categoryId');
        _navigateToCategoryWithData(categoryId);
        return;
      }
      if (pathSegments.isNotEmpty && pathSegments[0] == 'catering') {
        // print('🔗 [GLOBAL_DEEPLINK] Catering link clicked, navigating...');
        // _navigateToCatering();
        return;
      } else if (pathSegments.length >= 1) {
        // Direct product ID in path
        productId = pathSegments[0];
        print('🔥 [NEW HANDLER] HTTPS scheme direct - Product ID: $productId');
      }
    }

    print('🔥 [NEW HANDLER] Final extracted product ID: $productId');
    print('🔥 [NEW HANDLER] ===== END URL PARSING =====');

    if (productId != null) {
      // Navigate to the REAL product details screen with actual product data
      print(
          '🔥 [NEW HANDLER] Navigating to REAL product details screen with actual data...');
      try {
        // Get the real product data from MartController
        print('🔥 [NEW HANDLER] Fetching real product data for: $productId');

        // Try to get MartController and fetch the real product
        try {
          final martController = Get.find<MartController>();
          print('🔥 [NEW HANDLER] MartController found, fetching product...');
          print('🔥 [NEW HANDLER] Searching for product ID: $productId');

          // Ensure CartController is available for product details screen
          if (!Get.isRegistered<CartController>()) {
            print(
                '🔥 [NEW HANDLER] CartController not available, initializing for deep link...');
            Get.put(CartController(), permanent: true);
          }

          // Fetch the real product data
          print(
              '🔥 [NEW HANDLER] Calling martController.getProductById($productId)...');
          final product = await martController.getProductById(productId);

          if (product != null) {
            print('🔥 [NEW HANDLER] ✅ Real product found!');
            print('🔥 [NEW HANDLER] Product Name: ${product.name}');
            print('🔥 [NEW HANDLER] Product ID: ${product.id}');
            print('🔥 [NEW HANDLER] Product Price: ${product.currentPrice}');
            print('🔥 [NEW HANDLER] Product Available: ${product.isAvailable}');

            // Navigate to the real MartProductDetailsScreen with actual product data
            GlobalDeeplinkHandler.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) =>
                    MartProductDetailsScreen(product: product),
              ),
            );
            print(
                '🔥✅ [NEW HANDLER] Successfully navigated to REAL product details screen with actual data!');
          } else {
            print('❌ [NEW HANDLER] Product not found in database: $productId');
            print('🔍 [NEW HANDLER] This could mean:');
            print('🔍 [NEW HANDLER] 1. Product ID is incorrect');
            print('🔍 [NEW HANDLER] 2. Product doesn\'t exist in database');
            print('🔍 [NEW HANDLER] 3. Product is not published/available');
            print(
                '🔍 [NEW HANDLER] Redirecting to mart home instead of showing fallback product');

            // Navigate to mart home instead of showing a fallback product
            _navigateToMartHome();
          }
        } catch (e) {
          print('❌ [NEW HANDLER] Error getting MartController or product: $e');
          print('🔍 [NEW HANDLER] Redirecting to mart home due to error');

          // Navigate to mart home instead of showing a fallback product
          _navigateToMartHome();
        }
      } catch (e) {
        print('❌ [NEW HANDLER] Navigation error: $e');
        print(
            '🔍 [NEW HANDLER] Redirecting to mart home due to navigation error');

        // Navigate to mart home instead of showing a fallback product
        _navigateToMartHome();
      }
    } else {
      print('❌ [NEW HANDLER] No product ID found in URL');
    }
  }

  void _navigateToCatering() {
    try {
      print('🔗 [GLOBAL_DEEPLINK] Navigating to CateringServiceScreen ');
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CateringServiceScreen()))
      Get.to(() => CateringServiceScreen()); // <-- your screen widget
    } catch (e) {
      print('❌ [GLOBAL_DEEPLINK] Error navigating to catering: $e');
    }
  }

  void _navigateToProductWithGetX(String productId) async {
    print('🔍 [FLUTTER] Starting SIMPLE navigation for product: $productId');

    // Wait 20 seconds to ensure everything is ready
    print(
        '🔍 [FLUTTER] DEBUG - Waiting 20 seconds for everything to be ready...');
    await Future.delayed(Duration(seconds: 20));

    print('🔍 [FLUTTER] DEBUG - Attempting SIMPLE navigation...');

    // Use the simplest possible navigation - NO GetX dependencies
    try {
      if (GlobalDeeplinkHandler.navigatorKey.currentState != null) {
        print(
            '🔍 [FLUTTER] DEBUG - Navigator available, pushing SIMPLE route...');

        // Navigate to the simplest possible screen
        GlobalDeeplinkHandler.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Deep Link Success!'),
                backgroundColor: Colors.green,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 100, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      'DEEP LINK WORKING! ✅',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Product ID: $productId',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Product ID: $productId',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Navigation successful! 🎉',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        print(
            '✅ [FLUTTER] PRINT TEST - Successfully navigated to SIMPLE product screen');
      } else {
        print('❌ [FLUTTER] PRINT TEST - Navigator key is null');
      }
    } catch (e) {
      print('❌ [FLUTTER] Error in SIMPLE navigation: $e');
    }
  }
}
