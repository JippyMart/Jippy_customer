import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/login_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(LoginController());
    final isDark = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.primary300.withOpacity(0.1),
                    AppThemeData.primary300.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppThemeData.primary300.withOpacity(0.08),
                    AppThemeData.primary300.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Icon/Logo section
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppThemeData.primary300,
                                AppThemeData.primary300.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemeData.primary300.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title and subtitle
                        Text(
                          "Welcome Back! 👋".tr,
                          style: TextStyle(
                            color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontSize: 32,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Log in to continue enjoying delicious food delivered to your doorstep.".tr,
                          style: TextStyle(
                            color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                            fontSize: 16,
                            fontFamily: AppThemeData.regular,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Phone number input with enhanced design
                        TextFieldWidget(
                          title: 'Phone Number'.tr,
                          controller: controller.phoneEditingController.value,
                          hintText: 'Enter Phone Number'.tr,
                          textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          ],
                          prefix: CountryCodePicker(
                            onChanged: (value) {},
                            dialogTextStyle: TextStyle(
                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.medium,
                            ),
                            dialogBackgroundColor: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                            initialSelection: 'IN',
                            countryFilter: const ['IN'],
                            comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: AppThemeData.medium,
                            ),
                            searchDecoration: InputDecoration(
                              iconColor: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                            searchStyle: TextStyle(
                              color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.medium,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OTP sent success message
                        Obx(() => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: controller.isOtpSent.value ? 60 : 0,
                          child: controller.isOtpSent.value
                              ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'OTP sent successfully!'.tr,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.medium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink(),
                        )),

                        SizedBox(height: controller.isOtpSent.value ? 24 : 0),

                        // Send OTP button
                        Obx(() => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: !controller.isOtpSent.value
                              ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppThemeData.primary300.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: RoundedButtonFill(
                              title: controller.isVerifying.value ? "Sending...".tr : "Send OTP".tr,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: controller.isVerifying.value
                                  ? null
                                  : () async {
                                final phone = controller.phoneEditingController.value.text.trim();
                                if (phone.isEmpty) {
                                  ShowToastDialog.showToast("Please enter mobile number".tr);
                                } else if (phone.length < 10 || phone.length > 15) {
                                  ShowToastDialog.showToast("Phone number must be 10-15 digits".tr);
                                } else {
                                  await controller.sendOtp();
                                }
                              },
                            ),
                          )
                              : const SizedBox.shrink(),
                        )),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppThemeData.grey800.withOpacity(0.3)
                                : AppThemeData.grey100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Your phone number is safe with us. We'll send you a one-time password.".tr,
                                  style: TextStyle(
                                    color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 13,
                                    fontFamily: AppThemeData.regular,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 150),
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
  }
}

// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:customer/constant/show_toast_dialog.dart';
// import 'package:customer/controllers/login_controller.dart';
// import 'package:customer/themes/app_them_data.dart';
// import 'package:customer/themes/round_button_fill.dart';
// import 'package:customer/themes/text_field_widget.dart';
// import 'package:customer/utils/dark_theme_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// class PhoneNumberScreen extends StatelessWidget {
//   const PhoneNumberScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     final controller = Get.put(LoginController());
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Welcome Back! 👋".tr,
//                       style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
//                     ),
//                     Text(
//                       "Log in to continue enjoying delicious food delivered to your doorstep.".tr,
//                       style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
//                     ),
//               const SizedBox(height: 32),
//                     TextFieldWidget(
//                       title: 'Phone Number'.tr,
//                 controller: controller.phoneEditingController.value,
//                       hintText: 'Enter Phone Number'.tr,
//                       textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
//                       textInputAction: TextInputAction.done,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp('[0-9]')),
//                       ],
//                       prefix: CountryCodePicker(
//                         onChanged: (value) {
//                     // Optionally handle country code if needed
//                         },
//                   dialogTextStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
//                         dialogBackgroundColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
//                         initialSelection: 'IN',
//                         countryFilter: const ['IN'],
//                         comparator: (a, b) => b.name!.compareTo(a.name.toString()),
//                         textStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
//                         searchDecoration: InputDecoration(iconColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
//                   searchStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
//                       ),
//                     ),
//               const SizedBox(height: 36),
//               Obx(() => controller.isOtpSent.value
//                   ? Center(child: Text('OTP sent!'))
//                   : Obx(() => RoundedButtonFill(
//                         title: controller.isVerifying.value ? "Sending...".tr : "Send OTP".tr,
//                       color: AppThemeData.primary300,
//                       textColor: AppThemeData.grey50,
//                         onPress: controller.isVerifying.value
//                             ? null
//                             : () async {
//                                 final phone = controller.phoneEditingController.value.text.trim();
//                                 if (phone.isEmpty) {
//                           ShowToastDialog.showToast("Please enter mobile number".tr);
//                                 } else if (phone.length < 10 || phone.length > 15) {
//                                   ShowToastDialog.showToast("Phone number must be 10-15 digits".tr);
//                         } else {
//                                   await controller.sendOtp();
//                         }
//                       },
//                       ))),
//                     // Padding(
//                     //   padding: const EdgeInsets.symmetric(horizontal: 40),
//                     //   child: Row(
//                     //     children: [
//                     //       const Expanded(child: Divider(thickness: 1)),
//                     //       Padding(
//                     //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                     //         child: Text(
//                     //           "or".tr,
//                     //           textAlign: TextAlign.center,
//                     //           style: TextStyle(
//                     //             color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
//                     //             fontSize: 16,
//                     //             fontFamily: AppThemeData.medium,
//                     //             fontWeight: FontWeight.w500,
//                     //           ),
//                     //         ),
//                     //       ),
//                     //       const Expanded(child: Divider()),
//                     //     ],
//                     //   ),
//                     // ),
//                     // RoundedButtonBorder(
//                     //   title: "Continue with Email".tr,
//                     //   textColor: AppThemeData.primary300,
//                     //   icon: SvgPicture.asset("assets/icons/ic_mail.svg"),
//                     //   isRight: false,
//                     //   onPress: () async {
//                     //     Get.back();
//                     //   },
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//             // bottomNavigationBar: Padding(
//             //   padding: EdgeInsets.symmetric(vertical: Platform.isAndroid ? 10 : 30),
//             //   child: Column(
//             //     mainAxisSize: MainAxisSize.min,
//             //     children: [
//             //       Text.rich(
//             //         TextSpan(
//             //           children: [
//             //             TextSpan(
//             //               text: "Don't have an account?".tr,
//             //               style: TextStyle(
//             //                 color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//             //                 fontSize: 14,
//             //                 fontWeight: FontWeight.w400,
//             //               ),
//             //             ),
//             //       const WidgetSpan(child: SizedBox(width: 10)),
//             //             TextSpan(
//             //                 recognizer: TapGestureRecognizer()
//             //                   ..onTap = () {
//             //                     Get.to(const SignupScreen());
//             //                   },
//             //                 text: 'Sign up'.tr,
//             //                 style: TextStyle(
//             //                     color: AppThemeData.primary300,
//             //                     fontFamily: AppThemeData.bold,
//             //                     fontWeight: FontWeight.w500,
//             //                     decoration: TextDecoration.underline,
//             //                     decorationColor: AppThemeData.primary300)),
//             //           ],
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//           );
//   }
// }
