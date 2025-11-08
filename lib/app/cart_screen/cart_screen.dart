import 'dart:developer' as dev;

import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/cart_screen/coupon_list_screen.dart';
import 'package:customer/app/cart_screen/widget/cart_bill_details_widget.dart';
import 'package:customer/app/cart_screen/widget/cart_build_delivery_ui.dart';
import 'package:customer/app/cart_screen/widget/cart_navigation_bar_widget.dart';
import 'package:customer/app/cart_screen/widget/cart_product_details_image_widget.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/controllers/mart_navigation_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/mart_zone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customer/utils/utils/color_const.dart';
import 'package:provider/provider.dart';

// Cart theme enum for different color schemes

class CartScreen extends StatefulWidget {
  final bool hideBackButton;
  final String? source; // 'food' or 'mart' or null for auto-detect
  final bool isFromMartNavigation; // true if accessed from mart navigation tabs

  const CartScreen(
      {Key? key,
      this.hideBackButton = false,
      this.source,
      this.isFromMartNavigation = false})
      : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartController controller;
  @override
  void initState() {
    super.initState();
    print(
        '🚀 DEBUG: CartScreen initState() called - Initializing CartController...');
    controller = Get.put(CartController());
    print('✅ DEBUG: CartController initialized successfully');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart data when dependencies change (navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartData();
    });
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }

  void _refreshCartData() {
    print('DEBUG: Refreshing cart data...');
    // Use the enhanced force refresh method
    controller.forceRefreshCart();

    // **FIXED: Re-initialize address if not selected (for global cart controller)**
    if (controller.selectedAddress.value == null) {
      print(
          '🏠 [CART_REFRESH] No address selected, re-initializing address...');
      // Trigger address initialization by calling the public method
      controller.initializeAddress();
    }

    // Ensure payment method is set correctly based on order total
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.checkAndUpdatePaymentMethod();
      print(
          'DEBUG: Cart refresh completed - Items: ${cartItem.length}, Total: ${controller.totalAmount.value}');
    });
  }

  // Get theme colors based on cart theme
  CartThemeColors _getThemeColors(CartTheme theme) {
    switch (theme) {
      case CartTheme.mart:
        return CartThemeColors(
          primary: MartTheme.jippyMartButton,
          primaryDark:  ColorConst.martPrimary,
          accent: ColorConst.martPrimary,
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
          primary: const Color(0xFF607D8B),
          primaryDark: const Color(0xFF455A64),
          accent: const Color(0xFF78909C),
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

    return GetX<CartController>(builder: (controller) {
      // Check payment method every time the UI is built
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
                  : ColorConst.martPrimary,
              // themeColors.primary,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: !widget.hideBackButton,
              leading: widget.hideBackButton
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
                      onPressed: () {
                        // Check if we're in mart navigation system (cart tab)
                        if (widget.source == 'mart' &&
                            widget.isFromMartNavigation) {
                          // If accessed from mart navigation cart tab, go back to mart home
                          try {
                            final martNavController =
                                Get.find<MartNavigationController>();
                            martNavController.goToHome();
                          } catch (e) {
                            // Fallback to regular back navigation
                            Get.back();
                          }
                        } else {
                          // Regular back navigation for other cases (product details, etc.)
                          Get.back();
                        }
                      },
                    ),
              title: Text(
                cartTheme == CartTheme.mart ? 'Mart Cart' : 'Cart',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                // Debug buttons removed - methods not available in current version
              ],
            ),
            body: cartItem.isEmpty
                ? Constant.showEmptyView(message: "No Available Items")
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.selectedFoodType.value == 'TakeAway'
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(const AddressListScreen())!.then(
                                      (value) async {
                                        if (value != null) {
                                          ShippingAddress addressModel = value;

                                          // 🔑 ZONE DETECTION: Use the same zone system as restaurants
                                          if (addressModel.location?.latitude !=
                                                  null &&
                                              addressModel
                                                      .location?.longitude !=
                                                  null) {
                                            try {
                                              print(
                                                  '🔍 [CART_ADDRESS_CHANGE] Using restaurant zone system for consistency...');

                                              // Use the same zone as restaurants (Constant.selectedZone)
                                              if (Constant.selectedZone !=
                                                  null) {
                                                addressModel.zoneId =
                                                    Constant.selectedZone!.id;
                                                print(
                                                    '✅ [CART_ADDRESS_CHANGE] Using restaurant zone: ${Constant.selectedZone!.name} (${Constant.selectedZone!.id})');
                                              } else {
                                                // Fallback to mart zone detection if restaurant zone not available
                                                print(
                                                    '⚠️ [CART_ADDRESS_CHANGE] No restaurant zone available, trying mart zone detection...');
                                                final zoneId =
                                                    await MartZoneUtils
                                                        .getZoneIdForCoordinates(
                                                  addressModel
                                                      .location!.latitude!,
                                                  addressModel
                                                      .location!.longitude!,
                                                );

                                                if (zoneId.isNotEmpty) {
                                                  addressModel.zoneId = zoneId;
                                                  print(
                                                      '✅ [CART_ADDRESS_CHANGE] Mart zone detected: $zoneId');
                                                } else {
                                                  print(
                                                      '⚠️ [CART_ADDRESS_CHANGE] No zone detected for coordinates - leaving zoneId as null');
                                                }
                                              }
                                            } catch (e) {
                                              print(
                                                  '❌ [CART_ADDRESS_CHANGE] Error detecting zone: $e');
                                              // Continue without zone ID if detection fails
                                            }
                                          } else {
                                            print(
                                                '⚠️ [CART_ADDRESS_CHANGE] No coordinates available for zone detection');
                                          }

                                          controller.selectedAddress.value =
                                              addressModel;
                                          controller.calculatePrice();
                                        }
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_send_one.svg"),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.selectedAddress
                                                              .value?.addressAs
                                                              ?.toString() ??
                                                          "No Address Selected",
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
                                                  ),
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_down.svg"),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                //changed here1
                                                controller.selectedAddress.value
                                                        ?.getFullAddress() ??
                                                    "Please select a delivery address",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        cartProductDetailsImageWidget(
                          themeChange,
                          controller,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          visible: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${'Delivery Type'.tr} (${controller.selectedFoodType.value})"
                                      .tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                controller.selectedFoodType.value == 'TakeAway'
                                    ? const SizedBox()
                                    : Container(
                                        width: Responsive.width(100, context),
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Instant Delivery".tr,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppThemeData.medium,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .primary300
                                                            : AppThemeData
                                                                .primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Standard".tr,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppThemeData.medium,
                                                        fontSize: 12,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey400
                                                            : AppThemeData
                                                                .grey500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Radio(
                                                value: controller
                                                    .deliveryType.value,
                                                groupValue: "instant".tr,
                                                activeColor:
                                                    AppThemeData.primary300,
                                                onChanged: (value) {
                                                  controller.deliveryType
                                                      .value = "instant".tr;
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Offstage(
                                    offstage: true,
                                    child: InkWell(
                                      onTap: () {
                                        controller.deliveryType.value =
                                            "schedule".tr;
                                        BottomPicker.dateTime(
                                          onSubmit: (index) {
                                            controller.scheduleDateTime.value =
                                                index;
                                          },
                                          minDateTime: DateTime.now(),
                                          displaySubmitButton: true,
                                          pickerTitle: Text('Schedule Time'.tr),
                                          buttonSingleColor:
                                              AppThemeData.primary300,
                                        ).show(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Schedule Time".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .primary300
                                                              : AppThemeData
                                                                  .primary300,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "${'Your preferred time'.tr} ${controller.deliveryType.value == "schedule" ? Constant.timestampToDateTime(Timestamp.fromDate(controller.scheduleDateTime.value)) : ""}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontSize: 12,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey400
                                                          : AppThemeData
                                                              .grey500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Radio(
                                              value:
                                                  controller.deliveryType.value,
                                              groupValue: "schedule".tr,
                                              activeColor:
                                                  AppThemeData.primary300,
                                              onChanged: (value) {
                                                controller.deliveryType.value =
                                                    "schedule".tr;
                                                BottomPicker.dateTime(
                                                  initialDateTime: controller
                                                      .scheduleDateTime.value,
                                                  onSubmit: (index) {
                                                    controller.scheduleDateTime
                                                        .value = index;
                                                  },
                                                  minDateTime: controller
                                                      .scheduleDateTime.value,
                                                  displaySubmitButton: true,
                                                  pickerTitle:
                                                      Text('Schedule Time'.tr),
                                                  buttonSingleColor:
                                                      AppThemeData.primary300,
                                                ).show(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offers & Benefits".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  // Show loading indicator while fetching coupons
                                  ShowToastDialog.showLoader(
                                      "Loading coupons...");
                                  await controller.getCartData();
                                  ShowToastDialog.closeLoader();
                                  Get.to(const CouponListScreen());
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 52,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Apply Coupons".tr,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        billCartWidget(
                          themeChange,
                          controller,
                          context,
                        ),
                        controller.selectedFoodType.value == 'TakeAway' ||
                                (controller.vendorModel.value.isSelfDelivery ==
                                        true &&
                                    Constant.isSelfDeliveryFeature == true)
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Thanks with a tip!".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 52,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 14),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Around the clock, our delivery partners bring you your favorite meals. Show your appreciation with a tip."
                                                        .tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SvgPicture.asset(
                                                    "assets/images/ic_tips.svg")
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 05;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      05
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "05"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 10;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      10
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "10"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 15;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      15
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "15"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return tipsDialog(
                                                              controller,
                                                              themeChange);
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            'Other'.tr,
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextFieldWidget(
                                title: 'Remarks'.tr,
                                controller: controller.reMarkController.value,
                                hintText: 'Write remarks for the restaurant'.tr,
                                maxLine: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            //changed here
            bottomNavigationBar: cartItem.isEmpty
                ? null
                :
                  cartNavigationBarWidget(
                      themeChange,
                      controller,
                      context,
                    ),
                ),
      );
    });
  }

  /// Reusable method to build delivery fee UI for different order types
  ///
  /// Parameters:
  /// - [isFreeDelivery]: Whether delivery is free or not
  /// - [originalFee]: Original delivery fee to show with strikethrough (for free delivery)
  /// - [currentFee]: Current delivery fee to display
  /// - [themeChange]: Theme controller for dark/light mode
  ///
  /// Returns:
  /// - Row widget with appropriate delivery fee display
}
