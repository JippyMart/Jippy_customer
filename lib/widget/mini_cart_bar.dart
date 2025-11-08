import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/cart_check_out_page/cart_check_out_screen.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../app/cart_screen/cart_screen.dart';
import '../app/restaurant_details_screen/restaurant_details_screen.dart';
import '../constant/constant.dart';
import '../utils/fire_store_utils.dart';
import '../constant/show_toast_dialog.dart';

class MiniCartBar extends StatelessWidget {
  const MiniCartBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int itemCount = cartItem.length;
      if (itemCount == 0) return const SizedBox.shrink();
      final String vendorName = cartItem.first.vendorName ?? 'Restaurant';
      final vendorId = cartItem.first.vendorID;
      final String productImage = cartItem.first.photo ?? '';

      return SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product image (left, small, rounded)
              if (productImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    productImage,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey, size: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 24),
                ),
              const SizedBox(width: 12),
              // Restaurant name (clickable)
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (vendorId != null) {
                      ShowToastDialog.showLoader("Loading restaurant...");
                      final vendorModel = await FireStoreUtils.getVendorById(vendorId.toString());
                      ShowToastDialog.closeLoader();
                      if (vendorModel != null) {
                        Get.to(const RestaurantDetailsScreen(), arguments: {'vendorModel': vendorModel});
                      } else {
                        ShowToastDialog.showToast("Restaurant not found");
                      }
                    }
                  },
                  child: Text(
                    vendorName,
                    style: const TextStyle(
                      color: Color(0xFFff5201),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // // WhatsApp button
              // InkWell(
              //   onTap: () async {
              //     // WhatsApp number - you can change this to your desired number
              //     const String phoneNumber = '+919876543210'; // Replace with your actual WhatsApp number
              //     const String message = 'Hello! I need help with my order.'; // Customize the message
                  
              //     final Uri whatsappUrl = Uri.parse(
              //       'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
              //     );
                  
              //     try {
              //       if (await canLaunchUrl(whatsappUrl)) {
              //         await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              //       } else {
              //         // Fallback to regular phone call if WhatsApp is not available
              //         final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
              //         if (await canLaunchUrl(phoneUrl)) {
              //           await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
              //         }
              //       }
              //     } catch (e) {
              //       print('Error launching WhatsApp: $e');
              //     }
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.green, // WhatsApp green color
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     padding: const EdgeInsets.all(10),
              //     child: const Icon(
              //       Icons.chat_bubble,
              //       color: Colors.white,
              //       size: 20,
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 8),
              // View Cart button with item count below
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 100));
                      // Get.to(const CartScreen());
                      Get.to(const CartCheckOutScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFff5201),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    child: Text('View Cart • $itemCount item${itemCount > 1 ? 's' : ''}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
} 