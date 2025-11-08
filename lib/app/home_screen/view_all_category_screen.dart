import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/view_all_category_controller.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ViewAllCategoryScreen extends StatelessWidget {
  const ViewAllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX(
      init: ViewAllCategoryController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDark ? AppThemeData.grey50 : AppThemeData.grey50,
          appBar: AppBar(
            backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            title: Text(
              "Categories".tr,
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                fontFamily: AppThemeData.extraBold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(10),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: controller.vendorCategoryModel.length,
                      itemBuilder: (context, index) {
                        VendorCategoryModel vendorCategoryModel = controller.vendorCategoryModel[index];
                        return _buildCategoryItem(
                          vendorCategoryModel,
                          isDark,
                          context,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
      VendorCategoryModel category,
      bool isDark,
      BuildContext context,
      ) {
    return Card(
      elevation: 0,
      shadowColor: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? AppThemeData.grey50 : AppThemeData.grey50,
      child: InkWell(
        onTap: () {
          Get.to(
            const CategoryRestaurantScreen(),
            arguments: {
              "vendorCategoryModel": category,
              "dineIn": false,
            },
            transition: Transition.cupertino,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Category Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppThemeData.surfaceDark : Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: NetworkImageWidget(
                    imageUrl: category.photo.toString(),
                    fit: BoxFit.cover,
                    // placeholder: Container(
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: isDark ? AppThemeData.grey800 : AppThemeData.grey200,
                    //   ),
                    //   child: Icon(
                    //     Icons.category,
                    //     color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    //     size: 30,
                    //   ),
                    // ),
                  ),
                ),
              ),

              // Category Name
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.title ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    fontFamily: AppThemeData.medium,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}