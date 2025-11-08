import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/mart_search_controller.dart';
import 'package:customer/controllers/category_detail_controller.dart';
import 'package:customer/app/mart/widgets/mart_search_widget.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/utils/color_const.dart';

class MartSearchScreen extends StatefulWidget {
  const MartSearchScreen({Key? key}) : super(key: key);

  @override
  State<MartSearchScreen> createState() => _MartSearchScreenState();
}

class _MartSearchScreenState extends State<MartSearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;

  // Mart emojis for floating animation from theme - Enhanced with more visible emojis
  final List<String> floatingEmojis = [
    MartEmojis.cart,
    MartEmojis.milk,
    MartEmojis.bread,
    MartEmojis.egg,
    MartEmojis.cheese,
    MartEmojis.apple,
    MartEmojis.carrot,
    MartEmojis.bottle,
    MartEmojis.banana,
    MartEmojis.baguette,
    MartEmojis.potato,
    MartEmojis.onion,
    MartEmojis.tomato,
    MartEmojis.cucumber,
    MartEmojis.lettuce,
    MartEmojis.nuts,
    MartEmojis.honey,
    MartEmojis.bacon,
    MartEmojis.meat,
    MartEmojis.fish,
    // 🔑 Added more diverse and visible emojis
    '🛒', // Shopping cart
    '🍎', // Apple
    '🥛', // Milk
    '🍞', // Bread
    '🥚', // Egg
    '🧀', // Cheese
    '🥕', // Carrot
    '🍌', // Banana
    '🥔', // Potato
    '🍅', // Tomato
    '🥒', // Cucumber
    '🥬', // Lettuce
    '🥜', // Nuts
    '🍯', // Honey
    '🥓', // Bacon
    '🥩', // Meat
    '🐟', // Fish
    '🍇', // Grapes
    '🍓', // Strawberry
    '🍊', // Orange
    '🥑', // Avocado
    '🌽', // Corn
    '🍄', // Mushroom
    '🥖', // Baguette
    '🧈', // Butter
    '🍕', // Pizza
    '🍔', // Burger
    '🌮', // Taco
    '🍜', // Noodles
    '🍲', // Stew
    '🥗', // Salad
    '🍰', // Cake
    '🍪', // Cookie
    '🍫', // Chocolate
    '🍭', // Lollipop
    '☕', // Coffee
    '🍵', // Tea
    '🥤', // Soft drink
    '🧊', // Ice
    '🍦', // Ice cream
    '🍨', // Soft serve
    '🍩', // Donut
    '🧁', // Cupcake
    '🍯', // Honey pot
    '🥞', // Pancakes
    '🧇', // Waffle
    '🍳', // Fried egg
    '🥪', // Sandwich
    '🌭', // Hot dog
    '🥙', // Stuffed flatbread
    '🌯', // Burrito
    '🥘', // Paella
    '🍝', // Spaghetti
    '🍛', // Curry
    '🍚', // Rice
    '🍙', // Onigiri
    '🍘', // Rice cracker
    '🍱', // Bento box
    '🍣', // Sushi
    '🍤', // Fried shrimp
    '🍥', // Fish cake
    '🥟', // Dumpling
    '🍢', // Oden
    '🍡', // Dango
    '🍧', // Shaved ice
    '🍨', // Soft serve
    '🍩', // Donut
    '🍪', // Cookie
    '🍫', // Chocolate bar
    '🍬', // Candy
    '🍭', // Lollipop
    '🍮', // Custard
    '🍯', // Honey pot
    '🍰', // Shortcake
    '🧁', // Cupcake
    '🥧', // Pie
    '🍪', // Cookie
    '🍫', // Chocolate bar
    '🍬', // Candy
    '🍭', // Lollipop
    '🍮', // Custard
    '🍯', // Honey pot
    '🍰', // Shortcake
    '🧁', // Cupcake
    '🥧', // Pie
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the search controller
    Get.put(MartSearchController());

    // Initialize the category detail controller for product cards
    try {
      Get.find<CategoryDetailController>();
    } catch (e) {
      Get.put(CategoryDetailController());
    }

    // Floating animation controller
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppThemeData.homeScreenBackground,
        ),
        child: Stack(
          children: [
            // Floating animated emojis - Smaller size, edge positioning only
            ...List.generate(8, (index) { // 🔑 Reduced from 12 to 8 emojis
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              // 🔑 Position only at edges and diagonals
              double left, top;
              switch (index) {
                case 0: // Top-left corner
                  left = 10;
                  top = 100;
                  break;
                case 1: // Top-right corner
                  left = screenWidth - 50;
                  top = 120;
                  break;
                case 2: // Bottom-left corner
                  left = 15;
                  top = screenHeight - 200;
                  break;
                case 3: // Bottom-right corner
                  left = screenWidth - 45;
                  top = screenHeight - 180;
                  break;
                case 4: // Top-center edge
                  left = screenWidth * 0.5 - 25;
                  top = 80;
                  break;
                case 5: // Bottom-center edge
                  left = screenWidth * 0.5 - 25;
                  top = screenHeight - 150;
                  break;
                case 6: // Left-center edge
                  left = 20;
                  top = screenHeight * 0.5;
                  break;
                case 7: // Right-center edge
                  left = screenWidth - 40;
                  top = screenHeight * 0.5;
                  break;
                default:
                  left = 0;
                  top = 0;
              }
              
              return Positioned(
                left: left,
                top: top,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    // 🔑 Subtle edge animation with smaller movement
                    final time = _floatingController.value;
                    final horizontalOffset = 8 * (index % 2 == 0 ? 1 : -1) * 
                        (0.5 + 0.5 * (time + index * 0.1));
                    final verticalOffset = 6 * (index % 3 == 0 ? 1 : -1) * 
                        (0.5 + 0.5 * (time + index * 0.1));
                    final opacity = 0.3 + 0.15 * (0.5 + 0.5 * (time + index * 0.05));
                    
                    return Transform.translate(
                      offset: Offset(horizontalOffset, verticalOffset),
                      child: Transform.rotate(
                        angle: 0.02 * (time + index * 0.1), // 🔑 Very subtle rotation
                        child: Transform.scale(
                          scale: 0.98 + 0.04 * (0.5 + 0.5 * (time + index * 0.05)), // 🔑 Very subtle scaling
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Text(
                              floatingEmojis[index % floatingEmojis.length],
                              style: TextStyle(
                                fontSize: 16 + (index % 3) * 4, // 🔑 Reduced size for edge positioning
                                shadows: [ // 🔑 Added text shadow for better visibility
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Main content
            Column(
              children: [
                // Custom colorful app bar
                Container(
                  decoration: BoxDecoration(
                    color: ColorConst.martPrimary,
                    boxShadow: MartTheme.elevatedShadow,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Back button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(MartTheme.buttonRadius),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title with emoji
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  '🛒 ',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const Text(
                                  'Search Products',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                // Search widget with transparent background
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    // 🔑 Removed white background and shadow for transparent look
                    child: const MartSearchWidget(
                      showHistory: true,
                      showCategories: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
