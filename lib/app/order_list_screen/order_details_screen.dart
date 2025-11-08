import 'package:customer/app/chat_screens/chat_screen.dart';
import 'package:customer/app/order_list_screen/live_tracking_screen.dart';
import 'package:customer/app/rate_us_screen/rate_product_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/order_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';

class OrderBillDetails {
  final double subTotal;
  final double deliveryCharges;
  final double originalDeliveryFee;
  final double couponAmount;
  final double specialDiscountAmount;
  final double taxAmount;
  final double deliveryTips;
  final double totalAmount;
  final bool isFreeDelivery;
  OrderBillDetails({
    required this.subTotal,
    required this.deliveryCharges,
    required this.originalDeliveryFee,
    required this.couponAmount,
    required this.specialDiscountAmount,
    required this.taxAmount,
    required this.deliveryTips,
    required this.totalAmount,
    required this.isFreeDelivery,
  });
}

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, this.surgeFee});
  final double? surgeFee;
  Future<OrderBillDetails> _calculateOrderBillDetails(
      OrderModel order,
      VendorModel? vendor,
      DeliveryCharge deliveryCharge,
      double totalDistance) async {
    double subTotal = 0.0;
    double deliveryCharges = 0.0;
    double originalDeliveryFee = 0.0;
    double couponAmount = 0.0;
    double specialDiscountAmount = 0.0;
    double taxAmount = 0.0;
    double deliveryTips = double.tryParse(order.tipAmount ?? '0') ?? 0.0;
    double totalAmount = 0.0;

    // Subtotal - Enhanced promotional detection
    if (order.products != null) {
      for (var element in order.products!) {
        final priceValue = double.tryParse(element.price.toString()) ?? 0.0;
        final discountPriceValue =
            double.tryParse(element.discountPrice.toString()) ?? 0.0;

        // Enhanced promotional detection - check both promoId and price comparison
        final hasPromo = element.promoId != null && element.promoId!.isNotEmpty;
        final isPricePromotional = priceValue > 0 &&
            discountPriceValue > 0 &&
            priceValue < discountPriceValue;
        final isPromotional = hasPromo || isPricePromotional;

        print('DEBUG: Order Details - Processing product: ${element.name}');
        print(
            'DEBUG: Order Details - Price: $priceValue, DiscountPrice: $discountPriceValue');
        print(
            'DEBUG: Order Details - Has PromoId: $hasPromo, Is Price Promotional: $isPricePromotional');
        print('DEBUG: Order Details - Is Promotional: $isPromotional');

        double itemPrice;
        if (isPromotional) {
          // Use the lower price (promotional price) for calculations
          itemPrice =
              priceValue < discountPriceValue ? priceValue : discountPriceValue;
          print('DEBUG: Order Details - Using promotional price: $itemPrice');
        } else if (discountPriceValue <= 0) {
          // No discount - use regular price
          itemPrice = priceValue;
          print('DEBUG: Order Details - Using regular price: $itemPrice');
        } else {
          // Regular discount - use discount price
          itemPrice = discountPriceValue;
          print('DEBUG: Order Details - Using discount price: $itemPrice');
        }

        final quantity = double.parse(element.quantity.toString());
        final extrasPrice = double.parse(element.extrasPrice.toString());

        final itemTotal = (itemPrice * quantity) + (extrasPrice * quantity);
        subTotal += itemTotal;
        print(
            'DEBUG: Order Details - Item total: $itemTotal, Running subtotal: $subTotal');
      }
    }

    // Delivery Charges - Enhanced for promotional items
    final threshold = deliveryCharge.itemTotalThreshold ?? 299;
    final baseCharge = deliveryCharge.baseDeliveryCharge ?? 23;
    final freeKm = deliveryCharge.freeDeliveryDistanceKm ?? 7;
    final perKm = deliveryCharge.perKmChargeAboveFreeDistance ?? 8;

    // Check if cart has promotional items
    final hasPromotionalItems = order.products!.any((item) {
      final priceValue = double.tryParse(item.price.toString()) ?? 0.0;
      final discountPriceValue =
          double.tryParse(item.discountPrice.toString()) ?? 0.0;
      final hasPromo = item.promoId != null && item.promoId!.isNotEmpty;
      final isPricePromotional = priceValue > 0 &&
          discountPriceValue > 0 &&
          priceValue < discountPriceValue;
      return hasPromo || isPricePromotional;
    });

    print(
        'DEBUG: Order Details - Has promotional items for delivery calculation: $hasPromotionalItems');

    if (vendor?.isSelfDelivery == true &&
        Constant.isSelfDeliveryFeature == true) {
      deliveryCharges = 0.0;
      originalDeliveryFee = 0.0;
      print('DEBUG: Order Details - Self delivery - no charge');
    } else if (hasPromotionalItems) {
      // Promotional items delivery logic - Get dynamic settings from Firestore
      final promotionalItems = order.products!.where((item) {
        final priceValue = double.tryParse(item.price.toString()) ?? 0.0;
        final discountPriceValue =
            double.tryParse(item.discountPrice.toString()) ?? 0.0;
        final hasPromo = item.promoId != null && item.promoId!.isNotEmpty;
        final isPricePromotional = priceValue > 0 &&
            discountPriceValue > 0 &&
            priceValue < discountPriceValue;
        return hasPromo || isPricePromotional;
      }).toList();

      if (promotionalItems.isNotEmpty) {
        final firstPromoItem = promotionalItems.first;

        try {
          // Get promotional item details from Firestore (DYNAMIC)
          final promoDetails =
              await FireStoreUtils.getActivePromotionForProduct(
            productId: firstPromoItem.id ?? '',
            restaurantId: firstPromoItem.vendorID ?? '',
          );

          if (promoDetails != null) {
            final freeDeliveryKm =
                (promoDetails['free_delivery_km'] as num?)?.toDouble() ?? 3.0;
            final extraKmCharge =
                (promoDetails['extra_km_charge'] as num?)?.toDouble() ?? 7.0;
            final promoBaseCharge =
                23.0; // Base delivery charge for promotional items

            print(
                'DEBUG: Order Details - Promotional delivery settings from Firestore:');
            print('DEBUG: Order Details - Free delivery km: $freeDeliveryKm');
            print('DEBUG: Order Details - Extra km charge: $extraKmCharge');
            print('DEBUG: Order Details - Total distance: $totalDistance km');

            if (totalDistance <= freeDeliveryKm) {
              // Free delivery within promotional distance
              deliveryCharges = 0.0;
              originalDeliveryFee = promoBaseCharge.toDouble();
              print(
                  'DEBUG: Order Details - Promotional free delivery within ${freeDeliveryKm}km - showing original fee: ₹$promoBaseCharge');
            } else {
              // Paid delivery for promotional items beyond free delivery distance
              double extraKm = (totalDistance - freeDeliveryKm).ceilToDouble();
              deliveryCharges = extraKm * extraKmCharge;
              originalDeliveryFee = deliveryCharges;
              print(
                  'DEBUG: Order Details - Promotional paid delivery beyond ${freeDeliveryKm}km: $extraKm km × ₹$extraKmCharge = ₹${deliveryCharges}');
            }
          } else {
            print(
                'DEBUG: Order Details - No promotional details found, using regular delivery charge');
            // Fallback to regular delivery logic
            if (subTotal < threshold) {
              if (totalDistance <= freeKm) {
                deliveryCharges = baseCharge.toDouble();
                originalDeliveryFee = baseCharge.toDouble();
              } else {
                double extraKm = (totalDistance - freeKm).ceilToDouble();
                deliveryCharges = (baseCharge + (extraKm * perKm)).toDouble();
                originalDeliveryFee = deliveryCharges;
              }
            } else {
              if (totalDistance <= freeKm) {
                deliveryCharges = 0.0;
                originalDeliveryFee = baseCharge.toDouble();
              } else {
                double extraKm = (totalDistance - freeKm).ceilToDouble();
                deliveryCharges = (extraKm * perKm).toDouble();
                originalDeliveryFee =
                    (baseCharge + (extraKm * perKm)).toDouble();
              }
            }
          }
        } catch (e) {
          print(
              'DEBUG: Order Details - Error fetching promotional delivery settings: $e');
          // Fallback to regular delivery logic
          if (subTotal < threshold) {
            if (totalDistance <= freeKm) {
              deliveryCharges = baseCharge.toDouble();
              originalDeliveryFee = baseCharge.toDouble();
            } else {
              double extraKm = (totalDistance - freeKm).ceilToDouble();
              deliveryCharges = (baseCharge + (extraKm * perKm)).toDouble();
              originalDeliveryFee = deliveryCharges;
            }
          } else {
            if (totalDistance <= freeKm) {
              deliveryCharges = 0.0;
              originalDeliveryFee = baseCharge.toDouble();
            } else {
              double extraKm = (totalDistance - freeKm).ceilToDouble();
              deliveryCharges = (extraKm * perKm).toDouble();
              originalDeliveryFee = (baseCharge + (extraKm * perKm)).toDouble();
            }
          }
        }
      }
    } else {
      // Regular items delivery logic
      if (subTotal < threshold) {
        if (totalDistance <= freeKm) {
          deliveryCharges = baseCharge.toDouble();
          originalDeliveryFee = baseCharge.toDouble();
        } else {
          double extraKm = (totalDistance - freeKm).ceilToDouble();
          deliveryCharges = (baseCharge + (extraKm * perKm)).toDouble();
          originalDeliveryFee = deliveryCharges;
        }
      } else {
        if (totalDistance <= freeKm) {
          deliveryCharges = 0.0;
          originalDeliveryFee = baseCharge.toDouble();
        } else {
          double extraKm = (totalDistance - freeKm).ceilToDouble();
          deliveryCharges = (extraKm * perKm).toDouble();
          originalDeliveryFee = (baseCharge + (extraKm * perKm)).toDouble();
        }
      }
    }

    // Coupon Discount - Check if promotional items exist
    if (hasPromotionalItems) {
      // If cart has promotional items, don't apply coupons
      couponAmount = 0.0;
      print(
          'DEBUG: Order Details - No coupon applied - cart contains promotional items');
    } else if (order.couponId != null &&
        order.couponId!.isNotEmpty &&
        order.discount != null) {
      couponAmount = double.tryParse(order.discount.toString()) ?? 0.0;
      print('DEBUG: Order Details - Coupon applied: ${order.couponId}');
    } else {
      couponAmount = 0.0;
    }

    // Special Discount
    if (order.specialDiscount != null &&
        order.specialDiscount!['special_discount'] != null) {
      specialDiscountAmount = double.tryParse(
              order.specialDiscount!['special_discount'].toString()) ??
          0.0;
    }

    // Taxes
    double sgst = subTotal * 0.05;
    double gst = originalDeliveryFee * 0.18;
    taxAmount = sgst + gst;

    print('DEBUG: subTotal = ' + subTotal.toString());
    print('DEBUG: totalDistance = ' + totalDistance.toString());
    print('DEBUG: originalDeliveryFee = ' + originalDeliveryFee.toString());
    print('DEBUG: deliveryCharges = ' + deliveryCharges.toString());
    // Free Delivery logic for total - Enhanced for promotional items
    bool isFreeDelivery = false;
    if (hasPromotionalItems) {
      // For promotional items, check if within free delivery distance (dynamic from Firestore)
      final promotionalItems = order.products!.where((item) {
        final priceValue = double.tryParse(item.price.toString()) ?? 0.0;
        final discountPriceValue =
            double.tryParse(item.discountPrice.toString()) ?? 0.0;
        final hasPromo = item.promoId != null && item.promoId!.isNotEmpty;
        final isPricePromotional = priceValue > 0 &&
            discountPriceValue > 0 &&
            priceValue < discountPriceValue;
        return hasPromo || isPricePromotional;
      }).toList();

      if (promotionalItems.isNotEmpty) {
        final firstPromoItem = promotionalItems.first;

        try {
          // Get promotional item details from Firestore (DYNAMIC)
          final promoDetails =
              await FireStoreUtils.getActivePromotionForProduct(
            productId: firstPromoItem.id ?? '',
            restaurantId: firstPromoItem.vendorID ?? '',
          );

          if (promoDetails != null) {
            final freeDeliveryKm =
                (promoDetails['free_delivery_km'] as num?)?.toDouble() ?? 3.0;
            if (totalDistance <= freeDeliveryKm) {
              isFreeDelivery = true;
              print(
                  'DEBUG: Order Details - Promotional free delivery within ${freeDeliveryKm}km - isFreeDelivery: true');
            }
          } else {
            // Fallback to regular delivery logic
            if (subTotal >= threshold && totalDistance <= freeKm) {
              isFreeDelivery = true;
              print(
                  'DEBUG: Order Details - Fallback to regular free delivery - isFreeDelivery: true');
            }
          }
        } catch (e) {
          print(
              'DEBUG: Order Details - Error checking promotional free delivery: $e');
          // Fallback to regular delivery logic
          if (subTotal >= threshold && totalDistance <= freeKm) {
            isFreeDelivery = true;
            print(
                'DEBUG: Order Details - Fallback to regular free delivery - isFreeDelivery: true');
          }
        }
      }
    } else {
      // For regular items, use regular delivery settings
      if (subTotal >= threshold && totalDistance <= freeKm) {
        isFreeDelivery = true;
        print(
            'DEBUG: Order Details - Regular free delivery - isFreeDelivery: true');
      }
    }

    totalAmount = (subTotal - couponAmount - specialDiscountAmount) +
        taxAmount +
        (isFreeDelivery ? 0.0 : deliveryCharges) +
        deliveryTips;
    print('DEBUG: Order Details - Final calculation:');
    print('DEBUG: Order Details - SubTotal: ₹$subTotal');
    print('DEBUG: Order Details - Delivery Charges: ₹$deliveryCharges');
    print('DEBUG: Order Details - Is Free Delivery: $isFreeDelivery');
    print('DEBUG: Order Details - Total Amount: ₹$totalAmount');

    return OrderBillDetails(
      subTotal: subTotal,
      deliveryCharges: deliveryCharges,
      originalDeliveryFee: originalDeliveryFee,
      couponAmount: couponAmount,
      specialDiscountAmount: specialDiscountAmount,
      taxAmount: taxAmount,
      deliveryTips: deliveryTips,
      totalAmount: totalAmount,
      isFreeDelivery: isFreeDelivery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: OrderDetailsController(),
      builder: (controller) {
        final order = controller.orderModel.value;

        // Handle orders without products (shouldn't happen but safety check)
        if (order.products == null || order.products!.isEmpty) {
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Order Details".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey900,
                ),
              ),
            ),
            body: Center(
              child: Text(
                  "Order details are incomplete. Please contact support.".tr),
            ),
          );
        }

        // For mart orders, use the actual vendor data or create default
        final vendor = order.vendor ??
            VendorModel(
              title: "Jippy Mart",
              location: "Jippy Mart Store",
              phonenumber: "Contact Support",
              isSelfDelivery: false,
              deliveryCharge: DeliveryCharge(
                baseDeliveryCharge: 23.0,
                itemTotalThreshold: 299.0,
                freeDeliveryDistanceKm: 7.0,
                perKmChargeAboveFreeDistance: 8.0,
              ),
              latitude: 0.0,
              longitude: 0.0,
              vType: 'mart', // Mark as mart vendor
            );

        final deliveryCharge = vendor.deliveryCharge ?? DeliveryCharge();
        final totalDistance = order.vendor != null
            ? Constant.calculateDistance(
                vendor.latitude ?? 0.0,
                vendor.longitude ?? 0.0,
                order.address?.location?.latitude ?? 0.0,
                order.address?.location?.longitude ?? 0.0,
              )
            : 0.0; // Default distance for mart orders

        return FutureBuilder<OrderBillDetails>(
            future: _calculateOrderBillDetails(
                order, vendor, deliveryCharge, totalDistance),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface,
                  appBar: AppBar(
                    backgroundColor: themeChange.getThem()
                        ? AppThemeData.surfaceDark
                        : AppThemeData.surface,
                    centerTitle: false,
                    titleSpacing: 0,
                    title: Text(
                      "Order Details".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 16,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                  ),
                  body: Constant.loader(message: "Loading order details...".tr),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface,
                  appBar: AppBar(
                    backgroundColor: themeChange.getThem()
                        ? AppThemeData.surfaceDark
                        : AppThemeData.surface,
                    centerTitle: false,
                    titleSpacing: 0,
                    title: Text(
                      "Order Details".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 16,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                  ),
                  body: Center(
                    child: Text("Error loading order details".tr),
                  ),
                );
              }

              final bill = snapshot.data!;
              return Scaffold(
                backgroundColor: themeChange.getThem()
                    ? AppThemeData.surfaceDark
                    : AppThemeData.surface,
                appBar: AppBar(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface,
                  centerTitle: false,
                  titleSpacing: 0,
                  title: Text(
                    "Order Details".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppThemeData.medium,
                      fontSize: 16,
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                    ),
                  ),
                ),
                body: controller.isLoading.value
                    ? Constant.loader(message: "Loading order details...".tr)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${'Order'.tr} ${Constant.orderId(orderId: controller.orderModel.value.id.toString())}"
                                              .tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            fontSize: 18,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RoundedButtonFill(
                                    title: controller.orderModel.value.status
                                        .toString()
                                        .tr,
                                    color: Constant.statusColor(
                                        status: controller
                                            .orderModel.value.status
                                            .toString()),
                                    width: 32,
                                    height: 4.5,
                                    radius: 10,
                                    textColor: Constant.statusText(
                                        status: controller
                                            .orderModel.value.status
                                            .toString()),
                                    onPress: () async {},
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              controller.orderModel.value.takeAway == true
                                  ? Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${controller.orderModel.value.vendor?.title ?? 'Jippy Mart'}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      fontSize: 16,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .primary300
                                                              : AppThemeData
                                                                  .primary300,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${controller.orderModel.value.vendor?.location ?? 'Jippy Mart Store'}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontSize: 14,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                final phone = controller
                                                        .orderModel
                                                        .value
                                                        .vendor
                                                        ?.phonenumber
                                                        ?.toString() ??
                                                    'Contact Support';
                                                final vendorId = controller
                                                        .orderModel
                                                        .value
                                                        .vendor
                                                        ?.author
                                                        ?.toString() ??
                                                    'mart_support';
                                                final orderId = controller
                                                    .orderModel.value.id;
                                                debugPrint('[CALL VENDOR]');
                                                debugPrint(
                                                    'Collection: vendors');
                                                debugPrint(
                                                    'Document ID (vendorId): $vendorId');
                                                debugPrint(
                                                    'Order ID: $orderId');
                                                debugPrint(
                                                    'Call Number: $phone');
                                                debugPrint('Calling: Vendor');
                                                if (phone !=
                                                    'Contact Support') {
                                                  Constant.makePhoneCall(phone);
                                                } else {
                                                  ShowToastDialog.showToast(
                                                      "Please contact Jippy Mart support for assistance.");
                                                }
                                              },
                                              child: Container(
                                                width: 42,
                                                height: 42,
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey700
                                                            : AppThemeData
                                                                .grey200),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            120),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SvgPicture.asset(
                                                      "assets/icons/ic_phone_call.svg"),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                ShowToastDialog.showLoader(
                                                    "Please wait".tr);
                                                UserModel? customer =
                                                    await FireStoreUtils
                                                        .getUserProfile(
                                                            controller
                                                                .orderModel
                                                                .value
                                                                .authorID
                                                                .toString());
                                                UserModel? restaurantUser =
                                                    controller
                                                                .orderModel
                                                                .value
                                                                .vendor
                                                                ?.author !=
                                                            null
                                                        ? await FireStoreUtils
                                                            .getUserProfile(
                                                                controller
                                                                    .orderModel
                                                                    .value
                                                                    .vendor!
                                                                    .author
                                                                    .toString())
                                                        : null;
                                                VendorModel? vendorModel =
                                                    await FireStoreUtils
                                                        .getVendorById(
                                                            restaurantUser!
                                                                .vendorID
                                                                .toString());
                                                ShowToastDialog.closeLoader();
                                                debugPrint(
                                                    'VENDOR CHAT BUTTON PRESSED');
                                                debugPrint(
                                                    'ChatType: restaurant');
                                                debugPrint(
                                                    'To: ${vendorModel!.title} (UserID: ${restaurantUser.id})');
                                                debugPrint(
                                                    'Customer: ${customer!.fullName()} (UserID: ${customer.id})');
                                                Get.to(const ChatScreen(),
                                                    arguments: {
                                                      "customerName":
                                                          '${customer.fullName()}',
                                                      "restaurantName":
                                                          vendorModel.title,
                                                      "orderId": controller
                                                          .orderModel.value.id,
                                                      "restaurantId":
                                                          restaurantUser.id,
                                                      "customerId": customer.id,
                                                      "customerProfileImage":
                                                          customer
                                                              .profilePictureURL,
                                                      "restaurantProfileImage":
                                                          vendorModel.photo,
                                                      "token": restaurantUser
                                                          .fcmToken,
                                                      "chatType": "restaurant",
                                                    });
                                              },
                                              child: Container(
                                                width: 42,
                                                height: 42,
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey700
                                                            : AppThemeData
                                                                .grey200),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            120),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SvgPicture.asset(
                                                      "assets/icons/ic_wechat.svg"),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          children: [
                                            Timeline.tileBuilder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              theme: TimelineThemeData(
                                                nodePosition: 0,
                                                // indicatorPosition: 0,
                                              ),
                                              builder:
                                                  TimelineTileBuilder.connected(
                                                contentsAlign:
                                                    ContentsAlign.basic,
                                                indicatorBuilder:
                                                    (context, index) {
                                                  return SvgPicture.asset(
                                                      "assets/icons/ic_location.svg");
                                                },
                                                connectorBuilder: (context,
                                                    index, connectorType) {
                                                  return const DashedLineConnector(
                                                    color: AppThemeData.grey300,
                                                    gap: 3,
                                                  );
                                                },
                                                contentsBuilder:
                                                    (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                    child: index == 0
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "${controller.orderModel.value.vendor?.title ?? 'Jippy Mart'}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            AppThemeData.semiBold,
                                                                        fontSize:
                                                                            16,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.primary300
                                                                            : AppThemeData.primary300,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "${controller.orderModel.value.vendor?.location ?? 'Jippy Mart Store'}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            AppThemeData.medium,
                                                                        fontSize:
                                                                            14,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.grey300
                                                                            : AppThemeData.grey600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // InkWell(
                                                              //   onTap: () {
                                                              //     Constant.makePhoneCall(controller
                                                              //         .orderModel
                                                              //         .value
                                                              //         .vendor!
                                                              //         .phonenumber
                                                              //         .toString());
                                                              //   },
                                                              //   child:
                                                              //       Container(
                                                              //     width: 42,
                                                              //     height: 42,
                                                              //     decoration:
                                                              //         ShapeDecoration(
                                                              //       shape:
                                                              //           RoundedRectangleBorder(
                                                              //         side: BorderSide(
                                                              //             width:
                                                              //                 1,
                                                              //             color: themeChange.getThem()
                                                              //                 ? AppThemeData.grey700
                                                              //                 : AppThemeData.grey200),
                                                              //         borderRadius:
                                                              //             BorderRadius.circular(
                                                              //                 120),
                                                              //       ),
                                                              //     ),
                                                              //     child:
                                                              //         Padding(
                                                              //       padding:
                                                              //           const EdgeInsets
                                                              //               .all(
                                                              //               8.0),
                                                              //       child: SvgPicture
                                                              //           .asset(
                                                              //               "assets/icons/ic_phone_call.svg"),
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  ShowToastDialog
                                                                      .showLoader(
                                                                          "Please wait"
                                                                              .tr);

                                                                  UserModel?
                                                                      customer =
                                                                      await FireStoreUtils.getUserProfile(controller
                                                                          .orderModel
                                                                          .value
                                                                          .authorID
                                                                          .toString());
                                                                  UserModel?
                                                                      restaurantUser =
                                                                      await FireStoreUtils.getUserProfile(controller
                                                                          .orderModel
                                                                          .value
                                                                          .vendor!
                                                                          .author
                                                                          .toString());
                                                                  VendorModel?
                                                                      vendorModel =
                                                                      await FireStoreUtils.getVendorById(restaurantUser!
                                                                          .vendorID
                                                                          .toString());
                                                                  ShowToastDialog
                                                                      .closeLoader();

                                                                  Get.to(
                                                                      const ChatScreen(),
                                                                      arguments: {
                                                                        "customerName":
                                                                            '${customer!.fullName()}',
                                                                        "restaurantName":
                                                                            restaurantUser!.fullName(),
                                                                        "orderId": controller
                                                                            .orderModel
                                                                            .value
                                                                            .id,
                                                                        "restaurantId":
                                                                            restaurantUser.id,
                                                                        "customerId":
                                                                            customer.id,
                                                                        "customerProfileImage":
                                                                            customer.profilePictureURL,
                                                                        "restaurantProfileImage":
                                                                            restaurantUser.profilePictureURL,
                                                                        "token":
                                                                            restaurantUser.fcmToken,
                                                                        "chatType":
                                                                            "restaurant",
                                                                      });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 42,
                                                                  height: 42,
                                                                  decoration:
                                                                      ShapeDecoration(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.grey700
                                                                              : AppThemeData.grey200),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              120),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: SvgPicture
                                                                        .asset(
                                                                            "assets/icons/ic_wechat.svg"),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "${controller.orderModel.value.address!.addressAs}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  fontSize: 16,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .primary300
                                                                      : AppThemeData
                                                                          .primary300,
                                                                ),
                                                              ),
                                                              Text(
                                                                controller
                                                                    .orderModel
                                                                    .value
                                                                    .address!
                                                                    .getFullAddress(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  fontSize: 14,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey300
                                                                      : AppThemeData
                                                                          .grey600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  );
                                                },
                                                itemCount: 2,
                                              ),
                                            ),
                                            controller.orderModel.value
                                                        .status ==
                                                    Constant.orderRejected
                                                ? const SizedBox()
                                                : Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: MySeparator(
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey700
                                                                : AppThemeData
                                                                    .grey200),
                                                      ),
                                                      controller.orderModel.value
                                                                      .status ==
                                                                  Constant
                                                                      .orderCompleted &&
                                                              controller
                                                                      .orderModel
                                                                      .value
                                                                      .driver !=
                                                                  null
                                                          ? Row(
                                                              children: [
                                                                SvgPicture.asset(
                                                                    "assets/icons/ic_check_small.svg"),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  controller
                                                                      .orderModel
                                                                      .value
                                                                      .driver!
                                                                      .fullName(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey100
                                                                        : AppThemeData
                                                                            .grey800,
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "Order Delivered."
                                                                      .tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey100
                                                                        : AppThemeData
                                                                            .grey800,
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .regular,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : controller
                                                                          .orderModel
                                                                          .value
                                                                          .status ==
                                                                      Constant
                                                                          .orderAccepted ||
                                                                  controller
                                                                          .orderModel
                                                                          .value
                                                                          .status ==
                                                                      Constant
                                                                          .driverPending
                                                              ? Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                            "assets/icons/ic_timer.svg"),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        "${'Your Order has been Preparing and assign to the driver'.tr}\n${'Preparation Time'.tr} ${controller.orderModel.value.estimatedTimeToPrepare}"
                                                                            .tr,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: themeChange.getThem()
                                                                              ? AppThemeData.warning400
                                                                              : AppThemeData.warning400,
                                                                          fontFamily:
                                                                              AppThemeData.semiBold,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : controller
                                                                          .orderModel
                                                                          .value
                                                                          .driver !=
                                                                      null
                                                                  ? Row(
                                                                      children: [
                                                                        ClipOval(
                                                                          child:
                                                                              NetworkImageWidget(
                                                                            imageUrl:
                                                                                controller.orderModel.value.author!.profilePictureURL.toString(),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            height:
                                                                                Responsive.height(5, context),
                                                                            width:
                                                                                Responsive.width(10, context),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                controller.orderModel.value.driver!.fullName().toString(),
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(
                                                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                  fontFamily: AppThemeData.semiBold,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                controller.orderModel.value.driver!.email.toString(),
                                                                                textAlign: TextAlign.start,
                                                                                style: TextStyle(
                                                                                  color: themeChange.getThem() ? AppThemeData.success400 : AppThemeData.success400,
                                                                                  fontFamily: AppThemeData.regular,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Constant.makePhoneCall(controller.orderModel.value.driver!.phoneNumber.toString());
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                42,
                                                                            height:
                                                                                42,
                                                                            decoration:
                                                                                ShapeDecoration(
                                                                              shape: RoundedRectangleBorder(
                                                                                side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                                borderRadius: BorderRadius.circular(120),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            ShowToastDialog.showLoader("Please wait".tr);

                                                                            UserModel?
                                                                                customer =
                                                                                await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                                            UserModel?
                                                                                driverUser =
                                                                                await FireStoreUtils.getUserProfile(controller.orderModel.value.driverID.toString());

                                                                            ShowToastDialog.closeLoader();

                                                                            Get.to(const ChatScreen(), arguments: {
                                                                              "customerName": '${customer!.fullName()}',
                                                                              "restaurantName": driverUser!.fullName(),
                                                                              "orderId": controller.orderModel.value.id,
                                                                              "restaurantId": driverUser.id,
                                                                              "customerId": customer.id,
                                                                              "customerProfileImage": customer.profilePictureURL,
                                                                              "restaurantProfileImage": driverUser.profilePictureURL,
                                                                              "token": driverUser.fcmToken,
                                                                              "chatType": "Driver",
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                42,
                                                                            height:
                                                                                42,
                                                                            decoration:
                                                                                ShapeDecoration(
                                                                              shape: RoundedRectangleBorder(
                                                                                side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                                borderRadius: BorderRadius.circular(120),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                                  : const SizedBox(),
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 14,
                              ),
                              Text(
                                "Your Order".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  fontSize: 16,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: controller
                                        .orderModel.value.products!.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      CartProductModel cartProductModel =
                                          controller.orderModel.value
                                              .products![index];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(14)),
                                                child: Stack(
                                                  children: [
                                                    NetworkImageWidget(
                                                      imageUrl: cartProductModel
                                                          .photo
                                                          .toString(),
                                                      height: Responsive.height(
                                                          8, context),
                                                      width: Responsive.width(
                                                          16, context),
                                                      fit: BoxFit.cover,
                                                      fixOrientation: true,
                                                    ),
                                                    Container(
                                                      height: Responsive.height(
                                                          8, context),
                                                      width: Responsive.width(
                                                          16, context),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              const Alignment(
                                                                  -0.00, -1.00),
                                                          end: const Alignment(
                                                              0, 1),
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(0),
                                                            const Color(
                                                                0xFF111827)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "${cartProductModel.name}",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .regular,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "x ${cartProductModel.quantity}",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .regular,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    (() {
                                                      // Check if this is a promotional item
                                                      final priceValue =
                                                          double.tryParse(
                                                                  cartProductModel
                                                                      .price
                                                                      .toString()) ??
                                                              0.0;
                                                      final discountPriceValue =
                                                          double.tryParse(cartProductModel
                                                                  .discountPrice
                                                                  .toString()) ??
                                                              0.0;
                                                      final hasPromo =
                                                          cartProductModel
                                                                      .promoId !=
                                                                  null &&
                                                              cartProductModel
                                                                  .promoId!
                                                                  .isNotEmpty;
                                                      final isPricePromotional =
                                                          priceValue > 0 &&
                                                              discountPriceValue >
                                                                  0 &&
                                                              priceValue <
                                                                  discountPriceValue;
                                                      final isPromotional =
                                                          hasPromo ||
                                                              isPricePromotional;

                                                      if (isPromotional) {
                                                        // For promotional items: price = promotional, discountPrice = original
                                                        return Row(
                                                          children: [
                                                            Text(
                                                              Constant.amountShow(
                                                                  amount: cartProductModel
                                                                      .price
                                                                      .toString()),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              Constant.amountShow(
                                                                  amount: cartProductModel
                                                                      .discountPrice
                                                                      .toString()),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                decorationColor: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } else if (double.parse(cartProductModel
                                                                          .discountPrice ==
                                                                      null ||
                                                                  cartProductModel
                                                                      .discountPrice!
                                                                      .isEmpty
                                                              ? "0.0"
                                                              : cartProductModel
                                                                  .discountPrice
                                                                  .toString()) <=
                                                          0) {
                                                        // No discount - show regular price
                                                        return Text(
                                                          Constant.amountShow(
                                                              amount:
                                                                  cartProductModel
                                                                      .price),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontFamily:
                                                                AppThemeData
                                                                    .semiBold,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        );
                                                      } else {
                                                        // Regular discount - show discount price prominently, original price strikethrough
                                                        return Row(
                                                          children: [
                                                            Text(
                                                              Constant.amountShow(
                                                                  amount: cartProductModel
                                                                      .discountPrice
                                                                      .toString()),
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              Constant.amountShow(
                                                                  amount:
                                                                      cartProductModel
                                                                          .price),
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                decorationColor: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey500
                                                                    : AppThemeData
                                                                        .grey400,
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    })(),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: RoundedButtonFill(
                                                        title: "Rate us".tr,
                                                        height: 3.8,
                                                        width: 20,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .warning300
                                                            : AppThemeData
                                                                .warning300,
                                                        textColor: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey100
                                                            : AppThemeData
                                                                .grey800,
                                                        onPress: () async {
                                                          Get.to(
                                                              const RateProductScreen(),
                                                              arguments: {
                                                                "orderModel":
                                                                    controller
                                                                        .orderModel
                                                                        .value,
                                                                "productId":
                                                                    cartProductModel
                                                                        .id
                                                              });
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          cartProductModel.variantInfo ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                      .variantOptions!.isEmpty
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Variants".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .semiBold,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Wrap(
                                                        spacing: 6.0,
                                                        runSpacing: 6.0,
                                                        children: List.generate(
                                                          cartProductModel
                                                              .variantInfo!
                                                              .variantOptions!
                                                              .length,
                                                          (i) {
                                                            return Container(
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey800
                                                                    : AppThemeData
                                                                        .grey100,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        5),
                                                                child: Text(
                                                                  "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .medium,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          cartProductModel.extras == null ||
                                                  cartProductModel
                                                      .extras!.isEmpty
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Addons".tr,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey300
                                                                  : AppThemeData
                                                                      .grey600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          Constant.amountShow(
                                                              amount: (double.parse(cartProductModel
                                                                          .extrasPrice
                                                                          .toString()) *
                                                                      double.parse(cartProductModel
                                                                          .quantity
                                                                          .toString()))
                                                                  .toString()),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
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
                                                      ],
                                                    ),
                                                    Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 6.0,
                                                      children: List.generate(
                                                        cartProductModel
                                                            .extras!.length,
                                                        (i) {
                                                          return Container(
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          5),
                                                              child: Text(
                                                                cartProductModel
                                                                    .extras![i]
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: MySeparator(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey700
                                                : AppThemeData.grey200),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              Text(
                                "Bill Details".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  fontSize: 16,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
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
                                              "Item totals".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount:
                                                    bill.subTotal.toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Delivery Fee".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          (() {
                                            // Check if cart has promotional items
                                            final hasPromotionalItems =
                                                order.products!.any((item) {
                                              final priceValue =
                                                  double.tryParse(item.price
                                                          .toString()) ??
                                                      0.0;
                                              final discountPriceValue =
                                                  double.tryParse(item
                                                          .discountPrice
                                                          .toString()) ??
                                                      0.0;
                                              final hasPromo =
                                                  item.promoId != null &&
                                                      item.promoId!.isNotEmpty;
                                              final isPricePromotional =
                                                  priceValue > 0 &&
                                                      discountPriceValue > 0 &&
                                                      priceValue <
                                                          discountPriceValue;
                                              return hasPromo ||
                                                  isPricePromotional;
                                            });

                                            // Self delivery check
                                            if (vendor?.isSelfDelivery ==
                                                    true &&
                                                Constant.isSelfDeliveryFeature ==
                                                    true) {
                                              return Text(
                                                'Free Delivery',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.regular,
                                                  color:
                                                      AppThemeData.success400,
                                                  fontSize: 16,
                                                ),
                                              );
                                            }

                                            // Promotional items delivery logic
                                            if (hasPromotionalItems) {
                                              // For promotional items, check if within free delivery distance (3 km)
                                              if (totalDistance <= 3.0) {
                                                // Free delivery for promotional items within 3 km
                                                return Row(
                                                  children: [
                                                    Text(
                                                      'Free Delivery',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: AppThemeData
                                                            .success400,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: '23.00'),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: AppThemeData
                                                            .danger300,
                                                        fontSize: 16,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            AppThemeData
                                                                .danger300,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: '0.00'),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                // Paid delivery for promotional items beyond 3 km
                                                return Row(
                                                  children: [
                                                    Text(
                                                      'Delivery Charge',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: bill
                                                              .deliveryCharges
                                                              .toString()),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            }

                                            // Regular items delivery logic - continue with existing logic
                                            if (bill.subTotal >=
                                                    (deliveryCharge
                                                            .itemTotalThreshold ??
                                                        299) &&
                                                totalDistance >
                                                    (deliveryCharge
                                                            .freeDeliveryDistanceKm ??
                                                        7)) {
                                              return Row(
                                                children: [
                                                  Text(
                                                    'Free Delivery',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: AppThemeData
                                                          .success400,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    Constant.amountShow(
                                                        amount: bill
                                                            .originalDeliveryFee
                                                            .toString()),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: AppThemeData
                                                          .danger300,
                                                      fontSize: 16,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          AppThemeData
                                                              .danger300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    Constant.amountShow(
                                                        amount: bill
                                                            .deliveryCharges
                                                            .toString()),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey50
                                                          : AppThemeData
                                                              .grey900,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            if (bill.subTotal >=
                                                    (deliveryCharge
                                                            .itemTotalThreshold ??
                                                        299) &&
                                                totalDistance <=
                                                    (deliveryCharge
                                                            .freeDeliveryDistanceKm ??
                                                        7)) {
                                              return Row(
                                                children: [
                                                  Text(
                                                    'Free Delivery',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: AppThemeData
                                                          .success400,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    Constant.amountShow(
                                                        amount: (deliveryCharge
                                                                    .baseDeliveryCharge ??
                                                                23)
                                                            .toString()),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: AppThemeData
                                                          .danger300,
                                                      fontSize: 16,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          AppThemeData
                                                              .danger300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    Constant.amountShow(
                                                        amount: '0.00'),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey50
                                                          : AppThemeData
                                                              .grey900,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            // Default case - paid delivery
                                            return Row(
                                              children: [
                                                Text(
                                                  'Delivery Charge',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  Constant.amountShow(
                                                      amount: bill
                                                          .deliveryCharges
                                                          .toString()),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            );
                                          })()
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Platform Fee".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '15.00',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: AppThemeData.danger300,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  AppThemeData.danger300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Surge Fee".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "₹${surgeFee ?? 0.0}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Coupon Discount".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "- (${Constant.amountShow(amount: order.discount.toString())})",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.danger300
                                                  : AppThemeData.danger300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      order.specialDiscount != null &&
                                              order.specialDiscount![
                                                      'special_discount'] !=
                                                  null
                                          ? Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Special Discount".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "- (${Constant.amountShow(amount: order.specialDiscount!['special_discount'].toString())})",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color:
                                                            themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .danger300
                                                                : AppThemeData
                                                                    .danger300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      order.takeAway == true ||
                                              vendor?.isSelfDelivery == true
                                          ? const SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Delivery Tips".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  Constant.amountShow(
                                                      amount: order.tipAmount
                                                          .toString()),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Taxes & Charges",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount:
                                                    bill.taxAmount.toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "To Pay".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount:
                                                    "${bill.totalAmount + (surgeFee ?? 0.0)}"),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              Text(
                                "Order Detailss".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  fontSize: 16,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
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
                                              "Delivery type".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            order.takeAway == true
                                                ? "TakeAway".tr
                                                : order.scheduleTime == null
                                                    ? "Standard".tr
                                                    : "Schedule".tr,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.medium,
                                              color: order.scheduleTime != null
                                                  ? AppThemeData.primary300
                                                  : themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Payment Method".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            order.paymentMethod.toString(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Date and Time".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.timestampToDateTime(
                                                order.createdAt!),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey300
                                                  : AppThemeData.grey600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Phone Number".tr,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey300
                                                        : AppThemeData.grey600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            order.author!.phoneNumber
                                                .toString(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              order.notes == null || order.notes!.isEmpty
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Remarks".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            fontSize: 16,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
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
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 14),
                                            child: Text(
                                              order.notes.toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey900,
                                                fontSize: 16,
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
                bottomNavigationBar: order.status == Constant.orderShipped ||
                        order.status == Constant.orderInTransit ||
                        order.status == Constant.orderCompleted
                    ? Container(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: order.status == Constant.orderShipped ||
                                  order.status == Constant.orderInTransit
                              ? RoundedButtonFill(
                                  title: "Track Order".tr,
                                  height: 5.5,
                                  color: AppThemeData.warning300,
                                  textColor: AppThemeData.grey900,
                                  onPress: () async {
                                    Get.to(const LiveTrackingScreen(),
                                        arguments: {"orderModel": order});
                                  },
                                )
                              : RoundedButtonFill(
                                  title: "Reorder".tr,
                                  height: 5.5,
                                  color: AppThemeData.primary300,
                                  textColor: AppThemeData.grey50,
                                  onPress: () async {
                                    for (var element in order.products!) {
                                      controller.addToCart(
                                          cartProductModel: element);
                                      ShowToastDialog.showToast(
                                          "Item Added In a cart".tr);
                                    }
                                  },
                                ),
                        ),
                      )
                    : const SizedBox(),
              );
            });
      },
    );
  }
}
