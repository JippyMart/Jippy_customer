import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/cetegory_service_controller.dart';

class CateringServiceScreen extends StatelessWidget {
  const CateringServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CategoryServiceController(),
    );
    return Scaffold(
      body: GetBuilder<CategoryServiceController>(
          init: CategoryServiceController(),
          builder: (controller) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFE8E8),
                    Color(0xFFE8F4FF),
                    Color(0xFFE8FFE8),
                  ],
                ),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    _buildHeaderSection(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 0, right: 16, bottom: 16, left: 16.0),
                        child: ListView(
                          children: [
                            // const SizedBox(height: 10),
                            // Title with improved design
                            // _buildTitleSection(),
                            // const SizedBox(height: 30),
                            // Form Fields in Card
                            Card(
                              elevation: 8,
                              // color: Color(0xFFE8FFE8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    // Name Field
                                    _buildTextField(
                                      controller: controller.nameController,
                                      label: 'Name *',
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),

                                    // Mobile Field
                                    _buildTextField(
                                      controller: controller.mobileController,
                                      label: 'Mobile Number *',
                                      keyboardType: TextInputType.phone,
                                      icon: Icons.phone_android_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter mobile number';
                                        }
                                        if (!RegExp(r'^[0-9]{10}$')
                                            .hasMatch(value)) {
                                          return 'Please enter valid 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                    ),

                                    _buildTextField(
                                      controller: controller.alterMobileNumber,
                                      label: 'Alternative Mobile Number ',
                                      keyboardType: TextInputType.phone,
                                      icon: Icons.phone_android_outlined,
                                      validator: (value) {
                                        if (value != null &&
                                            value.isNotEmpty &&
                                            !RegExp(r'^[0-9]{10}$')
                                                .hasMatch(value )) {
                                          return 'Please enter valid 10-digit mobile number';
                                        }

                                        return null;
                                      },
                                    ),

                                    // Email Field
                                    _buildTextField(
                                      controller: controller.emailController,
                                      label: 'Email (Optional)',
                                      keyboardType: TextInputType.emailAddress,
                                      icon: Icons.email_outlined,
                                      validator: (value) {
                                        if (value != null &&
                                            value.isNotEmpty &&
                                            !value.contains('@')) {
                                          return 'Please enter valid email';
                                        }
                                        return null;
                                      },
                                    ),

                                    // Place/Address Field
                                    _buildTextField(
                                      controller: controller.placeController,
                                      label: 'Place / Address *',
                                      maxLines: 3,
                                      icon: Icons.location_on_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter place/address';
                                        }
                                        return null;
                                      },
                                    ),
                                    // Function Type Dropdown
                                    _buildFunctionTypeDropdown(
                                        controller: controller),

                                    // Date Field
                                    _buildDateField(
                                        controller: controller,
                                        context: context),

                                    // Guests Field
                                    _buildTextField(
                                      controller: controller.guestsController,
                                      label: 'No. of Guests *',
                                      keyboardType: TextInputType.number,
                                      icon: Icons.people_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter number of guests';
                                        }
                                        final guests = int.tryParse(value);
                                        if (guests == null || guests < 1) {
                                          return 'Please enter valid number of guests (min 1)';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) =>
                                          controller.updateGuestCounts(),
                                    ),
                                    // Meal Preference Radio
                                    _buildMealPreferenceRadio(
                                        controller: controller),
                                    // Veg/Non-Veg Counts
                                    if (controller.mealPreference ==
                                        'Both') ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Guest Distribution',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildTextField(
                                                    controller: controller
                                                        .vegCountController,
                                                    label: 'Veg',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    icon: Icons.eco_outlined,
                                                    validator: (value) {
                                                      final guests =
                                                          int.tryParse(controller
                                                                  .guestsController
                                                                  .text) ??
                                                              0;
                                                      final veg = int.tryParse(
                                                              value ?? '0') ??
                                                          0;
                                                      final nonveg =
                                                          int.tryParse(controller
                                                                  .nonvegCountController
                                                                  .text) ??
                                                              0;
                                                      if (veg + nonveg !=
                                                          guests) {
                                                        controller
                                                            .showSnackBarInGustDistribution();
                                                        return 'Veg + Non-Veg must equal total guests';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _buildTextField(
                                                    controller: controller
                                                        .nonvegCountController,
                                                    label: 'Non-Veg',
                                                    keyboardType:
                                                        TextInputType.number,
                                                    icon: Icons
                                                        .restaurant_outlined,
                                                    validator: (value) {
                                                      final guests =
                                                          int.tryParse(controller
                                                                  .guestsController
                                                                  .text) ??
                                                              0;
                                                      final veg = int.tryParse(
                                                              controller
                                                                  .vegCountController
                                                                  .text) ??
                                                          0;
                                                      final nonveg =
                                                          int.tryParse(value ??
                                                                  '0') ??
                                                              0;
                                                      if (veg + nonveg !=
                                                          guests) {
                                                        return 'Veg + Non-Veg must equal total guests';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Special Requirements
                                    _buildTextField(
                                      controller: controller
                                          .specialRequirementsController,
                                      label: 'Special Requirements',
                                      maxLines: 3,
                                      icon: Icons.note_alt_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Submit Button
                            _buildSubmitButton(
                                controller: controller, context: context),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60.0,
        bottom: 20.0,
        left: 20.0,
        right: 20.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'JippyMart Catering Service',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  const String phoneNumber = '+919390579864';
                  const String message =
                      'Hello! I need help with my JippyMart order.';

                  final Uri whatsappUrl = Uri.parse(
                      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

                  try {
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl,
                          mode: LaunchMode.externalApplication);
                    } else {
                      final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                      if (await canLaunchUrl(phoneUrl)) {
                        await launchUrl(phoneUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  } catch (e) {
                    debugPrint('Error launching WhatsApp: $e');
                  }
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.green,
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
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/images/whatsapp.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildHeaderSection(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     height: 190,
  //     padding: const EdgeInsets.only(
  //       top: 60.0,
  //       bottom: 10.0,
  //       left: 20.0,
  //       right: 20.0,
  //     ),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.deepOrange.shade400,
  //           Colors.orange.shade600,
  //         ],
  //       ),
  //       borderRadius: const BorderRadius.only(
  //         bottomLeft: Radius.circular(30),
  //         bottomRight: Radius.circular(30),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.deepOrange.withOpacity(0.3),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Stack(
  //       children: [
  //         Row(
  //           children: [
  //             InkWell(
  //               onTap: () => Get.back(),
  //               child:
  //                   const Icon(Icons.arrow_back_ios_new, color: Colors.white),
  //             ),
  //             const SizedBox(width: 10),
  //             const Expanded(
  //               child: Text(
  //                 'JippyMart Catering Service',
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Positioned(
  //           right: 16,
  //           bottom: 0,
  //           child: GestureDetector(
  //             onTap: () async {
  //               const String phoneNumber = '+919390579864';
  //               const String message =
  //                   'Hello! I need help with my JippyMart order.';
  //               final Uri whatsappUrl = Uri.parse(
  //                   'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
  //               try {
  //                 if (await canLaunchUrl(whatsappUrl)) {
  //                   await launchUrl(whatsappUrl,
  //                       mode: LaunchMode.externalApplication);
  //                 } else {
  //                   final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
  //                   if (await canLaunchUrl(phoneUrl)) {
  //                     await launchUrl(phoneUrl,
  //                         mode: LaunchMode.externalApplication);
  //                   }
  //                 }
  //               } catch (e) {
  //                 debugPrint('Error launching WhatsApp: $e');
  //               }
  //             },
  //             child: Container(
  //               width: 50,
  //               height: 50,
  //               decoration: BoxDecoration(
  //                 color: Colors.green,
  //                 shape: BoxShape.circle,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.2),
  //                     blurRadius: 8,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(10.0),
  //                 child: SvgPicture.asset(
  //                   'assets/images/whatsapp.svg',
  //                   colorFilter:
  //                       const ColorFilter.mode(Colors.white, BlendMode.srcIn),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildHeaderSection(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.only(
  //       top: 60.0,
  //       bottom: 10.0,
  //       left: 20.0,
  //       right: 20.0,
  //     ),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.deepOrange.shade400,
  //           Colors.orange.shade600,
  //         ],
  //       ),
  //       borderRadius: const BorderRadius.only(
  //         bottomLeft: Radius.circular(30),
  //         bottomRight: Radius.circular(30),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.deepOrange.withOpacity(0.3),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             InkWell(
  //               onTap: () {
  //                 Get.back();
  //               },
  //               child: Icon(
  //                 Icons.arrow_back_ios_new,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             SizedBox(
  //               width: 10,
  //             ),
  //             const Text(
  //               'JippyMart Catering Service',
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(
  //                 right: 10,
  //               ),
  //               child: const Text(
  //                 'Contact Us ', // Replace with actual user name
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             // WhatsApp Button
  //             Positioned(
  //               bottom: MediaQuery.of(context).padding.bottom +
  //                   120, // Above bottom navigation
  //               right: 16,
  //               child: GestureDetector(
  //                 onTap: () async {
  //                   // WhatsApp number - you can change this to your desired number
  //                   const String phoneNumber =
  //                       '+919390579864'; // Your actual WhatsApp number
  //                   const String message =
  //                       'Hello! I need help with my JippyMart order.'; // Customize the message
  //
  //                   final Uri whatsappUrl = Uri.parse(
  //                       'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
  //
  //                   try {
  //                     if (await canLaunchUrl(whatsappUrl)) {
  //                       await launchUrl(whatsappUrl,
  //                           mode: LaunchMode.externalApplication);
  //                     } else {
  //                       // Fallback to regular phone call if WhatsApp is not available
  //                       final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
  //                       if (await canLaunchUrl(phoneUrl)) {
  //                         await launchUrl(phoneUrl,
  //                             mode: LaunchMode.externalApplication);
  //                       }
  //                     }
  //                   } catch (e) {
  //                     print('Error launching WhatsApp: $e');
  //                   }
  //                 },
  //                 child: Container(
  //                   width: 50,
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     color: Colors.green, // WhatsApp green color
  //                     shape: BoxShape.circle,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.2),
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(0.0),
  //                     child: SvgPicture.asset(
  //                       'assets/images/whatsapp.svg',
  //                       width: 20,
  //                       height: 20,
  //                       colorFilter: const ColorFilter.mode(
  //                         Colors.white,
  //                         BlendMode.srcIn,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTitleSection() {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.deepOrange.withOpacity(0.1),
  //               blurRadius: 10,
  //               offset: const Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           children: [
  //             const Icon(
  //               Icons.restaurant_menu_rounded,
  //               color: Colors.deepOrange,
  //               size: 40,
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'JippyMart Catering Service',
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.deepOrange,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               'Fill the form below to book our premium catering service',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[600],
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            icon,
            color: Colors.deepOrange,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required CategoryServiceController controller,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller.dateController,
        readOnly: true,
        onTap: () {
          controller.selectDate(context: context);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select date';
          }
          return null;
        },
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Date *',
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Colors.deepOrange,
          ),
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.deepOrange,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionTypeDropdown({
    required CategoryServiceController controller,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            value: controller.functionTypeController.text.isEmpty
                ? null
                : controller.functionTypeController.text,
            items: controller.functionTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              controller.dropDownChanger(newValue ?? "");
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select function type';
              }
              return null;
            },
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Type of Function *',
              labelStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.deepOrange, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.celebration_outlined,
                color: Colors.deepOrange,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.deepOrange,
            ),
            dropdownColor: Colors.white,
          ),
        ),

        // Show additional text field when "Other" is selected
        Obx(
          () => controller.isOtherFunctionType.value
              ? _buildOtherFunctionTypeField(controller: controller)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildOtherFunctionTypeField({
    required CategoryServiceController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller.otherFunctionTypeController,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Specify Function Type *',
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.edit_outlined,
            color: Colors.deepOrange,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (controller.isOtherFunctionType.value &&
              (value == null || value.isEmpty)) {
            return 'Please specify the function type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMealPreferenceRadio({
    required CategoryServiceController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meal Preference *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMealOption(
                  value: 'Veg',
                  label: 'Veg',
                  icon: Icons.eco_outlined,
                  controller: controller,
                ),
                _buildMealOption(
                  value: 'Non-Veg',
                  label: 'Non-Veg',
                  icon: Icons.restaurant_outlined,
                  controller: controller,
                ),
                _buildMealOption(
                  value: 'Both',
                  label: 'Both',
                  icon: Icons.auto_awesome_mosaic_outlined,
                  controller: controller,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealOption({
    required String value,
    required String label,
    required IconData icon,
    required CategoryServiceController controller,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.vegChanger(value);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: controller.mealPreference == value
                ? Colors.deepOrange.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: controller.mealPreference == value
                  ? Colors.deepOrange
                  : Colors.grey[300]!,
              width: controller.mealPreference == value ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: controller.mealPreference == value
                    ? Colors.deepOrange
                    : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: controller.mealPreference == value
                      ? Colors.deepOrange
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required CategoryServiceController controller,
    required BuildContext context,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () {
                controller.submitForm(
                    categoryServiceController: controller, context: context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: controller.isLoading
            ? SpinKitWave(
                color: Colors.white, // customize color
                size: 30.0, // customize size
                duration: const Duration(
                  seconds: 1,
                ), // optional speed
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 20),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Submit Catering Request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  void _showWhatsAppOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact via WhatsApp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an option to connect with us',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildWhatsAppOption(
                icon: Icons.chat_outlined,
                title: 'Chat with Support',
                subtitle: 'Get instant help for your queries',
                onTap: () {
                  Navigator.pop(context);
                  // Implement WhatsApp chat functionality
                },
              ),
              const SizedBox(height: 12),
              _buildWhatsAppOption(
                icon: Icons.help_outline,
                title: 'Quick Assistance',
                subtitle: 'Get help with form filling',
                onTap: () {
                  Navigator.pop(context);
                  // Implement WhatsApp assistance functionality
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWhatsAppOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
