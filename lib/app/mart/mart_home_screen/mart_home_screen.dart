import 'package:customer/app/mart/mart_home_screen/widget/grocery_component_widget.dart';
import 'package:customer/app/mart/mart_home_screen/widget/mart_header_card.dart';
import 'package:customer/app/mart/mart_search_screen.dart';
import 'package:customer/app/mart/screens/mart_categorhy_details_screen/mart_category_detail_screen.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/app/mart/mart_home_screen/widget/mart_sub_category_section.dart';
import 'package:customer/app/mart/widgets/mart_product_home_card.dart';
import 'package:customer/app/mart/widgets/mart_search_bar.dart';
import 'package:customer/app/mart/widgets/playtime_product_card.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/models/mart_banner_model.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/mart_subcategory_model.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/utils/color_const.dart';
import 'package:customer/utils/utils/image_const.dart';
import 'package:customer/widget/animated_search_hint.dart';
import 'package:customer/widgets/reusable_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MartHomeScreen extends StatelessWidget {
  const MartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return Theme(
        data: MartTheme.theme,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GetBuilder<MartController>(
            builder: (controller) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.featuredCategories.isEmpty &&
                    !controller.isCategoryLoading.value &&
                    !controller.isHomepageCategoriesLoaded.value) {
                  controller.loadHomepageCategoriesStreaming(limit: 6);
                }
                if (controller.featuredItems.isEmpty &&
                    !controller.isProductLoading.value) {
                  controller.loadFeaturedItemsStreaming();
                }
                if (controller.trendingItems.isEmpty &&
                    !controller.isTrendingLoading.value) {
                  controller.loadTrendingItemsStreaming();
                }
                // Load subcategories for the subcategories section
                if (controller.subcategories.isEmpty &&
                    !controller.isSubcategoryLoading.value) {

                  if (controller.featuredCategories.isNotEmpty) {
                    final mainCategory = controller.featuredCategories[0];
                    controller
                        .loadSubcategoriesStreaming(mainCategory.id ?? '');
                  }
                }
                Future.microtask(() {
                  controller.loadMartBannersStream();
                });
                if (controller.martTopBanners.isNotEmpty) {
                  controller.startMartBannerTimer();
                }
              });
              return SingleChildScrollView(
                child: Column(
                  children: [
                  Stack(
                        children: [
                          Container(
                            height: 430, // set your desired height
                            width: double.infinity,  // set your desired width
                            decoration: BoxDecoration(
                              color: ColorConst.greenLight,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(26),bottomRight: Radius.circular(26
                                ,)
                                ,), // set your desired radius
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: controller.refreshData,
                            child: Column(
                              children: [
                                MartHeaderCard(screenWidth: screenWidth),
                                SizedBox(height: 10,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => const MartSearchScreen());
                                    },
                                    child: AnimatedSearchHint(
                                      controller: null,
                                      enable: false,
                                      fillColor: Colors.white,
                                      fontFamily: 'Outfit-Bold',
                                      textStyle: TextStyle(
                                        fontFamily: 'Outfit-Bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      hintTextStyle: TextStyle(
                                        fontFamily: 'Outfit-Bold',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                      suffix: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_search.svg",
                                          color: Color(0xFFff5201),
                                        ),
                                      ),
                                      hints: [
                                        "Search 'milk'",
                                        "Search 'bread'",
                                        "Search 'rice'",
                                        "Search 'atta'",
                                        "Search 'oil'",
                                        "Search 'sugar'",
                                        "Search 'tea'",
                                        "Search 'coffee'",
                                        "Search 'snacks'",
                                        "Search 'biscuits'",
                                        "Search 'cold drinks'",
                                        "Search 'toothpaste'",
                                        "Search 'detergent'",
                                        "Search 'shampoo'",
                                        "Search 'soap'",
                                        "Search 'cleaning supplies'",
                                        "Search 'baby care'",
                                        "Search 'personal care'",
                                        "Search 'frozen food'",
                                        "Search 'fresh vegetables'",
                                        "Search 'fruits'",
                                        "Search 'eggs'",
                                        "Search 'dry fruits'",
                                        "Search 'masala'",
                                        "Search 'instant food'",
                                        "Search 'breakfast items'",
                                        "Search 'stationery'",
                                        "Search 'pet food'",
                                        "Search 'household essentials'",
                                        "Search 'kitchen items'",
                                        "Search 'offers near you'",
                                        "Search 'best deals'",
                                        "Search 'today’s discount'",
                                        "Search 'new arrivals'",
                                        "Search 'bestsellers'",
                                      ],
                                      interval: const Duration(seconds: 2),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Obx(() {
                                    if (controller.martTopBanners.isNotEmpty) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10),
                                            child: ReusableBannerWidget(
                                              banners: controller.martTopBanners,
                                              pageController: controller
                                                  .martTopBannerController.value,
                                              currentPage:
                                              controller.currentTopBannerPage,
                                              height: 150,
                                              onPanStart: () =>
                                                  controller.stopMartBannerTimer(),
                                              onPanEnd: () =>
                                                  controller.startMartBannerTimer(),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                                SizedBox(height: 10,),
                                groceryComponent(size),
                              // MartFeaturedProducts(screenWidth: screenWidth),
                              // Obx(() {
                              //       if (controller.martBottomBanners.isNotEmpty) {
                              //         return Column(
                              //           children: [
                              //             const SizedBox(height: 8),
                              //             ReusableBannerWidget(
                              //               banners: controller.martBottomBanners,
                              //               pageController: controller
                              //                   .martBottomBannerController.value,
                              //               currentPage:
                              //               controller.currentBottomBannerPage,
                              //               height: 150,
                              //               enableAutoScroll:
                              //               false, // Bottom banners don't auto-scroll
                              //             ),
                              //             const SizedBox(height: 8),
                              //             BannerIndicatorDots(
                              //               itemCount:
                              //               controller.martBottomBanners.length,
                              //               currentIndex:
                              //               controller.currentBottomBannerPage,
                              //               activeColor: const Color(0xFF00998a),
                              //               inactiveColor: Colors.grey[300]!,
                              //             ),
                              //             const SizedBox(height: 8),
                              //           ],
                              //         );
                              //       }
                              //       return const SizedBox.shrink();
                              //     }),
                               // MartTrendingDealsPersonalCare(
                               //        screenWidth: screenWidth,),
                                // Subcategories Section
                                // MartSubcategoriesSection(
                                //       screenWidth: screenWidth),
                                // // Product Deals Section
                              // MartProductDealsSection(screenWidth: screenWidth),
                                // Dynamic Sections from Firebase
                                // MartDynamicSections(screenWidth: screenWidth),
                                MartDynamicSectionsEnhanced(screenWidth: screenWidth),
                                 SizedBox(height: 25,),
                              ],
                            ),
                          ),
                          // Positioned(
                          //   bottom: MediaQuery.of(context).padding.bottom +
                          //       120, // Above bottom navigation
                          //   right: 16,
                          //   child: GestureDetector(
                          //     onTap: () async {
                          //       // WhatsApp number - you can change this to your desired number
                          //       const String phoneNumber =
                          //           '+919390579864'; // Your actual WhatsApp number
                          //       const String message =
                          //           'Hello! I need help with my JippyMart order.'; // Customize the message
                          //
                          //       final Uri whatsappUrl = Uri.parse(
                          //           'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
                          //
                          //       try {
                          //         if (await canLaunchUrl(whatsappUrl)) {
                          //           await launchUrl(whatsappUrl,
                          //               mode: LaunchMode.externalApplication);
                          //         } else {
                          //           // Fallback to regular phone call if WhatsApp is not available
                          //           final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                          //           if (await canLaunchUrl(phoneUrl)) {
                          //             await launchUrl(phoneUrl,
                          //                 mode: LaunchMode.externalApplication);
                          //           }
                          //         }
                          //       } catch (e) {
                          //         print('Error launching WhatsApp: $e');
                          //       }
                          //     },
                          //     child: Container(
                          //       width: 56,
                          //       height: 56,
                          //       decoration: BoxDecoration(
                          //         color: Colors.green, // WhatsApp green color
                          //         shape: BoxShape.circle,
                          //         boxShadow: [
                          //           BoxShadow(
                          //             color: Colors.black.withOpacity(0.2),
                          //             blurRadius: 8,
                          //             offset: const Offset(0, 4),
                          //           ),
                          //         ],
                          //       ),
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(0.0),
                          //         child: SvgPicture.asset(
                          //           'assets/images/whatsapp.svg',
                          //           width: 24,
                          //           height: 24,
                          //           colorFilter: const ColorFilter.mode(
                          //             Colors.white,
                          //             BlendMode.srcIn,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton:   GestureDetector(
            onTap: () async {
              // WhatsApp number - you can change this to your desired number
              const String phoneNumber =
                  '+919390579864'; // Your actual WhatsApp number
              const String message =
                  'Hello! I need help with my JippyMart order.'; // Customize the message

              final Uri whatsappUrl = Uri.parse(
                  'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

              try {
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl,
                      mode: LaunchMode.externalApplication);
                } else {
                  // Fallback to regular phone call if WhatsApp is not available
                  final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                  if (await canLaunchUrl(phoneUrl)) {
                    await launchUrl(phoneUrl,
                        mode: LaunchMode.externalApplication);
                  }
                }
              } catch (e) {
                print('Error launching WhatsApp: $e');
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green, // WhatsApp green color
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SvgPicture.asset(
                  'assets/images/whatsapp.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}



class MartSpotlightSelections extends StatelessWidget {
  final double screenWidth;

  const MartSpotlightSelections({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 413,
      height: 263,
      decoration: const BoxDecoration(
        color: Color(0xFF00998a), // Rectangle 5 background
      ),
      child: Stack(
        children: [
          // Face In Clouds icon
          Positioned(
            left: 169,
            top: 19,
            child: Container(
              width: 67,
              height: 67,
              child: Image.asset(
                'assets/images/FaceInClouds.gif',
                width: 67,
                height: 67,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 67,
                    height: 67,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(33.5),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          // Spotlight Selections title
          Positioned(
            left: 35,
            top: 86,
            child: const Text(
              'Spotlight Selections',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 39 / 32,
                color: Colors.white,
              ),
            ),
          ),

          // Frame 40 - Horizontal scrollable container
          Positioned(
            left: 1,
            top: 150,
            child: Container(
              width: 402,
              height: 92,
              child: GetX<MartController>(
                builder: (controller) {
                  if (controller.spotlightItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'No spotlight items available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...controller.spotlightItems
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Row(
                            children: [
                              _SpotlightCard(
                                title: item['title'] ?? 'Category',
                                discount: item['discount'] ?? 'Up to 50% OFF',
                              ),
                              // Add spacing between cards (except for the last one)
                              if (index < controller.spotlightItems.length - 1)
                                const SizedBox(width: 12),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Spotlight Card widget matching CSS specifications
class _SpotlightCard extends StatelessWidget {
  final String title;
  final String discount;

  const _SpotlightCard({
    required this.title,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show coming soon message
        Get.snackbar(
          'Coming Soon',
          'This feature is under development',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        width: 88,
        height: 92,
        child: Stack(
          children: [
            // Rectangle background (white card)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 88,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9EE),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            // Category title - positioned based on CSS
            Positioned(
              left: 4,
              top: 7,
              child: SizedBox(
                width: 80,
                height: 24,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 12 / 10,
                    color: Color(0xFF000000),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Gradient offer bar - positioned based on CSS
            Positioned(
              left: 4,
              top: 73,
              child: Container(
                width: 80,
                height: 15,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF595BD4), // #595BD4
                      Color(0xFF9140D8), // #9140D8
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
              ),
            ),

            // Discount text - positioned based on CSS
            Positioned(
              left: 12,
              top: 76,
              child: Text(
                discount,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  height: 9 / 7,
                  color: Colors.white,
                ),
              ),
            ),

            // Placeholder icon in center (Rectangle with background url)
            Positioned(
              left: 30, // Fixed position for all cards
              top: 36, // 39.13% of 92px ≈ 36px
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D56F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper method for spotlight subcategories
List<MartSubcategoryModel> _getSpotlightSubcategories(String title) {
  // Generate subcategories based on spotlight title
  final cleanTitle = title.toLowerCase();

  if (cleanTitle.contains('fresh fruits')) {
    return [
      MartSubcategoryModel(
        id: 'spotlight_fruit_001',
        title: 'Seasonal Fruits',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_fruit_002',
        title: 'Citrus Fruits',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_fruit_003',
        title: 'Tropical Fruits',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_fruit_004',
        title: 'Berries',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_fruit_005',
        title: 'Exotic Fruits',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_fruit_006',
        title: 'Organic Fruits',
        photo:
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
      ),
    ];
  } else if (cleanTitle.contains('dairy')) {
    return [
      MartSubcategoryModel(
        id: 'spotlight_dairy_001',
        title: 'Milk & Milk Products',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_dairy_002',
        title: 'Cheese & Butter',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_dairy_003',
        title: 'Yogurt & Curd',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_dairy_004',
        title: 'Bread & Bakery',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_dairy_005',
        title: 'Eggs',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_dairy_006',
        title: 'Organic Dairy',
        photo:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
      ),
    ];
  } else if (cleanTitle.contains('tea') || cleanTitle.contains('coffee')) {
    return [
      MartSubcategoryModel(
        id: 'spotlight_beverage_001',
        title: 'Tea Varieties',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_beverage_002',
        title: 'Coffee Beans',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_beverage_003',
        title: 'Instant Coffee',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_beverage_004',
        title: 'Milk Drinks',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_beverage_005',
        title: 'Energy Drinks',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_beverage_006',
        title: 'Organic Beverages',
        photo:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
      ),
    ];
  } else {
    // Default subcategories for other spotlight items
    return [
      MartSubcategoryModel(
        id: 'spotlight_default_001',
        title: 'Popular Items',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_default_002',
        title: 'New Arrivals',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_default_003',
        title: 'Best Sellers',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_default_004',
        title: 'On Sale',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_default_005',
        title: 'Premium Selection',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
      MartSubcategoryModel(
        id: 'spotlight_default_006',
        title: 'Organic Options',
        photo:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
      ),
    ];
  }
}

class SpotlightCard extends StatelessWidget {
  final String title;
  final String offer;
  final String imageUrl;

  const SpotlightCard({
    super.key,
    required this.title,
    required this.offer,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MartTheme.greenVeryLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title at top
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 6, right: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // GIF placeholder in middle (purple background)
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: const Color(0xFF5D56F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imageUrl,
                          width: 67,
                          height: 67,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 67,
                              height: 67,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A45D1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 67,
                        height: 67,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A45D1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),
            ),
          ),

          // Gradient discount footer (purple to blue gradient)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB96CF3), Color(0xFF5F55FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Text(
              offer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MartStealsOfMoment extends StatelessWidget {
  final double screenWidth;

  const MartStealsOfMoment({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 413,
      height: 158,
      // margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Padding(
            padding:
                EdgeInsets.only(left: 16, bottom: 4), // Reduced from 8 to 4
            child: Text(
              'Steals of the moment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Frame 276 - Horizontal scrollable container
          Expanded(
            child: SizedBox(
              width: 413,
              height: 123, // Reduced from 141 to fit smaller container
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1040, // Total width to accommodate all cards
                  height: 123, // Reduced from 141 to fit smaller container
                  child: Stack(
                    children: [
                      // Card 1: Hair Styling (Group 267)
                      Positioned(
                        left: 11,
                        top: 1,
                        child: Container(
                          width: 119,
                          height: 141,
                          child: Stack(
                            children: [
                              // Rectangle 6 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCCCFF),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Hair Styling text
                              Positioned(
                                left: 16,
                                top: 24,
                                child: SizedBox(
                                  width: 103,
                                  height: 32,
                                  child: Text(
                                    'Hair Styling',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      height: 20 / 16,
                                      color: const Color(0xFF00998a),
                                    ),
                                  ),
                                ),
                              ),
                              // FEATURED label
                              Positioned(
                                left: 21, // Center the label
                                top: 133,
                                child: SizedBox(
                                  width: 76,
                                  height: 9,
                                  child: Text(
                                    'FEATURED',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 2: Breakfast Essentials (Group 268)
                      Positioned(
                        left: 141,
                        top: 2,
                        child: Container(
                          width: 118.61,
                          height: 140,
                          child: Stack(
                            children: [
                              // Rectangle 7 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7CC),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Breakfast Essentials text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 20, // Moved up to give more space
                                child: SizedBox(
                                  width: 86.26,
                                  height:
                                      50, // Increased height to prevent text cutoff
                                  child: Text(
                                    'Breakfast Essentials\nUp To 50% OFF',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      height: 16 / 13,
                                      color: const Color(0xFF7E3D29),
                                    ),
                                  ),
                                ),
                              ),
                              // IN FOCUS label
                              Positioned(
                                left: 23, // Center the label
                                top: 133, // 135 - 2
                                child: SizedBox(
                                  width: 72,
                                  height: 7,
                                  child: Text(
                                    'IN FOCUS',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 3: Indian Sweets (Group 269)
                      Positioned(
                        left: 270.61,
                        top: 0,
                        child: Container(
                          width: 118.61,
                          height: 142,
                          child: Stack(
                            children: [
                              // Rectangle 8 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7D0EE),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Indian Sweets text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 24, // Adjusted for better positioning
                                child: SizedBox(
                                  width: 83,
                                  height: 32,
                                  child: Text(
                                    'Indian Sweets',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      height: 18 / 15,
                                      color: const Color(0xFFE32D8F),
                                    ),
                                  ),
                                ),
                              ),
                              // TRENDING NOW label
                              Positioned(
                                left: 10, // Center the label
                                top: 133, // 133 - 0
                                child: SizedBox(
                                  width: 99,
                                  height: 9,
                                  child: Text(
                                    'TRENDING NOW',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 4: All Natural juices (Group 270)
                      Positioned(
                        left: 400.22,
                        top: 2,
                        child: Container(
                          width: 118.61,
                          height: 140,
                          child: Stack(
                            children: [
                              // Rectangle 9 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC7EEFE),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // All Natural juices text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 24, // Adjusted for better positioning
                                child: SizedBox(
                                  width: 76.83,
                                  height: 32.35,
                                  child: Text(
                                    'All Natural juices',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      height: 20 / 16,
                                      color: const Color(0xFF4C4EE1),
                                    ),
                                  ),
                                ),
                              ),
                              // FRESHLY DROPPED label
                              Positioned(
                                left: 5, // 405.22 - 400.22
                                top: 133, // 135 - 2
                                child: SizedBox(
                                  width: 104,
                                  height: 7,
                                  child: Text(
                                    'FRESHLY DROPPED',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 5: Toys & Games (Group 274)
                      Positioned(
                        left: 529.83,
                        top: 2,
                        child: Container(
                          width: 118.61,
                          height: 140,
                          child: Stack(
                            children: [
                              // Rectangle 10 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5C3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Toys & Games text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 20, // Moved up to give more space
                                child: SizedBox(
                                  width: 100,
                                  height:
                                      50, // Increased height to prevent text cutoff
                                  child: Text(
                                    'Toys & Games\nStarting From ₹ 99',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      height: 17 / 14,
                                      color: const Color(0xFF890C23),
                                    ),
                                  ),
                                ),
                              ),
                              // SALE label
                              Positioned(
                                left: 42.87, // 572.7 - 529.83
                                top: 132, // 134 - 2
                                child: SizedBox(
                                  width: 40,
                                  height: 8,
                                  child: Text(
                                    'SALE',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 6: Stationery & Arts (Group 275)
                      Positioned(
                        left: 659.43,
                        top: 1,
                        child: Container(
                          width: 118.65,
                          height: 141,
                          child: Stack(
                            children: [
                              // Rectangle 11 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD0E7EE),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Stationery & Arts text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 24, // Adjusted for better positioning
                                child: SizedBox(
                                  width: 97,
                                  height: 32,
                                  child: Text(
                                    'Stationery & Arts',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      height: 18 / 15,
                                      color: const Color(0xFF5C5C99),
                                    ),
                                  ),
                                ),
                              ),
                              // FEATURED label
                              Positioned(
                                left: 25.35, // 684.78 - 659.43
                                top: 132, // 133 - 1
                                child: SizedBox(
                                  width: 68,
                                  height: 9,
                                  child: Text(
                                    'FEATURED',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 7: Diapers Stockup Sale (Group 272)
                      Positioned(
                        left: 789.09,
                        top: 1,
                        child: Container(
                          width: 118.61,
                          height: 141,
                          child: Stack(
                            children: [
                              // Rectangle 12 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDCDD),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // Up to 60% OFF text (small)
                              Positioned(
                                left: 21.56, // 810.65 - 789.09
                                top: 97.04, // 98.04 - 1
                                child: SizedBox(
                                  width: 74.13,
                                  height: 12.13,
                                  child: Text(
                                    'Up to 60% OFF',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 7,
                                      fontWeight: FontWeight.w700,
                                      height: 9 / 7,
                                      color: const Color(0xFFFFDCDD),
                                    ),
                                  ),
                                ),
                              ),
                              // Diapers Stockup Sale text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 20, // Moved up to give more space
                                child: SizedBox(
                                  width: 86.26,
                                  height:
                                      50, // Increased height to prevent text cutoff
                                  child: Text(
                                    'Diapers Stockup Sale\nUp To 60% OFF',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      height: 17 / 14,
                                      color: const Color(0xFFDC3489),
                                    ),
                                  ),
                                ),
                              ),
                              // TRENDING NOW label
                              Positioned(
                                left: 16.78, // 805.87 - 789.09
                                top: 132, // 133 - 1
                                child: SizedBox(
                                  width: 86,
                                  height: 9,
                                  child: Text(
                                    'TRENDING NOW',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Card 8: BUY GET 1 (Group 273)
                      Positioned(
                        left: 918.7,
                        top: 1,
                        child: Container(
                          width: 121.91,
                          height: 141,
                          child: Stack(
                            children: [
                              // Rectangle 13 - Background
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 118.61,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFFFF2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              // BUY GET text
                              Positioned(
                                left: 16, // Adjusted for better positioning
                                top: 24, // Adjusted for better positioning
                                child: SizedBox(
                                  width: 60.65,
                                  height: 64.7,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF3C720E),
                                        Color(0xFF72D81B)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'BUY GET',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        height: 24 / 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 1 text
                              Positioned(
                                left: 80, // Adjusted for better positioning
                                top: 24, // Adjusted for better positioning
                                child: SizedBox(
                                  width: 40.43,
                                  height: 64.7,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF3C720E),
                                        Color(0xFF72D81B)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        fontFamily: 'NanumGothic',
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                        height: 48 / 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // DEALS OF THE DAY label
                              Positioned(
                                left: 10.91, // 929.61 - 918.7
                                top: 132, // 133 - 1
                                child: SizedBox(
                                  width: 111,
                                  height: 9,
                                  child: Text(
                                    'DEALS OF THE DAY',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 12 / 10,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _StealCard extends StatelessWidget {
  final String title;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double left;
  final bool isSpecial;

  const _StealCard({
    required this.title,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.left,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118.61,
      height: 141,
      margin: EdgeInsets.only(left: left == 11 ? 0 : 12),
      child: Stack(
        children: [
          // Main card background
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 118.61,
              height: 124,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          // Title text
          Positioned(
            left: _getTitleLeft(title),
            top: _getTitleTop(title),
            child: SizedBox(
              width: _getTitleWidth(title),
              height: _getTitleHeight(title),
              child: isSpecial
                  ? _buildSpecialText(title)
                  : Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: _getTitleFontSize(title),
                        fontWeight: FontWeight.w800,
                        height: _getTitleLineHeight(title),
                        color: textColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ),
          ),

          // Label below card
          Positioned(
            left: _getLabelLeft(label),
            top: 133,
            child: SizedBox(
              width: _getLabelWidth(label),
              height: 9,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 12 / 10,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialText(String title) {
    if (title.contains('BUY GET')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "BUY GET" text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3C720E), Color(0xFF72D81B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              'BUY GET',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 24 / 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // "1" text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3C720E), Color(0xFF72D81B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              '1',
              style: TextStyle(
                fontFamily: 'NanumGothic',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 48 / 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    return Text(title);
  }

  double _getTitleLeft(String title) {
    switch (title) {
      case 'Hair Styling':
        return 27;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 158.52;
      case 'Indian Sweets':
        return 289.87;
      case 'All Natural juices':
        return 418.61;
      case 'Toys & Games\nStarting From ₹ 99':
        return 548.35;
      case 'Stationery & Arts':
        return 681.09;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 807.87;
      case 'BUY GET\n1':
        return 937.57;
      default:
        return 27;
    }
  }

  double _getTitleTop(String title) {
    switch (title) {
      case 'Hair Styling':
        return 24;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 25.87;
      case 'Indian Sweets':
        return 23;
      case 'All Natural juices':
        return 26;
      case 'Toys & Games\nStarting From ₹ 99':
        return 26;
      case 'Stationery & Arts':
        return 25;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 25;
      case 'BUY GET\n1':
        return 22.57;
      default:
        return 24;
    }
  }

  double _getTitleWidth(String title) {
    switch (title) {
      case 'Hair Styling':
        return 103;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 86.26;
      case 'Indian Sweets':
        return 83;
      case 'All Natural juices':
        return 76.83;
      case 'Toys & Games\nStarting From ₹ 99':
        return 100;
      case 'Stationery & Arts':
        return 97;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 86.26;
      case 'BUY GET\n1':
        return 60.65;
      default:
        return 103;
    }
  }

  double _getTitleHeight(String title) {
    switch (title) {
      case 'Hair Styling':
        return 32;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 40.43;
      case 'Indian Sweets':
        return 32;
      case 'All Natural juices':
        return 32.35;
      case 'Toys & Games\nStarting From ₹ 99':
        return 40;
      case 'Stationery & Arts':
        return 32;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 40.43;
      case 'BUY GET\n1':
        return 64.7;
      default:
        return 32;
    }
  }

  double _getTitleFontSize(String title) {
    switch (title) {
      case 'Hair Styling':
        return 16;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 13;
      case 'Indian Sweets':
        return 15;
      case 'All Natural juices':
        return 16;
      case 'Toys & Games\nStarting From ₹ 99':
        return 14;
      case 'Stationery & Arts':
        return 15;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 14;
      case 'BUY GET\n1':
        return 20;
      default:
        return 16;
    }
  }

  double _getTitleLineHeight(String title) {
    switch (title) {
      case 'Hair Styling':
        return 20 / 16;
      case 'Breakfast Essentials\nUp To 50% OFF':
        return 16 / 13;
      case 'Indian Sweets':
        return 18 / 15;
      case 'All Natural juices':
        return 20 / 16;
      case 'Toys & Games\nStarting From ₹ 99':
        return 17 / 14;
      case 'Stationery & Arts':
        return 18 / 15;
      case 'Diapers Stockup Sale\nUp To 60% OFF':
        return 17 / 14;
      case 'BUY GET\n1':
        return 24 / 20;
      default:
        return 20 / 16;
    }
  }

  double _getLabelLeft(String label) {
    switch (label) {
      case 'FEATURED':
        return 32;
      case 'IN FOCUS':
        return 173;
      case 'TRENDING NOW':
        return 281.61;
      case 'FRESHLY DROPPED':
        return 405.22;
      case 'SALE':
        return 572.7;
      case 'DEALS OF THE DAY':
        return 929.61;
      default:
        return 32;
    }
  }

  double _getLabelWidth(String label) {
    switch (label) {
      case 'FEATURED':
        return 76;
      case 'IN FOCUS':
        return 72;
      case 'TRENDING NOW':
        return 99;
      case 'FRESHLY DROPPED':
        return 104;
      case 'SALE':
        return 40;
      case 'DEALS OF THE DAY':
        return 111;
      default:
        return 76;
    }
  }
}

class MartTrendingNowSection extends StatelessWidget {
  final double screenWidth;

  const MartTrendingNowSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Trending Now on Jippymart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Trending Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TrendingCategoryItem(
                icon: Icons.home,
                label: 'Home',
                screenWidth: screenWidth,
              ),
              _TrendingCategoryItem(
                icon: Icons.kitchen,
                label: 'Kitchen',
                screenWidth: screenWidth,
              ),
              _TrendingCategoryItem(
                icon: Icons.toys,
                label: 'Toys',
                screenWidth: screenWidth,
              ),
              _TrendingCategoryItem(
                icon: Icons.fitness_center,
                label: 'Sports &\nFitness',
                screenWidth: screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mock controller for testing
  CategoryDetailController _getMockController() {
    final controller = CategoryDetailController();
    // Set mock subcategory data for the controller
    controller.subcategories.value = [
      MartSubcategoryModel(
        id: 'featured',
        title: 'Featured',
        photo:
            'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
      ),
    ];
    return controller;
  }
}

class MartTrendingDealsPersonalCare extends StatelessWidget {
  final double screenWidth;

  const MartTrendingDealsPersonalCare({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    // Load trending items when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final martController = Get.find<MartController>();
        if (martController.filteredTrendingItems.isEmpty &&
            !martController.isTrendingLoading.value) {
          martController.loadTrendingItemsStreaming();
        }
      } catch (e) {
        print(
            '[MART HOME] Controller not found, skipping trending items load: $e');
      }
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          // left: 16,
          // right: 16,
          ), // Reduced from 16 to 12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Title and See All
          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 16,
          //     right: 16,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       const Text(
          //         'Trending deals',
          //         style: TextStyle(
          //           fontSize: 20,
          //           fontWeight: FontWeight.bold,
          //           color: Color(0xFF2D1B69),
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: () {
          //           // Navigate to category detail screen with trending filter
          //           Get.to(() => MartCategoryDetailScreen(), arguments: {
          //             'categoryId': 'trending',
          //             'categoryName': 'Trending Deals',
          //             'initialFilter': 'trending',
          //           });
          //         },
          //         child: const Text(
          //           'See All >',
          //           style: TextStyle(
          //             fontSize: 16,
          //             color: Colors.blue,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending deals',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => MartCategoryDetailScreen(), arguments: {
                      'categoryId': 'trending',
                      'categoryName': 'Trending Deals',
                      'initialFilter': 'trending',
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConst.martPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.martPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal Scrolling Products using MartProductCard with API data
          GetX<MartController>(
            builder: (controller) {
              if (controller.isTrendingLoading.value) {
                return const SizedBox(
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.filteredTrendingItems.isEmpty) {
                return SizedBox(
                  height: 280,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No trending items found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            controller.loadTrendingItemsStreaming();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isTablet = screenWidth > 600;
                  final isLargePhone = screenWidth > 400;
                  // Calculate dynamic card width based on screen size
                  // final cardWidth =
                  //     isTablet ? 200.0 : (isLargePhone ? 180.0 : 160.0);
                  final cardWidth =
                  isTablet ? 200.0 : (isLargePhone ? 130.0 : 130.0);
                  // 🔑 Auto-adjustable layout using Wrap for truly flexible card heights
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      // right: 16,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: 0,
                        runSpacing: 16.0,
                        children:
                            controller.filteredTrendingItems.map((product) {
                          return SizedBox(
                            width: cardWidth,
                            child: MartProductCardHome(
                              product: product,
                              controller: _getMockController(),
                              screenWidth: screenWidth,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Mock controller for testing
  CategoryDetailController _getMockController() {
    final controller = CategoryDetailController();
    // Set mock subcategory data for the controller
    controller.subcategories.value = [
      MartSubcategoryModel(
        id: 'trending',
        title: 'Trending',
        photo:
            'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
      ),
    ];
    return controller;
  }
}

class _TrendingCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double screenWidth;

  const _TrendingCategoryItem({
    required this.icon,
    required this.label,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final itemSize = (screenWidth - 80) / 4;

    return Column(
      children: [
        Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            color: const Color(0xFFD8D5FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: itemSize * 0.4,
            color: const Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1B69),
          ),
        ),
      ],
    );
  }
}

class MartKitchenGrocerySection extends StatelessWidget {
  final double screenWidth;

  const MartKitchenGrocerySection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'KITCHEN & GROCERY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Grocery Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Fixed overflow issue
            children: [
              _GroceryItem(
                label: 'Fresh\nVegetables',
                imageUrl:
                    'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Fresh\nFruits',
                imageUrl:
                    'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Dairy, Bread\nand Eggs',
                imageUrl:
                    'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Cereals and\nBreakfast',
                imageUrl:
                    'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Atta, Rice\nand Dal',
                imageUrl:
                    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Oils and\nGhee',
                imageUrl:
                    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Masalas',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Dry Fruits\nand Seed Mix',
                imageUrl:
                    'https://images.unsplash.com/photo-1603046891744-76e6300f82b8?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Biscuits and\nCakes',
                imageUrl:
                    'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Tea, Coffee\nand Milk drinks',
                imageUrl:
                    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Sauces and\nSpreads',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Meat and\nSeafood',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroceryItem extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _GroceryItem({
    required this.label,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            // Show coming soon message
            Get.snackbar(
              'Coming Soon',
              'This feature is under development',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
      child: Container(
        width: 87,
        height: 129,
        child: Stack(
          children: [
            // Rectangle 15 (Image placeholder)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 87,
                height: 91,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAFD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          width: 87,
                          height: 91,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFECEAFD),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Color(0xFF5D56F3),
                                size: 30,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFECEAFD),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF5D56F3),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEAFD),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Color(0xFF5D56F3),
                            size: 30,
                          ),
                        ),
                ),
              ),
            ),

            // Text label
            Positioned(
              left: 9, // 24 - 15 (container left offset)
              top: 99, // 817 - 718 (top offset)
              child: SizedBox(
                width: 70,
                height: 30,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 15 / 12, // line-height: 15px
                    color: Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MartGlowWellnessSection extends StatelessWidget {
  final double screenWidth;

  const MartGlowWellnessSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'GLOW & WELLNESS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Wellness Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 87 / 129, // Exact ratio from CSS
            children: [
              _GroceryItem(
                label: 'Bath &\nBody',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Hair\nCare',
                imageUrl:
                    'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Skincare',
                imageUrl:
                    'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Makeup',
                imageUrl:
                    'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Oral\nCare',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Grooming',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Baby\nCare',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Fragrances',
                imageUrl:
                    'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Protein and\nSupplements',
                imageUrl:
                    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Feminine\nHygiene',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Sexual\nWellness',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Health and\nPharma',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class MartSnacksRefreshmentsSection extends StatelessWidget {
  final double screenWidth;

  const MartSnacksRefreshmentsSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'SNACKS & REFRESHMENTS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Snacks Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 87 / 129, // Exact ratio from CSS
            children: [
              _GroceryItem(
                label: 'Cold Drinks\nand Juices',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Ice Creams and\nFrozen Desserts',
                imageUrl:
                    'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Chips and\nNamkeens',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Chocolates',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Noodles Pasta\nVermicelli',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Frozen\nFood',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Sweets',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Paan\nCorner',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class MartEverydayLifeHomeSection extends StatelessWidget {
  final double screenWidth;

  const MartEverydayLifeHomeSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'EVERYDAY LIFE & HOME',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Everyday Life Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 87 / 129, // Exact ratio from CSS
            children: [
              _GroceryItem(
                label: 'Home and\nFurnishing',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Kitchen and\nDining',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Cleaning\nEssentials',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Clothing',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Mobiles and\nElectronics',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Appliances',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Books and\nStationery',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Jewellery and\nAccessories',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Puja',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Toys and\nGames',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Sports and\nFitness',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
              _GroceryItem(
                label: 'Pet\nSupplies',
                imageUrl:
                    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class MartLocalStoreSection extends StatelessWidget {
  final double screenWidth;

  const MartLocalStoreSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'LOCAL STORE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Local Store Categories - Horizontal Scroll
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _LocalStoreItem(
                  label: 'Party Store',
                  color: const Color(0xFFD8D5FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Gourmet Store',
                  color: const Color(0xFFFFE4B5),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Puja Store',
                  color: const Color(0xFFFFE4E1),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Local Favourites',
                  color: const Color(0xFFFFE4B5),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Toys & Stationery',
                  color: const Color(0xFFFFE4E1),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Gifting Store',
                  color: const Color(0xFFE0E0FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Pet Store',
                  color: const Color(0xFFE8D7C6),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Health & Fitness',
                  color: const Color(0xFFD8D5FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Travel Store',
                  color: const Color(0xFFE0E0FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Electronics Store',
                  color: const Color(0xFFD8D5FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Fashion Store',
                  color: const Color(0xFFFFE4E1),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Beauty Store',
                  color: const Color(0xFFFFE4B5),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Sports Store',
                  color: const Color(0xFFE8D7C6),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Book Store',
                  color: const Color(0xFFD8D5FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Music Store',
                  color: const Color(0xFFE0E0FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Art & Craft',
                  color: const Color(0xFFFFE4B5),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Garden Store',
                  color: const Color(0xFFE8D7C6),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Auto Store',
                  color: const Color(0xFFD8D5FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Hardware Store',
                  color: const Color(0xFFE0E0FF),
                  screenWidth: screenWidth,
                ),
                _LocalStoreItem(
                  label: 'Pharmacy',
                  color: const Color(0xFFFFE4E1),
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalStoreItem extends StatelessWidget {
  final String label;
  final Color color;
  final double screenWidth;

  const _LocalStoreItem({
    required this.label,
    required this.color,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final itemSize = 120.0; // Further reduced size to fit

    return Container(
      width: itemSize + 12, // Add margin
      margin: const EdgeInsets.only(right: 2),
      child: Column(
        children: [
          Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1B69),
            ),
          ),
        ],
      ),
    );
  }
}

class MartTrendingTodaySection extends StatelessWidget {
  final double screenWidth;

  const MartTrendingTodaySection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Trending Today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Scroll of Promotional Cards
          SizedBox(
            height: 203,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: List.generate(10, (index) => _TrendingCard()),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MartBannerModel>>(
      stream: Get.isRegistered<MartController>()
          ? Get.find<MartController>().streamBannersByPosition('top', limit: 1)
          : Stream.value([]),
      builder: (context, snapshot) {
        // Default data if no banner is available
        String title = 'Nurture with love';
        String description =
            'Find a range of trusted essentials for mom & baby';
        String buttonText = 'SHOP NOW';

        // Use real data if available
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final banner = snapshot.data!.first;
          title = (banner.title?.isNotEmpty == true) ? banner.title! : title;
          description = (banner.description?.isNotEmpty == true &&
                  banner.description != '-')
              ? banner.description!
              : description;
          buttonText = 'SHOP NOW'; // Keep button text consistent
        }

        return GestureDetector(
          onTap: () {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              try {
                Get.find<MartController>()
                    .handleBannerTap(snapshot.data!.first);
              } catch (e) {
                print('[MART HOME] Controller not found for banner tap: $e');
              }
            }
          },
          child: Container(
            width: 300,
            height: 203,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5C5C99),
                  Color(0xFF1F1F33),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Title
                Positioned(
                  left: 20,
                  top: 16,
                  child: SizedBox(
                    width: 158,
                    height: 78,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.22, // 39/32
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Subtitle
                Positioned(
                  left: 20,
                  top: 102,
                  child: SizedBox(
                    width: 174,
                    height: 32,
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.23, // 16/13
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Shop Now Button
                Positioned(
                  left: 20,
                  top: 151,
                  child: Container(
                    width: 130,
                    height: 39,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9EE),
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: Center(
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.21, // 17/14
                          color: Color(0xFF00998a),
                        ),
                      ),
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
}

class MartProductDealsSection extends StatelessWidget {
  final double screenWidth;

  const MartProductDealsSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        // left: 16,
        // right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          // Container(
          //   width: double.infinity,
          //   height: 22,
          //   child: Stack(
          //     children: [
          //       // Section title
          //       const Positioned(
          //         left: 9, // 25 - 16 (container padding)
          //         top: 0,
          //         child: Text(
          //           'Trending deals',
          //           style: TextStyle(
          //             fontFamily: 'Montserrat',
          //             fontSize: 18,
          //             fontWeight: FontWeight.w600,
          //             height: 22 / 18, // line-height: 22px
          //             color: Color(0xFF000000),
          //           ),
          //         ),
          //       ),
          //
          //       // See All text
          //       Positioned(
          //         right: 32, // 338 - 280 (container width - text position)
          //         top: 3, // 3123 - 3120 (top offset)
          //         child: GestureDetector(
          //           onTap: () {
          //             // Navigate to category detail screen with trending filter
          //             Get.to(() => MartCategoryDetailScreen(), arguments: {
          //               'categoryId': 'trending',
          //               'categoryName': 'Trending Deals',
          //               'initialFilter': 'trending',
          //             });
          //           },
          //           child: const Text(
          //             'See All',
          //             style: TextStyle(
          //               fontFamily: 'Montserrat',
          //               fontSize: 14,
          //               fontWeight: FontWeight.w600,
          //               height: 17 / 14, // line-height: 17px
          //               color: Color(0xFF1717FE),
          //             ),
          //           ),
          //         ),
          //       ),
          //
          //
          //       // Right arrow icon
          //       Positioned(
          //         right: 9, // 387 - 378 (container width - icon position)
          //         top: 0,
          //         child: Container(
          //           width: 24,
          //           height: 24,
          //           child: const Icon(
          //             Icons.arrow_forward_ios,
          //             size: 16,
          //             color: Color(0xFF1717FE),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical:8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending deals',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to category detail screen with trending filter
                    Get.to(() => MartCategoryDetailScreen(), arguments: {
                      'categoryId': 'trending',
                      'categoryName': 'Trending Deals',
                      'initialFilter': 'trending',
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConst.martPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.martPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              // right: 16,
            ),
            child: SizedBox(
              height: 215,
              child: StreamBuilder<List<MartItemModel>>(
                stream: Get.isRegistered<MartController>()
                    ? Get.find<MartController>().streamProductDeals(limit: 10)
                    : Stream.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading products'),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No products available'),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _martItemToPlaytimeCard(
                          products[index], screenWidth);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}



class MartHairCareSection extends StatelessWidget {
  final double screenWidth;

  const MartHairCareSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          Container(
            width: double.infinity,
            height: 22,
            child: Stack(
              children: [
                // Section title
                const Positioned(
                  left: 9,
                  top: 0,
                  child: Text(
                    'Deals on Hair Care',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),

                // See All text
                Positioned(
                  right: 32,
                  top: 3,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),

                // Right arrow icon
                Positioned(
                  right: 9,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Cards - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: List.generate(
                  10,
                  (index) => PlaytimeProductCard(
                        volume: '580 ml',
                        productName: 'Keratin Smooth Shampoo',
                        discount: '40% OFF',
                        currentPrice: '₹619',
                        originalPrice: '₹1016',
                        screenWidth: screenWidth,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class MartChocolatesSection extends StatelessWidget {
  final double screenWidth;

  const MartChocolatesSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          Container(
            width: double.infinity,
            height: 22,
            child: Stack(
              children: [
                // Section title
                const Positioned(
                  left: 9,
                  top: 0,
                  child: Text(
                    'Best deals on Chocolates',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),

                // See All text
                Positioned(
                  right: 32,
                  top: 3,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),

                // Right arrow icon
                Positioned(
                  right: 9,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Cards - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: List.generate(
                  10,
                  (index) => PlaytimeProductCard(
                        volume: '150 g',
                        productName: 'Amul Dark Chocolate',
                        discount: '8% OFF',
                        currentPrice: '₹179',
                        originalPrice: '₹200',
                        screenWidth: screenWidth,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class MartPlaytimeSection extends StatelessWidget {
  final double screenWidth;

  const MartPlaytimeSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          Container(
            width: double.infinity,
            height: 22,
            child: Stack(
              children: [
                // Section title
                const Positioned(
                  left: 9,
                  top: 0,
                  child: Text(
                    'Playtime Savings',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),

                // See All text
                Positioned(
                  right: 32,
                  top: 3,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),

                // Right arrow icon
                Positioned(
                  right: 9,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Cards - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Teddy bear',
                  discount: '25% OFF',
                  currentPrice: '₹399',
                  originalPrice: '₹500',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Fluffy Bear',
                  discount: '45% OFF',
                  currentPrice: '₹699',
                  originalPrice: '₹1000',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'UNO',
                  discount: '30% OFF',
                  currentPrice: '₹199',
                  originalPrice: '₹300',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Teddy bear',
                  discount: '25% OFF',
                  currentPrice: '₹399',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Teddy bear',
                  discount: '25% OFF',
                  currentPrice: '₹399',
                  originalPrice: '₹500',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Fluffy Bear',
                  discount: '45% OFF',
                  currentPrice: '₹699',
                  originalPrice: '₹1000',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'UNO',
                  discount: '30% OFF',
                  currentPrice: '₹199',
                  originalPrice: '₹300',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Teddy bear',
                  discount: '25% OFF',
                  currentPrice: '₹399',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Teddy bear',
                  discount: '25% OFF',
                  currentPrice: '₹399',
                  originalPrice: '₹500',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Fluffy Bear',
                  discount: '45% OFF',
                  currentPrice: '₹699',
                  originalPrice: '₹1000',
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MartBabyCareSection extends StatelessWidget {
  final double screenWidth;

  const MartBabyCareSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          Container(
            width: double.infinity,
            height: 22,
            child: Stack(
              children: [
                // Section title
                const Positioned(
                  left: 9,
                  top: 0,
                  child: Text(
                    'Best deals on Baby Care',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),

                // See All text
                Positioned(
                  right: 32,
                  top: 3,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),

                // Right arrow icon
                Positioned(
                  right: 9,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Cards - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Huggies Larg 32 pieces',
                  discount: '32% OFF',
                  currentPrice: '₹359',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Pampers XL 78 pieces',
                  discount: '20% OFF',
                  currentPrice: '₹1579',
                  originalPrice: '₹1049',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Huggies Larg 32 pieces',
                  discount: '32% OFF',
                  currentPrice: '₹359',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Pampers XL 78 pieces',
                  discount: '20% OFF',
                  currentPrice: '₹1579',
                  originalPrice: '₹1049',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Huggies Larg 32 pieces',
                  discount: '32% OFF',
                  currentPrice: '₹359',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Pampers XL 78 pieces',
                  discount: '20% OFF',
                  currentPrice: '₹1579',
                  originalPrice: '₹1049',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Huggies Larg 32 pieces',
                  discount: '32% OFF',
                  currentPrice: '₹359',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Pampers XL 78 pieces',
                  discount: '20% OFF',
                  currentPrice: '₹1579',
                  originalPrice: '₹1049',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Huggies Larg 32 pieces',
                  discount: '32% OFF',
                  currentPrice: '₹359',
                  originalPrice: '₹450',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '',
                  productName: 'Pampers XL 78 pieces',
                  discount: '20% OFF',
                  currentPrice: '₹1579',
                  originalPrice: '₹1049',
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MartLocalGrocerySection extends StatelessWidget {
  final double screenWidth;

  const MartLocalGrocerySection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with See All
          Container(
            width: double.infinity,
            height: 22,
            child: Stack(
              children: [
                // Section title
                const Positioned(
                  left: 9,
                  top: 0,
                  child: Text(
                    'Local Grocery Essentials',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 22 / 18,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),

                // See All text
                Positioned(
                  right: 32,
                  top: 3,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 17 / 14,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),

                // Right arrow icon
                Positioned(
                  right: 9,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1717FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Cards - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Aashirvaad Atta',
                  discount: '15% OFF',
                  currentPrice: '₹549',
                  originalPrice: '₹640',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Sona Masoori Economy Rice',
                  discount: '40% OFF',
                  currentPrice: '₹1189',
                  originalPrice: '₹2200',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '5 ltr',
                  productName: 'Gold Drop Refined Sunflower Oil',
                  discount: '20% OFF',
                  currentPrice: '₹739',
                  originalPrice: '₹950',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Aashirvaad Atta',
                  discount: '15% OFF',
                  currentPrice: '₹549',
                  originalPrice: '₹640',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Sona Masoori Economy Rice',
                  discount: '40% OFF',
                  currentPrice: '₹1189',
                  originalPrice: '₹2200',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '5 ltr',
                  productName: 'Gold Drop Refined Sunflower Oil',
                  discount: '20% OFF',
                  currentPrice: '₹739',
                  originalPrice: '₹950',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Aashirvaad Atta',
                  discount: '15% OFF',
                  currentPrice: '₹549',
                  originalPrice: '₹640',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Sona Masoori Economy Rice',
                  discount: '40% OFF',
                  currentPrice: '₹1189',
                  originalPrice: '₹2200',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '5 ltr',
                  productName: 'Gold Drop Refined Sunflower Oil',
                  discount: '20% OFF',
                  currentPrice: '₹739',
                  originalPrice: '₹950',
                  screenWidth: screenWidth,
                ),
                PlaytimeProductCard(
                  volume: '10 kg',
                  productName: 'Aashirvaad Atta',
                  discount: '15% OFF',
                  currentPrice: '₹549',
                  originalPrice: '₹640',
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MartSloganSection extends StatelessWidget {
  final double screenWidth;

  const MartSloganSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 353,
      color: const Color(0xFFEEEEF2),
      child: Stack(
        children: [
          // "Basket full" text
          Positioned(
            left: 26, // 27 - 1 (container left offset)
            top: 54, // 5169 - 5115 (top offset)
            child: const Text(
              'Basket full',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 49 / 40, // line-height: 49px
                color: Color(0xFF787878),
              ),
            ),
          ),

          // "Heart full !" text
          Positioned(
            left: 27, // 28 - 1 (container left offset)
            top: 103, // 5218 - 5115 (top offset)
            child: const Text(
              'Heart full !',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 50,
                fontWeight: FontWeight.w800,
                height: 61 / 50, // line-height: 61px
                color: Color(0xFF787878),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MartFeaturedProducts extends StatelessWidget {
  final double screenWidth;

  const MartFeaturedProducts({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(
        //     left: 16,
        //     right: 16,
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const Text(
        //         'Featured Products',
        //         style: TextStyle(
        //           fontSize: 20,
        //           fontWeight: FontWeight.bold,
        //           color: Color(0xFF2D1B69),
        //         ),
        //       ),
        //       GestureDetector(
        //         onTap: () {
        //           // Navigate to category detail screen with featured filter
        //           Get.to(() => MartCategoryDetailScreen(), arguments: {
        //             'categoryId': 'featured',
        //             'categoryName': 'Featured Products',
        //             'initialFilter': 'featured',
        //           });
        //         },
        //         child: const Text(
        //           'See All >',
        //           style: TextStyle(
        //             fontSize: 16,
        //             color: Colors.blue,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => MartCategoryDetailScreen(), arguments: {
                    'categoryId': 'featured',
                    'categoryName': 'Featured Products',
                    'initialFilter': 'featured',
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConst.martPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.martPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        GetX<MartController>(
          builder: (controller) {
            if (controller.isProductLoading.value) {
              return const SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.featuredItems.isEmpty) {
              return SizedBox(
                height: 280,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8), // Reduced from 16 to 8
                      const Text(
                        'No featured products found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isTablet = screenWidth > 600;
                final isLargePhone = screenWidth > 400;
                // Calculate dynamic card width based on screen size
                final cardWidth =
                    isTablet ? 200.0 : (isLargePhone ? 130.0 : 130.0);
                // 🔑 Auto-adjustable layout using Wrap for truly flexible card heights
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    // right: 16,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: 0,
                      runSpacing: 0,
                      children: controller.featuredItems.map((product) {
                        return SizedBox(
                          width: cardWidth,
                          child: MartProductCardHome(
                              product: product,
                              controller: _getMockController(),
                              screenWidth: screenWidth),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Mock controller for testing
  CategoryDetailController _getMockController() {
    final controller = CategoryDetailController();
    // Set mock subcategory data for the controller
    controller.subcategories.value = [
      MartSubcategoryModel(
        id: 'featured',
        title: 'Featured',
        photo:
            'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
      ),
    ];
    return controller;
  }
}

// Helper function to parse color from hex string
Color _parseColor(String hexColor) {
  try {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add alpha channel
    }
    return Color(int.parse(hexColor, radix: 16));
  } catch (e) {
    return const Color(0xFFE8E4FF); // Default color
  }
}

// Helper function to sanitize image URLs
// Enhanced version that uses controller methods
class MartDynamicSectionsEnhanced extends StatefulWidget {
  final double screenWidth;

  const MartDynamicSectionsEnhanced({super.key, required this.screenWidth});

  @override
  State<MartDynamicSectionsEnhanced> createState() => _MartDynamicSectionsEnhancedState();
}

class _MartDynamicSectionsEnhancedState extends State<MartDynamicSectionsEnhanced> {
  bool _hasTriggeredLoading = false;
// @override
//   void initState() {
//   final controller = Get.put(MartController());
//   controller.  loadCategoryProductsForSections();
//     super.initState();
//   }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MartController>(
      builder: (controller) {
        // Trigger category products loading
        if (!_hasTriggeredLoading) {
          _hasTriggeredLoading = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.loadCategoryProductsForSections();
          });
        }

        final categoryProducts = controller.categoryProductsMap;
        final uniqueCategories = controller.uniqueCategoryTitles;

        if (uniqueCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: uniqueCategories.map((category) {
            return _buildCategorySection(controller, category, categoryProducts[category] ?? []);
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategorySection(MartController controller, String categoryName, List<MartItemModel> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    print('[MART DYNAMIC SECTIONS] 🔗 Navigating to category: $categoryName');

                    // Find the category ID for this category title
                    final category = controller.martCategories.firstWhere(
                          (cat) => cat.title == categoryName,
                      orElse: () => MartCategoryModel(id: '', title: categoryName),
                    );

                    Get.to(() => MartCategoryDetailScreen(), arguments: {
                      'categoryId': category.id ?? 'category_${categoryName.toLowerCase().replaceAll(' ', '_')}',
                      'categoryName': categoryName,
                      'initialFilter': 'category',
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConst.martPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.martPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Scroll of Products
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              height: 215,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return PlaytimeProductCard(
                    volume: '${product.grams ?? 0}${_getVolumeUnit(product)}',
                    productName: product.name ?? 'Product',
                    discount: '${_calculateDiscount(product)}% OFF',
                    currentPrice: '₹${product.disPrice ?? product.price ?? 0}',
                    originalPrice: '₹${product.price ?? 0}',
                    screenWidth: widget.screenWidth,
                    imageUrl: product.photo,
                    product: product,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24), // Add spacing between sections
        ],
      ),
    );
  }

  String _getVolumeUnit(MartItemModel product) {
    if (product.grams != null && product.grams! > 0) {
      return 'g';
    }
    return 'g'; // Default to grams
  }

  int _calculateDiscount(MartItemModel product) {
    if (product.disPrice != null &&
        product.price != null &&
        product.price! > product.disPrice!) {
      return ((product.price! - product.disPrice!) / product.price! * 100).round();
    }
    return 0;
  }
}
// Dynamic Sections Widget
class MartDynamicSections extends StatefulWidget {
  final double screenWidth;

  const MartDynamicSections({super.key, required this.screenWidth});

  @override
  State<MartDynamicSections> createState() => _MartDynamicSectionsState();
}
class _MartDynamicSectionsState extends State<MartDynamicSections> {
  bool _hasTriggeredLoading = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MartController>(
      builder: (controller) {
        // Trigger sections loading only once to prevent blinking
        if (!_hasTriggeredLoading && controller.availableSections.isEmpty) {
          _hasTriggeredLoading = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.loadSectionsImmediately();
            Future.delayed(const Duration(seconds: 2), () {
              if (controller.availableSections.isEmpty) {
                controller.addTestSections();
              }
            });
          });
        }
        if (controller.availableSections.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: controller.availableSections.map((section) {
            return _buildSection(controller, section);
          }).toList(),
        );
      },
    );
  }

  Widget _buildSection(MartController controller, String sectionName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        // left: 16,
        // right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
            sectionName,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print(
                        '[MART DYNAMIC SECTIONS] 🔗 Navigating to section: $sectionName');
                    Get.to(() => MartCategoryDetailScreen(), arguments: {
                      'categoryId':
                      'section_${sectionName.toLowerCase().replaceAll(' ', '_')}',
                      'categoryName': sectionName,
                      'initialFilter': 'section',
                      'sectionName': sectionName, // Pass the actual section name
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConst.martPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.martPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       child: Text(
          //         sectionName, // Use the section name from Firebase
          //         style: TextStyle(
          //           fontSize: widget.screenWidth < 360 ? 14 : 16,
          //           fontWeight: FontWeight.bold,
          //           color: const Color(0xFF2D1B69),
          //         ),
          //         overflow: TextOverflow.ellipsis,
          //         maxLines: 1,
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     GestureDetector(
          //       onTap: () {
          //         // Navigate to category detail screen with section filter
          //         print(
          //             '[MART DYNAMIC SECTIONS] 🔗 Navigating to section: $sectionName');
          //         Get.to(() => MartCategoryDetailScreen(), arguments: {
          //           'categoryId':
          //               'section_${sectionName.toLowerCase().replaceAll(' ', '_')}',
          //           'categoryName': sectionName,
          //           'initialFilter': 'section',
          //           'sectionName': sectionName, // Pass the actual section name
          //         });
          //       },
          //       child: const Text(
          //         'See All >',
          //         style: TextStyle(
          //           fontSize: 16,
          //           color: Colors.blue,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // Horizontal Scroll of Products using PlaytimeProductCard
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
            ),
            child: GetBuilder<MartController>(
              builder: (controller) {
                // Get products for this section from Firebase
                final sectionProducts =
                    controller.getProductsForSection(sectionName);
                // If no products available, don't show anything (sections will appear as products load)
                if (sectionProducts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 215,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sectionProducts.length,
                    itemBuilder: (context, index) {
                      final product = sectionProducts[index];
                      return PlaytimeProductCard(
                        volume: '${product.grams ?? 0}g',
                        productName: product.name ?? 'Product',
                        discount: '${_calculateDiscount(product)}% OFF',
                        currentPrice:
                            '₹${product.disPrice ?? product.price ?? 0}',
                        originalPrice: '₹${product.price ?? 0}',
                        screenWidth: widget.screenWidth,
                        imageUrl: product.photo,
                        product: product, // Pass the product model for navigation
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDiscount(MartItemModel product) {
    if (product.disPrice != null &&
        product.price != null &&
        product.price > product.disPrice!) {
      return ((product.price - product.disPrice!) / product.price! * 100)
          .round();
    }
    return 0;
  }
}


Widget searchWidgetMain() {
  /// Get appropriate icon for category based on name

  return Container(
    // width: 412,
    // height: 190,
    color: Colors.transparent,
    // decoration: const BoxDecoration(
    //   gradient: LinearGradient(
    //     begin: Alignment.topCenter,
    //     end: Alignment.bottomCenter,
    //     colors: [
    //       const Color(0xFFFAF9EE), // Custom cream color - top
    //       const Color(0xFFFAF9EE), // Custom cream color - bottom
    //     ],
    //     stops: [0.0, 1.0], // 0% to 100%
    //   ),
    //   borderRadius: BorderRadius.only(
    //     bottomLeft: Radius.circular(10),
    //     bottomRight: Radius.circular(10),
    //   ),
    // ),
    child: Column(
      children: [
        SizedBox(
          height: 16,
        ),
        // Group 262 - Search Bar

      ],
    ),
  );
}

// Helper method for user initials (keeping this one as it's still used)


// Dynamic Categories Section - Replaces dummy data sections
class MartDynamicCategoriesSection extends StatelessWidget {
  final double screenWidth;

  const MartDynamicCategoriesSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return GetX<MartController>(
      builder: (controller) {
        if (controller.isCategoryLoading.value) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B69),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Fixed overflow issue
                  children: List.generate(
                    8,
                    (index) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.featuredCategories.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B69),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Categories Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Fixed overflow issue
                children: controller.featuredCategories
                    .map(
                      (category) => _DynamicCategoryItem(
                        category: category,
                        onTap: () {
                          // Navigate to category detail screen
                          Get.to(() => const MartCategoryDetailScreen(),
                              arguments: {
                                'categoryId': category.id,
                                'categoryName': category.title,
                              });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DynamicCategoryItem extends StatelessWidget {
  final MartCategoryModel category;
  final VoidCallback? onTap;

  const _DynamicCategoryItem({
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Image or Icon
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _parseColor(category.backgroundColor ?? '#E8E4FF'),
                ),
                child: category.photo != null && category.photo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageWidget(
                          imageUrl: category.photo!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: _getCategoryIcon(category.title ?? ''),
                        ),
                      )
                    : _getCategoryIcon(category.title ?? ''),
              ),
            ),

            // Category Name
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  category.title ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D1B69),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String categoryName) {
    IconData icon;
    Color color;

    final name = categoryName.toLowerCase();

    if (name.contains('grocery') ||
        name.contains('vegetable') ||
        name.contains('fruit')) {
      icon = Icons.shopping_basket;
      color = Colors.green;
    } else if (name.contains('dairy') ||
        name.contains('milk') ||
        name.contains('bread')) {
      icon = Icons.egg;
      color = Colors.orange;
    } else if (name.contains('medicine') || name.contains('health')) {
      icon = Icons.local_pharmacy;
      color = Colors.red;
    } else if (name.contains('pet')) {
      icon = Icons.pets;
      color = Colors.brown;
    } else if (name.contains('electronics') || name.contains('mobile')) {
      icon = Icons.phone_android;
      color = Colors.blue;
    } else if (name.contains('clothing') || name.contains('fashion')) {
      icon = Icons.checkroom;
      color = Colors.purple;
    } else if (name.contains('home') || name.contains('furniture')) {
      icon = Icons.home;
      color = Colors.indigo;
    } else if (name.contains('sports') || name.contains('fitness')) {
      icon = Icons.sports_soccer;
      color = Colors.teal;
    } else {
      icon = Icons.category;
      color = Colors.grey;
    }

    return Icon(
      icon,
      size: 32,
      color: color,
    );
  }
}

// Helper function to convert MartItemModel to PlaytimeProductCard format
PlaytimeProductCard _martItemToPlaytimeCard(
    MartItemModel item, double screenWidth) {
  // Calculate discount percentage
  String discount = '';
  if (item.disPrice != null &&
      item.price != null &&
      item.disPrice! < item.price!) {
    double discountPercent =
        ((item.price! - item.disPrice!) / item.price! * 100).round().toDouble();
    discount = '${discountPercent.toInt()}% OFF';
  }

  // Get volume/weight from item attributes or use default
  String volume = item.weight ?? '1 pc';

  // Format prices
  String currentPrice =
      '₹${item.disPrice?.toStringAsFixed(0) ?? item.price?.toStringAsFixed(0) ?? '0'}';
  String originalPrice = '₹${item.price?.toStringAsFixed(0) ?? '0'}';

  return PlaytimeProductCard(
    volume: volume,
    productName: item.name ?? 'Product',
    discount: discount,
    currentPrice: currentPrice,
    originalPrice: originalPrice,
    screenWidth: screenWidth,
    imageUrl: item.photo,
    product: item, // Pass the product model for cart functionality
  );
}


// import 'package:customer/app/mart/mart_category_detail_screen.dart';
// import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
// import 'package:customer/app/mart/mart_home_screen/widget/mart_sub_category_section.dart';
// import 'package:customer/app/mart/widgets/mart_product_card.dart';
// import 'package:customer/app/mart/widgets/mart_search_bar.dart';
// import 'package:customer/app/mart/widgets/playtime_product_card.dart';
// import 'package:customer/constant/constant.dart';
// import 'package:customer/controllers/category_detail_controller.dart';
// import 'package:customer/models/mart_banner_model.dart';
// import 'package:customer/models/mart_category_model.dart';
// import 'package:customer/models/mart_item_model.dart';
// import 'package:customer/models/mart_subcategory_model.dart';
// import 'package:customer/themes/mart_theme.dart';
// import 'package:customer/utils/network_image_widget.dart';
// import 'package:customer/widgets/reusable_banner_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class MartHomeScreen extends StatelessWidget {
//   const MartHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Theme(
//         data: MartTheme.theme,
//         child: Scaffold(
//           backgroundColor: const Color(0xFFFAF9EE),
//           body: GetBuilder<MartController>(
//             builder: (controller) {
//               // Manually trigger streaming data loading when screen is built
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 print(
//                     '[MART HOME] 🚀 Screen built, triggering streaming data load...');
//
//                 // Load homepage categories from Firestore
//                 if (controller.featuredCategories.isEmpty &&
//                     !controller.isCategoryLoading.value &&
//                     !controller.isHomepageCategoriesLoaded.value) {
//                   print(
//                       '[MART HOME] 🏠 Loading homepage categories from Firestore...');
//                   controller.loadHomepageCategoriesStreaming(limit: 6);
//                 }
//
//                 // Load featured products via streaming
//                 if (controller.featuredItems.isEmpty &&
//                     !controller.isProductLoading.value) {
//                   print(
//                       '[MART HOME] ⭐ Triggering featured products streaming...');
//                   controller.loadFeaturedItemsStreaming();
//                 }
//
//                 // Load trending items via streaming
//                 if (controller.trendingItems.isEmpty &&
//                     !controller.isTrendingLoading.value) {
//                   print(
//                       '[MART HOME] 🔥 Triggering trending items streaming...');
//                   controller.loadTrendingItemsStreaming();
//                 }
//
//                 // Load subcategories for the subcategories section
//                 if (controller.subcategories.isEmpty &&
//                     !controller.isSubcategoryLoading.value) {
//                   print(
//                       '[MART HOME] 🏷️ Triggering subcategories streaming...');
//                   // Load subcategories from the first main category
//                   if (controller.featuredCategories.isNotEmpty) {
//                     final mainCategory = controller.featuredCategories[0];
//                     controller
//                         .loadSubcategoriesStreaming(mainCategory.id ?? '');
//                   }
//                 }
//
//                 // Load dynamic sections immediately in parallel (highest priority)
//                 print(
//                     '[MART HOME] 📂 Triggering dynamic sections loading in parallel...');
//                 controller.loadSectionsImmediately();
//
//                 // Load mart banners using lazy loading streams (after screen is built)
//                 print(
//                     '[MART HOME] 🎯 Starting lazy loading mart banners stream...');
//                 // Use Future.microtask to load banners after the current frame
//                 Future.microtask(() {
//                   controller.loadMartBannersStream();
//                 });
//
//                 // Start banner timer if banners are loaded
//                 if (controller.martTopBanners.isNotEmpty) {
//                   print('[MART HOME] 🎯 Starting banner timer...');
//                   controller.startMartBannerTimer();
//                 }
//               });
//
//               return Stack(
//                 children: [
//                   RefreshIndicator(
//                     onRefresh: controller.refreshData,
//                     child: CustomScrollView(
//                       slivers: [
//                         // Header Card (Group 266) - Toggle and Address only
//                         SliverToBoxAdapter(
//                           child: MartHeaderCard(screenWidth: screenWidth),
//                         ),
//
//                         // Top Banners Section - Only show if banners are available
//                         SliverToBoxAdapter(
//                           child: Obx(() {
//                             print(
//                                 '[MART HOME] Banner count: ${controller.martTopBanners.length}');
//                             if (controller.martTopBanners.isNotEmpty) {
//                               return Column(
//                                 children: [
//                                   const SizedBox(height: 6),
//                                   ReusableBannerWidget(
//                                     banners: controller.martTopBanners,
//                                     pageController: controller
//                                         .martTopBannerController.value,
//                                     currentPage:
//                                         controller.currentTopBannerPage,
//                                     height: 200,
//                                     onPanStart: () =>
//                                         controller.stopMartBannerTimer(),
//                                     onPanEnd: () =>
//                                         controller.startMartBannerTimer(),
//                                   ),
//                                 ],
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }),
//                         ),
//
//
//                         SliverToBoxAdapter(
//                           child: searchWidgetMain(),
//                         ),
//
//
//                         // Minimal spacing
//                         SliverToBoxAdapter(
//                           child: SizedBox(height: 2),
//                         ),
//
//
//                         // Minimal spacing
//                         SliverToBoxAdapter(
//                           child: SizedBox(height: 2),
//                         ),
//
//
//
//                         // Minimal spacing
//                         SliverToBoxAdapter(
//                           child: SizedBox(height: 4),
//                         ),
//
//                         // Featured Products
//                         SliverToBoxAdapter(
//                           child: MartFeaturedProducts(screenWidth: screenWidth),
//                         ),
//
//                         // Minimal spacing
//                         SliverToBoxAdapter(
//                           child: SizedBox(height: 4),
//                         ),
//
//                         // Bottom Banners Section
//                         SliverToBoxAdapter(
//                           child: Obx(() {
//                             if (controller.martBottomBanners.isNotEmpty) {
//                               return Column(
//                                 children: [
//                                   const SizedBox(height: 8),
//                                   ReusableBannerWidget(
//                                     banners: controller.martBottomBanners,
//                                     pageController: controller
//                                         .martBottomBannerController.value,
//                                     currentPage:
//                                         controller.currentBottomBannerPage,
//                                     height: 150,
//                                     enableAutoScroll:
//                                         false, // Bottom banners don't auto-scroll
//                                   ),
//                                   const SizedBox(height: 8),
//                                   BannerIndicatorDots(
//                                     itemCount:
//                                         controller.martBottomBanners.length,
//                                     currentIndex:
//                                         controller.currentBottomBannerPage,
//                                     activeColor: const Color(0xFF00998a),
//                                     inactiveColor: Colors.grey[300]!,
//                                   ),
//                                   const SizedBox(height: 8),
//                                 ],
//                               );
//                             }
//                             return const SizedBox.shrink();
//                           }),
//                         ),
//
//
//                         // Trending Deals on Personal Care Section
//                         SliverToBoxAdapter(
//                           child: MartTrendingDealsPersonalCare(
//                               screenWidth: screenWidth),
//                         ),
//
//                         // Subcategories Section
//                         SliverToBoxAdapter(
//                           child: MartSubcategoriesSection(
//                               screenWidth: screenWidth),
//                         ),
//
//                         // // Product Deals Section
//                         SliverToBoxAdapter(
//                           child:
//                               MartProductDealsSection(screenWidth: screenWidth),
//                         ),
//
//                         // Dynamic Sections from Firebase
//                         SliverToBoxAdapter(
//                           child: MartDynamicSections(screenWidth: screenWidth),
//                         ),
//
//
//                         // Bottom padding
//                         SliverToBoxAdapter(
//                           child: SizedBox(height: 25),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Positioned WhatsApp button above bottom navigation
//                   Positioned(
//                     bottom: MediaQuery.of(context).padding.bottom +
//                         120, // Above bottom navigation
//                     right: 16,
//                     child: GestureDetector(
//                       onTap: () async {
//                         // WhatsApp number - you can change this to your desired number
//                         const String phoneNumber =
//                             '+919390579864'; // Your actual WhatsApp number
//                         const String message =
//                             'Hello! I need help with my JippyMart order.'; // Customize the message
//
//                         final Uri whatsappUrl = Uri.parse(
//                             'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
//
//                         try {
//                           if (await canLaunchUrl(whatsappUrl)) {
//                             await launchUrl(whatsappUrl,
//                                 mode: LaunchMode.externalApplication);
//                           } else {
//                             // Fallback to regular phone call if WhatsApp is not available
//                             final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
//                             if (await canLaunchUrl(phoneUrl)) {
//                               await launchUrl(phoneUrl,
//                                   mode: LaunchMode.externalApplication);
//                             }
//                           }
//                         } catch (e) {
//                           print('Error launching WhatsApp: $e');
//                         }
//                       },
//                       child: Container(
//                         width: 56,
//                         height: 56,
//                         decoration: BoxDecoration(
//                           color: Colors.green, // WhatsApp green color
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(0.0),
//                           child: SvgPicture.asset(
//                             'assets/images/whatsapp.svg',
//                             width: 24,
//                             height: 24,
//                             colorFilter: const ColorFilter.mode(
//                               Colors.white,
//                               BlendMode.srcIn,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ));
//   }
// }
//
// class MartHeaderCard extends StatefulWidget {
//   final double screenWidth;
//
//   const MartHeaderCard({super.key, required this.screenWidth});
//
//   @override
//   State<MartHeaderCard> createState() => _MartHeaderCardState();
// }
//
// class _MartHeaderCardState extends State<MartHeaderCard> {
//   bool isMartSelected = true; // Since we're in mart screen, mart is selected
//
//   void _navigateToCorrectHomeScreen() {
//     print('Jippy Food button tapped!');
//     try {
//       // Simply go back to the previous screen (which will be the correct home screen)
//       // Since both home screens use Get.to() to navigate here, Get.back() will work correctly
//       Get.back();
//     } catch (e) {
//       // Fallback navigation
//       print('Navigation error: $e');
//       Get.back();
//     }
//   }
//
//   void _selectMart() {
//     print('JippyMart button tapped!');
//     // Already in mart screen, so just stay here
//     // Could add some visual feedback if needed
//   }
//
//   void _showVendorSelectionDialog(
//       BuildContext context, MartController controller) {
//     if (controller.martVendors.isEmpty) {
//       Get.snackbar(
//         'No Vendors Available',
//         'Please wait while we load available vendors...',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select a Vendor'),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 300,
//           child: ListView.builder(
//             itemCount: controller.martVendors.length,
//             itemBuilder: (context, index) {
//               final vendor = controller.martVendors[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: const Color(0xFF00998a),
//                   child: Text(
//                     vendor.name?.substring(0, 1).toUpperCase() ?? 'V',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 title: Text(vendor.name ?? 'Unknown Vendor'),
//                 subtitle: Text(vendor.description ?? ''),
//                 onTap: () {
//                   controller.selectVendor(vendor.id!);
//                   Navigator.of(context).pop();
//                   Get.snackbar(
//                     'Vendor Selected',
//                     '${vendor.name} selected successfully!',
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity, // Use full width instead of fixed 412
//       height: 180, // Back to original height - only toggle and address
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFFE8F8DB), // #CCCCFF
//             Color(0xFFE8F8DB), // #ECEAFD
//           ],
//           stops: [0.0, 1.0], // 0% to 100%
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
//         child: Stack(
//           children: [
//             // Group 280 - Toggle Button
//             Positioned(
//               left: 16,
//               right: 16,
//               top: 16,
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF9EE),
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     // Jippy Food Button (Left)
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _navigateToCorrectHomeScreen,
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: const Color(
//                                 0xFFFAF9EE), // Jippy Food is not selected in mart screen
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'FOOD',
//                               style: TextStyle(
//                                 color:
//                                     Color(0xFF666666), // Consistent grey color
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // JippyMart Button (Right)
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _selectMart,
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: const Color(
//                                 0xFF007F73), // Purple for selected mart
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Center(
//                             child: Text(
//                               'MART',
//                               style: TextStyle(
//                                 color: Colors.white, // White text for selected
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Group 289 - Delivery Address Section
//             Positioned(
//               left: 16,
//               top: 70, // Reduced for better visibility on all devices
//               right: 16,
//               child: Container(
//                 height: 60, // Increased from 55 to 60 to prevent overflow
//                 child: Row(
//                   children: [
//                     // User avatar with initials
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF00998a),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getUserInitials(),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 16),
//
//                     // Delivery address information
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Delivery to ${Constant.selectedLocation.addressAs ?? 'Current Location'}',
//                             style: const TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               height:
//                                   1.2, // Reduced from 20/16 to 1.2 to save space
//                               color: Color(0xFF000000),
//                             ),
//                           ),
//                           const SizedBox(
//                               height: 1), // Reduced from 2 to 1 to save space
//                           Text(
//                             Constant.selectedLocation.getFullAddress(),
//                             style: const TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               height:
//                                   1.2, // Reduced from 15/12 to 1.2 to save space
//                               color: Color(0xFF000000),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(width: 8),
//
//                     // Down arrow
//                     Container(
//                       width: 24,
//                       height: 24,
//                       child: const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Color(0xFF474747),
//                         size: 20,
//                       ),
//                     ),
//
//                     const SizedBox(width: 8),
//
//                     // Delivery time box
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF00998a),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '20',
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               height: 20 / 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             'min',
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                               height: 15 / 12,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MartSpotlightSelections extends StatelessWidget {
//   final double screenWidth;
//
//   const MartSpotlightSelections({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 413,
//       height: 263,
//       decoration: const BoxDecoration(
//         color: Color(0xFF00998a), // Rectangle 5 background
//       ),
//       child: Stack(
//         children: [
//           // Face In Clouds icon
//           Positioned(
//             left: 169,
//             top: 19,
//             child: Container(
//               width: 67,
//               height: 67,
//               child: Image.asset(
//                 'assets/images/FaceInClouds.gif',
//                 width: 67,
//                 height: 67,
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: 67,
//                     height: 67,
//                     decoration: BoxDecoration(
//                       color: Colors.amber,
//                       borderRadius: BorderRadius.circular(33.5),
//                     ),
//                     child: const Icon(
//                       Icons.star,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // Spotlight Selections title
//           Positioned(
//             left: 35,
//             top: 86,
//             child: const Text(
//               'Spotlight Selections',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 32,
//                 fontWeight: FontWeight.w700,
//                 height: 39 / 32,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//
//           // Frame 40 - Horizontal scrollable container
//           Positioned(
//             left: 1,
//             top: 150,
//             child: Container(
//               width: 402,
//               height: 92,
//               child: GetX<MartController>(
//                 builder: (controller) {
//                   if (controller.spotlightItems.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         'No spotlight items available',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     );
//                   }
//
//                   return SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         ...controller.spotlightItems
//                             .asMap()
//                             .entries
//                             .map((entry) {
//                           final index = entry.key;
//                           final item = entry.value;
//
//                           return Row(
//                             children: [
//                               _SpotlightCard(
//                                 title: item['title'] ?? 'Category',
//                                 discount: item['discount'] ?? 'Up to 50% OFF',
//                               ),
//                               // Add spacing between cards (except for the last one)
//                               if (index < controller.spotlightItems.length - 1)
//                                 const SizedBox(width: 12),
//                             ],
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Spotlight Card widget matching CSS specifications
// class _SpotlightCard extends StatelessWidget {
//   final String title;
//   final String discount;
//
//   const _SpotlightCard({
//     required this.title,
//     required this.discount,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Show coming soon message
//         Get.snackbar(
//           'Coming Soon',
//           'This feature is under development',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       },
//       child: Container(
//         width: 88,
//         height: 92,
//         child: Stack(
//           children: [
//             // Rectangle background (white card)
//             Positioned(
//               left: 0,
//               top: 0,
//               child: Container(
//                 width: 88,
//                 height: 92,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFAF9EE),
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//               ),
//             ),
//
//             // Category title - positioned based on CSS
//             Positioned(
//               left: 4,
//               top: 7,
//               child: SizedBox(
//                 width: 80,
//                 height: 24,
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontFamily: 'Montserrat',
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                     height: 12 / 10,
//                     color: Color(0xFF000000),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//
//             // Gradient offer bar - positioned based on CSS
//             Positioned(
//               left: 4,
//               top: 73,
//               child: Container(
//                 width: 80,
//                 height: 15,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                     colors: [
//                       Color(0xFF595BD4), // #595BD4
//                       Color(0xFF9140D8), // #9140D8
//                     ],
//                   ),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(18),
//                     bottomRight: Radius.circular(18),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Discount text - positioned based on CSS
//             Positioned(
//               left: 12,
//               top: 76,
//               child: Text(
//                 discount,
//                 style: const TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: 7,
//                   fontWeight: FontWeight.w700,
//                   height: 9 / 7,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//
//             // Placeholder icon in center (Rectangle with background url)
//             Positioned(
//               left: 30, // Fixed position for all cards
//               top: 36, // 39.13% of 92px ≈ 36px
//               child: Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5D56F3),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(
//                   Icons.shopping_basket,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Helper method for spotlight subcategories
// List<MartSubcategoryModel> _getSpotlightSubcategories(String title) {
//   // Generate subcategories based on spotlight title
//   final cleanTitle = title.toLowerCase();
//
//   if (cleanTitle.contains('fresh fruits')) {
//     return [
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_001',
//         title: 'Seasonal Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_002',
//         title: 'Citrus Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_003',
//         title: 'Tropical Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_004',
//         title: 'Berries',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_005',
//         title: 'Exotic Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_fruit_006',
//         title: 'Organic Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanTitle.contains('dairy')) {
//     return [
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_001',
//         title: 'Milk & Milk Products',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_002',
//         title: 'Cheese & Butter',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_003',
//         title: 'Yogurt & Curd',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_004',
//         title: 'Bread & Bakery',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_005',
//         title: 'Eggs',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_dairy_006',
//         title: 'Organic Dairy',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanTitle.contains('tea') || cleanTitle.contains('coffee')) {
//     return [
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_001',
//         title: 'Tea Varieties',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_002',
//         title: 'Coffee Beans',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_003',
//         title: 'Instant Coffee',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_004',
//         title: 'Milk Drinks',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_005',
//         title: 'Energy Drinks',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_beverage_006',
//         title: 'Organic Beverages',
//         photo:
//             'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else {
//     // Default subcategories for other spotlight items
//     return [
//       MartSubcategoryModel(
//         id: 'spotlight_default_001',
//         title: 'Popular Items',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_default_002',
//         title: 'New Arrivals',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_default_003',
//         title: 'Best Sellers',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_default_004',
//         title: 'On Sale',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_default_005',
//         title: 'Premium Selection',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'spotlight_default_006',
//         title: 'Organic Options',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//     ];
//   }
// }
//
// class SpotlightCard extends StatelessWidget {
//   final String title;
//   final String offer;
//   final String imageUrl;
//
//   const SpotlightCard({
//     super.key,
//     required this.title,
//     required this.offer,
//     required this.imageUrl,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: MartTheme.greenVeryLight,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Title at top
//           Padding(
//             padding: const EdgeInsets.only(top: 8, left: 6, right: 6),
//             child: Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//
//           // GIF placeholder in middle (purple background)
//           Expanded(
//             child: Container(
//               margin:
//                   const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5D56F3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: imageUrl.isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.asset(
//                           imageUrl,
//                           width: 67,
//                           height: 67,
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: 67,
//                               height: 67,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF4A45D1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.image,
//                                 color: Colors.white,
//                                 size: 32,
//                               ),
//                             );
//                           },
//                         ),
//                       )
//                     : Container(
//                         width: 67,
//                         height: 67,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4A45D1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.image,
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                       ),
//               ),
//             ),
//           ),
//
//           // Gradient discount footer (purple to blue gradient)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFB96CF3), Color(0xFF5F55FF)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(
//                 bottom: Radius.circular(16),
//               ),
//             ),
//             child: Text(
//               offer,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartStealsOfMoment extends StatelessWidget {
//   final double screenWidth;
//
//   const MartStealsOfMoment({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 413,
//       height: 158,
//       // margin: const EdgeInsets.only(top: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Padding(
//             padding:
//                 EdgeInsets.only(left: 16, bottom: 4), // Reduced from 8 to 4
//             child: Text(
//               'Steals of the moment',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//
//           // Frame 276 - Horizontal scrollable container
//           Expanded(
//             child: Container(
//               width: 413,
//               height: 123, // Reduced from 141 to fit smaller container
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                   width: 1040, // Total width to accommodate all cards
//                   height: 123, // Reduced from 141 to fit smaller container
//                   child: Stack(
//                     children: [
//                       // Card 1: Hair Styling (Group 267)
//                       Positioned(
//                         left: 11,
//                         top: 1,
//                         child: Container(
//                           width: 119,
//                           height: 141,
//                           child: Stack(
//                             children: [
//                               // Rectangle 6 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFCCCCFF),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Hair Styling text
//                               Positioned(
//                                 left: 16,
//                                 top: 24,
//                                 child: SizedBox(
//                                   width: 103,
//                                   height: 32,
//                                   child: Text(
//                                     'Hair Styling',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                       height: 20 / 16,
//                                       color: const Color(0xFF00998a),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // FEATURED label
//                               Positioned(
//                                 left: 21, // Center the label
//                                 top: 133,
//                                 child: SizedBox(
//                                   width: 76,
//                                   height: 9,
//                                   child: Text(
//                                     'FEATURED',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 2: Breakfast Essentials (Group 268)
//                       Positioned(
//                         left: 141,
//                         top: 2,
//                         child: Container(
//                           width: 118.61,
//                           height: 140,
//                           child: Stack(
//                             children: [
//                               // Rectangle 7 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFFFF7CC),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Breakfast Essentials text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 20, // Moved up to give more space
//                                 child: SizedBox(
//                                   width: 86.26,
//                                   height:
//                                       50, // Increased height to prevent text cutoff
//                                   child: Text(
//                                     'Breakfast Essentials\nUp To 50% OFF',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w800,
//                                       height: 16 / 13,
//                                       color: const Color(0xFF7E3D29),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // IN FOCUS label
//                               Positioned(
//                                 left: 23, // Center the label
//                                 top: 133, // 135 - 2
//                                 child: SizedBox(
//                                   width: 72,
//                                   height: 7,
//                                   child: Text(
//                                     'IN FOCUS',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 3: Indian Sweets (Group 269)
//                       Positioned(
//                         left: 270.61,
//                         top: 0,
//                         child: Container(
//                           width: 118.61,
//                           height: 142,
//                           child: Stack(
//                             children: [
//                               // Rectangle 8 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFE7D0EE),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Indian Sweets text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 24, // Adjusted for better positioning
//                                 child: SizedBox(
//                                   width: 83,
//                                   height: 32,
//                                   child: Text(
//                                     'Indian Sweets',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w800,
//                                       height: 18 / 15,
//                                       color: const Color(0xFFE32D8F),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // TRENDING NOW label
//                               Positioned(
//                                 left: 10, // Center the label
//                                 top: 133, // 133 - 0
//                                 child: SizedBox(
//                                   width: 99,
//                                   height: 9,
//                                   child: Text(
//                                     'TRENDING NOW',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 4: All Natural juices (Group 270)
//                       Positioned(
//                         left: 400.22,
//                         top: 2,
//                         child: Container(
//                           width: 118.61,
//                           height: 140,
//                           child: Stack(
//                             children: [
//                               // Rectangle 9 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFC7EEFE),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // All Natural juices text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 24, // Adjusted for better positioning
//                                 child: SizedBox(
//                                   width: 76.83,
//                                   height: 32.35,
//                                   child: Text(
//                                     'All Natural juices',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                       height: 20 / 16,
//                                       color: const Color(0xFF4C4EE1),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // FRESHLY DROPPED label
//                               Positioned(
//                                 left: 5, // 405.22 - 400.22
//                                 top: 133, // 135 - 2
//                                 child: SizedBox(
//                                   width: 104,
//                                   height: 7,
//                                   child: Text(
//                                     'FRESHLY DROPPED',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 5: Toys & Games (Group 274)
//                       Positioned(
//                         left: 529.83,
//                         top: 2,
//                         child: Container(
//                           width: 118.61,
//                           height: 140,
//                           child: Stack(
//                             children: [
//                               // Rectangle 10 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFFFE5C3),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Toys & Games text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 20, // Moved up to give more space
//                                 child: SizedBox(
//                                   width: 100,
//                                   height:
//                                       50, // Increased height to prevent text cutoff
//                                   child: Text(
//                                     'Toys & Games\nStarting From ₹ 99',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w800,
//                                       height: 17 / 14,
//                                       color: const Color(0xFF890C23),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // SALE label
//                               Positioned(
//                                 left: 42.87, // 572.7 - 529.83
//                                 top: 132, // 134 - 2
//                                 child: SizedBox(
//                                   width: 40,
//                                   height: 8,
//                                   child: Text(
//                                     'SALE',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 6: Stationery & Arts (Group 275)
//                       Positioned(
//                         left: 659.43,
//                         top: 1,
//                         child: Container(
//                           width: 118.65,
//                           height: 141,
//                           child: Stack(
//                             children: [
//                               // Rectangle 11 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFD0E7EE),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Stationery & Arts text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 24, // Adjusted for better positioning
//                                 child: SizedBox(
//                                   width: 97,
//                                   height: 32,
//                                   child: Text(
//                                     'Stationery & Arts',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w800,
//                                       height: 18 / 15,
//                                       color: const Color(0xFF5C5C99),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // FEATURED label
//                               Positioned(
//                                 left: 25.35, // 684.78 - 659.43
//                                 top: 132, // 133 - 1
//                                 child: SizedBox(
//                                   width: 68,
//                                   height: 9,
//                                   child: Text(
//                                     'FEATURED',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 7: Diapers Stockup Sale (Group 272)
//                       Positioned(
//                         left: 789.09,
//                         top: 1,
//                         child: Container(
//                           width: 118.61,
//                           height: 141,
//                           child: Stack(
//                             children: [
//                               // Rectangle 12 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFFFDCDD),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // Up to 60% OFF text (small)
//                               Positioned(
//                                 left: 21.56, // 810.65 - 789.09
//                                 top: 97.04, // 98.04 - 1
//                                 child: SizedBox(
//                                   width: 74.13,
//                                   height: 12.13,
//                                   child: Text(
//                                     'Up to 60% OFF',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 7,
//                                       fontWeight: FontWeight.w700,
//                                       height: 9 / 7,
//                                       color: const Color(0xFFFFDCDD),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // Diapers Stockup Sale text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 20, // Moved up to give more space
//                                 child: SizedBox(
//                                   width: 86.26,
//                                   height:
//                                       50, // Increased height to prevent text cutoff
//                                   child: Text(
//                                     'Diapers Stockup Sale\nUp To 60% OFF',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w800,
//                                       height: 17 / 14,
//                                       color: const Color(0xFFDC3489),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // TRENDING NOW label
//                               Positioned(
//                                 left: 16.78, // 805.87 - 789.09
//                                 top: 132, // 133 - 1
//                                 child: SizedBox(
//                                   width: 86,
//                                   height: 9,
//                                   child: Text(
//                                     'TRENDING NOW',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Card 8: BUY GET 1 (Group 273)
//                       Positioned(
//                         left: 918.7,
//                         top: 1,
//                         child: Container(
//                           width: 121.91,
//                           height: 141,
//                           child: Stack(
//                             children: [
//                               // Rectangle 13 - Background
//                               Positioned(
//                                 left: 0,
//                                 top: 0,
//                                 child: Container(
//                                   width: 118.61,
//                                   height: 124,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFEFFFF2),
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                               ),
//                               // BUY GET text
//                               Positioned(
//                                 left: 16, // Adjusted for better positioning
//                                 top: 24, // Adjusted for better positioning
//                                 child: SizedBox(
//                                   width: 60.65,
//                                   height: 64.7,
//                                   child: ShaderMask(
//                                     shaderCallback: (bounds) =>
//                                         const LinearGradient(
//                                       colors: [
//                                         Color(0xFF3C720E),
//                                         Color(0xFF72D81B)
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ).createShader(bounds),
//                                     child: const Text(
//                                       'BUY GET',
//                                       style: TextStyle(
//                                         fontFamily: 'Montserrat',
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.w800,
//                                         height: 24 / 20,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // 1 text
//                               Positioned(
//                                 left: 80, // Adjusted for better positioning
//                                 top: 24, // Adjusted for better positioning
//                                 child: SizedBox(
//                                   width: 40.43,
//                                   height: 64.7,
//                                   child: ShaderMask(
//                                     shaderCallback: (bounds) =>
//                                         const LinearGradient(
//                                       colors: [
//                                         Color(0xFF3C720E),
//                                         Color(0xFF72D81B)
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ).createShader(bounds),
//                                     child: const Text(
//                                       '1',
//                                       style: TextStyle(
//                                         fontFamily: 'NanumGothic',
//                                         fontSize: 48,
//                                         fontWeight: FontWeight.w800,
//                                         height: 48 / 48,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // DEALS OF THE DAY label
//                               Positioned(
//                                 left: 10.91, // 929.61 - 918.7
//                                 top: 132, // 133 - 1
//                                 child: SizedBox(
//                                   width: 111,
//                                   height: 9,
//                                   child: Text(
//                                     'DEALS OF THE DAY',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       height: 12 / 10,
//                                       color: const Color(0xFF000000),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StealCard extends StatelessWidget {
//   final String title;
//   final String label;
//   final Color backgroundColor;
//   final Color textColor;
//   final double left;
//   final bool isSpecial;
//
//   const _StealCard({
//     required this.title,
//     required this.label,
//     required this.backgroundColor,
//     required this.textColor,
//     required this.left,
//     this.isSpecial = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 118.61,
//       height: 141,
//       margin: EdgeInsets.only(left: left == 11 ? 0 : 12),
//       child: Stack(
//         children: [
//           // Main card background
//           Positioned(
//             left: 0,
//             top: 0,
//             child: Container(
//               width: 118.61,
//               height: 124,
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//           ),
//
//           // Title text
//           Positioned(
//             left: _getTitleLeft(title),
//             top: _getTitleTop(title),
//             child: SizedBox(
//               width: _getTitleWidth(title),
//               height: _getTitleHeight(title),
//               child: isSpecial
//                   ? _buildSpecialText(title)
//                   : Text(
//                       title,
//                       style: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: _getTitleFontSize(title),
//                         fontWeight: FontWeight.w800,
//                         height: _getTitleLineHeight(title),
//                         color: textColor,
//                       ),
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.center,
//                     ),
//             ),
//           ),
//
//           // Label below card
//           Positioned(
//             left: _getLabelLeft(label),
//             top: 133,
//             child: SizedBox(
//               width: _getLabelWidth(label),
//               height: 9,
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                   height: 12 / 10,
//                   color: Color(0xFF000000),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSpecialText(String title) {
//     if (title.contains('BUY GET')) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // "BUY GET" text
//           ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               colors: [Color(0xFF3C720E), Color(0xFF72D81B)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ).createShader(bounds),
//             child: const Text(
//               'BUY GET',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 height: 24 / 20,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           // "1" text
//           ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               colors: [Color(0xFF3C720E), Color(0xFF72D81B)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ).createShader(bounds),
//             child: const Text(
//               '1',
//               style: TextStyle(
//                 fontFamily: 'NanumGothic',
//                 fontSize: 48,
//                 fontWeight: FontWeight.w800,
//                 height: 48 / 48,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//     return Text(title);
//   }
//
//   double _getTitleLeft(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 27;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 158.52;
//       case 'Indian Sweets':
//         return 289.87;
//       case 'All Natural juices':
//         return 418.61;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 548.35;
//       case 'Stationery & Arts':
//         return 681.09;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 807.87;
//       case 'BUY GET\n1':
//         return 937.57;
//       default:
//         return 27;
//     }
//   }
//
//   double _getTitleTop(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 24;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 25.87;
//       case 'Indian Sweets':
//         return 23;
//       case 'All Natural juices':
//         return 26;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 26;
//       case 'Stationery & Arts':
//         return 25;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 25;
//       case 'BUY GET\n1':
//         return 22.57;
//       default:
//         return 24;
//     }
//   }
//
//   double _getTitleWidth(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 103;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 86.26;
//       case 'Indian Sweets':
//         return 83;
//       case 'All Natural juices':
//         return 76.83;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 100;
//       case 'Stationery & Arts':
//         return 97;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 86.26;
//       case 'BUY GET\n1':
//         return 60.65;
//       default:
//         return 103;
//     }
//   }
//
//   double _getTitleHeight(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 32;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 40.43;
//       case 'Indian Sweets':
//         return 32;
//       case 'All Natural juices':
//         return 32.35;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 40;
//       case 'Stationery & Arts':
//         return 32;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 40.43;
//       case 'BUY GET\n1':
//         return 64.7;
//       default:
//         return 32;
//     }
//   }
//
//   double _getTitleFontSize(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 16;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 13;
//       case 'Indian Sweets':
//         return 15;
//       case 'All Natural juices':
//         return 16;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 14;
//       case 'Stationery & Arts':
//         return 15;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 14;
//       case 'BUY GET\n1':
//         return 20;
//       default:
//         return 16;
//     }
//   }
//
//   double _getTitleLineHeight(String title) {
//     switch (title) {
//       case 'Hair Styling':
//         return 20 / 16;
//       case 'Breakfast Essentials\nUp To 50% OFF':
//         return 16 / 13;
//       case 'Indian Sweets':
//         return 18 / 15;
//       case 'All Natural juices':
//         return 20 / 16;
//       case 'Toys & Games\nStarting From ₹ 99':
//         return 17 / 14;
//       case 'Stationery & Arts':
//         return 18 / 15;
//       case 'Diapers Stockup Sale\nUp To 60% OFF':
//         return 17 / 14;
//       case 'BUY GET\n1':
//         return 24 / 20;
//       default:
//         return 20 / 16;
//     }
//   }
//
//   double _getLabelLeft(String label) {
//     switch (label) {
//       case 'FEATURED':
//         return 32;
//       case 'IN FOCUS':
//         return 173;
//       case 'TRENDING NOW':
//         return 281.61;
//       case 'FRESHLY DROPPED':
//         return 405.22;
//       case 'SALE':
//         return 572.7;
//       case 'DEALS OF THE DAY':
//         return 929.61;
//       default:
//         return 32;
//     }
//   }
//
//   double _getLabelWidth(String label) {
//     switch (label) {
//       case 'FEATURED':
//         return 76;
//       case 'IN FOCUS':
//         return 72;
//       case 'TRENDING NOW':
//         return 99;
//       case 'FRESHLY DROPPED':
//         return 104;
//       case 'SALE':
//         return 40;
//       case 'DEALS OF THE DAY':
//         return 111;
//       default:
//         return 76;
//     }
//   }
// }
//
// class MartTrendingNowSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartTrendingNowSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'Trending Now on Jippymart',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Trending Categories
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _TrendingCategoryItem(
//                 icon: Icons.home,
//                 label: 'Home',
//                 screenWidth: screenWidth,
//               ),
//               _TrendingCategoryItem(
//                 icon: Icons.kitchen,
//                 label: 'Kitchen',
//                 screenWidth: screenWidth,
//               ),
//               _TrendingCategoryItem(
//                 icon: Icons.toys,
//                 label: 'Toys',
//                 screenWidth: screenWidth,
//               ),
//               _TrendingCategoryItem(
//                 icon: Icons.fitness_center,
//                 label: 'Sports &\nFitness',
//                 screenWidth: screenWidth,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Mock controller for testing
//   CategoryDetailController _getMockController() {
//     final controller = CategoryDetailController();
//     // Set mock subcategory data for the controller
//     controller.subcategories.value = [
//       MartSubcategoryModel(
//         id: 'featured',
//         title: 'Featured',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//     ];
//     return controller;
//   }
// }
//
// class MartTrendingDealsPersonalCare extends StatelessWidget {
//   final double screenWidth;
//
//   const MartTrendingDealsPersonalCare({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     // Load trending items when widget is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final martController = Get.find<MartController>();
//         if (martController.filteredTrendingItems.isEmpty &&
//             !martController.isTrendingLoading.value) {
//           martController.loadTrendingItemsStreaming();
//         }
//       } catch (e) {
//         print(
//             '[MART HOME] Controller not found, skipping trending items load: $e');
//       }
//     });
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(
//           // left: 16,
//           // right: 16,
//           ), // Reduced from 16 to 12
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Header with Title and See All
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 16,
//               right: 16,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Trending deals',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2D1B69),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // Navigate to category detail screen with trending filter
//                     Get.to(() => MartCategoryDetailScreen(), arguments: {
//                       'categoryId': 'trending',
//                       'categoryName': 'Trending Deals',
//                       'initialFilter': 'trending',
//                     });
//                   },
//                   child: const Text(
//                     'See All >',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12), // Reduced from 16 to 12
//
//           // Horizontal Scrolling Products using MartProductCard with API data
//           GetX<MartController>(
//             builder: (controller) {
//               if (controller.isTrendingLoading.value) {
//                 return const SizedBox(
//                   height: 280,
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }
//
//               if (controller.filteredTrendingItems.isEmpty) {
//                 return SizedBox(
//                   height: 280,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'No trending items found',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             controller.loadTrendingItemsStreaming();
//                           },
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//
//               return LayoutBuilder(
//                 builder: (context, constraints) {
//                   final screenWidth = constraints.maxWidth;
//                   final isTablet = screenWidth > 600;
//                   final isLargePhone = screenWidth > 400;
//
//                   // Calculate dynamic card width based on screen size
//                   final cardWidth =
//                       isTablet ? 200.0 : (isLargePhone ? 180.0 : 160.0);
//
//                   // 🔑 Auto-adjustable layout using Wrap for truly flexible card heights
//                   return Padding(
//                     padding: const EdgeInsets.only(
//                       left: 16,
//                       // right: 16,
//                     ),
//                     child: SingleChildScrollView(
//                       padding: EdgeInsets.zero,
//                       scrollDirection: Axis.horizontal,
//                       child: Wrap(
//                         alignment: WrapAlignment.start,
//                         crossAxisAlignment: WrapCrossAlignment.start,
//                         runAlignment: WrapAlignment.start,
//                         spacing: 0,
//                         runSpacing: 16.0,
//                         children:
//                             controller.filteredTrendingItems.map((product) {
//                           return SizedBox(
//                             width: cardWidth,
//                             child: MartProductCard(
//                               product: product,
//                               controller: _getMockController(),
//                               screenWidth: screenWidth,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Mock controller for testing
//   CategoryDetailController _getMockController() {
//     final controller = CategoryDetailController();
//     // Set mock subcategory data for the controller
//     controller.subcategories.value = [
//       MartSubcategoryModel(
//         id: 'trending',
//         title: 'Trending',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//     ];
//     return controller;
//   }
// }
//
// class _TrendingCategoryItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final double screenWidth;
//
//   const _TrendingCategoryItem({
//     required this.icon,
//     required this.label,
//     required this.screenWidth,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final itemSize = (screenWidth - 80) / 4;
//
//     return Column(
//       children: [
//         Container(
//           width: itemSize,
//           height: itemSize,
//           decoration: BoxDecoration(
//             color: const Color(0xFFD8D5FF),
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             size: itemSize * 0.4,
//             color: const Color(0xFF2D1B69),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D1B69),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class MartKitchenGrocerySection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartKitchenGrocerySection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'KITCHEN & GROCERY',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Grocery Grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 4,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 16,
//             childAspectRatio: 0.75, // Fixed overflow issue
//             children: [
//               _GroceryItem(
//                 label: 'Fresh\nVegetables',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Fresh\nFruits',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Dairy, Bread\nand Eggs',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Cereals and\nBreakfast',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Atta, Rice\nand Dal',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Oils and\nGhee',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Masalas',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Dry Fruits\nand Seed Mix',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1603046891744-76e6300f82b8?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Biscuits and\nCakes',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Tea, Coffee\nand Milk drinks',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Sauces and\nSpreads',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Meat and\nSeafood',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _GroceryItem extends StatelessWidget {
//   final String label;
//   final String? imageUrl;
//   final VoidCallback? onTap;
//
//   const _GroceryItem({
//     required this.label,
//     this.imageUrl,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap ??
//           () {
//             // Show coming soon message
//             Get.snackbar(
//               'Coming Soon',
//               'This feature is under development',
//               snackPosition: SnackPosition.BOTTOM,
//             );
//           },
//       child: Container(
//         width: 87,
//         height: 129,
//         child: Stack(
//           children: [
//             // Rectangle 15 (Image placeholder)
//             Positioned(
//               left: 0,
//               top: 0,
//               child: Container(
//                 width: 87,
//                 height: 91,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFECEAFD),
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(18),
//                   child: imageUrl != null
//                       ? Image.network(
//                           imageUrl!,
//                           width: 87,
//                           height: 91,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFECEAFD),
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: const Icon(
//                                 Icons.image,
//                                 color: Color(0xFF5D56F3),
//                                 size: 30,
//                               ),
//                             );
//                           },
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFECEAFD),
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: const Center(
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Color(0xFF5D56F3),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFECEAFD),
//                             borderRadius: BorderRadius.circular(18),
//                           ),
//                           child: const Icon(
//                             Icons.image,
//                             color: Color(0xFF5D56F3),
//                             size: 30,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//
//             // Text label
//             Positioned(
//               left: 9, // 24 - 15 (container left offset)
//               top: 99, // 817 - 718 (top offset)
//               child: SizedBox(
//                 width: 70,
//                 height: 30,
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontFamily: 'Montserrat',
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     height: 15 / 12, // line-height: 15px
//                     color: Color(0xFF000000),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Helper method for category subcategories
// List<MartSubcategoryModel> _getSubcategoriesForCategory(String categoryName) {
//   // Generate sample subcategories based on the category
//   final cleanCategoryName = categoryName.replaceAll('\n', ' ').toLowerCase();
//
//   if (cleanCategoryName.contains('fresh vegetables')) {
//     return [
//       MartSubcategoryModel(
//         id: 'veg_001',
//         title: 'Leafy Vegetables',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'veg_002',
//         title: 'Root Vegetables',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'veg_003',
//         title: 'Gourds & Squashes',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'veg_004',
//         title: 'Exotic Vegetables',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'veg_005',
//         title: 'Herbs & Seasonings',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'veg_006',
//         title: 'Organic Vegetables',
//         photo:
//             'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanCategoryName.contains('fresh fruits')) {
//     return [
//       MartSubcategoryModel(
//         id: 'fruit_001',
//         title: 'Seasonal Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'fruit_002',
//         title: 'Citrus Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'fruit_003',
//         title: 'Tropical Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'fruit_004',
//         title: 'Berries',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'fruit_005',
//         title: 'Exotic Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'fruit_006',
//         title: 'Organic Fruits',
//         photo:
//             'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanCategoryName.contains('dairy')) {
//     return [
//       MartSubcategoryModel(
//         id: 'dairy_001',
//         title: 'Milk & Milk Products',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'dairy_002',
//         title: 'Cheese & Butter',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'dairy_003',
//         title: 'Yogurt & Curd',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'dairy_004',
//         title: 'Bread & Bakery',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'dairy_005',
//         title: 'Eggs',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'dairy_006',
//         title: 'Organic Dairy',
//         photo:
//             'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanCategoryName.contains('hair care')) {
//     return [
//       MartSubcategoryModel(
//         id: 'hair_001',
//         title: 'Shampoo & Conditioner',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'hair_002',
//         title: 'Hair Oils & Serums',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'hair_003',
//         title: 'Hair Styling',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'hair_004',
//         title: 'Hair Treatments',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'hair_005',
//         title: 'Hair Accessories',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'hair_006',
//         title: 'Professional Hair Care',
//         photo:
//             'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanCategoryName.contains('skincare')) {
//     return [
//       MartSubcategoryModel(
//         id: 'skin_001',
//         title: 'Face Wash & Cleansers',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'skin_002',
//         title: 'Moisturizers & Creams',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'skin_003',
//         title: 'Sunscreen & Protection',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'skin_004',
//         title: 'Face Masks & Treatments',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'skin_005',
//         title: 'Anti-Aging Products',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'skin_006',
//         title: 'Natural & Organic',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else if (cleanCategoryName.contains('chocolates')) {
//     return [
//       MartSubcategoryModel(
//         id: 'choc_001',
//         title: 'Dark Chocolates',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'choc_002',
//         title: 'Milk Chocolates',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'choc_003',
//         title: 'White Chocolates',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'choc_004',
//         title: 'Chocolate Bars',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'choc_005',
//         title: 'Chocolate Gifts',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'choc_006',
//         title: 'Sugar-Free Chocolates',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//     ];
//   } else {
//     // Default subcategories for other categories
//     return [
//       MartSubcategoryModel(
//         id: 'default_001',
//         title: 'Popular Items',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'default_002',
//         title: 'New Arrivals',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'default_003',
//         title: 'Best Sellers',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'default_004',
//         title: 'On Sale',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'default_005',
//         title: 'Premium Selection',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//       MartSubcategoryModel(
//         id: 'default_006',
//         title: 'Organic Options',
//         photo:
//             'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
//       ),
//     ];
//   }
// }
//
// class MartGlowWellnessSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartGlowWellnessSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'GLOW & WELLNESS',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Wellness Grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 4,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 12,
//             childAspectRatio: 87 / 129, // Exact ratio from CSS
//             children: [
//               _GroceryItem(
//                 label: 'Bath &\nBody',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Hair\nCare',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1522338140263-f46f5913618a?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Skincare',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Makeup',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Oral\nCare',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Grooming',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Baby\nCare',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Fragrances',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Protein and\nSupplements',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Feminine\nHygiene',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Sexual\nWellness',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Health and\nPharma',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _WellnessItem extends StatelessWidget {
//   final String label;
//
//   const _WellnessItem({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFD8D5FF),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D1B69),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class MartSnacksRefreshmentsSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartSnacksRefreshmentsSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'SNACKS & REFRESHMENTS',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Snacks Grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 4,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 12,
//             childAspectRatio: 87 / 129, // Exact ratio from CSS
//             children: [
//               _GroceryItem(
//                 label: 'Cold Drinks\nand Juices',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Ice Creams and\nFrozen Desserts',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Chips and\nNamkeens',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Chocolates',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Noodles Pasta\nVermicelli',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Frozen\nFood',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Sweets',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Paan\nCorner',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SnackItem extends StatelessWidget {
//   final String label;
//
//   const _SnackItem({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFD8D5FF),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D1B69),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class MartEverydayLifeHomeSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartEverydayLifeHomeSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'EVERYDAY LIFE & HOME',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Everyday Life Grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 4,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 12,
//             childAspectRatio: 87 / 129, // Exact ratio from CSS
//             children: [
//               _GroceryItem(
//                 label: 'Home and\nFurnishing',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Kitchen and\nDining',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Cleaning\nEssentials',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Clothing',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Mobiles and\nElectronics',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Appliances',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Books and\nStationery',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Jewellery and\nAccessories',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Puja',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Toys and\nGames',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Sports and\nFitness',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//               _GroceryItem(
//                 label: 'Pet\nSupplies',
//                 imageUrl:
//                     'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EverydayItem extends StatelessWidget {
//   final String label;
//
//   const _EverydayItem({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFD8D5FF),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D1B69),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class MartLocalStoreSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartLocalStoreSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'LOCAL STORE',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Local Store Categories - Horizontal Scroll
//           SizedBox(
//             height: 140,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: [
//                 _LocalStoreItem(
//                   label: 'Party Store',
//                   color: const Color(0xFFD8D5FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Gourmet Store',
//                   color: const Color(0xFFFFE4B5),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Puja Store',
//                   color: const Color(0xFFFFE4E1),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Local Favourites',
//                   color: const Color(0xFFFFE4B5),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Toys & Stationery',
//                   color: const Color(0xFFFFE4E1),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Gifting Store',
//                   color: const Color(0xFFE0E0FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Pet Store',
//                   color: const Color(0xFFE8D7C6),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Health & Fitness',
//                   color: const Color(0xFFD8D5FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Travel Store',
//                   color: const Color(0xFFE0E0FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Electronics Store',
//                   color: const Color(0xFFD8D5FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Fashion Store',
//                   color: const Color(0xFFFFE4E1),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Beauty Store',
//                   color: const Color(0xFFFFE4B5),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Sports Store',
//                   color: const Color(0xFFE8D7C6),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Book Store',
//                   color: const Color(0xFFD8D5FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Music Store',
//                   color: const Color(0xFFE0E0FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Art & Craft',
//                   color: const Color(0xFFFFE4B5),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Garden Store',
//                   color: const Color(0xFFE8D7C6),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Auto Store',
//                   color: const Color(0xFFD8D5FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Hardware Store',
//                   color: const Color(0xFFE0E0FF),
//                   screenWidth: screenWidth,
//                 ),
//                 _LocalStoreItem(
//                   label: 'Pharmacy',
//                   color: const Color(0xFFFFE4E1),
//                   screenWidth: screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _LocalStoreItem extends StatelessWidget {
//   final String label;
//   final Color color;
//   final double screenWidth;
//
//   const _LocalStoreItem({
//     required this.label,
//     required this.color,
//     required this.screenWidth,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final itemSize = 120.0; // Further reduced size to fit
//
//     return Container(
//       width: itemSize + 12, // Add margin
//       margin: const EdgeInsets.only(right: 2),
//       child: Column(
//         children: [
//           Container(
//             width: itemSize,
//             height: itemSize,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartTrendingTodaySection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartTrendingTodaySection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           const Text(
//             'Trending Today',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D1B69),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Horizontal Scroll of Promotional Cards
//           SizedBox(
//             height: 203,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: List.generate(10, (index) => _TrendingCard()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _TrendingCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<MartBannerModel>>(
//       stream: Get.isRegistered<MartController>()
//           ? Get.find<MartController>().streamBannersByPosition('top', limit: 1)
//           : Stream.value([]),
//       builder: (context, snapshot) {
//         // Default data if no banner is available
//         String title = 'Nurture with love';
//         String description =
//             'Find a range of trusted essentials for mom & baby';
//         String buttonText = 'SHOP NOW';
//
//         // Use real data if available
//         if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//           final banner = snapshot.data!.first;
//           title = (banner.title?.isNotEmpty == true) ? banner.title! : title;
//           description = (banner.description?.isNotEmpty == true &&
//                   banner.description != '-')
//               ? banner.description!
//               : description;
//           buttonText = 'SHOP NOW'; // Keep button text consistent
//         }
//
//         return GestureDetector(
//           onTap: () {
//             if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//               try {
//                 Get.find<MartController>()
//                     .handleBannerTap(snapshot.data!.first);
//               } catch (e) {
//                 print('[MART HOME] Controller not found for banner tap: $e');
//               }
//             }
//           },
//           child: Container(
//             width: 300,
//             height: 203,
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF5C5C99),
//                   Color(0xFF1F1F33),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 // Title
//                 Positioned(
//                   left: 20,
//                   top: 16,
//                   child: SizedBox(
//                     width: 158,
//                     height: 78,
//                     child: Text(
//                       title,
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 32,
//                         fontWeight: FontWeight.w800,
//                         height: 1.22, // 39/32
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Subtitle
//                 Positioned(
//                   left: 20,
//                   top: 102,
//                   child: SizedBox(
//                     width: 174,
//                     height: 32,
//                     child: Text(
//                       description,
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         height: 1.23, // 16/13
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Shop Now Button
//                 Positioned(
//                   left: 20,
//                   top: 151,
//                   child: Container(
//                     width: 130,
//                     height: 39,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFAF9EE),
//                       borderRadius: BorderRadius.circular(70),
//                     ),
//                     child: Center(
//                       child: Text(
//                         buttonText,
//                         style: const TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           height: 1.21, // 17/14
//                           color: Color(0xFF00998a),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class MartProductDealsSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartProductDealsSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(
//         left: 16,
//         right: 16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9, // 25 - 16 (container padding)
//                   top: 0,
//                   child: Text(
//                     'Trending deals',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18, // line-height: 22px
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32, // 338 - 280 (container width - text position)
//                   top: 3, // 3123 - 3120 (top offset)
//                   child: GestureDetector(
//                     onTap: () {
//                       // Navigate to category detail screen with trending filter
//                       Get.to(() => MartCategoryDetailScreen(), arguments: {
//                         'categoryId': 'trending',
//                         'categoryName': 'Trending Deals',
//                         'initialFilter': 'trending',
//                       });
//                     },
//                     child: const Text(
//                       'See All',
//                       style: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         height: 17 / 14, // line-height: 17px
//                         color: Color(0xFF1717FE),
//                       ),
//                     ),
//                   ),
//                 ),
//
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9, // 387 - 378 (container width - icon position)
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll with Real-time Data
//           SizedBox(
//             height: 200,
//             child: StreamBuilder<List<MartItemModel>>(
//               stream: Get.isRegistered<MartController>()
//                   ? Get.find<MartController>().streamProductDeals(limit: 10)
//                   : Stream.value([]),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//
//                 if (snapshot.hasError) {
//                   return const Center(
//                     child: Text('Error loading products'),
//                   );
//                 }
//
//                 final products = snapshot.data ?? [];
//
//                 if (products.isEmpty) {
//                   return const Center(
//                     child: Text('No products available'),
//                   );
//                 }
//
//                 return ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     return _martItemToPlaytimeCard(
//                         products[index], screenWidth);
//                   },
//                 );
//               },
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//
//           const SizedBox(height: 16),
//
//         ],
//       ),
//     );
//   }
// }
//
// // _ProductCard class has been extracted to PlaytimeProductCard component
// // See: lib/app/mart/widgets/playtime_product_card.dart
//
// class MartHairCareSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartHairCareSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9,
//                   top: 0,
//                   child: Text(
//                     'Deals on Hair Care',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32,
//                   top: 3,
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 17 / 14,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9,
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll
//           SizedBox(
//             height: 200,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: List.generate(
//                   10,
//                   (index) => PlaytimeProductCard(
//                         volume: '580 ml',
//                         productName: 'Keratin Smooth Shampoo',
//                         discount: '40% OFF',
//                         currentPrice: '₹619',
//                         originalPrice: '₹1016',
//                         screenWidth: screenWidth,
//                       )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartChocolatesSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartChocolatesSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9,
//                   top: 0,
//                   child: Text(
//                     'Best deals on Chocolates',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32,
//                   top: 3,
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 17 / 14,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9,
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll
//           SizedBox(
//             height: 200,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: List.generate(
//                   10,
//                   (index) => PlaytimeProductCard(
//                         volume: '150 g',
//                         productName: 'Amul Dark Chocolate',
//                         discount: '8% OFF',
//                         currentPrice: '₹179',
//                         originalPrice: '₹200',
//                         screenWidth: screenWidth,
//                       )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartPlaytimeSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartPlaytimeSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9,
//                   top: 0,
//                   child: Text(
//                     'Playtime Savings',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32,
//                   top: 3,
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 17 / 14,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9,
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll
//           SizedBox(
//             height: 200,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: [
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Teddy bear',
//                   discount: '25% OFF',
//                   currentPrice: '₹399',
//                   originalPrice: '₹500',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Fluffy Bear',
//                   discount: '45% OFF',
//                   currentPrice: '₹699',
//                   originalPrice: '₹1000',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'UNO',
//                   discount: '30% OFF',
//                   currentPrice: '₹199',
//                   originalPrice: '₹300',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Teddy bear',
//                   discount: '25% OFF',
//                   currentPrice: '₹399',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Teddy bear',
//                   discount: '25% OFF',
//                   currentPrice: '₹399',
//                   originalPrice: '₹500',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Fluffy Bear',
//                   discount: '45% OFF',
//                   currentPrice: '₹699',
//                   originalPrice: '₹1000',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'UNO',
//                   discount: '30% OFF',
//                   currentPrice: '₹199',
//                   originalPrice: '₹300',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Teddy bear',
//                   discount: '25% OFF',
//                   currentPrice: '₹399',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Teddy bear',
//                   discount: '25% OFF',
//                   currentPrice: '₹399',
//                   originalPrice: '₹500',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Fluffy Bear',
//                   discount: '45% OFF',
//                   currentPrice: '₹699',
//                   originalPrice: '₹1000',
//                   screenWidth: screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartBabyCareSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartBabyCareSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9,
//                   top: 0,
//                   child: Text(
//                     'Best deals on Baby Care',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32,
//                   top: 3,
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 17 / 14,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9,
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll
//           SizedBox(
//             height: 200,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: [
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Huggies Larg 32 pieces',
//                   discount: '32% OFF',
//                   currentPrice: '₹359',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Pampers XL 78 pieces',
//                   discount: '20% OFF',
//                   currentPrice: '₹1579',
//                   originalPrice: '₹1049',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Huggies Larg 32 pieces',
//                   discount: '32% OFF',
//                   currentPrice: '₹359',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Pampers XL 78 pieces',
//                   discount: '20% OFF',
//                   currentPrice: '₹1579',
//                   originalPrice: '₹1049',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Huggies Larg 32 pieces',
//                   discount: '32% OFF',
//                   currentPrice: '₹359',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Pampers XL 78 pieces',
//                   discount: '20% OFF',
//                   currentPrice: '₹1579',
//                   originalPrice: '₹1049',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Huggies Larg 32 pieces',
//                   discount: '32% OFF',
//                   currentPrice: '₹359',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Pampers XL 78 pieces',
//                   discount: '20% OFF',
//                   currentPrice: '₹1579',
//                   originalPrice: '₹1049',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Huggies Larg 32 pieces',
//                   discount: '32% OFF',
//                   currentPrice: '₹359',
//                   originalPrice: '₹450',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '',
//                   productName: 'Pampers XL 78 pieces',
//                   discount: '20% OFF',
//                   currentPrice: '₹1579',
//                   originalPrice: '₹1049',
//                   screenWidth: screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartLocalGrocerySection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartLocalGrocerySection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title with See All
//           Container(
//             width: double.infinity,
//             height: 22,
//             child: Stack(
//               children: [
//                 // Section title
//                 const Positioned(
//                   left: 9,
//                   top: 0,
//                   child: Text(
//                     'Local Grocery Essentials',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       height: 22 / 18,
//                       color: Color(0xFF000000),
//                     ),
//                   ),
//                 ),
//
//                 // See All text
//                 Positioned(
//                   right: 32,
//                   top: 3,
//                   child: const Text(
//                     'See All',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 17 / 14,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//
//                 // Right arrow icon
//                 Positioned(
//                   right: 9,
//                   top: 0,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Color(0xFF1717FE),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Product Cards - Horizontal Scroll
//           SizedBox(
//             height: 200,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               children: [
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Aashirvaad Atta',
//                   discount: '15% OFF',
//                   currentPrice: '₹549',
//                   originalPrice: '₹640',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Sona Masoori Economy Rice',
//                   discount: '40% OFF',
//                   currentPrice: '₹1189',
//                   originalPrice: '₹2200',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '5 ltr',
//                   productName: 'Gold Drop Refined Sunflower Oil',
//                   discount: '20% OFF',
//                   currentPrice: '₹739',
//                   originalPrice: '₹950',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Aashirvaad Atta',
//                   discount: '15% OFF',
//                   currentPrice: '₹549',
//                   originalPrice: '₹640',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Sona Masoori Economy Rice',
//                   discount: '40% OFF',
//                   currentPrice: '₹1189',
//                   originalPrice: '₹2200',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '5 ltr',
//                   productName: 'Gold Drop Refined Sunflower Oil',
//                   discount: '20% OFF',
//                   currentPrice: '₹739',
//                   originalPrice: '₹950',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Aashirvaad Atta',
//                   discount: '15% OFF',
//                   currentPrice: '₹549',
//                   originalPrice: '₹640',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Sona Masoori Economy Rice',
//                   discount: '40% OFF',
//                   currentPrice: '₹1189',
//                   originalPrice: '₹2200',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '5 ltr',
//                   productName: 'Gold Drop Refined Sunflower Oil',
//                   discount: '20% OFF',
//                   currentPrice: '₹739',
//                   originalPrice: '₹950',
//                   screenWidth: screenWidth,
//                 ),
//                 PlaytimeProductCard(
//                   volume: '10 kg',
//                   productName: 'Aashirvaad Atta',
//                   discount: '15% OFF',
//                   currentPrice: '₹549',
//                   originalPrice: '₹640',
//                   screenWidth: screenWidth,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartSloganSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartSloganSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 353,
//       color: const Color(0xFFEEEEF2),
//       child: Stack(
//         children: [
//           // "Basket full" text
//           Positioned(
//             left: 26, // 27 - 1 (container left offset)
//             top: 54, // 5169 - 5115 (top offset)
//             child: const Text(
//               'Basket full',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 40,
//                 fontWeight: FontWeight.w800,
//                 height: 49 / 40, // line-height: 49px
//                 color: Color(0xFF787878),
//               ),
//             ),
//           ),
//
//           // "Heart full !" text
//           Positioned(
//             left: 27, // 28 - 1 (container left offset)
//             top: 103, // 5218 - 5115 (top offset)
//             child: const Text(
//               'Heart full !',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 fontSize: 50,
//                 fontWeight: FontWeight.w800,
//                 height: 61 / 50, // line-height: 61px
//                 color: Color(0xFF787878),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MartFeaturedProducts extends StatelessWidget {
//   final double screenWidth;
//
//   const MartFeaturedProducts({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(
//             left: 16,
//             right: 16,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Featured Products',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2D1B69),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Navigate to category detail screen with featured filter
//                   Get.to(() => MartCategoryDetailScreen(), arguments: {
//                     'categoryId': 'featured',
//                     'categoryName': 'Featured Products',
//                     'initialFilter': 'featured',
//                   });
//                 },
//                 child: const Text(
//                   'See All >',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         GetX<MartController>(
//           builder: (controller) {
//             if (controller.isProductLoading.value) {
//               return const SizedBox(
//                 height: 280,
//                 child: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//
//             if (controller.featuredItems.isEmpty) {
//               return SizedBox(
//                 height: 280,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         size: 64,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 8), // Reduced from 16 to 8
//                       const Text(
//                         'No featured products found',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//
//             return LayoutBuilder(
//               builder: (context, constraints) {
//                 final screenWidth = constraints.maxWidth;
//                 final isTablet = screenWidth > 600;
//                 final isLargePhone = screenWidth > 400;
//
//                 // Calculate dynamic card width based on screen size
//                 final cardWidth =
//                     isTablet ? 200.0 : (isLargePhone ? 180.0 : 160.0);
//
//                 // 🔑 Auto-adjustable layout using Wrap for truly flexible card heights
//                 return Padding(
//                   padding: const EdgeInsets.only(
//                     left: 16,
//                     // right: 16,
//                   ),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.only(),
//                     child: Wrap(
//                       alignment: WrapAlignment.start,
//                       crossAxisAlignment: WrapCrossAlignment.start,
//                       runAlignment: WrapAlignment.start,
//                       spacing: 0,
//                       runSpacing: 16.0,
//                       children: controller.featuredItems.map((product) {
//                         return SizedBox(
//                           width: cardWidth,
//                           child: MartProductCard(
//                               product: product,
//                               controller: _getMockController(),
//                               screenWidth: screenWidth),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   // Mock controller for testing
//   CategoryDetailController _getMockController() {
//     final controller = CategoryDetailController();
//     // Set mock subcategory data for the controller
//     controller.subcategories.value = [
//       MartSubcategoryModel(
//         id: 'featured',
//         title: 'Featured',
//         photo:
//             'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
//       ),
//     ];
//     return controller;
//   }
// }
//
// // Helper function to parse color from hex string
// Color _parseColor(String hexColor) {
//   try {
//     hexColor = hexColor.replaceAll('#', '');
//     if (hexColor.length == 6) {
//       hexColor = 'FF$hexColor'; // Add alpha channel
//     }
//     return Color(int.parse(hexColor, radix: 16));
//   } catch (e) {
//     return const Color(0xFFE8E4FF); // Default color
//   }
// }
//
// // Helper function to sanitize image URLs
// String _sanitizeImageUrl(String url) {
//   if (url.startsWith('"') && url.endsWith('"')) {
//     return url.substring(1, url.length - 1);
//   }
//   return url;
// }
//
// // Dynamic Sections Widget
// class MartDynamicSections extends StatefulWidget {
//   final double screenWidth;
//
//   const MartDynamicSections({super.key, required this.screenWidth});
//
//   @override
//   State<MartDynamicSections> createState() => _MartDynamicSectionsState();
// }
//
// class _MartDynamicSectionsState extends State<MartDynamicSections> {
//   bool _hasTriggeredLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MartController>(
//       builder: (controller) {
//         print('[MART DYNAMIC SECTIONS] 🔍 Widget build called');
//         print(
//             '[MART DYNAMIC SECTIONS] 📊 Current state: sectionsCount=${controller.availableSections.length}');
//         print(
//             '[MART DYNAMIC SECTIONS] 📊 Available sections: ${controller.availableSections}');
//
//         // Trigger sections loading only once to prevent blinking
//         if (!_hasTriggeredLoading && controller.availableSections.isEmpty) {
//           _hasTriggeredLoading = true;
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             print('[MART HOME] 🚀 Triggering sections loading silently...');
//             print(
//                 '[MART HOME] 📊 Current state: sectionsCount=${controller.availableSections.length}');
//             controller.loadSectionsImmediately();
//
//             // TEMPORARY: Add test sections for debugging if Firebase fails
//             Future.delayed(const Duration(seconds: 2), () {
//               if (controller.availableSections.isEmpty) {
//                 print('[MART HOME] 🧪 Adding test sections for debugging...');
//                 controller.addTestSections();
//               }
//             });
//           });
//         }
//
//         // If no sections available, don't show anything (no loading indicator)
//         if (controller.availableSections.isEmpty) {
//           print(
//               '[MART DYNAMIC SECTIONS] ⚠️ No sections available, returning empty widget');
//           return const SizedBox.shrink();
//         }
//
//         print(
//             '[MART DYNAMIC SECTIONS] ✅ Showing ${controller.availableSections.length} sections');
//         // Show sections progressively as they load
//         return Column(
//           children: controller.availableSections.map((section) {
//             return _buildSection(controller, section);
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   Widget _buildSection(MartController controller, String sectionName) {
//     return Container(
//       width: double.infinity,
//       // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       padding: const EdgeInsets.only(
//         left: 16,
//         right: 16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Header with Title and See All
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   sectionName, // Use the section name from Firebase
//                   style: TextStyle(
//                     fontSize: widget.screenWidth < 360 ? 14 : 16,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF2D1B69),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: () {
//                   // Navigate to category detail screen with section filter
//                   print(
//                       '[MART DYNAMIC SECTIONS] 🔗 Navigating to section: $sectionName');
//                   Get.to(() => MartCategoryDetailScreen(), arguments: {
//                     'categoryId':
//                         'section_${sectionName.toLowerCase().replaceAll(' ', '_')}',
//                     'categoryName': sectionName,
//                     'initialFilter': 'section',
//                     'sectionName': sectionName, // Pass the actual section name
//                   });
//                 },
//                 child: const Text(
//                   'See All >',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // Horizontal Scroll of Products using PlaytimeProductCard
//           GetBuilder<MartController>(
//             builder: (controller) {
//               // Get products for this section from Firebase
//               final sectionProducts =
//                   controller.getProductsForSection(sectionName);
//
//               // If no products available, don't show anything (sections will appear as products load)
//               if (sectionProducts.isEmpty) {
//                 return const SizedBox.shrink();
//               }
//
//               return SizedBox(
//                 height: 215, // Same height as PlaytimeProductCard
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: sectionProducts.length,
//                   itemBuilder: (context, index) {
//                     final product = sectionProducts[index];
//                     return PlaytimeProductCard(
//                       volume: '${product.grams ?? 0}g',
//                       productName: product.name ?? 'Product',
//                       discount: '${_calculateDiscount(product)}% OFF',
//                       currentPrice:
//                           '₹${product.disPrice ?? product.price ?? 0}',
//                       originalPrice: '₹${product.price ?? 0}',
//                       screenWidth: widget.screenWidth,
//                       imageUrl: product.photo,
//                       product: product, // Pass the product model for navigation
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20), // Spacing between sections
//         ],
//       ),
//     );
//   }
//
//   int _calculateDiscount(MartItemModel product) {
//     if (product.disPrice != null &&
//         product.price != null &&
//         product.price > product.disPrice!) {
//       return ((product.price - product.disPrice!) / product.price! * 100)
//           .round();
//     }
//     return 0;
//   }
// }
//
// // Helper function to get placeholder image for spotlight items
// Widget _getSpotlightPlaceholder(String title) {
//   IconData icon;
//   Color color;
//
//   if (title.toLowerCase().contains('fruit')) {
//     icon = Icons.apple;
//     color = Colors.red;
//   } else if (title.toLowerCase().contains('dairy') ||
//       title.toLowerCase().contains('bread') ||
//       title.toLowerCase().contains('egg')) {
//     icon = Icons.egg;
//     color = Colors.orange;
//   } else if (title.toLowerCase().contains('tea') ||
//       title.toLowerCase().contains('coffee')) {
//     icon = Icons.coffee;
//     color = Colors.brown;
//   } else if (title.toLowerCase().contains('protein') ||
//       title.toLowerCase().contains('supplement')) {
//     icon = Icons.fitness_center;
//     color = Colors.blue;
//   } else {
//     icon = Icons.shopping_basket;
//     color = Colors.green;
//   }
//
//   return Container(
//     color: color.withOpacity(0.1),
//     child: Icon(
//       icon,
//       size: 40,
//       color: color,
//     ),
//   );
// }
//
//
// Widget searchWidgetMain() {
//   /// Get appropriate icon for category based on name
//   IconData _getCategoryIcon(String categoryName) {
//     final name = categoryName.toLowerCase();
//
//     if (name.contains('grocery') ||
//         name.contains('food') ||
//         name.contains('vegetable') ||
//         name.contains('fruit') ||
//         name.contains('dairy') ||
//         name.contains('meat')) {
//       return Icons.shopping_basket;
//     } else if (name.contains('medicine') ||
//         name.contains('health') ||
//         name.contains('pharmacy') ||
//         name.contains('medical') ||
//         name.contains('drug')) {
//       return Icons.local_pharmacy;
//     } else if (name.contains('pet') ||
//         name.contains('animal') ||
//         name.contains('dog') ||
//         name.contains('cat') ||
//         name.contains('bird')) {
//       return Icons.pets;
//     } else if (name.contains('electronics') ||
//         name.contains('phone') ||
//         name.contains('laptop') ||
//         name.contains('computer')) {
//       return Icons.devices;
//     } else if (name.contains('clothing') ||
//         name.contains('fashion') ||
//         name.contains('shirt') ||
//         name.contains('dress')) {
//       return Icons.checkroom;
//     } else if (name.contains('beauty') ||
//         name.contains('cosmetic') ||
//         name.contains('makeup') ||
//         name.contains('skincare')) {
//       return Icons.face;
//     } else if (name.contains('sports') ||
//         name.contains('fitness') ||
//         name.contains('gym') ||
//         name.contains('exercise')) {
//       return Icons.sports_soccer;
//     } else if (name.contains('book') ||
//         name.contains('stationery') ||
//         name.contains('pen') ||
//         name.contains('paper')) {
//       return Icons.book;
//     } else if (name.contains('home') ||
//         name.contains('furniture') ||
//         name.contains('kitchen') ||
//         name.contains('garden')) {
//       return Icons.home;
//     } else if (name.contains('toy') ||
//         name.contains('game') ||
//         name.contains('play') ||
//         name.contains('children')) {
//       return Icons.toys;
//     } else {
//       // Default icon for unknown categories
//       return Icons.category;
//     }
//   }
//
//   return Container(
//     // width: 412,
//     height: 190,
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           const Color(0xFFFAF9EE), // Custom cream color - top
//           const Color(0xFFFAF9EE), // Custom cream color - bottom
//         ],
//         stops: [0.0, 1.0], // 0% to 100%
//       ),
//       borderRadius: BorderRadius.only(
//         bottomLeft: Radius.circular(10),
//         bottomRight: Radius.circular(10),
//       ),
//     ),
//     child: Column(
//       children: [
//         SizedBox(
//           height: 20,
//         ),
//         // Group 262 - Search Bar
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: const MartSearchBar(
//             hintText: 'Search products, categories...',
//           ),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(
//             left: 16,
//             right: 16,
//           ),
//           child: GetX<MartController>(
//             builder: (controller) {
//               if (controller.featuredCategories.isEmpty &&
//                   !controller.isCategoryLoading.value &&
//                   !controller.isHomepageCategoriesLoaded.value) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   controller.loadHomepageCategoriesStreaming(limit: 6);
//                 });
//               }
//               if (controller.isCategoryLoading.value) {
//                 return SizedBox(
//                   height: 60,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: List.generate(
//                       3,
//                       (index) => Container(
//                         width: 28,
//                         height: 28,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }
//
//               // Check for Firestore errors
//               if (controller.errorMessage.value.isNotEmpty) {
//                 print(
//                     '[MART HOME] ❌ Firestore error: ${controller.errorMessage.value}');
//                 return SizedBox(
//                   height: 80,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Error loading categories',
//                           style: TextStyle(
//                             fontFamily: 'Montserrat',
//                             fontSize: 12,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: () {
//                             print(
//                                 '[MART HOME] 🔄 Retrying categories from Firestore...');
//                             controller.loadHomepageCategoriesStreaming(
//                                 limit: 6);
//                           },
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//
//               if (controller.featuredCategories.isEmpty) {
//                 // No categories loaded from Firestore
//                 print('[MART HOME] ⚠️ No categories loaded from Firestore');
//                 return const SizedBox(
//                   height: 80,
//                   child: Center(
//                     child: Text(
//                       'No categories available',
//                       style: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 );
//               }
//
//               return SizedBox(
//                 height: 90,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     // Dynamic category from Firestore
//                     Builder(
//                       builder: (context) {
//                         if (controller.featuredCategories.isNotEmpty) {
//                           final category = controller.featuredCategories[0];
//                           final categoryIcon =
//                               _getCategoryIcon(category.title ?? '');
//
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': category.id ?? '',
//                                     'categoryName':
//                                         category.title ?? 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     categoryIcon,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     category.title ?? 'Category',
//                                     style: const TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       // height: 16 / 14,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           // Fallback to default grocery icon
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': 'default',
//                                     'categoryName': 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.category,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 const SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     'Loading...',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       height: 16 / 14,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       },
//                     ),
//
//                     // Dynamic category from Firestore
//                     Builder(
//                       builder: (context) {
//                         if (controller.featuredCategories.length > 1) {
//                           final category = controller.featuredCategories[1];
//                           final categoryIcon =
//                               _getCategoryIcon(category.title ?? '');
//
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': category.id ?? '',
//                                     'categoryName':
//                                         category.title ?? 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     categoryIcon,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     category.title ?? 'Category',
//                                     style: const TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       // height: 16 / 14,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           // Fallback to default medicine icon
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': 'default',
//                                     'categoryName': 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.local_pharmacy,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 const SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     'Loading...',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       height: 16 / 14,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       },
//                     ),
//
//                     // Dynamic category from Firestore
//                     Builder(
//                       builder: (context) {
//                         if (controller.featuredCategories.length > 2) {
//                           final category = controller.featuredCategories[2];
//                           final categoryIcon =
//                               _getCategoryIcon(category.title ?? '');
//
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': category.id ?? '',
//                                     'categoryName':
//                                         category.title ?? 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     categoryIcon,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     category.title ?? 'Category',
//                                     style: const TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       // height: 16 / 18,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           // Fallback to default pet icon
//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => const MartCategoryDetailScreen(),
//                                   arguments: {
//                                     'categoryId': 'default',
//                                     'categoryName': 'Category',
//                                   });
//                             },
//                             borderRadius: BorderRadius.circular(20),
//                             child: Column(
//                               children: [
//                                 Container(
//                                   width: 45,
//                                   height: 45,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF00998a),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.pets_outlined,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 const SizedBox(
//                                   width: 80,
//                                   child: Text(
//                                     'Loading...',
//                                     style: TextStyle(
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       height: 16 / 14,
//                                       color: Color(0xFF000000),
//                                     ),
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // Helper method for user initials (keeping this one as it's still used)
//
// String _getUserInitials() {
//   final userModel = Constant.userModel;
//   if (userModel == null) return 'U';
//
//   String firstName = userModel.firstName?.trim() ?? '';
//   String lastName = userModel.lastName?.trim() ?? '';
//
//   String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
//   String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
//
//   if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
//     return '$firstInitial$lastInitial';
//   } else if (firstInitial.isNotEmpty) {
//     return firstInitial;
//   } else if (lastInitial.isNotEmpty) {
//     return lastInitial;
//   } else {
//     return 'U';
//   }
// }
//
// // Dynamic Categories Section - Replaces dummy data sections
// class MartDynamicCategoriesSection extends StatelessWidget {
//   final double screenWidth;
//
//   const MartDynamicCategoriesSection({super.key, required this.screenWidth});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<MartController>(
//       builder: (controller) {
//         if (controller.isCategoryLoading.value) {
//           return Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Categories',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2D1B69),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: 4,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.75, // Fixed overflow issue
//                   children: List.generate(
//                     8,
//                     (index) => Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (controller.featuredCategories.isEmpty) {
//           return Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Categories',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2D1B69),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Center(
//                   child: Text(
//                     'No categories available',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Section Title
//               const Text(
//                 'Categories',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2D1B69),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Dynamic Categories Grid
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 4,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 0.75, // Fixed overflow issue
//                 children: controller.featuredCategories
//                     .map(
//                       (category) => _DynamicCategoryItem(
//                         category: category,
//                         onTap: () {
//                           // Navigate to category detail screen
//                           Get.to(() => const MartCategoryDetailScreen(),
//                               arguments: {
//                                 'categoryId': category.id,
//                                 'categoryName': category.title,
//                               });
//                         },
//                       ),
//                     )
//                     .toList(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _DynamicCategoryItem extends StatelessWidget {
//   final MartCategoryModel category;
//   final VoidCallback? onTap;
//
//   const _DynamicCategoryItem({
//     required this.category,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Category Image or Icon
//             Expanded(
//               flex: 3,
//               child: Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: _parseColor(category.backgroundColor ?? '#E8E4FF'),
//                 ),
//                 child: category.photo != null && category.photo!.isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: NetworkImageWidget(
//                           imageUrl: category.photo!,
//                           width: double.infinity,
//                           height: double.infinity,
//                           fit: BoxFit.cover,
//                           errorWidget: _getCategoryIcon(category.title ?? ''),
//                         ),
//                       )
//                     : _getCategoryIcon(category.title ?? ''),
//               ),
//             ),
//
//             // Category Name
//             Expanded(
//               flex: 2,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                 child: Text(
//                   category.title ?? 'Unknown',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D1B69),
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _getCategoryIcon(String categoryName) {
//     IconData icon;
//     Color color;
//
//     final name = categoryName.toLowerCase();
//
//     if (name.contains('grocery') ||
//         name.contains('vegetable') ||
//         name.contains('fruit')) {
//       icon = Icons.shopping_basket;
//       color = Colors.green;
//     } else if (name.contains('dairy') ||
//         name.contains('milk') ||
//         name.contains('bread')) {
//       icon = Icons.egg;
//       color = Colors.orange;
//     } else if (name.contains('medicine') || name.contains('health')) {
//       icon = Icons.local_pharmacy;
//       color = Colors.red;
//     } else if (name.contains('pet')) {
//       icon = Icons.pets;
//       color = Colors.brown;
//     } else if (name.contains('electronics') || name.contains('mobile')) {
//       icon = Icons.phone_android;
//       color = Colors.blue;
//     } else if (name.contains('clothing') || name.contains('fashion')) {
//       icon = Icons.checkroom;
//       color = Colors.purple;
//     } else if (name.contains('home') || name.contains('furniture')) {
//       icon = Icons.home;
//       color = Colors.indigo;
//     } else if (name.contains('sports') || name.contains('fitness')) {
//       icon = Icons.sports_soccer;
//       color = Colors.teal;
//     } else {
//       icon = Icons.category;
//       color = Colors.grey;
//     }
//
//     return Icon(
//       icon,
//       size: 32,
//       color: color,
//     );
//   }
// }
//
// // Helper function to convert MartItemModel to PlaytimeProductCard format
// PlaytimeProductCard _martItemToPlaytimeCard(
//     MartItemModel item, double screenWidth) {
//   // Calculate discount percentage
//   String discount = '';
//   if (item.disPrice != null &&
//       item.price != null &&
//       item.disPrice! < item.price!) {
//     double discountPercent =
//         ((item.price! - item.disPrice!) / item.price! * 100).round().toDouble();
//     discount = '${discountPercent.toInt()}% OFF';
//   }
//
//   // Get volume/weight from item attributes or use default
//   String volume = item.weight ?? '1 pc';
//
//   // Format prices
//   String currentPrice =
//       '₹${item.disPrice?.toStringAsFixed(0) ?? item.price?.toStringAsFixed(0) ?? '0'}';
//   String originalPrice = '₹${item.price?.toStringAsFixed(0) ?? '0'}';
//
//   return PlaytimeProductCard(
//     volume: volume,
//     productName: item.name ?? 'Product',
//     discount: discount,
//     currentPrice: currentPrice,
//     originalPrice: originalPrice,
//     screenWidth: screenWidth,
//     imageUrl: item.photo,
//     product: item, // Pass the product model for cart functionality
//   );
// }
