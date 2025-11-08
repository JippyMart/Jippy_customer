import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/app/dash_board_screens/controller/dash_board_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/services/gps_location_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/performance_optimizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  DashBoardController dashBoardController = Get.find<DashBoardController>();
  final CartProvider cartProvider = CartProvider();
  final ScrollController scrollController = ScrollController();
  RxBool isNavBarVisible = true.obs;

  getCartData() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    update();
  }

  RxBool isLoading = true.obs;
  RxBool isListView = true.obs;
  RxBool isPopular = true.obs;
  RxString selectedOrderTypeValue = "Delivery".tr.obs;

  Rx<PageController> pageController = PageController(viewportFraction: 1.0).obs;
  Rx<PageController> pageBottomController =
      PageController(viewportFraction: 1.0).obs;
  RxInt currentPage = 0.obs;
  RxInt currentBottomPage = 0.obs;

  Timer? _bannerTimer;

  var selectedIndex = 0.obs;

  @override
  void onInit() {
    // Load all data in parallel for better performance
    _loadAllDataInParallel();

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection.toString() ==
          'ScrollDirection.reverse') {
        if (isNavBarVisible.value) isNavBarVisible.value = false;
      } else if (scrollController.position.userScrollDirection.toString() ==
          'ScrollDirection.forward') {
        if (!isNavBarVisible.value) isNavBarVisible.value = true;
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    startBannerTimer();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    try {
      if (pageController.value.hasClients) {
        pageController.value.dispose();
      }
      if (pageBottomController.value.hasClients) {
        pageBottomController.value.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
    }
    super.onClose();
  }

  void startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!Get.isRegistered<HomeController>() ||
          !pageController.value.hasClients) {
        timer.cancel();
        return;
      }

      if (bannerModel.isEmpty) return;

      int nextPage = currentPage.value + 1;

      if (nextPage >= bannerModel.length) {
        // Instead of animating back to 0, jump instantly without animation
        pageController.value.jumpToPage(0);
        currentPage.value = 0;
      } else {
        currentPage.value = nextPage;
        try {
          await pageController.value.animateToPage(
            currentPage.value,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          timer.cancel();
        }
      }
    });
  }

  // void startBannerTimer() {
  //   _bannerTimer?.cancel();
  //   _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
  //     // Check if controller is still valid and widget is mounted
  //     if (!Get.isRegistered<HomeController>() ||
  //         !pageController.value.hasClients) {
  //       timer.cancel();
  //       return;
  //     }
  //
  //     if (bannerModel.isNotEmpty) {
  //       if (currentPage.value < bannerModel.length - 1) {
  //         currentPage.value++;
  //       } else {
  //         currentPage.value = 0;
  //       }
  //
  //       // Only animate if attached
  //       try {
  //         if (pageController.value.hasClients) {
  //           pageController.value.animateToPage(
  //             currentPage.value,
  //             duration: const Duration(milliseconds: 500),
  //             curve: Curves.easeInOut,
  //           );
  //         }
  //       } catch (e) {
  //         // If any error occurs, cancel the timer
  //         timer.cancel();
  //       }
  //     }
  //   });
  // }

  void stopBannerTimer() {
    _bannerTimer?.cancel();
  }

  late TabController tabController;

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  RxList<AdvertisementModel> advertisementList = <AdvertisementModel>[].obs;
  RxList<VendorModel> popularRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> couponRestaurantList = <VendorModel>[].obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;

  RxList<StoryModel> storyList = <StoryModel>[].obs;
  RxList<BannerModel> bannerModel = <BannerModel>[].obs;
  RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  // Optimized parallel data loading
  Future<void> _loadAllDataInParallel() async {
    return PerformanceOptimizer.measureAsync('parallel_data_fetch', () async {
      isLoading.value = true;
      print('[DEBUG] Starting parallel data fetch');
      // Load cart data first (needed for UI)
      getCartData();
      // **CRITICAL: Load location and zone first, then load other data in parallel**
      await _ensureUserModelIsLoaded();
      await _ensureUserLocationIsSet();
      await getZone();
      // Now load other data in parallel
      await Future.wait([
        _loadVendorCategories(),
        _loadBanners(),
        _loadFavorites(),
        _loadRestaurantsAndRelatedData(),
      ]);
      // startBannerTimer();
      print('[DEBUG] All parallel data fetch completed');

      setLoading();
    });
  }

  // Load vendor categories in parallel
  Future<void> _loadVendorCategories() async {
    print('[DEBUG] Loading vendor categories');
    await FireStoreUtils.getHomeVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
        print('[DEBUG] Vendor categories loaded: ${value.length}');
      },
    );
  }

  // Load banners in parallel
  Future<void> _loadBanners() async {
    print('[DEBUG] Loading banners');

    // Log current zone information (should be set by now)
    String? currentZoneId = Constant.selectedZone?.id;
    String? currentZoneTitle = Constant.selectedZone?.name;
    print(
        '[BANNER_LOADING] Current customer zone - ID: $currentZoneId, Title: $currentZoneTitle');

    await Future.wait([
      FireStoreUtils.getHomeTopBanner().then((value) {
        bannerModel.value = value;
        print('[BANNER_LOADING] Top banners loaded: ${value.length}');
        print(
            '[BANNER_LOADING] Top banner details: ${value.map((b) => '${b.title} (Zone: ${b.zoneId})').join(', ')}');
      }),
      FireStoreUtils.getHomeBottomBanner().then((value) {
        bannerBottomModel.value = value;
        print('[BANNER_LOADING] Bottom banners loaded: ${value.length}');
        print(
            '[BANNER_LOADING] Bottom banner details: ${value.map((b) => '${b.title} (Zone: ${b.zoneId})').join(', ')}');
      }),
    ]);
    // ✅ Start timer AFTER banners are loaded and only if not empty
    if (bannerModel.isNotEmpty) {
      startBannerTimer();
    }
    print(
        '[BANNER_LOADING] Total banners loaded - Top: ${bannerModel.length}, Bottom: ${bannerBottomModel.length}');
  }

  // Load favorites in parallel
  Future<void> _loadFavorites() async {
    print('[DEBUG] Loading favorites');
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
          print('[DEBUG] Favorites loaded: ${value.length}');
        },
      );
    }
  }

  // Load restaurants and related data in parallel
  Future<void> _loadRestaurantsAndRelatedData() async {
    print('[DEBUG] Loading restaurants and related data');

    // **CRITICAL: Add initial delay to ensure splash screen has finished**
    await Future.delayed(Duration(milliseconds: 100));

    // Location and zone should already be set by the main loading process

    // Start restaurant stream and load related data in parallel
    FireStoreUtils.getAllNearestRestaurant().listen((event) async {
      print('[DEBUG] Restaurant stream received ${event.length} restaurants');

      // Clear lists efficiently
      popularRestaurantList.clear();
      newArrivalRestaurantList.clear();
      allNearestRestaurant.clear();
      advertisementList.clear();

      // Add all restaurants at once
      allNearestRestaurant.addAll(event);
      newArrivalRestaurantList.addAll(event);
      popularRestaurantList.addAll(event);
      Constant.restaurantList = allNearestRestaurant;

      // Load related data in parallel
      await _loadRelatedDataInParallel(allNearestRestaurant);

      // Calculate distances and sort
      await _processRestaurantData(allNearestRestaurant);

      // **DEBUG: Log restaurant diagnostics**
      logRestaurantDiagnostics();
    });
  }

  // Load related data (coupons, stories, ads) in parallel
  Future<void> _loadRelatedDataInParallel(List<VendorModel> restaurants) async {
    print('[DEBUG] Loading related data in parallel');

    final futures = <Future<void>>[];

    // Load coupons
    futures.add(FireStoreUtils.getHomeCoupon().then((value) {
      couponRestaurantList.clear();
      couponList.clear();
      for (var element1 in value) {
        for (var element in restaurants) {
          if (element1.resturantId == element.id &&
              element1.expiresAt!.toDate().isAfter(DateTime.now())) {
            couponList.add(element1);
            couponRestaurantList.add(element);
          }
        }
      }
      print('[DEBUG] Coupons loaded: ${couponList.length}');
    }));

    // Load stories
    futures.add(FireStoreUtils.getStory().then((value) {
      print('[DEBUG] Raw stories from Firebase: ${value.length}');
      storyList.clear();
      for (var element1 in value) {
        print('[DEBUG] Story vendor ID: ${element1.vendorID}');
        for (var element in restaurants) {
          if (element1.vendorID == element.id) {
            storyList.add(element1);
            print('[DEBUG] Added story for restaurant: ${element.title}');
          }
        }
      }
      print('[DEBUG] Stories loaded: ${storyList.length}');
      print('[DEBUG] Story enable setting: ${Constant.storyEnable}');
    }));

    // Load advertisements (if enabled)
    if (Constant.isEnableAdsFeature == true) {
      futures.add(FireStoreUtils.getAllAdvertisement().then((value) {
        advertisementList.clear();
        for (var element1 in value) {
          for (var element in restaurants) {
            if (element1.vendorId == element.id) {
              advertisementList.add(element1);
            }
          }
        }
        print('[DEBUG] Advertisements loaded: ${advertisementList.length}');
      }));
    }

    // Wait for all related data to load
    await Future.wait(futures);
    print('[DEBUG] All related data loaded');
  }

  // Process restaurant data (distances and sorting)
  Future<void> _processRestaurantData(List<VendorModel> restaurants) async {
    print('[DEBUG] Processing restaurant data');

    // Calculate distances in batches for better performance
    await _calculateDistancesInBatches(restaurants);

    // Sort by distance, then by rating
    allNearestRestaurant.sort((a, b) {
      double distanceA = Constant.calculateDistance(
        Constant.selectedLocation.location!.latitude!,
        Constant.selectedLocation.location!.longitude!,
        a.latitude!,
        a.longitude!,
      );
      double distanceB = Constant.calculateDistance(
        Constant.selectedLocation.location!.latitude!,
        Constant.selectedLocation.location!.longitude!,
        b.latitude!,
        b.longitude!,
      );
      int distanceCompare = distanceA.compareTo(distanceB);
      if (distanceCompare != 0) return distanceCompare;
      // If distance is the same, compare by rating (higher first)
      double ratingA = double.tryParse(a.reviewsSum?.toString() ?? '0') ?? 0;
      double ratingB = double.tryParse(b.reviewsSum?.toString() ?? '0') ?? 0;
      return ratingB.compareTo(ratingA);
    });

    popularRestaurantList.sort(
      (a, b) => Constant.calculateReview(
              reviewCount: b.reviewsCount.toString(),
              reviewSum: b.reviewsSum.toString())
          .compareTo(Constant.calculateReview(
              reviewCount: a.reviewsCount.toString(),
              reviewSum: a.reviewsSum.toString())),
    );

    newArrivalRestaurantList.sort(
      (a, b) => (b.createdAt ?? Timestamp.now())
          .toDate()
          .compareTo((a.createdAt ?? Timestamp.now()).toDate()),
    );

    print('[DEBUG] Restaurant data processing completed');
  }

  /// **ENSURE USER MODEL IS LOADED BEFORE LOCATION DETECTION**
  Future<void> _ensureUserModelIsLoaded() async {
    print('[DEBUG] _ensureUserModelIsLoaded: Checking user model...');

    // If user model is already loaded, return
    if (Constant.userModel != null) {
      print('[DEBUG] User model already loaded: ${Constant.userModel!.id}');
      return;
    }

    // Wait for user model to be loaded with retry mechanism
    for (int attempt = 1; attempt <= 5; attempt++) {
      print('[DEBUG] User model loading attempt $attempt/5');

      if (Constant.userModel != null) {
        print(
            '[DEBUG] User model loaded successfully: ${Constant.userModel!.id}');
        return;
      }

      // Wait before retry
      if (attempt < 5) {
        print(
            '[DEBUG] User model not loaded yet, waiting 200ms before retry...');
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    print(
        '[DEBUG] User model not loaded after 5 attempts, trying to load fresh...');

    // **FALLBACK: Try to load user model fresh from Firestore**
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('[DEBUG] Attempting to load user model fresh from Firestore...');
        final userModel = await FireStoreUtils.getUserProfile(currentUser.uid);
        if (userModel != null) {
          Constant.userModel = userModel;
          print(
              '[DEBUG] User model loaded fresh from Firestore: ${userModel.id}');
          return;
        }
      }
    } catch (e) {
      print('[DEBUG] Error loading user model fresh: $e');
    }

    print('[DEBUG] User model not available, proceeding anyway');
  }

  /// **ENSURE USER LOCATION IS SET BEFORE ZONE DETECTION WITH RETRY MECHANISM**
  Future<void> _ensureUserLocationIsSet() async {
    print('[DEBUG] _ensureUserLocationIsSet: Checking current location...');
    print(
        '[DEBUG] Current location: ${Constant.selectedLocation.location?.latitude}, ${Constant.selectedLocation.location?.longitude}');

    // If location is already set, return
    if (Constant.selectedLocation.location?.latitude != null &&
        Constant.selectedLocation.location?.longitude != null) {
      print('[DEBUG] Location already set, proceeding with zone detection');
      return;
    }

    // **RETRY MECHANISM: Try multiple times with delays**
    for (int attempt = 1; attempt <= 3; attempt++) {
      print('[DEBUG] Location detection attempt $attempt/3');

      // Try to get location from user model
      if (Constant.userModel != null &&
          Constant.userModel!.shippingAddress != null &&
          Constant.userModel!.shippingAddress!.isNotEmpty) {
        final defaultAddress = Constant.userModel!.shippingAddress!.firstWhere(
            (a) => a.isDefault == true,
            orElse: () => Constant.userModel!.shippingAddress!.first);

        if (defaultAddress.location?.latitude != null &&
            defaultAddress.location?.longitude != null) {
          Constant.selectedLocation = defaultAddress;
          print(
              '[DEBUG] Location set from user model (attempt $attempt): ${defaultAddress.location?.latitude}, ${defaultAddress.location?.longitude}');
          return;
        }
      }

      // Try to get location from local storage
      try {
        final box = GetStorage();
        final savedLocation = box.read('user_location');
        if (savedLocation != null &&
            savedLocation['latitude'] != null &&
            savedLocation['longitude'] != null) {
          // Check if we have saved address information
          String savedAddress = savedLocation['address'] ?? '';
          String savedLocality = savedLocation['locality'] ?? '';

          // If we don't have address info, try to get it from GPS cache first
          if (savedAddress.isEmpty || savedLocality.isEmpty) {
            try {
              // First try to get from GPS cache
              final gpsCacheInfo =
                  await GpsLocationService.getCachedAddressInfo();
              if (gpsCacheInfo != null &&
                  gpsCacheInfo['address']?.isNotEmpty == true &&
                  gpsCacheInfo['locality']?.isNotEmpty == true) {
                savedAddress = gpsCacheInfo['address']!;
                savedLocality = gpsCacheInfo['locality']!;
                print('[DEBUG] Using GPS cached address info');
              } else {
                // If GPS cache doesn't have address, try to get it from coordinates
                final fullAddress =
                    await GpsLocationService.getAddressFromCoordinates(
                        savedLocation['latitude'], savedLocation['longitude']);
                savedAddress = fullAddress;
                savedLocality = fullAddress;
                print('[DEBUG] Got address from coordinates');
              }

              // Save the updated address info to local storage
              await box.write('user_location', {
                'latitude': savedLocation['latitude'],
                'longitude': savedLocation['longitude'],
                'address': savedAddress,
                'locality': savedLocality,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              });
              print('[DEBUG] Updated local storage with address info');
            } catch (e) {
              print('[DEBUG] Error getting address for saved location: $e');
              // Use fallback address
              savedAddress = 'Current Location';
              savedLocality = 'Current Location';
            }
          }

          Constant.selectedLocation = ShippingAddress(
            addressAs: 'Home',
            address: savedAddress,
            location: UserLocation(
              latitude: savedLocation['latitude'],
              longitude: savedLocation['longitude'],
            ),
            locality: savedLocality,
          );
          print(
              '[DEBUG] Location set from local storage (attempt $attempt): ${savedLocation['latitude']}, ${savedLocation['longitude']} - $savedAddress');
          return;
        }
      } catch (e) {
        print(
            '[DEBUG] Error reading location from local storage (attempt $attempt): $e');
      }

      // **NEW: Try to get location from GPS as fallback**
      try {
        print(
            '[DEBUG] Attempting GPS location detection (attempt $attempt)...');
        final gpsLocation =
            await GpsLocationService.getLocationForZoneDetection();
        if (gpsLocation != null &&
            gpsLocation['latitude'] != null &&
            gpsLocation['longitude'] != null) {
          // Get full address from GPS coordinates
          final fullAddress =
              await GpsLocationService.getAddressFromCoordinates(
                  gpsLocation['latitude']!, gpsLocation['longitude']!);

          // 🔑 CRITICAL: Detect zone ID for GPS location
          String? detectedZoneId = await _detectZoneIdForCoordinates(
              gpsLocation['latitude']!, gpsLocation['longitude']!);

          Constant.selectedLocation = ShippingAddress(
            id: 'gps_location_${DateTime.now().millisecondsSinceEpoch}', // 🔑 Add unique ID
            addressAs: 'Current Location',
            address: fullAddress,
            location: UserLocation(
              latitude: gpsLocation['latitude']!,
              longitude: gpsLocation['longitude']!,
            ),
            locality: fullAddress,
            zoneId: detectedZoneId, // 🔑 Add detected zone ID
          );
          print(
              '[DEBUG] Location set from GPS (attempt $attempt): ${gpsLocation['latitude']}, ${gpsLocation['longitude']} - $fullAddress');
          return;
        }
      } catch (e) {
        print('[DEBUG] Error getting GPS location (attempt $attempt): $e');
      }

      // If user model is not loaded yet, wait and retry
      if (Constant.userModel == null) {
        print(
            '[DEBUG] User model not loaded yet, waiting 500ms before retry...');
        await Future.delayed(Duration(milliseconds: 500));
        continue;
      }

      // If we reach here, location is not available, wait before retry
      if (attempt < 3) {
        print('[DEBUG] Location not found, waiting 300ms before retry...');
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    print(
        '[DEBUG] No valid location found after 3 attempts, will use fallback zone');

    // **FINAL DEBUG: Log all available location sources**
    await _debugLocationSources();
  }

  /// 🔑 DETECT ZONE ID FOR COORDINATES
  ///
  /// This method detects the zone ID for given coordinates by checking
  /// if the coordinates fall within any zone polygon
  Future<String?> _detectZoneIdForCoordinates(
      double latitude, double longitude) async {
    try {
      print(
          '[DEBUG] Starting zone detection for coordinates: $latitude, $longitude');

      // Get all zones from Firestore
      List<ZoneModel>? zones = await FireStoreUtils.getZone();

      if (zones == null || zones.isEmpty) {
        print('[DEBUG] No zones available in database');
        return null;
      }

      print('[DEBUG] Found ${zones.length} zones to check');

      // Check if coordinates fall within any zone polygon
      for (ZoneModel zone in zones) {
        if (zone.area != null && zone.area!.isNotEmpty) {
          print('[DEBUG] Checking zone: ${zone.name} (${zone.id})');

          // Use the existing polygon validation logic
          if (Constant.isPointInPolygon(
            LatLng(latitude, longitude),
            zone.area!,
          )) {
            print('[DEBUG] Zone detected: ${zone.name} (${zone.id})');
            return zone.id;
          }
        }
      }

      print('[DEBUG] Coordinates not within any service zone');
      return null;
    } catch (e) {
      print('[DEBUG] Error detecting zone: $e');
      return null;
    }
  }

  /// **GET LOCATION NAME FROM GPS COORDINATES**
  String _getLocationNameFromCoordinates(double latitude, double longitude) {
    // Indian location mappings for better user experience
    // You can expand this list with more Indian locations as needed

    // Mumbai area
    if (latitude >= 19.0 &&
        latitude <= 19.1 &&
        longitude >= 72.8 &&
        longitude <= 72.9) {
      return 'Mumbai, India';
    }

    // Delhi area
    if (latitude >= 28.6 &&
        latitude <= 28.7 &&
        longitude >= 77.2 &&
        longitude <= 77.3) {
      return 'Delhi, India';
    }

    // Bangalore area
    if (latitude >= 12.9 &&
        latitude <= 13.0 &&
        longitude >= 77.6 &&
        longitude <= 77.7) {
      return 'Bangalore, India';
    }

    // Chennai area
    if (latitude >= 13.0 &&
        latitude <= 13.1 &&
        longitude >= 80.2 &&
        longitude <= 80.3) {
      return 'Chennai, India';
    }

    // Hyderabad area
    if (latitude >= 17.4 &&
        latitude <= 17.5 &&
        longitude >= 78.4 &&
        longitude <= 78.5) {
      return 'Hyderabad, India';
    }

    // Pune area
    if (latitude >= 18.5 &&
        latitude <= 18.6 &&
        longitude >= 73.8 &&
        longitude <= 73.9) {
      return 'Pune, India';
    }

    // Kolkata area
    if (latitude >= 22.5 &&
        latitude <= 22.6 &&
        longitude >= 88.3 &&
        longitude <= 88.4) {
      return 'Kolkata, India';
    }

    // Ahmedabad area
    if (latitude >= 23.0 &&
        latitude <= 23.1 &&
        longitude >= 72.6 &&
        longitude <= 72.7) {
      return 'Ahmedabad, India';
    }

    // Jaipur area
    if (latitude >= 26.9 &&
        latitude <= 27.0 &&
        longitude >= 75.8 &&
        longitude <= 75.9) {
      return 'Jaipur, India';
    }

    // Kochi area
    if (latitude >= 9.9 &&
        latitude <= 10.0 &&
        longitude >= 76.2 &&
        longitude <= 76.3) {
      return 'Kochi, India';
    }

    // Goa area
    if (latitude >= 15.4 &&
        latitude <= 15.5 &&
        longitude >= 73.8 &&
        longitude <= 73.9) {
      return 'Goa, India';
    }

    // If no specific location matches, return a generic location name
    return 'Current Location';
  }

  /// **DEBUG ALL LOCATION SOURCES**
  Future<void> _debugLocationSources() async {
    print('\n🔍 LOCATION SOURCES DEBUG:');
    print(
        '📍 Constant.selectedLocation: ${Constant.selectedLocation.location?.latitude}, ${Constant.selectedLocation.location?.longitude}');
    print('👤 Constant.userModel: ${Constant.userModel?.id ?? "NULL"}');

    if (Constant.userModel?.shippingAddress != null) {
      print(
          '🏠 User shipping addresses: ${Constant.userModel!.shippingAddress!.length}');
      for (int i = 0; i < Constant.userModel!.shippingAddress!.length; i++) {
        final addr = Constant.userModel!.shippingAddress![i];
        print(
            '   Address $i: ${addr.addressAs} - ${addr.location?.latitude}, ${addr.location?.longitude} (default: ${addr.isDefault})');
      }
    } else {
      print('🏠 User shipping addresses: NULL');
    }

    try {
      final box = GetStorage();
      final savedLocation = box.read('user_location');
      print(
          '💾 Local storage location: ${savedLocation?['latitude']}, ${savedLocation?['longitude']}');
    } catch (e) {
      print('💾 Local storage error: $e');
    }

    // **NEW: Check GPS location availability**
    try {
      final isGpsAvailable = await GpsLocationService.isLocationAvailable();
      print('📡 GPS location available: $isGpsAvailable');
      if (isGpsAvailable) {
        final gpsLocation =
            await GpsLocationService.getLocationForZoneDetection();
        print(
            '📡 GPS location: ${gpsLocation?['latitude']}, ${gpsLocation?['longitude']}');
      }
    } catch (e) {
      print('📡 GPS location error: $e');
    }

    print('🔍 END LOCATION SOURCES DEBUG\n');
  }

  /// **RESTAURANT VISIBILITY DIAGNOSTICS**
  void logRestaurantDiagnostics() {
    if (!kDebugMode) return;

    print('\n🔍 RESTAURANT VISIBILITY DIAGNOSTICS:');
    print('📋 Zone Available: ${Constant.isZoneAvailable}');
    print(
        '📍 Selected Zone: ${Constant.selectedZone?.name ?? "None"} (ID: ${Constant.selectedZone?.id ?? "None"})');
    print(
        '🌍 User Location: ${Constant.selectedLocation.location?.latitude}, ${Constant.selectedLocation.location?.longitude}');
    print('📏 Search Radius: ${Constant.radius}km');
    print('🏪 Total Restaurants: ${allNearestRestaurant.length}');
    print('🍽️ Popular Restaurants: ${popularRestaurantList.length}');
    print('🆕 New Arrivals: ${newArrivalRestaurantList.length}');
    print('💳 Subscription Model: ${Constant.isSubscriptionModelApplied}');
    print('🔍 END RESTAURANT DIAGNOSTICS\n');
  }

  setLoading() async {
    await Future.delayed(Duration(seconds: 1), () async {
      print(
          '[DEBUG] setLoading() - Restaurant count: ${allNearestRestaurant.length}');
      print(
          '[DEBUG] setLoading() - Zone available: ${Constant.isZoneAvailable}');
      print(
          '[DEBUG] setLoading() - Selected zone: ${Constant.selectedZone?.name}');

      if (allNearestRestaurant.isEmpty) {
        print(
            '[DEBUG] setLoading() - No restaurants found, extending loading time');
        await Future.delayed(Duration(seconds: 2), () {
          isLoading.value = false;
        });
      } else {
        print(
            '[DEBUG] setLoading() - Restaurants found, setting loading to false');
        isLoading.value = false;
      }
      update();
    });
  }

  // Backward compatibility methods
  getData() async {
    // This method is now replaced by _loadAllDataInParallel()
    // but kept for backward compatibility
    print('[DEBUG] getData() called - using parallel loading instead');
    await _loadAllDataInParallel();
  }

  Future<void> getRefresh() async {
    await _loadAllDataInParallel();
  }

  getVendorCategory() async {
    // This method is now replaced by _loadVendorCategories()
    // but kept for backward compatibility
    print(
        '[DEBUG] getVendorCategory() called - using parallel loading instead');
    _loadVendorCategories();
  }

  getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }

  // Optimized distance calculation in batches
  Future<void> _calculateDistancesInBatches(List<VendorModel> vendors) async {
    const int batchSize = 10; // Process 10 vendors at a time

    for (int i = 0; i < vendors.length; i += batchSize) {
      final end =
          (i + batchSize < vendors.length) ? i + batchSize : vendors.length;
      final batch = vendors.sublist(i, end);

      // Process batch
      for (var vendor in batch) {
        if (vendor.latitude != null && vendor.longitude != null) {
          vendor.distance = Constant.calculateDistance(
            Constant.selectedLocation.location!.latitude!,
            Constant.selectedLocation.location!.longitude!,
            vendor.latitude!,
            vendor.longitude!,
          );
        } else {
          vendor.distance = null;
        }
      }

      // Allow UI to update between batches
      if (i + batchSize < vendors.length) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }
  }

  getZone() async {
    print(
        '[DEBUG] getZone() called - User location: ${Constant.selectedLocation.location?.latitude}, ${Constant.selectedLocation.location?.longitude}');
    await FireStoreUtils.getZone().then((value) async {
      if (value != null) {
        ZoneModel? detectedZone;
        for (int i = 0; i < value.length; i++) {
          if (Constant.isPointInPolygon(
              LatLng(Constant.selectedLocation.location?.latitude ?? 0.0,
                  Constant.selectedLocation.location?.longitude ?? 0.0),
              value[i].area!)) {
            //    Constant.selectedZone = value[i];
            //   Constant.isZoneAvailable = true;
            //   break;
            // } else {
            //   Constant.selectedZone = value[i];
            //   Constant.isZoneAvailable = false;
            // }

            detectedZone = value[i];
            break;
          }
        }
        if (detectedZone != null) {
          print(
              '[DEBUG] User location: ${Constant.selectedLocation.location?.latitude}, ${Constant.selectedLocation.location?.longitude}');
          Constant.selectedZone = detectedZone;
          Constant.isZoneAvailable = true;
          print(
              '[DEBUG] Zone detected: ${detectedZone.name} (${detectedZone.id})');
        } else {
          /*


// Try to find any available zone as fallback
          ZoneModel? fallbackZone;
          for (ZoneModel zone in value) {
            if (zone.publish == true) {
              fallbackZone = zone;
              break;
            }
          }

          if (fallbackZone != null) {
            Constant.selectedZone = fallbackZone;
            Constant.isZoneAvailable = false; // User is outside service area
            print('[DEBUG] No zone found for location, using fallback zone: ${fallbackZone.name} (${fallbackZone.id})');
            print('[DEBUG] User is outside service area - no restaurants will be shown');

            // Only set fallback address if we don't have a valid location
            if (Constant.selectedLocation.location?.latitude == null ||
                Constant.selectedLocation.location?.longitude == null) {
              Constant.selectedLocation = ShippingAddress(
                addressAs: '${fallbackZone.name} Center',
                location: UserLocation(
                  latitude: fallbackZone.latitude ?? 15.41813013195468,
                  longitude: fallbackZone.longitude ?? 80.05922178576178,
                ),
                locality: 'Ongole, Andhra Pradesh, India',
              );
            }
          } else {
            Constant.selectedZone = null;
            Constant.isZoneAvailable = false;
            print('[DEBUG] No zone found for this location and no fallback zone available!');
          }
        }
      }
    });


       */

          // User is outside all zones - get fallback zone from Firebase
          await _setFallbackZoneFromFirebase();
        }
      }
    });
  }

  /// **SET FALLBACK ZONE FROM FIREBASE CONFIGURATION**
  ///
  /// Gets fallback zone configuration from Firebase instead of hardcoding
  Future<void> _setFallbackZoneFromFirebase() async {
    try {
      print('[DEBUG] Getting fallback zone configuration from Firebase...');

      // Try to get fallback zone configuration from Firebase
      final fallbackConfig = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('fallback_zone')
          .get();

      if (fallbackConfig.exists && fallbackConfig.data() != null) {
        final config = fallbackConfig.data()!;
        final fallbackZoneId = config['zone_id'] as String?;
        final isEnabled = config['enabled'] as bool? ?? true;

        if (isEnabled && fallbackZoneId != null) {
          print('[DEBUG] Fallback zone configuration found: $fallbackZoneId');

          // Get the fallback zone details
          final fallbackZoneDoc = await FirebaseFirestore.instance
              .collection('zone')
              .doc(fallbackZoneId)
              .get();

          if (fallbackZoneDoc.exists && fallbackZoneDoc.data() != null) {
            final zoneData = fallbackZoneDoc.data()!;
            final fallbackZone = ZoneModel.fromJson(zoneData);

            Constant.selectedZone = fallbackZone;
            Constant.isZoneAvailable = false; // User is outside service area
            print(
                '[DEBUG] Using Firebase fallback zone: ${fallbackZone.name} (${fallbackZone.id})');
            print(
                '[DEBUG] User is outside service area - no restaurants will be shown');

            // Set fallback address if we don't have a valid location
            if (Constant.selectedLocation.location?.latitude == null ||
                Constant.selectedLocation.location?.longitude == null) {
              Constant.selectedLocation = ShippingAddress(
                addressAs: '${fallbackZone.name} Center',
                location: UserLocation(
                  latitude: fallbackZone.latitude ?? 15.41813013195468,
                  longitude: fallbackZone.longitude ?? 80.05922178576178,
                ),
                locality: '${fallbackZone.name}, Andhra Pradesh, India',
              );
            }

            // Cache the fallback configuration for offline use
            await _cacheFallbackZoneConfig(fallbackZoneId, isEnabled);
            return;
          }
        }
      }

      // If Firebase config not found or disabled, use local fallback
      print(
          '[DEBUG] Firebase fallback config not found, using local fallback...');
      await _setLocalFallbackZone();
    } catch (e) {
      print('[DEBUG] Error getting fallback zone from Firebase: $e');
      print('[DEBUG] Using local fallback zone...');
      await _setLocalFallbackZone();
    }
  }

  /// **SET LOCAL FALLBACK ZONE (HARDCODED)**
  ///
  /// Fallback when Firebase configuration is not available
  Future<void> _setLocalFallbackZone() async {
    try {
      // Try to get any available zone as fallback
      final zones = await FireStoreUtils.getZone();
      ZoneModel? fallbackZone;

      if (zones != null) {
        for (ZoneModel zone in zones) {
          if (zone.publish == true) {
            fallbackZone = zone;
            break;
          }
        }
      }

      if (fallbackZone != null) {
        Constant.selectedZone = fallbackZone;
        Constant.isZoneAvailable = false; // User is outside service area
        print(
            '[DEBUG] Using local fallback zone: ${fallbackZone.name} (${fallbackZone.id})');
        print(
            '[DEBUG] User is outside service area - no restaurants will be shown');

        // Set fallback address if we don't have a valid location
        if (Constant.selectedLocation.location?.latitude == null ||
            Constant.selectedLocation.location?.longitude == null) {
          Constant.selectedLocation = ShippingAddress(
            addressAs: '${fallbackZone.name} Center',
            location: UserLocation(
              latitude: fallbackZone.latitude ?? 15.41813013195468,
              longitude: fallbackZone.longitude ?? 80.05922178576178,
            ),
            locality: '${fallbackZone.name}, Andhra Pradesh, India',
          );
        }
      } else {
        Constant.selectedZone = null;
        Constant.isZoneAvailable = false;
        print('[DEBUG] No fallback zone available!');
      }
    } catch (e) {
      print('[DEBUG] Error setting local fallback zone: $e');
      Constant.selectedZone = null;
      Constant.isZoneAvailable = false;
    }
  }

  /// **CACHE FALLBACK ZONE CONFIGURATION**
  ///
  /// Caches fallback zone configuration for offline use
  Future<void> _cacheFallbackZoneConfig(String zoneId, bool enabled) async {
    try {
      final box = GetStorage();
      await box.write('fallback_zone_config', {
        'zone_id': zoneId,
        'enabled': enabled,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('[DEBUG] Cached fallback zone configuration: $zoneId');
    } catch (e) {
      print('[DEBUG] Error caching fallback zone config: $e');
    }
  }

  /// **GET CACHED FALLBACK ZONE CONFIGURATION**
  ///
  /// Gets cached fallback zone configuration for offline use
  Future<Map<String, dynamic>?> _getCachedFallbackZoneConfig() async {
    try {
      final box = GetStorage();
      final cached = box.read('fallback_zone_config');
      if (cached != null) {
        final timestamp = cached['timestamp'] as int?;
        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();

          // Cache valid for 24 hours
          if (now.difference(cacheTime) < Duration(hours: 24)) {
            print(
                '[DEBUG] Using cached fallback zone config: ${cached['zone_id']}');
            return cached;
          }
        }
      }
      return null;
    } catch (e) {
      print('[DEBUG] Error getting cached fallback zone config: $e');
      return null;
    }
  }
}
