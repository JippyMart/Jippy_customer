
import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/controllers/mart_navigation_controller.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/utils/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../cart_screen/widget/cart_build_delivery_ui.dart' show CartTheme, CartThemeColors;

class MartCategoriesScreen extends StatefulWidget {
  const MartCategoriesScreen({super.key});

  @override
  State<MartCategoriesScreen> createState() => _MartCategoriesScreenState();
}

class _MartCategoriesScreenState extends State<MartCategoriesScreen> {
  late MartController _martController;

  @override
  void initState() {
    super.initState();
    _martController = Get.find<MartController>();

  }
  Future<void> _loadCategories() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _martController.loadCategoriesStreaming();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:ColorConst.martPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () {
              try {
                final martNavController =
                Get.find<MartNavigationController>();
                martNavController.goToHome();
              } catch (e) {
                Get.back();
              }
          },
        ),
        title: Text(
          'Categories',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
        ],
      ),
      backgroundColor: Colors.white, // Pure white background for grocery app
      body: GetX<MartController>(
        builder: (controller) {
          if (controller.isCategoryLoading.value) {
            return _buildLoadingState();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState();
          }
          return RefreshIndicator(
            backgroundColor: Colors.white,
            color: MartTheme.jippyMartButton,
            onRefresh: _loadCategories,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: _buildCategoriesBySections(controller.martCategories),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MartTheme.jippyMartButton.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: MartTheme.jippyMartButton,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your grocery items ready',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your internet connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: MartTheme.jippyMartButton,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: MartTheme.jippyMartButton.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategoriesBySections(List<MartCategoryModel> categories) {
    Map<String, List<MartCategoryModel>> sections = {};
    Map<String, int> sectionOrders = {};
    for (var category in categories) {
      String sectionName = category.section ?? 'Other';
      if (!sections.containsKey(sectionName)) {
        sections[sectionName] = [];
        sectionOrders[sectionName] = category.sectionOrder ?? 999;
      }
      sections[sectionName]!.add(category);
    }

    List<String> sortedSections = sections.keys.toList()
      ..sort((a, b) => (sectionOrders[a] ?? 999).compareTo(sectionOrders[b] ?? 999));
    return Column(
      children: [
        ...sortedSections.asMap().entries.map((entry) {
          final index = entry.key;
          final sectionName = entry.value;
          final sectionCategories = sections[sectionName]!;
          return _buildSection(sectionName, sectionCategories);
        }),
      ],
    );
  }

  Widget _buildSection(String sectionName, List<MartCategoryModel> sectionCategories) {
    sectionCategories.sort((a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: sectionCategories.length,
      itemBuilder: (context, index) {
        final category = sectionCategories[index];
        return _buildCategoryCard(category,);
      },
    );
  }

  Widget _buildCategoryCard(MartCategoryModel category, ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.to(() => const MartCategoryDetailScreen(), arguments: {
            'categoryId': category.id,
            'categoryName': category.title ?? 'Category',
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(width: double.infinity,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 83 ,
                height:  50 ,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFE), // Slightly darker purple for better contrast
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: MartTheme.jippyMartButton.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: category.photo != null && category.photo!.isNotEmpty
                      ? NetworkImageWidget(
                    imageUrl: category.photo!,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: const Color(0xFFF0EFFE),
                      child: Icon(
                        Icons.category_rounded,
                        size:  24,
                        color: MartTheme.jippyMartButton,
                      ),
                    ),
                  )  : Container(
                    color: const Color(0xFFF0EFFE),
                    child: Icon(
                      Icons.category_rounded,
                      size: 24,
                      color: MartTheme.jippyMartButton,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 30,),
              Text(
                category.title ?? 'Category',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorConst.blackColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,color: ColorConst.blackColor,)
            ],
          ),
        ),
      ),
    );
  }
}

