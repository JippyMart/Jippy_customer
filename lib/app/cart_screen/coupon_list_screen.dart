import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/utils/color_const.dart';
import 'package:customer/utils/utils/image_const.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/src/dotted_border_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CartController>(
        builder: (controller) {
          // Ensure coupons are loaded when screen opens
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('[COUPON_DEBUG] 🖥️ Coupon screen opened, ensuring coupons are loaded...');
            controller.ensureCouponsLoaded();
          });
          // Show 'No coupons available' if couponList is empty and loading is done
          if (controller.couponList.isEmpty) {
            return Scaffold(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              appBar: AppBar(
                backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                centerTitle: false,
                titleSpacing: 0,
                title: Text(
                  "Coupon Code".tr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.medium,
                    fontSize: 16,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No coupons available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Coupon Code".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFieldWidget(
                    hintText: 'Enter coupon code'.tr,
                    controller: controller.couponCodeController.value,
                    suffix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: InkWell(
                        onTap: () {
                          final enteredCode = controller.couponCodeController.value.text.toLowerCase();
                          final found = controller.allCouponList.where((p0) => p0.code!.toLowerCase() == enteredCode);
                          if (found.isNotEmpty) {
                            CouponModel element = found.first;
                            if (element.isEnabled == false) {
                              ShowToastDialog.showToast("You have already used this coupon".tr);
                              return;
                            }
                            double minValue = double.tryParse(element.itemValue ?? '0') ?? 0.0;
                            if (controller.subTotal.value <= minValue) {
                              ShowToastDialog.showToast(
                                "This coupon can only be applied for orders above ₹${minValue.toStringAsFixed(0)}."
                              );
                              return;
                            }
                            controller.selectedCouponModel.value = element;
                            controller.calculatePrice();
                            Get.back();
                          } else {
                            ShowToastDialog.showToast("Invalid Coupon".tr);
                          }
                        },
                        child: Text(
                          "Apply",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: 16,
                            color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: controller.couponList.isEmpty
                ? Center(
                    child: Text(
                      'No coupons available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: controller.couponList.length,
              itemBuilder: (context, index) {
                CouponModel couponModel = controller.couponList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    color: Colors.transparent,
                    // decoration: ShapeDecoration(
                    //   color: couponModel.isEnabled == false
                    //       ? (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey200)
                    //       : (themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
                    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    //
                    // ),
                    // decoration: ShapeDecoration(
                    //   color: couponModel.isEnabled == false
                    //       ? (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey200)
                    //       : (themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   shadows: const [ // optional elevation
                    //     BoxShadow(
                    //       color: Colors.black26,
                    //       blurRadius: 6,
                    //       offset: Offset(0, 3),
                    //     ),
                    //   ],
                    // ),
                child:       GestureDetector(
                                    onTap: couponModel.isEnabled == false
                                        ? (){
                                      ShowToastDialog.showToast(
                                        "Coupon Expired",
                                      );
                                    }
                                        : () {
                                      double minValue = double.tryParse(
                                          couponModel.itemValue ?? '0') ??
                                          0.0;
                                      if (controller.subTotal.value <= minValue) {
                                        ShowToastDialog.showToast(
                                          "This coupon can only be applied for orders above ₹${minValue.toStringAsFixed(0)}.",
                                        );
                                        return;
                                      }
                                      double couponAmount = Constant
                                          .calculateDiscount(
                                          amount: controller.subTotal.value
                                              .toString(),
                                          offerModel: couponModel);
                                      if (couponAmount < controller.subTotal.value) {
                                        controller.selectedCouponModel.value =
                                            couponModel;
                                        controller.couponCodeController.value.text =
                                            couponModel.code ?? '';
                                        controller.calculatePrice();
                                        Get.back();
                                      } else {
                                        ShowToastDialog.showToast(
                                            "Coupon code not applied".tr);
                                      }
                                    },
                  child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: SvgPicture.asset(color:couponModel.isEnabled ==true?null: Colors.grey,
                                  ImageConst.cupon,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 125,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: RotatedBox(
                                          quarterTurns: -1,
                                          child: Text(
                                            "${couponModel.discountType == "Fix Price" ? Constant.amountShow(amount: couponModel.discount) : "${couponModel.discount}%"} ${'Off'.tr}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.surface
                                                  : AppThemeData.surface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                        SizedBox(width: 20,),
                        SizedBox(
                          height: 80,
                          child: DottedBorder(
                            options: CustomPathDottedBorderOptions(
                              dashPattern: [8, 8],
                              strokeWidth: 4,
                              color: ColorConst.white,  customPath: (size) {
                              return Path()
                                ..moveTo(size.width / 2, 0)
                                ..lineTo(size.width / 2, size.height);
                            },
                            ),
                            child: const SizedBox(width: 2), // just a thin column
                          ),
                        ),
                                  SizedBox(width: 10,),
                                  Column(
                                    children: [
                                      Text(
                                        "Coupon",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          // fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                          color: themeChange.getThem()
                                              ? AppThemeData.surface
                                              : AppThemeData.surface,
                                        ),
                                      ),
                                      Stack(
                                        alignment: Alignment.center, // ✅ centers all children
                                        children: [
                                          SvgPicture.asset(
                                            ImageConst.codeCupon,
                                            fit: BoxFit.fill,
                                            height: 40,
                                            width: 40,
                                          ),
                                          Center( // ✅ ensures the text stays centered
                                            child: Column(mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(height: 5,),
                                                Text(
                                                  "${couponModel.code}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.semiBold,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.surface
                                                        : AppThemeData.surface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Stack(
                                      //   children: [
                                      //     SvgPicture.asset(
                                      //       ImageConst.codeCupon,
                                      //       fit: BoxFit.fill,height: 40,
                                      //       width: 40,
                                      //     ),
                                      //     Text(
                                      //       "${couponModel.code}",
                                      //       textAlign: TextAlign.start,
                                      //       style: TextStyle(
                                      //         fontFamily: AppThemeData.semiBold,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: 18,
                                      //         color: themeChange.getThem()
                                      //             ? AppThemeData.surface
                                      //             : AppThemeData.surface,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      SizedBox(height: 10,),
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  "${couponModel.description}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.medium,
                                                    fontSize: 16,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.surface
                                                        : AppThemeData.surface,

                                                  ),maxLines: 2,
                                                ),
                                              ),
                                      SizedBox(height: 10,),
                                    ],
                                  ),
                                  // Expanded(
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  //     child: Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       mainAxisSize: MainAxisSize.min,
                                  //       children: [
                                  //         Row(
                                  //           children: [
                                  //             DottedBorder(
                                  //               options: RoundedRectDottedBorderOptions(
                                  //                 color: couponModel.isEnabled == false
                                  //                     ? (themeChange.getThem()
                                  //                     ? AppThemeData.grey600
                                  //                     : AppThemeData.grey400)
                                  //                     : (themeChange.getThem()
                                  //                     ? AppThemeData.grey400
                                  //                     : AppThemeData.grey500),
                                  //                 strokeWidth: 1,
                                  //                 radius: const Radius.circular(6),
                                  //                 dashPattern: const [6, 6],
                                  //               ),
                                  //               child: Padding(
                                  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
                                  //                 child: Text(
                                  //                   "${couponModel.code}",
                                  //                   textAlign: TextAlign.start,
                                  //                   style: TextStyle(
                                  //                     fontFamily: AppThemeData.semiBold,
                                  //                     fontSize: 16,
                                  //                     color: couponModel.isEnabled == false
                                  //                         ? (themeChange.getThem()
                                  //                         ? AppThemeData.grey600
                                  //                         : AppThemeData.grey400)
                                  //                         : (themeChange.getThem()
                                  //                         ? AppThemeData.grey400
                                  //                         : AppThemeData.grey500),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             const SizedBox(width: 8),
                                  //             if (couponModel.isEnabled == false)
                                  //               Container(
                                  //                 padding: const EdgeInsets.symmetric(
                                  //                     horizontal: 8, vertical: 2),
                                  //                 decoration: BoxDecoration(
                                  //                   color: themeChange.getThem()
                                  //                       ? AppThemeData.grey700
                                  //                       : AppThemeData.grey300,
                                  //                   borderRadius: BorderRadius.circular(6),
                                  //                 ),
                                  //                 child: Text(
                                  //                   "Used",
                                  //                   style: TextStyle(
                                  //                     color: themeChange.getThem()
                                  //                         ? AppThemeData.grey200
                                  //                         : AppThemeData.grey800,
                                  //                     fontFamily: AppThemeData.medium,
                                  //                     fontSize: 12,
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             const Expanded(child: SizedBox(height: 10)),
                                  //             InkWell(
                                  //               onTap: couponModel.isEnabled == false
                                  //                   ? null
                                  //                   : () {
                                  //                 double minValue = double.tryParse(
                                  //                     couponModel.itemValue ?? '0') ??
                                  //                     0.0;
                                  //                 if (controller.subTotal.value <= minValue) {
                                  //                   ShowToastDialog.showToast(
                                  //                     "This coupon can only be applied for orders above ₹${minValue.toStringAsFixed(0)}.",
                                  //                   );
                                  //                   return;
                                  //                 }
                                  //                 double couponAmount = Constant
                                  //                     .calculateDiscount(
                                  //                     amount: controller.subTotal.value
                                  //                         .toString(),
                                  //                     offerModel: couponModel);
                                  //                 if (couponAmount < controller.subTotal.value) {
                                  //                   controller.selectedCouponModel.value =
                                  //                       couponModel;
                                  //                   controller.couponCodeController.value.text =
                                  //                       couponModel.code ?? '';
                                  //                   controller.calculatePrice();
                                  //                   Get.back();
                                  //                 } else {
                                  //                   ShowToastDialog.showToast(
                                  //                       "Coupon code not applied".tr);
                                  //                 }
                                  //               },
                                  //               child: Text(
                                  //                 couponModel.isEnabled == false
                                  //                     ? "Used"
                                  //                     : "Tap To Apply".tr,
                                  //                 textAlign: TextAlign.start,
                                  //                 style: TextStyle(
                                  //                   fontFamily: AppThemeData.medium,
                                  //                   color: couponModel.isEnabled == false
                                  //                       ? (themeChange.getThem()
                                  //                       ? AppThemeData.grey600
                                  //                       : AppThemeData.grey400)
                                  //                       : (themeChange.getThem()
                                  //                       ? AppThemeData.primary300
                                  //                       : AppThemeData.primary300),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         const SizedBox(height: 20),
                                  //         MySeparator(
                                  //             color: themeChange.getThem()
                                  //                 ? AppThemeData.grey700
                                  //                 : AppThemeData.grey200),
                                  //         const SizedBox(height: 20),
                                  //         Text(
                                  //           "${couponModel.description}",
                                  //           textAlign: TextAlign.start,
                                  //           style: TextStyle(
                                  //             fontFamily: AppThemeData.medium,
                                  //             fontSize: 16,
                                  //             color: themeChange.getThem()
                                  //                 ? AppThemeData.grey50
                                  //                 : AppThemeData.grey900,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                )
                    // child: Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start, // This makes the orange banner fill the card height
                    //   children: [
                    //     ClipRRect(
                    //       borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    //       child: SizedBox(
                    //         width: 60,
                    //         height: 125,
                    //         child: Stack(
                    //           children: [
                    //             Positioned.fill(
                    //               child: Image.asset(
                    //                 "assets/images/ic_coupon_image.png",
                    //                 fit: BoxFit.fill,
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 10),
                    //               child: Align(
                    //                 alignment: Alignment.center,
                    //                 child: RotatedBox(
                    //                   quarterTurns: -1,
                    //                   child: Text(
                    //                     "${couponModel.discountType == "Fix Price" ? Constant.amountShow(amount: couponModel.discount) : "${couponModel.discount}%"} ${'Off'.tr}",
                    //                     textAlign: TextAlign.start,
                    //                     style: TextStyle(
                    //                       fontFamily: AppThemeData.semiBold,
                    //                       fontSize: 16,
                    //                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 DottedBorder(
                    //                   options: RoundedRectDottedBorderOptions(
                    //                     color: couponModel.isEnabled == false
                    //                         ? (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400)
                    //                         : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500),
                    //                     strokeWidth: 1,
                    //                     radius: const Radius.circular(6),
                    //                     dashPattern: const [6, 6],
                    //                   ),
                    //                   child: Padding(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 16),
                    //                     child: Text(
                    //                       "${couponModel.code}",
                    //                       textAlign: TextAlign.start,
                    //                       style: TextStyle(
                    //                         fontFamily: AppThemeData.semiBold,
                    //                         fontSize: 16,
                    //                         color: couponModel.isEnabled == false
                    //                             ? (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400)
                    //                             : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 const SizedBox(width: 8),
                    //                 if (couponModel.isEnabled == false)
                    //                   Container(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    //                     decoration: BoxDecoration(
                    //                       color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300,
                    //                       borderRadius: BorderRadius.circular(6),
                    //                     ),
                    //                     child: Text(
                    //                       "Used",
                    //                       style: TextStyle(
                    //                         color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey800,
                    //                         fontFamily: AppThemeData.medium,
                    //                         fontSize: 12,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 const Expanded(child: SizedBox(height: 10)),
                    //                 InkWell(
                    //                   onTap: couponModel.isEnabled == false
                    //                       ? null
                    //                       : () {
                    //                     double minValue = double.tryParse(couponModel.itemValue ?? '0') ?? 0.0;
                    //                     if (controller.subTotal.value <= minValue) {
                    //                       ShowToastDialog.showToast(
                    //                         "This coupon can only be applied for orders above ₹${minValue.toStringAsFixed(0)}."
                    //                       );
                    //                       return;
                    //                     }
                    //                     double couponAmount = Constant.calculateDiscount(amount: controller.subTotal.value.toString(), offerModel: couponModel);
                    //                     if (couponAmount < controller.subTotal.value) {
                    //                       controller.selectedCouponModel.value = couponModel;
                    //                       controller.couponCodeController.value.text = couponModel.code ?? '';
                    //                       controller.calculatePrice();
                    //                       Get.back();
                    //                     } else {
                    //                       ShowToastDialog.showToast("Coupon code not applied".tr);
                    //                     }
                    //                   },
                    //                   child: Text(
                    //                     couponModel.isEnabled == false ? "Used" : "Tap To Apply".tr,
                    //                     textAlign: TextAlign.start,
                    //                     style: TextStyle(
                    //                       fontFamily: AppThemeData.medium,
                    //                       color: couponModel.isEnabled == false
                    //                           ? (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400)
                    //                           : (themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             const SizedBox(
                    //               height: 20,
                    //             ),
                    //             MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                    //             const SizedBox(
                    //               height: 20,
                    //             ),
                    //             Text(
                    //               "${couponModel.description}",
                    //               textAlign: TextAlign.start,
                    //               style: TextStyle(
                    //                 fontFamily: AppThemeData.medium,
                    //                 fontSize: 16,
                    //                 color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                );
              },
            ),
          );
        });
  }
}

