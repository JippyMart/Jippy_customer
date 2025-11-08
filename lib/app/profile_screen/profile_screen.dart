import 'package:customer/app/auth_screen/phone_number_screen.dart';
import 'package:customer/app/change%20langauge/change_language_screen.dart';
import 'package:customer/app/chat_screens/driver_inbox_screen.dart';
import 'package:customer/app/chat_screens/restaurant_inbox_screen.dart';
import 'package:customer/app/dine_in_booking/dine_in_booking_screen.dart';
import 'package:customer/app/dine_in_screeen/dine_in_screen.dart';
import 'package:customer/app/edit_profile_screen/edit_profile_screen.dart';
import 'package:customer/app/gift_card/gift_card_screen.dart';
import 'package:customer/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/controllers/my_profile_controller.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/custom_dialog_box.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams;
import 'package:customer/controllers/login_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      body: GetX(
          init: MyProfileController(),
          builder: (controller) {
            return controller.isLoading.value
                ? Constant.loader(message: "Loading profile...".tr)
                : Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Profile".tr,
                              style: TextStyle(
                                fontSize: 24,
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Manage your personal information, preferences, and settings all in one place.".tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontFamily: AppThemeData.regular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "General Information".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  children: [
                                    Constant.userModel == null
                                        ? const SizedBox()
                                        : cardDecoration(themeChange, controller, "assets/images/ic_profile.svg", "Profile Information".tr, () {
                                            Get.to(const EditProfileScreen());
                                          }),
                                    if (Constant.isEnabledForCustomer == true)
                                      Visibility(
                                        visible: false,
                                        child: cardDecoration(themeChange, controller, "assets/images/ic_dinin.svg", "Dine-In".tr, () {
                                          Get.to(const DineInScreen());
                                        }),
                                      ),
                                    Visibility(
                                      visible: false,
                                      child: cardDecoration(themeChange, controller, "assets/images/ic_gift.svg", "Gift Card".tr, () {
                                        Get.to(const GiftCardScreen());
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: false,
                              child: Constant.isEnabledForCustomer == true
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Bookings Information".tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: Responsive.width(100, context),
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            child: Column(
                                              children: [
                                                cardDecoration(themeChange, controller, "assets/icons/ic_dinin_order.svg", "Dine-In Booking".tr, () {
                                                  Get.to(const DineInBookingScreen());
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Preferences".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  children: [
                                    cardDecoration(themeChange, controller, "assets/icons/ic_change_language.svg", "Change Language".tr, () {
                                      Get.to(const ChangeLanguageScreen());
                                    }),
                                    // cardDecoration(themeChange, controller, "assets/icons/ic_light_dark.svg", "Dark Mode".tr, () {}),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Social".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  children: [
                                    Constant.userModel == null
                                        ? const SizedBox()
                                        // : cardDecoration(themeChange, controller, "assets/icons/ic_refer.svg", "Refer a Friend", () {
                                        //     Get.to(const ReferFriendScreen());
                                        //   }),
                                    : cardDecoration(themeChange, controller, "assets/icons/ic_share.svg", "Share app", () {
                                      SharePlus.instance.share(
                                        ShareParams(
                                          text: 'Hey! Just downloaded JippyMart and loving it!\nYou should try it too - get Rs.100 off on your first order!\nDon\'t miss out on this deal!\n\nGoogle Play: ${Constant.googlePlayLink}\nApp Store: ${Constant.appStoreLink}',
                                          subject: 'Look what I made!',
                                        ),
                                      );
                                    }),
                                    cardDecoration(themeChange, controller, "assets/icons/ic_rate.svg", "Rate the app", () {
                                      final InAppReview inAppReview = InAppReview.instance;
                                      inAppReview.requestReview();
                                    }),
                                    // Test button for GIF generation (remove in production)
                                    // cardDecoration(themeChange, controller, "assets/icons/ic_gift.svg", "Test GIF Generator", () {
                                    //   Get.to(() => const FaceInCloTestScreen());
                                    // }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Constant.userModel == null
                                ? const SizedBox()
                                : Visibility(
                                    visible: false,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Communication".tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: Responsive.width(100, context),
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            child: Column(
                                              children: [
                                                cardDecoration(themeChange, controller, "assets/icons/ic_restaurant_chat.svg", "Restaurant Inbox", () {
                                                  Get.to(const RestaurantInboxScreen());
                                                }),
                                                cardDecoration(themeChange, controller, "assets/icons/ic_restaurant_driver.svg", "Driver Inbox", () {
                                                  Get.to(const DriverInboxScreen());
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                            Text(
                              "Legal".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  children: [
                                    cardDecoration(themeChange, controller, "assets/icons/ic_privacy_policy.svg", "Privacy Policy", () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "privacy",
                                      ));
                                    }),
                                    cardDecoration(themeChange, controller, "assets/icons/ic_tearm_condition.svg", "Terms and Conditions", () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "termAndCondition",
                                      ));
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: Responsive.width(100, context),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Column(
                                  children: [
                                    Constant.userModel == null
                                        ? cardDecoration(themeChange, controller, "assets/icons/ic_logout.svg", "Log In", () {
                                            Get.offAll(const PhoneNumberScreen());
                                          })
                                        : cardDecoration(themeChange, controller, "assets/icons/ic_logout.svg", "Log out", () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title: "Log out".tr,
                                                    descriptions: "Are you sure you want to log out? You will need to enter your credentials to log back in.".tr,
                                                    positiveString: "Log out".tr,
                                                    negativeString: "Cancel".tr,
                                                    positiveClick: () async {
                                                      Constant.userModel!.fcmToken = "";
                                                      await FireStoreUtils.updateUser(Constant.userModel!);
                                                      Constant.userModel = null;
                                                      FireStoreUtils.backendUserId = null;
                                                      // Clear auth token if used
                                                      try {
                                                        if (Get.isRegistered<LoginController>()) {
                                                          Get.find<LoginController>().authToken.value = '';
                                                        }
                                                      } catch (_) {}
                                                      // Clear preferences (or use your Preferences.clear() if available)
                                                      await Preferences.clearSharPreference();
                                                      // Delete API token from secure storage
                                                      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
                                                      await secureStorage.delete(key: 'api_token');
                                                      // Clear cart data before logout
                                                      print('DEBUG: Profile logout - Starting cart clearing process');
                                                      try {
                                                        // Force clear cart from database directly
                                                        print('DEBUG: Profile logout - Clearing cart directly from database');
                                                        await DatabaseHelper.instance.deleteAllCartProducts();
                                                        print('DEBUG: Profile logout - Cart cleared from database');
                                                        
                                                        // Also try to clear via CartController if available
                                                        if (Get.isRegistered<CartController>()) {
                                                          print('DEBUG: Profile logout - CartController found, clearing cart');
                                                          final cartController = Get.find<CartController>();
                                                          await cartController.clearCart();
                                                          print('DEBUG: Profile logout - Cart cleared successfully');
                                                        } else {
                                                          print('DEBUG: Profile logout - CartController not registered, but database cleared');
                                                        }
                                                      } catch (e) {
                                                        print('DEBUG: Profile logout - Error clearing cart: $e');
                                                      }
                                                      
                                                      // Delete all controllers except splash/login
                                                      Get.deleteAll(force: true);
                                                      await FirebaseAuth.instance.signOut();
                                                      Get.offAll(const PhoneNumberScreen());
                                                    },
                                                    negativeClick: () {
                                                      Get.back();
                                                    },
                                                    img: Image.asset(
                                                      'assets/images/ic_logout.gif',
                                                      height: 50,
                                                      width: 50,
                                                    ),
                                                  );
                                                });
                                          }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Constant.userModel == null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomDialogBox(
                                                title: "Delete Account".tr,
                                                descriptions:
                                                    "Are you sure you want to delete your account? This action is irreversible and will permanently remove all your data.".tr,
                                                positiveString: "Delete".tr,
                                                negativeString: "Cancel".tr,
                                                positiveClick: () async {
                                                  ShowToastDialog.showLoader("Please wait".tr);
                                                  
                                                  // Clear cart data before account deletion
                                                  try {
                                                    if (Get.isRegistered<CartController>()) {
                                                      final cartController = Get.find<CartController>();
                                                      await cartController.clearCart();
                                                    }
                                                  } catch (_) {}
                                                  
                                                  await controller.deleteUserFromServer();
                                                  await FireStoreUtils.deleteUser().then((value) {
                                                    ShowToastDialog.closeLoader();
                                                    if (value == true) {
                                                      ShowToastDialog.showToast("Account deleted successfully".tr);
                                                      Get.offAll(const PhoneNumberScreen());
                                                    } else {
                                                      ShowToastDialog.showToast("Contact Administrator".tr);
                                                    }
                                                  });
                                                },
                                                negativeClick: () {
                                                  Get.back();
                                                },
                                                img: Image.asset(
                                                  'assets/icons/delete_dialog.gif',
                                                  height: 50,
                                                  width: 50,
                                                ),
                                              );
                                            });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset("assets/icons/ic_delete.svg"),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Delete Account".tr,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                            Center(
                              child: Text(
                                "V : ${Constant.appVersion}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 14,
                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
          }),
    );
  }


  cardDecoration(themeChange, MyProfileController controller, String image, String title, Function()? onPress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onPress!();
        },
        child: Row(
          children: [
            SvgPicture.asset(
              image,
              colorFilter: title == "Log In" ? const ColorFilter.mode(AppThemeData.success500, BlendMode.srcIn) : null,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title.tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: title == "Log out"
                      ? AppThemeData.danger300
                      : title == "Log In"
                          ? AppThemeData.success500
                          : themeChange.getThem()
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                ),
              ),
            ),
            title == "Dark Mode"
                ? Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: controller.isDarkModeSwitch.value,
                      activeColor: AppThemeData.primary300,
                      onChanged: (value) {
                        controller.isDarkModeSwitch.value = value;
                        if (controller.isDarkModeSwitch.value == true) {
                          Preferences.setString(Preferences.themKey, "Dark");
                          themeChange.darkTheme = 0;
                        } else if (controller.isDarkMode.value == "Light") {
                          Preferences.setString(Preferences.themKey, "Light");
                          themeChange.darkTheme = 1;
                        } else {
                          Preferences.setString(Preferences.themKey, "");
                          themeChange.darkTheme = 2;
                        }
                      },
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
