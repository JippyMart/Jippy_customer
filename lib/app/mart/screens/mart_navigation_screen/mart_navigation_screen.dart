import 'package:customer/utils/utils/color_const.dart';
import 'package:customer/utils/utils/image_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/mart_navigation_controller.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:provider/provider.dart';

class MartNavigationScreen extends StatelessWidget {
  const MartNavigationScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MartTheme.theme,
      child: GetBuilder<MartNavigationController>(
        init: MartNavigationController(),
        builder: (navController) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              if (navController.selectedIndex.value == 0) {
                Get.back();
              } else {
                navController.goToHome();
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F6FF),
              body:  Obx(() => IndexedStack(
                      index: navController.selectedIndex.value,
                      children: navController.pageList,
                    )),
              // body: Stack(
              //   children: [
              //     Obx(() => IndexedStack(
              //       index: navController.selectedIndex.value,
              //       children: navController.pageList,
              //     )),
              //
              //     // Fixed Enhanced Floating Navigation Bar
              //     // Obx(() {
              //     //   if (navController.selectedIndex.value != 2) {
              //     //     return Positioned(
              //     //       bottom: 0,
              //     //       left: 0,
              //     //       right: 0,
              //     //       child: _buildEnhancedNavigationBar(navController),
              //     //     );
              //     //   } else {
              //     //     return const SizedBox.shrink();
              //     //   }
              //     // }),
              //   ],
              // ),
              bottomNavigationBar:  Obx(() {
                if (navController.selectedIndex.value != 2) {
               return   _buildEnhancedNavigationBar(navController);
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedNavigationBar(MartNavigationController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(24),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.15),
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //     spreadRadius: 0,
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //     spreadRadius: 0,
        //   ),
        // ],
        // border: Border.all(
        //   color: Colors.grey.withOpacity(0.1),
        //   width: 1,
        // ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEnhancedNavItem(
              icon: ImageConst.homeOne,
              activeIcon:ImageConst.homeOne,
              label: 'Home',
              index: 0,
              controller: controller,
            ),
            _buildEnhancedNavItem(
              icon: ImageConst.categoriesOne,
              activeIcon: ImageConst.categoriesOne,
              label: 'Categories',
              index: 1,
              controller: controller,
            ),
            _buildEnhancedNavItem(
              icon: ImageConst.cartOne,
              activeIcon:  ImageConst.cartOne,
              label: 'Cart',
              index: 2,
              controller: controller,
              badge: Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return StreamBuilder<List<CartProductModel>>(
                    stream: cartProvider.cartStream,
                    builder: (context, snapshot) {
                      int cartItemCount = snapshot.data?.length ?? cartItem.length;
                      return cartItemCount > 0
                          ? _buildCartBadge(cartItemCount)
                          : const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
            _buildEnhancedNavItem(
              icon:  ImageConst.profile,
              activeIcon:  ImageConst.profile,
              label: 'Profile',
              index: 3,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNavItem({
    required String icon,
    required String activeIcon,
    required String label,
    required int index,
    required MartNavigationController controller,
    Widget? badge,
  }) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;
      final primaryColor =  ColorConst.orangeLight;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            gradient: isActive ? LinearGradient(
              colors: [
                primaryColor.withOpacity(0.12),
                primaryColor.withOpacity(0.04),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        isActive ? activeIcon : icon,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          isActive ? primaryColor : const Color(0xFF6B7280),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  if (badge != null && index == 2)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: badge,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? primaryColor : const Color(0xFF6B7280),
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCartBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xFFEF4444),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFEF4444),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          height: 0.8,
        ),
      ),
    );
  }
}