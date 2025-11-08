import 'package:customer/app/restaurant_details_screen/widget/restauant_product_list_view.dart';
import 'package:customer/app/restaurant_details_screen/widget/restaurant_detail_shimmer_widget.dart';
import 'package:customer/app/restaurant_details_screen/widget/resturant_cupon_list_view.dart';
import 'package:customer/app/review_list_screen/review_list_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../cart_check_out_page/cart_check_out_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String? scrollToProductId;

  const RestaurantDetailsScreen({
    super.key,
    this.scrollToProductId,
  });

  void _showMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 50, left: 20, right: 40),
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: GetBuilder<RestaurantDetailsController>(
                  builder: (restaurantDetailsController) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: ListView.builder(
                        itemCount: restaurantDetailsController
                            .vendorCategoryList.length,
                        itemBuilder: (context, index) {
                          final category = restaurantDetailsController
                              .vendorCategoryList[index];
                          return _buildMenuItem(
                            category.title.toString(),
                            restaurantDetailsController
                                .getProductsByCategory(category.id.toString())
                                .length,
                            onTap: () {
                              Navigator.pop(
                                  context); // Close bottom sheet first

                              // Use a small delay to ensure bottom sheet is closed
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                restaurantDetailsController
                                    .scrollToCategory(index);
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, int count,
      {bool isNew = false, void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isNew) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$count items',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // void _showMenuModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     isDismissible: true,
  //     enableDrag: true,
  //     builder: (context) => GestureDetector(
  //       onTap: () => Navigator.pop(context),
  //       child: Container(
  //         color: Colors.transparent,
  //         child: Align(
  //           alignment: Alignment.bottomCenter,
  //           child: GestureDetector(
  //             onTap: () {},
  //             child: Container(
  //               margin: const EdgeInsets.only(bottom: 50, left: 20, right: 40),
  //               height: MediaQuery.of(context).size.height * 0.35,
  //               width: MediaQuery.of(context).size.width * 0.7,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     offset: const Offset(0, -2),
  //                   ),
  //                 ],
  //               ),
  //               child: GetBuilder<RestaurantDetailsController>(
  //                   builder: (restaurantDetailsController) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(top: 5, bottom: 5),
  //                   child: ListView.builder(
  //                     itemCount:
  //                         restaurantDetailsController.vendorCategoryList.length,
  //                     itemBuilder: (context, index) {
  //                       final category = restaurantDetailsController
  //                           .vendorCategoryList[index];
  //                       return _buildMenuItem(
  //                           category.title.toString(),
  //                           restaurantDetailsController
  //                               .getProductsByCategory(
  //                                 category.id.toString(),
  //                               )
  //                               .length, onTap: () {
  //                         Navigator.pop(context);
  //                         WidgetsBinding.instance.addPostFrameCallback((_) {
  //                           restaurantDetailsController.scrollToCategory(index);
  //                         });
  //                       });
  //                     },
  //                   ),
  //                 );
  //               }),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMenuItem(String title, int count,
  //     {bool isNew = false, void Function()? onTap}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Row(
  //               children: [
  //                 Flexible(
  //                   child: Text(
  //                     title,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.black87,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                     maxLines: 1,
  //                   ),
  //                 ),
  //                 if (isNew) ...[
  //                   const SizedBox(width: 8),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 6, vertical: 2),
  //                     decoration: BoxDecoration(
  //                       color: Colors.red,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: const Text(
  //                       'NEW',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 10,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           ),
  //           const SizedBox(width: 16),
  //           Text(
  //             '$count items',
  //             style: const TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantDetailsController(scrollToProductId: scrollToProductId),
        autoRemove: false,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : InkWell(
                    onTap: () {
                      Get.to(const CartCheckOutScreen());
                    },
                    child: SafeArea(
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFF48000),
                              Color(0xFFff0404)
                              // AppThemeData.danger200,
                              // AppThemeData.danger300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cartItem.length} items',
                              style: TextStyle(
                                fontFamily: AppThemeData.medium,
                                color: AppThemeData.grey50,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'View Cart',
                              style: TextStyle(
                                fontFamily: AppThemeData.semiBold,
                                color: AppThemeData.grey50,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            floatingActionButton: Visibility(
              visible: true,
              child: FloatingActionButton(
                onPressed: () {
                  _showMenuModal(context);
                },
                backgroundColor: Colors.black, // WhatsApp green color
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SvgPicture.asset(
                    'assets/images/menu.svg',
                    width: 44,
                    height: 44,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: RefreshIndicator(
              onRefresh: controller.getArgument,
              child: NestedScrollView(
                // controller: controller.scrollControllerProduct,
                // physics: NeverScrollableScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: Responsive.height(30, context),
                      floating: true,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: AppThemeData.primary300,
                      title: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey50,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.vendorModel.value.title ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey50,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            controller.vendorModel.value.photos == null ||
                                    controller.vendorModel.value.photos!.isEmpty
                                ? Stack(
                                    children: [
                                      NetworkImageWidget(
                                        imageUrl: controller
                                            .vendorModel.value.photo
                                            .toString(),
                                        fit: BoxFit.cover,
                                        width: Responsive.width(100, context),
                                        height: Responsive.height(40, context),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: const Alignment(0.00, -1.00),
                                            end: const Alignment(0, 1),
                                            colors: [
                                              Colors.black.withOpacity(0),
                                              Colors.black
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : PageView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    controller: controller.pageController.value,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller
                                        .vendorModel.value.photos!.length,
                                    padEnds: false,
                                    pageSnapping: true,
                                    allowImplicitScrolling: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String image = controller
                                          .vendorModel.value.photos![index];
                                      return Stack(
                                        children: [
                                          NetworkImageWidget(
                                            imageUrl: image.toString(),
                                            fit: BoxFit.cover,
                                            width:
                                                Responsive.width(100, context),
                                            height:
                                                Responsive.height(40, context),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: const Alignment(
                                                    0.00, -1.00),
                                                end: const Alignment(0, 1),
                                                colors: [
                                                  Colors.black.withOpacity(0),
                                                  Colors.black
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            Positioned(
                              bottom: 10,
                              right: 0,
                              left: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  controller.vendorModel.value.photos!.length,
                                  (index) {
                                    return Obx(
                                      () => Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        alignment: Alignment.centerLeft,
                                        height: 9,
                                        width: 9,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: controller.currentPage.value ==
                                                  index
                                              ? AppThemeData.primary300
                                              : AppThemeData.grey300,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                //changed here1
                body: controller.isLoading.value
                    // ? Constant.loader(message: "Loading restaurant details...".tr)
                    ? resturantDetailsShimmer()
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SingleChildScrollView(
                          controller: controller.scrollController.value,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller
                                                    .vendorModel.value.title
                                                    .toString(),
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontWeight: FontWeight.w600,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                ),
                                              ),
                                              SizedBox(
                                                width: Responsive.width(
                                                    78, context),
                                                child: Text(
                                                  controller.vendorModel.value
                                                      .location
                                                      .toString(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.medium,
                                                    fontWeight: FontWeight.w500,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey400
                                                        : AppThemeData.grey400,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem()
                                                    ? AppThemeData.primary600
                                                    : AppThemeData.primary50,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            120)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_star.svg",
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              AppThemeData
                                                                  .primary300,
                                                              BlendMode.srcIn),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      Constant.calculateReview(
                                                          reviewCount: controller
                                                              .vendorModel
                                                              .value
                                                              .reviewsCount!
                                                              .toStringAsFixed(
                                                                  0),
                                                          reviewSum: controller
                                                              .vendorModel
                                                              .value
                                                              .reviewsSum
                                                              .toString()),
                                                      style: TextStyle(
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .primary300
                                                            : AppThemeData
                                                                .primary300,
                                                        fontFamily: AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(const ReviewListScreen(),
                                                    arguments: {
                                                      "vendorModel": controller
                                                          .vendorModel.value
                                                    });
                                              },
                                              child: Text(
                                                "${controller.vendorModel.value.reviewsCount} ${'Ratings'.tr}",
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey200
                                                      : AppThemeData.grey700,
                                                  fontFamily:
                                                      AppThemeData.regular,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        /*
                                  if (controller.vendorModel.value.reststatus == false) ...[
                                    Container(
                                  */
                                        // Use the new clean workflow for status display
                                        Obx(() {
                                          final statusInfo = controller
                                              .getRestaurantStatusInfo();
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusInfo['statusColor'],
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  statusInfo['statusIcon'],
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  statusInfo['statusText'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(
                                            Icons.circle,
                                            size: 5,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey500,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (controller.vendorModel.value
                                                .workingHours!.isEmpty) {
                                              ShowToastDialog.showToast(
                                                  "Timing is not added by restaurant"
                                                      .tr);
                                            } else {
                                              timeShowBottomSheet(
                                                  context, controller);
                                            }
                                          },
                                          child: Text(
                                            "View Timings".tr,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AppThemeData.secondary300,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.secondary300
                                                  : AppThemeData.secondary300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    controller.vendorModel.value.dineInActive ==
                                                true ||
                                            (controller.vendorModel.value
                                                        .openDineTime !=
                                                    null &&
                                                controller.vendorModel.value
                                                    .openDineTime!.isNotEmpty)
                                        ? const SizedBox() // Permanently hide Table Booking
                                        : const SizedBox(),
                                    controller.couponList.isEmpty
                                        ? const SizedBox()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Additional Offers".tr,
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontFamily:
                                                      AppThemeData.semiBold,
                                                  fontWeight: FontWeight.w600,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey50
                                                      : AppThemeData.grey900,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              CouponListView(
                                                controller: controller,
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Menu".tr,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextFieldWidget(
                                      controller: controller
                                          .searchEditingController.value,
                                      hintText:
                                          'Search the dish, food, meals and more...'
                                              .tr,
                                      onchange: (value) {
                                        controller.searchProduct(value);
                                      },
                                      prefix: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                            "assets/icons/ic_search.svg"),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Add spacing between search bar and filters
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (!controller.isVag.value) {
                                                controller.isVag.value = true;
                                                controller.isNonVag.value =
                                                    false;
                                                controller.filterRecord();
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4),
                                              decoration: controller.isVag.value
                                                  ? ShapeDecoration(
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .primary600
                                                              : AppThemeData
                                                                  .primary50,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: AppThemeData
                                                                .primary300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                      ),
                                                    )
                                                  : ShapeDecoration(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey800
                                                          : AppThemeData
                                                              .grey100,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey700
                                                                : AppThemeData
                                                                    .grey200),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                      ),
                                                    ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/ic_veg.svg",
                                                    height: 16,
                                                    width: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Veg'.tr,
                                                    style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey100
                                                          : AppThemeData
                                                              .grey800,
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (!controller.isNonVag.value) {
                                                controller.isNonVag.value =
                                                    true;
                                                controller.isVag.value = false;
                                                controller.filterRecord();
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4),
                                              decoration: controller
                                                      .isNonVag.value
                                                  ? ShapeDecoration(
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .primary600
                                                              : AppThemeData
                                                                  .primary50,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: AppThemeData
                                                                .primary300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                      ),
                                                    )
                                                  : ShapeDecoration(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey800
                                                          : AppThemeData
                                                              .grey100,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey700
                                                                : AppThemeData
                                                                    .grey200),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                      ),
                                                    ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/ic_nonveg.svg",
                                                    height: 16,
                                                    width: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Non Veg'.tr,
                                                    style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey100
                                                          : AppThemeData
                                                              .grey800,
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.toggleOfferFilter();
                                            },
                                            child:
                                                TweenAnimationBuilder<double>(
                                              duration: Duration(seconds: 2),
                                              tween:
                                                  Tween(begin: 0.95, end: 1.05),
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: controller
                                                          .isOfferFilter.value
                                                      ? 1.0
                                                      : value,
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    decoration: controller
                                                            .isOfferFilter.value
                                                        ? BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFFFF6B6B),
                                                                // Coral red
                                                                Color(
                                                                    0xFFFF8E53),
                                                                // Orange
                                                                Color(
                                                                    0xFFFF6B6B),
                                                                // Coral red
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              stops: [
                                                                0.0,
                                                                0.5,
                                                                1.0
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        120),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                        0xFFFF6B6B)
                                                                    .withOpacity(
                                                                        0.4),
                                                                blurRadius: 12,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                              BoxShadow(
                                                                color: Color(
                                                                        0xFFFF8E53)
                                                                    .withOpacity(
                                                                        0.2),
                                                                blurRadius: 20,
                                                                offset: Offset(
                                                                    0, 5),
                                                              ),
                                                            ],
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xFFFF6B6B),
                                                              width: 1.5,
                                                            ),
                                                          )
                                                        : BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: themeChange
                                                                      .getThem()
                                                                  ? [
                                                                      Color(0xFFFF6B6B)
                                                                          .withOpacity(
                                                                              0.15), // Subtle coral
                                                                      Color(0xFFFF8E53)
                                                                          .withOpacity(
                                                                              0.1), // Subtle orange
                                                                    ]
                                                                  : [
                                                                      Color(0xFFFF6B6B)
                                                                          .withOpacity(
                                                                              0.08),
                                                                      // Very subtle coral
                                                                      Color(0xFFFF8E53)
                                                                          .withOpacity(
                                                                              0.05),
                                                                      // Very subtle orange
                                                                    ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        120),
                                                            border: Border.all(
                                                              color: Color(
                                                                      0xFFFF6B6B)
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1.5,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                        0xFFFF6B6B)
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 6,
                                                                offset: Offset(
                                                                    0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.local_offer,
                                                          size: 16,
                                                          color: controller
                                                                  .isOfferFilter
                                                                  .value
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFFFF6B6B),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'Offers'.tr,
                                                          style: TextStyle(
                                                            color: controller
                                                                    .isOfferFilter
                                                                    .value
                                                                ? Colors.white
                                                                : Color(
                                                                    0xFFFF6B6B),
                                                            fontFamily:
                                                                AppThemeData
                                                                    .semiBold,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            shadows: controller
                                                                    .isOfferFilter
                                                                    .value
                                                                ? [
                                                                    Shadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.3),
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              1),
                                                                      blurRadius:
                                                                          2,
                                                                    ),
                                                                  ]
                                                                : null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          // Clear Filter Button
                                          Builder(
                                            builder: (context) {
                                              try {
                                                return Obx(() {
                                                  // Safety check for controller and reactive variables
                                                  if (!Get.isRegistered<
                                                      RestaurantDetailsController>()) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  // Show clear button only if any filter is active
                                                  final hasActiveFilters =
                                                      (controller.isVag
                                                                  .value ??
                                                              false) ||
                                                          (controller.isNonVag
                                                                  .value ??
                                                              false) ||
                                                          (controller
                                                                  .isOfferFilter
                                                                  .value ??
                                                              false) ||
                                                          (controller
                                                              .searchEditingController
                                                              .value
                                                              .text
                                                              .isNotEmpty);

                                                  if (!hasActiveFilters) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  return InkWell(
                                                    onTap: () {
                                                      try {
                                                        controller
                                                            .clearAllFilters();
                                                      } catch (e) {
                                                        print(
                                                            'Error clearing filters: $e');
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey700
                                                            : AppThemeData
                                                                .grey200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey600
                                                              : AppThemeData
                                                                  .grey300,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.clear,
                                                            size: 16,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey100
                                                                : AppThemeData
                                                                    .grey800,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            'Clear'.tr,
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey100
                                                                  : AppThemeData
                                                                      .grey800,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error building clear filter button: $e');
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // if (controller.vendorModel.value.reststatus == false || controller.isOpen.value == false) ...[
                              if (!controller.canAcceptOrders()) ...[
                                const SizedBox(height: 20),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.lock,
                                          color: Colors.red, size: 48),
                                      SizedBox(height: 8),
                                      Text(
                                        'This restaurant is currently closed.',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Obx(() {
                                        final statusInfo = controller
                                            .getRestaurantStatusInfo();
                                        return Column(
                                          children: [
                                            Text(
                                              statusInfo['reason'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600]),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (statusInfo['nextOpeningTime'] !=
                                                null) ...[
                                              SizedBox(height: 4),
                                              Text(
                                                'Next opening: ${statusInfo['nextOpeningTime']}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ] else ...[
                                ProductListView(controller: controller),
                              ],
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          );
        });
  }

  timeShowBottomSheet(
      BuildContext context, RestaurantDetailsController productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.70,
              child: StatefulBuilder(builder: (context1, setState) {
                final themeChange = Provider.of<DarkThemeProvider>(context1);
                return Scaffold(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: productModel
                                .vendorModel.value.workingHours!.length,
                            itemBuilder: (context, dayIndex) {
                              WorkingHours workingHours = productModel
                                  .vendorModel.value.workingHours![dayIndex];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${workingHours.day}",
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    workingHours.timeslot == null ||
                                            workingHours.timeslot!.isEmpty
                                        ? const SizedBox()
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                workingHours.timeslot!.length,
                                            itemBuilder: (context, timeIndex) {
                                              Timeslot timeSlotModel =
                                                  workingHours
                                                      .timeslot![timeIndex];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12)),
                                                            border: Border.all(
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey400
                                                                    : AppThemeData
                                                                        .grey200)),
                                                        child: Center(
                                                          child: Text(
                                                            timeSlotModel.from
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontSize: 14,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12)),
                                                            border: Border.all(
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey400
                                                                    : AppThemeData
                                                                        .grey200)),
                                                        child: Center(
                                                          child: Text(
                                                            timeSlotModel.to
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontSize: 14,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey400
                                                                  : AppThemeData
                                                                      .grey500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ));
  }
}

/// Builds the "No products available" message widget

// Menu Item Widget
Widget _buildMenuItem(String title, int count, {bool isNew = false}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8), // Small fixed spacing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          // decoration: BoxDecoration(
          //   color: Colors.grey[700],
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: Text(
            '$count items',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
