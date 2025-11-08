import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/app/dash_board_screens/controller/dash_board_controller.dart';
import 'package:customer/main.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customer/utils/utils/image_const.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DashBoardController(),
        builder: (controller) {
          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvoked: (didPop) {
              if (didPop) return;
              if(controller.selectedIndex.value==0){
                final now = DateTime.now();
                if (controller.currentBackPressTime == null ||
                    now.difference(controller.currentBackPressTime!) >
                        const Duration(seconds: 2)) {
                  controller.currentBackPressTime = now;
                  controller.canPopNow.value = false;
                  ShowToastDialog.showToast("Double press to exit".tr);
                } else {
                  // Second press within 2 seconds - exit the app
                  SystemNavigator.pop();
                }
              }else{
                controller.changeNavbar(0);
              }
            },
            // onPopInvokedWithResult: (didPop, dynamic) {
            //   final now = DateTime.now();
            //   if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
            //     controller.currentBackPressTime = now;
            //     controller.canPopNow.value = false;
            //     ShowToastDialog.showToast("Double press to exit");
            //     return;
            //   } else {
            //     controller.canPopNow.value = true;
            //   }
            // },
            child: Scaffold(
              body: Obx(() => IndexedStack(
                    index: controller.selectedIndex.value,
                    children: controller.pageList.toList(),
                  )),
              bottomNavigationBar: Obx(() {
                final items = [
                  navigationBarItem(
                    themeChange,
                    index: 0,
                    assetIcon:  ImageConst.homeOne,
                    label: 'Home'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 1,
                    assetIcon:ImageConst.favoriteOne,
                    label: 'Favourites'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 2,
                    assetIcon: ImageConst.cartOne,
                    label: 'Cart'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 3,
                    assetIcon: ImageConst.orderOne,
                    label: 'Orders'.tr,
                    controller: controller,
                  ),
                ];
                final safeIndex =
                    controller.selectedIndex.value.clamp(0, items.length - 1);
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: true,
                  showSelectedLabels: true,
                  selectedFontSize: 12,
                  selectedLabelStyle:
                      const TextStyle(fontFamily: AppThemeData.bold),
                  unselectedLabelStyle:
                      const TextStyle(fontFamily: AppThemeData.bold),
                  currentIndex: safeIndex,
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.grey900
                      : AppThemeData.grey50,
                  selectedItemColor: themeChange.getThem()
                      ? AppThemeData.primary300
                      : AppThemeData.primary300,
                  unselectedItemColor: themeChange.getThem()
                      ? AppThemeData.grey300
                      : AppThemeData.grey600,
                  onTap: (int index) {
                    controller.changeNavbar(index.clamp(0, items.length - 1));
                  },
                  items: items,
                );
              }),
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange,
      {required int index,
      required String label,
      required String assetIcon,
      required DashBoardController controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: assetIcon.endsWith('.svg')
            ? SvgPicture.asset(
                assetIcon,
                height: 22,
                width: 22,
                color: controller.selectedIndex.value == index
                    ? themeChange.getThem()
                        ? AppThemeData.primary300
                        : AppThemeData.primary300
                    : themeChange.getThem()
                        ? AppThemeData.grey300
                        : AppThemeData.grey600,
              )
            : Image.asset(
                assetIcon,
                height: 22,
                width: 22,
                color: controller.selectedIndex.value == index
                    ? themeChange.getThem()
                        ? AppThemeData.primary300
                        : AppThemeData.primary300
                    : themeChange.getThem()
                        ? AppThemeData.grey300
                        : AppThemeData.grey600,
              ),
      ),
      label: label,
    );
  }
}
