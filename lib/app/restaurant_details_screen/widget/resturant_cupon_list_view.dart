import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../themes/responsive.dart';

class CouponListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const CouponListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(9, context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponList.length,
        itemBuilder: (BuildContext context, int index) {
          CouponModel offerModel = controller.couponList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 300, // fixed width for coupon card
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1,
                      color: themeChange.getThem()
                          ? AppThemeData.grey800
                          : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/offer_gif.gif"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          offerModel.discountType == "Fix Price"
                              ? Constant.amountShow(amount: offerModel.discount)
                              : "${offerModel.discount}%",
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey50,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerModel.description.toString(),
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
                          offerModel.isEnabled == false
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Used",
                                    style: TextStyle(
                                      fontFamily: AppThemeData.medium,
                                      color: AppThemeData.grey400,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                            text: offerModel.code.toString()))
                                        .then((value) {
                                      ShowToastDialog.showToast("Copied".tr);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          offerModel.code.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey500,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SvgPicture.asset(
                                          "assets/icons/ic_copy.svg"),
                                      const SizedBox(
                                          height: 10, child: VerticalDivider()),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          Constant.timestampToDateTime(
                                              offerModel.expiresAt!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey500,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
