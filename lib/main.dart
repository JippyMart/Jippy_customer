import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/services/global_deeplink_handler.dart';
import 'package:customer/config/smartlook_config.dart';
import 'package:customer/constant/constant.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';  // TEMPORARILY DISABLED
import 'package:customer/app/dash_board_screens/controller/dash_board_controller.dart';
import 'package:customer/controllers/global_setting_controller.dart';
import 'package:customer/controllers/login_controller.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/controllers/otp_controller.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/models/language_model.dart';
import 'package:customer/services/api_service.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/services/final_deep_link_service.dart';
import 'package:customer/services/global_deeplink_handler.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/services/mart_firestore_service.dart';
import 'package:customer/services/mobile_deep_link_service.dart';
import 'package:customer/services/pending_deep_link_handler.dart';
import 'package:customer/services/smartlook_service.dart';
import 'package:customer/themes/styles.dart';
import 'package:customer/utils/anr_monitor.dart';
import 'package:customer/utils/app_lifecycle_logger.dart';
import 'package:customer/utils/cache_manager.dart';
import 'package:customer/utils/crash_prevention.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/native_lock_prevention.dart';
import 'package:customer/utils/performance_optimizer.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/utils/production_logger.dart';
import 'package:customer/utils/smartlook_anr_fix.dart';
import 'package:customer/utils/system_call_optimizer.dart';
import 'package:customer/utils/text_processing_anr_fix.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:customer/services/global_deeplink_handler.dart';
import 'package:provider/provider.dart';

import 'app/category_service/controller/cetegory_service_controller.dart';
import 'app/video_splash_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalDeeplinkHandler.init();
  Get.put(
    GlobalDeeplinkHandler.instance,
    permanent: true,
  );
  CrashPrevention();
  await SmartlookANRFix.configureSmartlook();
  await PlatformANRPrevention.preventMIUIANR();
  await PlatformANRPrevention.preventCiscoANR();
  try {
    // Initialize Firebase with timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 3,),);

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );

    ANRMonitor.startMonitoring();
    MemoryMonitor.startMemoryMonitoring();
    NativeLockPrevention.startLockContentionMonitoring();
    TextProcessingANRFix.startTextProcessingMonitoring();
    ANRStatusLogger.logANRPreventionStatus();
  } catch (e) {
  }

  // **OPTIMIZED: Initialize GetStorage first (fastest)**
  await GetStorage.init();

  // **OPTIMIZED: Initialize Preferences (needed for app)**
  await Preferences.initPref();

  // **OPTIMIZED: Initialize DatabaseHelper (lightweight)**
  DatabaseHelper.instance;
  // **OPTIMIZED: Register critical services and controllers immediately**
  Get.put(MartFirestoreService(), permanent: true);
  Get.put(OtpController(), permanent: true);
  Get.put(DashBoardController(), permanent: true);
  Get.put(LoginController());
  Get.put(MartController(), permanent: true);
  Get.put(
    CategoryServiceController(),
  );

  // **OPTIMIZED: Initialize cart provider (lightweight)**
  final cartProvider = CartProvider();
  await cartProvider.checkCartPersistence();

  // **OPTIMIZED: Start app immediately, defer heavy services**

  // **DEFERRED: Initialize heavy services in background**
  _initializeHeavyServicesInBackground();

  // **FIXED: Initialize deep link services asynchronously to prevent blocking**
  _initializeDeepLinkServicesInBackground();

  // **OPTIMIZED: Initialize SmartLook in background (non-blocking)**
  _initializeSmartLookInBackground();
  runApp(
    MyApp(),
  );
}

