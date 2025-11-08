import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/cart_product_model.dart' show CartProductModel;
import 'package:customer/models/product_model.dart';
import 'package:customer/themes/app_them_data.dart' show AppThemeData;
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/special_price_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/responsive.dart' show Responsive;

Widget cartProductDetailsImageWidget(
  DarkThemeProvider themeChange,
  CartController controller,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Container(
      decoration: ShapeDecoration(
        color:
            themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // margin: EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: cartItem.length,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            CartProductModel cartProductModel = cartItem[index];
            ProductModel? productModel;
            FireStoreUtils.getProductById(cartProductModel.id!.split('~').first)
                .then((value) {
              productModel = value;
            });
            Widget priceWidget;
            if (cartProductModel.promoId != null &&
                cartProductModel.promoId!.isNotEmpty) {
              priceWidget = Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Offer -',
                      style: TextStyle(
                        color: Color(0xFFFFD700), // gold
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    Constant.amountShow(amount: cartProductModel.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontFamily: AppThemeData.semiBold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (cartProductModel.discountPrice != null &&
                      double.tryParse(cartProductModel.discountPrice!) !=
                          null &&
                      double.parse(cartProductModel.discountPrice!) > 0)
                    Text(
                      Constant.amountShow(
                          amount: cartProductModel.discountPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: themeChange.getThem()
                            ? AppThemeData.grey500
                            : AppThemeData.grey400,
                        color: themeChange.getThem()
                            ? AppThemeData.grey500
                            : AppThemeData.grey400,
                        fontFamily: AppThemeData.semiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              );
            } else if (double.parse(
                    cartProductModel.discountPrice.toString()) <=
                0) {
              priceWidget = Text(
                Constant.amountShow(amount: cartProductModel.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey900,
                  fontFamily: AppThemeData.semiBold,
                  fontWeight: FontWeight.w600,
                ),
              );
            } else {
              priceWidget = Row(
                children: [
                  Flexible(
                    child: Text(
                      Constant.amountShow(
                          amount: cartProductModel.discountPrice.toString()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeChange.getThem()
                            ? AppThemeData.grey500
                            : AppThemeData.grey400,
                        fontFamily: AppThemeData.semiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      Constant.amountShow(amount: cartProductModel.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: themeChange.getThem()
                            ? AppThemeData.grey500
                            : AppThemeData.grey400,
                        color: themeChange.getThem()
                            ? AppThemeData.grey500
                            : AppThemeData.grey400,
                        fontFamily: AppThemeData.semiBold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }
            return InkWell(
              onTap: () async {
                await FireStoreUtils.getVendorById(
                        productModel!.vendorID.toString())
                    .then(
                  (value) {
                    if (value != null) {
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": value});
                    }
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  child: Stack(
                                    children: [
                                      NetworkImageWidget(
                                        imageUrl:
                                            cartProductModel.photo.toString(),
                                        height: Responsive.height(10, context),
                                        width: Responsive.width(16, context),
                                        fit: BoxFit.cover,
                                      ),
                                      // Promotional banner overlay
                                      if (cartProductModel.promoId != null &&
                                          cartProductModel.promoId!.isNotEmpty)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: const SpecialPriceBadge(
                                            showShimmer: true,
                                            width: 50,
                                            height: 50,
                                            margin: EdgeInsets.zero,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${cartProductModel.name}",
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.regular,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    // Check if this is a promotional item and show banner
                                    cartProductModel.promoId != null &&
                                            cartProductModel.promoId!.isNotEmpty
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    'Offer',
                                                    style: TextStyle(
                                                      color: Color(
                                                          0xFFFFD700), // gold
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    // Check if this is a promotional item
                                    cartProductModel.promoId != null &&
                                            cartProductModel.promoId!.isNotEmpty
                                        ? Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  Constant.amountShow(
                                                      amount: cartProductModel
                                                          .price),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontFamily:
                                                        AppThemeData.semiBold,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  Constant.amountShow(
                                                      amount: cartProductModel
                                                          .discountPrice
                                                          .toString()),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    decorationColor: themeChange
                                                            .getThem()
                                                        ? AppThemeData.grey500
                                                        : AppThemeData.grey400,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey500
                                                        : AppThemeData.grey400,
                                                    fontFamily:
                                                        AppThemeData.semiBold,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : double.parse(cartProductModel
                                                    .discountPrice
                                                    .toString()) <=
                                                0
                                            ? Text(
                                                Constant.amountShow(
                                                    amount:
                                                        cartProductModel.price),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount:
                                                              cartProductModel
                                                                  .discountPrice
                                                                  .toString()),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontFamily: AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount:
                                                              cartProductModel
                                                                  .price),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey500
                                                                : AppThemeData
                                                                    .grey400,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey500
                                                            : AppThemeData
                                                                .grey400,
                                                        fontFamily: AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                flex: 3,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 90),
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey900
                                          : AppThemeData.grey50,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 1, color: Color(0xFFD1D5DB)),
                                        borderRadius:
                                            BorderRadius.circular(200),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                controller.addToCart(
                                                  cartProductModel:
                                                      cartProductModel,
                                                  isIncrement: false,
                                                  quantity: cartProductModel
                                                          .quantity! -
                                                      1,
                                                );
                                              },
                                              child: const Icon(Icons.remove),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Text(
                                                cartProductModel.quantity
                                                    .toString(),
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  fontWeight: FontWeight.w500,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey100
                                                      : AppThemeData.grey800,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                productModel ??= await FireStoreUtils
                                                          .getProductById(
                                                              cartProductModel
                                                                  .id!
                                                                  .split('~')
                                                                  .first);
                                                // Check if this is a promotional item
                                                if (cartProductModel.promoId !=
                                                        null &&
                                                    cartProductModel
                                                        .promoId!.isNotEmpty) {
                                                  final isAllowed = await controller
                                                      .isPromotionalItemQuantityAllowed(
                                                          cartProductModel.id ??
                                                              '',
                                                          cartProductModel
                                                                  .vendorID ??
                                                              '',
                                                          cartProductModel
                                                                  .quantity! +
                                                              1);

                                                  if (!isAllowed) {
                                                    final limit = await controller
                                                        .getPromotionalItemLimit(
                                                            cartProductModel
                                                                    .id ??
                                                                '',
                                                            cartProductModel
                                                                    .vendorID ??
                                                                '');
                                                    ShowToastDialog.showToast(
                                                        "Maximum $limit items allowed for this promotional offer"
                                                            .tr);
                                                    return;
                                                  }
                                                }
                                                if (productModel != null &&
                                                    productModel!
                                                            .itemAttribute !=
                                                        null) {
                                                  if (productModel!
                                                      .itemAttribute!.variants!
                                                      .where((element) =>
                                                          element.variantSku ==
                                                          cartProductModel
                                                              .variantInfo!
                                                              .variantSku)
                                                      .isNotEmpty) {
                                                    if (int.parse(productModel!
                                                                .itemAttribute!
                                                                .variants!
                                                                .where((element) =>
                                                                    element.variantSku ==
                                                                    cartProductModel
                                                                        .variantInfo!
                                                                        .variantSku)
                                                                .first
                                                                .variantQuantity
                                                                .toString()) >=
                                                            (cartProductModel
                                                                    .quantity ??
                                                                0) ||
                                                        int.parse(productModel!
                                                                .itemAttribute!
                                                                .variants!
                                                                .where((element) =>
                                                                    element
                                                                        .variantSku ==
                                                                    cartProductModel
                                                                        .variantInfo!
                                                                        .variantSku)
                                                                .first
                                                                .variantQuantity
                                                                .toString()) ==
                                                            -1) {
                                                      await controller.addToCart(
                                                          cartProductModel:
                                                              cartProductModel,
                                                          isIncrement: true,
                                                          quantity:
                                                              cartProductModel
                                                                      .quantity! +
                                                                  1);
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          "Out of stock".tr);
                                                    }
                                                  } else {
                                                    if ((productModel!
                                                                    .quantity ??
                                                                0) >
                                                            (cartProductModel
                                                                    .quantity ??
                                                                0) ||
                                                        productModel!
                                                                .quantity ==
                                                            -1) {
                                                      await controller.addToCart(
                                                          cartProductModel:
                                                              cartProductModel,
                                                          isIncrement: true,
                                                          quantity:
                                                              cartProductModel
                                                                      .quantity! +
                                                                  1);
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          "Out of stock".tr);
                                                    }
                                                  }
                                                } else if (productModel !=
                                                    null) {
                                                  if ((productModel!.quantity ??
                                                              0) >
                                                          (cartProductModel
                                                                  .quantity ??
                                                              0) ||
                                                      productModel!.quantity ==
                                                          -1) {
                                                    await controller.addToCart(
                                                        cartProductModel:
                                                            cartProductModel,
                                                        isIncrement: true,
                                                        quantity:
                                                            cartProductModel
                                                                    .quantity! +
                                                                1);
                                                  } else {
                                                    ShowToastDialog.showToast(
                                                        "Out of stock".tr);
                                                  }
                                                } else {
                                                  // Fallback: if productModel is null, allow increment for mart items
                                                  await controller.addToCart(
                                                      cartProductModel:
                                                          cartProductModel,
                                                      isIncrement: true,
                                                      quantity: cartProductModel
                                                              .quantity! +
                                                          1);
                                                }
                                              },
                                              child: const Icon(Icons.add),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    cartProductModel.variantInfo == null ||
                            cartProductModel.variantInfo!.variantOptions ==
                                null ||
                            cartProductModel
                                .variantInfo!.variantOptions!.isEmpty
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Variants".tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey300
                                        : AppThemeData.grey600,
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
                                        .variantInfo!.variantOptions!.length,
                                    (i) {
                                      return Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey800
                                              : AppThemeData.grey100,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 5),
                                          child: Text(
                                            "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.medium,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey500
                                                  : AppThemeData.grey400,
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
                            cartProductModel.extras!.isEmpty ||
                            cartProductModel.extrasPrice == '0'
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Addons".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300
                                            : AppThemeData.grey600,
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
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.semiBold,
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary300
                                          : AppThemeData.primary300,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: List.generate(
                                  cartProductModel.extras!.length,
                                  (i) {
                                    return Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 5),
                                        child: Text(
                                          cartProductModel.extras![i]
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.medium,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey500
                                                : AppThemeData.grey400,
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
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
