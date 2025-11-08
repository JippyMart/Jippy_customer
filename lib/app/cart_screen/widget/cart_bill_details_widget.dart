
import 'package:customer/app/cart_screen/widget/cart_build_delivery_ui.dart';

import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/coupon_model.dart';

import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Widget billCartWidget(DarkThemeProvider themeChange, CartController controller,
    BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bill Details".tr,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Item totals".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(
                          amount: controller.subTotal.value.toString()),
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
                controller.selectedFoodType.value == 'TakeAway'
                    ? const SizedBox()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Delivery Fee".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.regular,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Check if cart has promotional items or mart items
                          Obx(() {
                            final hasPromotionalItems =
                                controller.hasPromotionalItems();
                            final hasMartItems =
                                controller.hasMartItemsInCart();

                            // Self delivery check
                            if (controller.vendorModel.value.isSelfDelivery ==
                                    true &&
                                Constant.isSelfDeliveryFeature == true) {
                              return Text(
                                'Free Delivery',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.regular,
                                  color: AppThemeData.success400,
                                  fontSize: 16,
                                ),
                              );
                            }

                            // Promotional items delivery logic
                            if (hasPromotionalItems) {
                              // For promotional items, always show "Free Delivery" UI with strikethrough ₹23
                              // because promotional items are eligible for free delivery base
                              return buildDeliveryFeeUI(
                                isFreeDelivery:
                                    true, // Always true for promotional items to show "Free Delivery"
                                originalFee: 23.0,
                                currentFee: controller.deliveryCharges.value,
                                themeChange: themeChange,
                              );
                            }

                            // Mart items delivery logic - Check free delivery eligibility
                            if (hasMartItems) {
                              print(
                                  '[CART_UI] 🛒 Building mart delivery UI...');
                              print(
                                  '[CART_UI]   - Subtotal: ₹${controller.subTotal.value}');
                              print(
                                  '[CART_UI]   - Distance: ${controller.totalDistance.value} km');
                              print(
                                  '[CART_UI]   - Delivery charges: ₹${controller.deliveryCharges.value}');
                              print(
                                  '[CART_UI]   - Original delivery fee: ₹${controller.originalDeliveryFee.value}');

                              // For mart items, use the same logic as restaurant items
                              // Get mart delivery settings (static values like restaurant)
                              double itemThreshold =
                                  199.0; // Default mart threshold
                              double freeDeliveryKm =
                                  5.0; // Default mart free distance
                              double baseDeliveryCharge =
                                  23.0; // Static base charge

                              final subtotal = controller.subTotal.value;
                              final distance = controller.totalDistance.value;

                              print(
                                  '[CART_UI]   - Mart threshold: ₹$itemThreshold');
                              print(
                                  '[CART_UI]   - Mart free distance: ${freeDeliveryKm} km');
                              print(
                                  '[CART_UI]   - Base delivery charge: ₹$baseDeliveryCharge');

                              // Determine delivery eligibility and charges (same logic as restaurant)
                              final isAboveThreshold =
                                  subtotal >= itemThreshold;
                              final isWithinFreeDistance =
                                  distance <= freeDeliveryKm;

                              print(
                                  '[CART_UI]   - Is above threshold: $isAboveThreshold');
                              print(
                                  '[CART_UI]   - Is within free distance: $isWithinFreeDistance');

                              if (isAboveThreshold) {
                                // Above threshold - eligible for free delivery logic
                                if (isWithinFreeDistance) {
                                  // Standard free delivery: Green "Free Delivery" + strikethrough base charge + ₹0.00
                                  print(
                                      '[CART_UI]   - Mart standard free delivery');
                                  return buildDeliveryFeeUI(
                                    isFreeDelivery: true,
                                    originalFee: baseDeliveryCharge,
                                    currentFee: 0.0,
                                    themeChange: themeChange,
                                  );
                                } else {
                                  // Free delivery with extra charge: Green "Free Delivery" + strikethrough base charge + extra charge
                                  print(
                                      '[CART_UI]   - Mart free delivery with extra charge');
                                  return buildDeliveryFeeUI(
                                    isFreeDelivery: true,
                                    originalFee: baseDeliveryCharge,
                                    currentFee:
                                        controller.deliveryCharges.value,
                                    themeChange: themeChange,
                                  );
                                }
                              } else {
                                // Below threshold - regular paid delivery
                                print(
                                    '[CART_UI]   - Mart regular paid delivery');
                                return buildDeliveryFeeUI(
                                  isFreeDelivery: false,
                                  originalFee: 0.0,
                                  currentFee: controller.deliveryCharges.value,
                                  themeChange: themeChange,
                                );
                              }
                            }

                            // Regular items delivery logic
                            final threshold = controller.deliveryChargeModel
                                    .value.itemTotalThreshold ??
                                299;
                            final freeKm = controller.deliveryChargeModel.value
                                    .freeDeliveryDistanceKm ??
                                7;
                            final subtotal = controller.subTotal.value;
                            final distance = controller.totalDistance.value;

                            print(
                                '[CART_UI] 🍽️ Building regular delivery UI...');
                            print('[CART_UI]   - Subtotal: ₹$subtotal');
                            print('[CART_UI]   - Threshold: ₹$threshold');
                            print('[CART_UI]   - Distance: ${distance} km');
                            print('[CART_UI]   - Free distance: ${freeKm} km');
                            print(
                                '[CART_UI]   - Delivery charges: ₹${controller.deliveryCharges.value}');
                            print(
                                '[CART_UI]   - Original delivery fee: ₹${controller.originalDeliveryFee.value}');

                            // Determine delivery eligibility and charges
                            final isAboveThreshold = subtotal >= threshold;
                            final isWithinFreeDistance = distance <= freeKm;
                            final isEligibleForFreeDelivery =
                                isAboveThreshold && isWithinFreeDistance;

                            print(
                                '[CART_UI]   - Is above threshold: $isAboveThreshold');
                            print(
                                '[CART_UI]   - Is within free distance: $isWithinFreeDistance');
                            print(
                                '[CART_UI]   - Is eligible for free delivery: $isEligibleForFreeDelivery');

                            // Get the base delivery charge for restaurant items (should be ₹23)
                            double baseDeliveryCharge = (controller
                                        .deliveryChargeModel
                                        .value
                                        .baseDeliveryCharge ??
                                    23.0)
                                .toDouble();
                            print(
                                '[CART_UI]   - Base delivery charge: ₹$baseDeliveryCharge');

                            if (isAboveThreshold) {
                              // Above threshold - eligible for free delivery logic
                              if (isWithinFreeDistance) {
                                // Standard free delivery: Green "Free Delivery" + strikethrough base charge + ₹0.00
                                print('[CART_UI]   - Standard free delivery');
                                return buildDeliveryFeeUI(
                                  isFreeDelivery: true,
                                  originalFee:
                                      baseDeliveryCharge, // Show base charge, not calculated total
                                  currentFee: 0.0,
                                  themeChange: themeChange,
                                );
                              } else {
                                // Free delivery with extra charge: Green "Free Delivery" + strikethrough base charge + extra charge
                                print(
                                    '[CART_UI]   - Free delivery with extra charge');
                                return buildDeliveryFeeUI(
                                  isFreeDelivery: true,
                                  originalFee:
                                      baseDeliveryCharge, // Show base charge, not calculated total
                                  currentFee: controller.deliveryCharges.value,
                                  themeChange: themeChange,
                                );
                              }
                            } else {
                              // Below threshold - regular paid delivery
                              print('[CART_UI]   - Regular paid delivery');
                              return buildDeliveryFeeUI(
                                isFreeDelivery: false,
                                originalFee: 0.0,
                                currentFee: controller.deliveryCharges.value,
                                themeChange: themeChange,
                              );
                            }
                          }),
                        ],
                      ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Platform Fee".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                    'Free',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        color: AppThemeData.success400,
                        fontSize: 16,
                      ),
                    ),    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '15.00',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        color: AppThemeData.danger300,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppThemeData.danger300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Surge Fee".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Obx(() {
                      return  Row(
                        children: [
                        Text(
                          controller.surgePercent.value<=0?'Free': "",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: AppThemeData.success400,
                          fontSize: 16,
                        ),
                      ), SizedBox(width: 10,),
                          Text(
                            controller.surgePercent.value<=0?"₹10": "₹${controller.surgePercent.value}",
                            textAlign: TextAlign.start,
                            style:controller.surgePercent.value<=0?
                            TextStyle(
                                  fontFamily: AppThemeData.regular,
                                  color: AppThemeData.danger300,
                                  fontSize: 16,
                                  decoration:
                                  TextDecoration.lineThrough,
                                  decorationColor:
                                  AppThemeData.danger300,
                                )
                                : TextStyle(
                              fontFamily: AppThemeData.regular,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    }),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Coupon Discount".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "- (" +
                              Constant.amountShow(
                                  amount: controller.couponAmount.value
                                      .toString()) +
                              ")",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            color: themeChange.getThem()
                                ? AppThemeData.danger300
                                : AppThemeData.danger300,
                            fontSize: 16,
                          ),
                        ),
                        controller.selectedCouponModel.value.id != null &&
                                controller
                                    .selectedCouponModel.value.id!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    controller.selectedCouponModel.value =
                                        CouponModel();
                                    controller.couponCodeController.value.text =
                                        '';
                                    controller.couponAmount.value = 0.0;
                                    controller.calculatePrice();
                                  },
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      color: AppThemeData.danger300,
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
                controller.specialDiscountAmount.value > 0
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Special Discount".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.regular,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "- (${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())})",
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
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                controller.selectedFoodType.value == 'TakeAway' ||
                        (controller.vendorModel.value.isSelfDelivery == true &&
                            Constant.isSelfDeliveryFeature == true)
                    ? const SizedBox()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivery Tips".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.regular,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
                                    fontSize: 16,
                                  ),
                                ),
                                controller.deliveryTips.value == 0
                                    ? const SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          controller.deliveryTips.value = 0;
                                          controller.calculatePrice();
                                        },
                                        child: Text(
                                          "Remove".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.medium,
                                            color: themeChange.getThem()
                                                ? AppThemeData.primary300
                                                : AppThemeData.primary300,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Text(
                            Constant.amountShow(
                                amount: controller.deliveryTips.toString()),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Taxes & Charges",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(
                          amount: controller.taxAmount.value.toString()),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "To Pay".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(
                          amount: controller.totalAmount.value.toString()),
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
      ],
    ),
  );
}