// **NEW: Background initialization function**
void _initializeHeavyServicesInBackground() {
  // Run heavy services in background without blocking app startup
  Future.microtask(() async {
    try {
      // Initialize heavy services with timeouts
      await Future.wait([
        Get.putAsync(
              () => ApiService().init(),
        ).timeout(
          const Duration(
            seconds: 5,
          ),
        ),
        Get.putAsync(
              () => MartFirestoreService().init(),
        ).timeout(const Duration(seconds: 5)),
        CacheManager.initialize().timeout(const Duration(seconds: 3)),
        PerformanceOptimizer.initialize().timeout(const Duration(seconds: 2)),
        ProductionLogger.initialize().timeout(const Duration(seconds: 2)),
        AppLifecycleLogger.initialize().timeout(const Duration(seconds: 2)),
      ]);
      await Future.wait([
        PendingDeepLinkHandler.checkPendingDeepLinks()
            .timeout(const Duration(seconds: 3)),
        MobileDeepLinkService()
            .initialize()
            .timeout(const Duration(seconds: 3)),
      ]);
    } catch (e) {
    }
  });
}

// **NEW: Deep Link Services background initialization**
void _initializeDeepLinkServicesInBackground() {
  Future.microtask(() async {
    try {
      await FinalDeepLinkService()
          .init(GlobalDeeplinkHandler.navigatorKey)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
    }
  });
}

// **NEW: SmartLook background initialization with crash prevention**
void _initializeSmartLookInBackground() {
  Future.microtask(() async {
    final smartlookService = SmartlookService();
    try {
      await smartlookService.preventSessionRecordingStorageCrash();
      await smartlookService
          .initialize(
        SmartlookConfig.projectKey,
        region: SmartlookConfig.region,
      )
          .timeout(const Duration(seconds: 3));

      if (smartlookService.isInitialized) {
        if (SmartlookConfig.enableSensitiveDataMasking) {
          smartlookService.setSensitiveDataMasking(true);
        }
        smartlookService.setRecordingQuality(SmartlookConfig.recordingQuality);
      }
    } catch (e) {
      try {
        await smartlookService.preventSessionRecordingStorageCrash();
        await smartlookService.forceReinitialize(SmartlookConfig.projectKey,
            region: SmartlookConfig.region);
        if (smartlookService.isInitialized) {
        }
      } catch (e2) {
      }
    }
  });
}
Future<bool> onWillPop(BuildContext context) async {
  bool? shouldExit = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Exit App'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            if (Platform.isAndroid) {
              SystemNavigator.pop(); // Close app properly on Android
            } else if (Platform.isIOS) {
              exit(0); // Force close on iOS (not recommended by Apple, but works)
            } else {
              SystemNavigator.pop();
            }
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  return shouldExit ?? false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    // Deep Link Service is already initialized in main()

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Preferences.getString(Preferences.languageCodeKey)
          .toString()
          .isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.slug.toString());
      } else {
        LanguageModel languageModel =
        LanguageModel(slug: "en", isRtl: false, title: "English");
        Preferences.setString(
            Preferences.languageCodeKey, jsonEncode(languageModel.toJson()));
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeChangeProvider),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        // ChangeNotifierProvider(
        // create: (_) {
        //   return themeChangeProvider;
        // },
        child: Consumer<DarkThemeProvider>(
          builder: (context, value, child) {
            // ✅ ENHANCED: Conditional Smartlook wrapping with error handling
            Widget appWidget = GetMaterialApp(
              navigatorKey: GlobalDeeplinkHandler.navigatorKey,
              title: 'JippyMart Customer'.tr,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(
                  themeChangeProvider.darkTheme == 0
                      ? true
                      : themeChangeProvider.darkTheme == 1
                      ? false
                      : false,
                  context),
              localizationsDelegates: const [
                CountryLocalizations.delegate,
              ],
              locale: LocalizationService.locale,
              fallbackLocale: LocalizationService.locale,
              translations: LocalizationService(),
              builder: EasyLoading.init(),
              home: GetBuilder<GlobalSettingController>(
                init: GlobalSettingController(),
                builder: (context) {
                  // return CateringServiceScreen();
                  return const VideoSplashScreen();
                },
              ),
            );
            try {
              return SmartlookRecordingWidget(
                child: appWidget,
              );
            } catch (e) {
              return appWidget;
            }
          },
        ),
      );
  }
}
