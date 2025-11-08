import 'package:customer/app/cart_screen/select_payment_screen.dart';
import 'package:customer/app/cart_screen/widget/cart_build_delivery_ui.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/payment/createRazorPayOrderModel.dart';
import 'package:customer/payment/rozorpayConroller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Widget cartNavigationBarWidget(DarkThemeProvider themeChange,
    CartController controller, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
        color:
            themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          // Expanded(
          //   flex: 2,
          //   child: InkWell(
          //     onTap: () {
          //       Get.to(const SelectPaymentScreen());
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         controller.selectedPaymentMethod.value == ''
          //             ? cardDecoration(
          //                 controller, PaymentGateway.wallet, themeChange, "")
          //             : controller.selectedPaymentMethod.value ==
          //                     PaymentGateway.wallet.name
          //                 ? cardDecoration(controller, PaymentGateway.wallet,
          //                     themeChange, "assets/images/ic_wallet.png")
          //                 : controller.selectedPaymentMethod.value ==
          //                         PaymentGateway.cod.name
          //                     ? cardDecoration(controller, PaymentGateway.cod,
          //                         themeChange, "assets/images/ic_cash.png")
          //                     : controller.selectedPaymentMethod.value ==
          //                             PaymentGateway.stripe.name
          //                         ? cardDecoration(
          //                             controller,
          //                             PaymentGateway.stripe,
          //                             themeChange,
          //                             "assets/images/stripe.png")
          //                         : controller.selectedPaymentMethod.value ==
          //                                 PaymentGateway.paypal.name
          //                             ? cardDecoration(
          //                                 controller,
          //                                 PaymentGateway.paypal,
          //                                 themeChange,
          //                                 "assets/images/paypal.png")
          //                             : controller.selectedPaymentMethod.value ==
          //                                     PaymentGateway.payStack.name
          //                                 ? cardDecoration(
          //                                     controller,
          //                                     PaymentGateway.payStack,
          //                                     themeChange,
          //                                     "assets/images/paystack.png")
          //                                 : controller.selectedPaymentMethod.value ==
          //                                         PaymentGateway
          //                                             .mercadoPago.name
          //                                     ? cardDecoration(
          //                                         controller,
          //                                         PaymentGateway.mercadoPago,
          //                                         themeChange,
          //                                         "assets/images/mercado-pago.png")
          //                                     : controller.selectedPaymentMethod.value ==
          //                                             PaymentGateway
          //                                                 .flutterWave.name
          //                                         ? cardDecoration(
          //                                             controller,
          //                                             PaymentGateway
          //                                                 .flutterWave,
          //                                             themeChange,
          //                                             "assets/images/flutterwave_logo.png")
          //                                         : controller.selectedPaymentMethod.value ==
          //                                                 PaymentGateway
          //                                                     .payFast.name
          //                                             ? cardDecoration(
          //                                                 controller,
          //                                                 PaymentGateway
          //                                                     .payFast,
          //                                                 themeChange,
          //                                                 "assets/images/payfast.png")
          //                                             : controller.selectedPaymentMethod.value ==
          //                                                     PaymentGateway
          //                                                         .paytm.name
          //                                                 ? cardDecoration(
          //                                                     controller,
          //                                                     PaymentGateway
          //                                                         .paytm,
          //                                                     themeChange,
          //                                                     "assets/images/paytm.png")
          //                                                 : controller.selectedPaymentMethod
          //                                                             .value ==
          //                                                         PaymentGateway
          //                                                             .midTrans
          //                                                             .name
          //                                                     ? cardDecoration(
          //                                                         controller,
          //                                                         PaymentGateway
          //                                                             .midTrans,
          //                                                         themeChange,
          //                                                         "assets/images/midtrans.png")
          //                                                     : controller.selectedPaymentMethod.value ==
          //                                                             PaymentGateway
          //                                                                 .orangeMoney
          //                                                                 .name
          //                                                         ? cardDecoration(controller, PaymentGateway.orangeMoney, themeChange, "assets/images/orange_money.png")
          //                                                         : controller.selectedPaymentMethod.value == PaymentGateway.xendit.name
          //                                                             ? cardDecoration(controller, PaymentGateway.xendit, themeChange, "assets/images/xendit.png")
          //                                                             : cardDecoration(controller, PaymentGateway.razorpay, themeChange, "assets/images/razorpay.png"),
          //         const SizedBox(
          //           width: 10,
          //         ),
          //         Column(
          //           mainAxisSize: MainAxisSize.min,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Pay Via".tr,
          //               textAlign: TextAlign.start,
          //               style: TextStyle(
          //                 fontFamily: AppThemeData.semiBold,
          //                 color: themeChange.getThem()
          //                     ? AppThemeData.grey400
          //                     : AppThemeData.grey500,
          //                 fontSize: 12,
          //               ),
          //             ),
          //             controller.selectedPaymentMethod.value == ''
          //                 ? Padding(
          //                     padding: const EdgeInsets.only(top: 4),
          //                     child: Container(
          //                         width: 60,
          //                         height: 12,
          //                         color: themeChange.getThem()
          //                             ? AppThemeData.grey800
          //                             : AppThemeData.grey100),
          //                   )
          //                 : Text(
          //                     controller.selectedPaymentMethod.value,
          //                     textAlign: TextAlign.start,
          //                     style: TextStyle(
          //                       fontFamily: AppThemeData.semiBold,
          //                       color: themeChange.getThem()
          //                           ? AppThemeData.grey50
          //                           : AppThemeData.grey900,
          //                       fontSize: 16,
          //                     ),
          //                   ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: RoundedButtonFill(
              textColor: AppThemeData.surface,
              isEnabled: true,
              title: controller.isProcessingOrder.value
                  ? "Processing...".tr
                  : "Place Order".tr,
              height: 5,
              color: AppThemeData.primary300,
              fontSizes: 16,
              onPress: () async {
                if (controller.isProcessingOrder.value) {
                  ShowToastDialog.showToast(
                      "Please wait, order is being processed...".tr);
                  return;
                }
                // print("${controller.vendorModel.value.author.toString()} "
                //     " ${controller.vendorModel.value.authorName.toString()}  ${controller.vendorModel.value.categoryTitle.toString()}  vendorModel.value.author ");

                await controller.showPaymentMethodDialog(context);
                if (controller.selectedPaymentMethod.value.isNotEmpty) {
                  await _processPayment(controller, context);
                }
              },
            ),
          ),
          // Expanded(
          //   child: RoundedButtonFill(
          //     textColor: AppThemeData.surface, // Always use primary text color
          //     isEnabled:
          //         true, // Always enable so user can see validation messages
          //     title: controller.isProcessingOrder.value
          //         ? "Processing...".tr
          //         : "Pay Now".tr,
          //     height: 5,
          //     color: AppThemeData.primary300, // Always use primary color
          //     fontSizes: 16,
          //     onPress: () async {
          //       final testResult = await controller.validateAndPlaceOrder();
          //       // Prevent multiple rapid clicks
          //       if (controller.isProcessingOrder.value) {
          //         ShowToastDialog.showToast(
          //             "Please wait, order is being processed...".tr);
          //         return;
          //       }
          //       final validationStartTime = DateTime.now();
          //       final canProceed =
          //           await controller.validateAndPlaceOrderBulletproof();
          //       final validationDuration =
          //           DateTime.now().difference(validationStartTime);
          //       if (!canProceed) {
          //         return;
          //       }
          //       if ((controller.couponAmount.value >= 1) &&
          //           (controller.couponAmount.value >
          //               controller.totalAmount.value)) {
          //         ShowToastDialog.showToast(
          //             "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total."
          //                 .tr);
          //         return;
          //       }
          //       if ((controller.specialDiscountAmount.value >= 1) &&
          //           (controller.specialDiscountAmount.value >
          //               controller.totalAmount.value)) {
          //         ShowToastDialog.showToast(
          //             "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total."
          //                 .tr);
          //         return;
          //       }
          //       if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.stripe.name) {
          //         // controller.stripeMakePayment(
          //         //     amount: controller.totalAmount.value
          //         //         .toString());
          //         ShowToastDialog.showToast("Stripe payment is disabled".tr);
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.paypal.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayPal
          //         controller.paypalPaymentSheet(
          //             controller.totalAmount.value.toString(), context);
          //
          //         /*
          //                         // OLD PAYPAL VALIDATION CODE - COMMENTED OUT FOR REFERENCE
          //                         // Comprehensive address validation for PayPal
          //                         if (controller.selectedAddress.value == null) {
          //                           ShowToastDialog.showToast("Please select a delivery address before placing your order.".tr);
          //                           return;
          //                         }
          //
          //                         // Check if address has required fields
          //                         if (controller.selectedAddress.value!.address == null ||
          //                             controller.selectedAddress.value!.address!.trim().isEmpty ||
          //                             controller.selectedAddress.value!.address == 'null') {
          //                           ShowToastDialog.showToast("Please select a valid delivery address with complete address details.".tr);
          //                           return;
          //                         }
          //
          //                         // Check if address has location coordinates
          //                         if (controller.selectedAddress.value!.location == null ||
          //                             controller.selectedAddress.value!.location!.latitude == null ||
          //                             controller.selectedAddress.value!.location!.longitude == null) {
          //                           ShowToastDialog.showToast("Please select a delivery address with valid location coordinates.".tr);
          //                           return;
          //                         }
          //
          //                         // Prevent order if fallback location is used
          //                         if (controller.selectedAddress.value?.locality == 'Ongole, Andhra Pradesh, India') {
          //                           ShowToastDialog.showToast("Please select your actual address or use current location to place order.".tr);
          //                           return;
          //                         }
          //                         */
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.payStack.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayStack
          //         controller
          //             .payStackPayment(controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.mercadoPago.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with MercadoPago
          //         controller.mercadoPagoMakePayment(
          //             context: context,
          //             amount: controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.flutterWave.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with FlutterWave
          //         controller.flutterWaveInitiatePayment(
          //             context: context,
          //             amount: controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.payFast.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayFast
          //         controller.payFastPayment(
          //             context: context,
          //             amount: controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.paytm.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Paytm
          //         controller.getPaytmCheckSum(context,
          //             amount: double.parse(
          //                 controller.totalAmount.value.toString()));
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.cod.name) {
          //         controller.placeOrder();
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.wallet.name) {
          //         controller.placeOrder();
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.midTrans.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with MidTrans
          //         controller.midtransMakePayment(
          //             context: context,
          //             amount: controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.orangeMoney.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Orange Money
          //         controller.orangeMakePayment(
          //             context: context,
          //             amount: controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.xendit.name) {
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Xendit
          //         controller.xenditPayment(
          //             context, controller.totalAmount.value.toString());
          //       } else if (controller.selectedPaymentMethod.value ==
          //           PaymentGateway.razorpay.name) {
          //         print(" rozer pay started ");
          //         // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Razorpay
          //         RazorPayController()
          //             .createOrderRazorPay(
          //                 amount: double.parse(
          //                     controller.totalAmount.value.toString()),
          //                 razorpayModel: controller.razorPayModel.value)
          //             .then((value) async {
          //           if (value == null) {
          //             Get.back();
          //             ShowToastDialog.showToast(
          //                 "Something went wrong, please contact admin.".tr);
          //           } else {
          //             CreateRazorPayOrderModel result = value;
          //             print(
          //                 "${controller.totalAmount.value.toString()} totalamount rozer pay");
          //             print(
          //                 "${value.amount.toString()} totalamount rozer pay new ");
          //             controller.openCheckout(
          //                 amount: value.amount, orderId: result.id);
          //           }
          //         });
          //         /*
          //                         // OLD RAZORPAY VALIDATION CODE - COMMENTED OUT FOR REFERENCE
          //                         // Comprehensive address validation for Razorpay
          //                         if (controller.selectedAddress.value == null) {
          //                           ShowToastDialog.showToast("Please select a delivery address before placing your order.".tr);
          //                           return;
          //                         }
          //
          //                         // Check if address has required fields
          //                         if (controller.selectedAddress.value!.address == null ||
          //                             controller.selectedAddress.value!.address!.trim().isEmpty ||
          //                             controller.selectedAddress.value!.address == 'null') {
          //                           ShowToastDialog.showToast("Please select a valid delivery address with complete address details.".tr);
          //                           return;
          //                         }
          //
          //                         // Check if address has location coordinates
          //                         if (controller.selectedAddress.value!.location == null ||
          //                             controller.selectedAddress.value!.location!.latitude == null ||
          //                             controller.selectedAddress.value!.location!.longitude == null) {
          //                           ShowToastDialog.showToast("Please select a delivery address with valid location coordinates.".tr);
          //                           return;
          //                         }
          //
          //                         // Prevent order if fallback location is used
          //                         if (controller.selectedAddress.value?.locality == 'Ongole, Andhra Pradesh, India') {
          //                           ShowToastDialog.showToast("Please select your actual address or use current location to place order.".tr);
          //                           return;
          //                         }
          //
          //                         // Validate mart minimum order value before proceeding with Razorpay payment
          //                         try {
          //                           await controller.validateMinimumOrderValue();
          //                         } catch (e) {
          //                           print('DEBUG: Mart minimum order validation failed for Razorpay: $e');
          //                           return; // Stop the payment process
          //                         }
          //
          //                         // 🔑 CRITICAL: Validate delivery zone before Razorpay payment
          //                         bool validationPassed = await controller.validateOrderBeforePayment();
          //                         if (!validationPassed) {
          //                           print('DEBUG: Delivery zone validation failed for Razorpay - blocking payment');
          //                           return; // Stop the payment process
          //                         }
          //                         */
          //       } else {
          //         ShowToastDialog.showToast("Please select payment method".tr);
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    ),
  );

}
Future<void> _processPayment(CartController controller, BuildContext context) async {
  // Run bulletproof validation
  final validationStartTime = DateTime.now();
  final canProceed = await controller.validateAndPlaceOrderBulletproof();
  final validationDuration = DateTime.now().difference(validationStartTime);
  if (!canProceed) {
    return;
  }
  // Validate coupon and discount amounts
  if ((controller.couponAmount.value >= 1) &&
      (controller.couponAmount.value > controller.totalAmount.value)) {
    ShowToastDialog.showToast(
        "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total."
            .tr);
    return;
  }
  if ((controller.specialDiscountAmount.value >= 1) &&
      (controller.specialDiscountAmount.value > controller.totalAmount.value)) {
    ShowToastDialog.showToast(
        "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total."
            .tr);
    return;
  }
  // Process based on selected payment method
  if (controller.selectedPaymentMethod.value == PaymentGateway.stripe.name) {
    ShowToastDialog.showToast("Stripe payment is disabled".tr);
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.paypal.name) {
    controller.paypalPaymentSheet(controller.totalAmount.value.toString(), context);
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.payStack.name) {
    controller.payStackPayment(controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.mercadoPago.name) {
    controller.mercadoPagoMakePayment(
        context: context,
        amount: controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.flutterWave.name) {
    controller.flutterWaveInitiatePayment(
        context: context,
        amount: controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.payFast.name) {
    controller.payFastPayment(
        context: context,
        amount: controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.paytm.name) {
    controller.getPaytmCheckSum(context,
        amount: double.parse(controller.totalAmount.value.toString()));
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.cod.name) {
    controller.placeOrder();
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.wallet.name) {
    controller.placeOrder();
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.midTrans.name) {
    controller.midtransMakePayment(
        context: context,
        amount: controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.orangeMoney.name) {
    controller.orangeMakePayment(
        context: context,
        amount: controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.xendit.name) {
    controller.xenditPayment(context, controller.totalAmount.value.toString());
  } else if (controller.selectedPaymentMethod.value == PaymentGateway.razorpay.name) {
    print("Razorpay payment started");
    RazorPayController()
        .createOrderRazorPay(
        amount: double.parse(controller.totalAmount.value.toString()),
        razorpayModel: controller.razorPayModel.value)
        .then((value) async {
      if (value == null) {
        Get.back();
        ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      } else {
        CreateRazorPayOrderModel result = value;
        controller.openCheckout(amount: value.amount, orderId: result.id);
      }
    });
  } else {
    ShowToastDialog.showToast("Please select payment method".tr);
  }

}