import 'package:customer/app/auth_screen/phone_number_screen.dart';
import 'package:customer/app/mart/screens/mart_address_screen/mart_address_screen.dart';
import 'package:customer/app/mart/screens/mart_edit_profile_screen/mart_edit_profile_screen.dart';
import 'package:customer/app/mart/mart_home_screen/controller/mart_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:customer/utils/utils/color_const.dart';

class MartProfileScreen extends StatelessWidget {
  const MartProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure user data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureUserDataLoaded();
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      body: GetBuilder<MartController>(
        builder: (controller) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 75,
                floating: false,
                pinned: true,
                backgroundColor: ColorConst.martPrimary,
                automaticallyImplyLeading: false, // Remove back arrow
                flexibleSpace: FlexibleSpaceBar(
                  title: const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration:  BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [ColorConst.martPrimary, ColorConst.martPrimary],
                      ),
                    ),
                  ),
                ),
                // actions: [
                //   IconButton(
                //     icon: const Icon(Icons.settings, color: Colors.white),
                //     onPressed: () {
                //       // TODO: Navigate to settings
                //       Get.snackbar(
                //         'Settings',
                //         'Settings screen coming soon!',
                //         snackPosition: SnackPosition.BOTTOM,
                //       );
                //     },
                //   ),
                // ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(),
                      const SizedBox(height: 24),

                      // Quick Stats
                      _buildQuickStats(),
                      const SizedBox(height: 24),

                      // Menu Items
                      _buildMenuItems(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userModel = Constant.userModel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture with Initials
          CircleAvatar(
            radius: 40,
            backgroundColor: ColorConst.martPrimary,
            backgroundImage: userModel?.profilePictureURL != null &&
                    userModel!.profilePictureURL!.isNotEmpty
                ? NetworkImage(userModel.profilePictureURL!)
                : null,
            child: userModel?.profilePictureURL == null ||
                    userModel!.profilePictureURL!.isEmpty
                ? Text(
                    _getUserInitials(userModel),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel?.fullName() ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userModel?.email ??
                      userModel?.phoneNumber ??
                      'No contact info',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D56F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userModel?.role?.toUpperCase() ?? 'CUSTOMER',
                    style:  TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorConst.orangeLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: () {
              Get.to(() => const MartEditProfileScreen());
            },
            icon:  Icon(
              Icons.edit,
              color: ColorConst.orangeLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final userModel = Constant.userModel;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag,
            title: 'Orders',
            value: userModel?.inProgressOrderID?.length.toString() ?? '0',
            color:  ColorConst.martPrimary,
          ),
        ),
        const SizedBox(width: 12),
        // Expanded(
        //   child: _buildStatCard(
        //     icon: Icons.account_balance_wallet,
        //     title: 'Wallet',
        //     value: '₹${userModel?.walletAmount?.toStringAsFixed(0) ?? '0'}',
        //     color: Colors.green,
        //   ),
        // ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on,
            title: 'Addresses',
            value: userModel?.shippingAddress?.length.toString() ?? '0',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'View your order history',
            onTap: () {
              Get.snackbar(
                'My Orders',
                'Order history screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            subtitle: 'Your saved items',
            onTap: () {
              Get.snackbar(
                'Favorites',
                'Favorites screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Delivery Addresses',
            subtitle: 'Manage your addresses',
            onTap: () {
              Get.to(() => const MartAddressScreen());
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () {
              Get.snackbar(
                'Payment Methods',
                'Payment methods screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            onTap: () {
              Get.snackbar(
                'Notifications',
                'Notifications screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              Get.snackbar(
                'Help & Support',
                'Support screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              Get.snackbar(
                'About',
                'About screen coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red :ColorConst.martPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey,
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // 1. Clear user data from memory
      Constant.userModel = null;
      Constant.selectedLocation = ShippingAddress();

      // 2. Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 3. Clear all secure storage
      const storage = FlutterSecureStorage();
      await storage.deleteAll(); // Clear all secure storage

      // 4. Clear all SharedPreferences
      await Preferences.clearSharPreference();

      // 5. Clear GetStorage
      final box = GetStorage();
      await box.erase();

      // 6. Clear any GetX stored data
      Get.deleteAll();

      // 7. Navigate to login screen with fresh start
      Get.offAll(() => const PhoneNumberScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200));

      // 8. Show success message after navigation
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.snackbar(
          'Logged Out',
          'You have been successfully logged out',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _ensureUserDataLoaded() {
    if (Constant.userModel == null) {
      // Try to get user data from Firebase
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // User is logged in but data not loaded, show loading
        Get.snackbar(
          'Loading Profile',
          'Please wait while we load your profile data...',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // No user logged in, redirect to login
        Get.offAll(() => const PhoneNumberScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 1200));
      }
    }
  }

  String _getUserInitials(UserModel? userModel) {
    if (userModel == null) return 'U';

    String firstName = userModel.firstName?.trim() ?? '';
    String lastName = userModel.lastName?.trim() ?? '';

    String firstInitial =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';

    if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
      return '$firstInitial$lastInitial';
    } else if (firstInitial.isNotEmpty) {
      return firstInitial;
    } else if (lastInitial.isNotEmpty) {
      return lastInitial;
    } else {
      return 'U';
    }
  }
}
