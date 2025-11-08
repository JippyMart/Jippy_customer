import 'dart:convert';

import 'package:customer/app/category_service/model/category_service_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CategoryServiceController extends GetxController {
  String baseUrl = 'https://jippymart.in/api/catering/';
  @override
  void onInit() {
    super.onInit();
    updateGuestCounts();
  }

  // Modify the dropdown changer method
  void dropDownChanger(String newValue) {
    functionTypeController.text = newValue;
    // Check if "Other" is selected
    if (newValue == 'Other') {
      isOtherFunctionType.value = true;
    } else {
      isOtherFunctionType.value = false;
      otherFunctionTypeController.clear();
    }
    update();
  }

  void vegChanger(String value) {
    mealPreference = value;
    updateGuestCounts();
    update();
  }

  void updateGuestCounts() {
    final guests = int.tryParse(guestsController.text) ?? '';
    if (mealPreference == 'Veg') {
      vegCountController.text = guests.toString();
      nonvegCountController.text = '';
    } else if (mealPreference == 'Non-Veg') {
      vegCountController.text = '';
      nonvegCountController.text = guests.toString();
    }
  }

  void showSnackBarInGustDistribution() {
    Get.snackbar(
      'Error',
      'Veg + Non-Veg must equal total guests',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> selectDate({required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Date',
          ),
          content: SizedBox(
            height: 400,
            width: 400,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: selectedDate,
              minDate: DateTime.now(),
              maxDate: DateTime.now().add(const Duration(days: 365)),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is DateTime) {
                  selectedDate = args.value as DateTime;
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  update();
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void showSuccessDialog(
      {required BuildContext context,
      String message = '',
      void Function()? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: message.isNotEmpty
              ? Text(message)
              : const Text(
                  'Your catering request has been submitted successfully. '
                  'We will contact you shortly to confirm the details.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(
      {required String message, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Update resetForm to clear the new field
  void resetForm() {
    formKey.currentState!.reset();
    selectedDate = DateTime.now();
    mealPreference = 'Veg';
    dateController.clear();
    otherFunctionTypeController.clear();
    isOtherFunctionType.value = false;
    update();
  }

  Future<Map<String, dynamic>> submitCateringRequest(
      CateringRequest request, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );
      print("${json.encode(request.toJson())} submitCateringRequest body ");
      print("${response.body} ${response.statusCode} submitCateringRequest ");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     builder: (context) => VideoSplashScreen(),
        //   ),
        //   (Route<dynamic> route) => false, // condition to stop removing
        // );

        return {
          'success': true,
          'message': 'Catering request submitted successfully!',
          'data': json.decode(response.body)['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to submit request',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check your connection',
      };
    }
  }

  final formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alterMobileNumber = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController functionTypeController = TextEditingController();
  final TextEditingController specialRequirementsController =
      TextEditingController();
  final TextEditingController vegCountController = TextEditingController();
  final TextEditingController nonvegCountController = TextEditingController();
  final TextEditingController otherFunctionTypeController =
      TextEditingController();
  DateTime selectedDate = DateTime.now();
  String mealPreference = 'Veg';
  bool isLoading = false;
  var isOtherFunctionType = false.obs;
  List<String> functionTypes = [
    'Wedding',
    'Birthday Party',
    'Corporate Event',
    'Family Function',
    'Other'
  ];
  // Update the submitForm method to handle "Other" function type
  Future<void> submitForm({
    required CategoryServiceController categoryServiceController,
    required BuildContext context,
  }) async {
    if (!formKey.currentState!.validate()) return;

    // If "Other" is selected, validate the other function type field
    if (isOtherFunctionType.value &&
        (otherFunctionTypeController.text.isEmpty ||
            otherFunctionTypeController.text.trim().isEmpty)) {
      showErrorDialog(
        message: 'Please specify the function type',
        context: context,
      );
      return;
    }

    isLoading = true;
    update();
    try {
      // Use the other function type if "Other" is selected
      String finalFunctionType = isOtherFunctionType.value
          ? otherFunctionTypeController.text
          : functionTypeController.text;

      final request = CateringRequest(
        name: nameController.text,
        mobile: mobileController.text,
        alternativeMobile: alterMobileNumber.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        place: placeController.text,
        date: selectedDate,
        guests: int.parse(guestsController.text),
        functionType: finalFunctionType, // Use the final function type
        mealPreference: mealPreference == "Veg"
            ? "veg"
            : mealPreference == "Non-Veg"
                ? "non_veg"
                : mealPreference == "Both"
                    ? "both"
                    : "veg",
        vegCount: int.parse(vegCountController.text),
        nonvegCount: int.parse(nonvegCountController.text),
        specialRequirements: specialRequirementsController.text.isEmpty
            ? null
            : specialRequirementsController.text,
      );
      final result = await categoryServiceController.submitCateringRequest(
          request, context);
      print("$result final result ");
      if (result['success']) {
        // Success flow
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     builder: (context) => VideoSplashScreen(),
        //   ),
        //   (Route<dynamic> route) => false, // condition to stop removing
        // );
        showSuccessDialog(
            message: result['message'],
            context: context,
            onPressed: () {
              Get.back();
              Get.back();
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(
              //     builder: (context) => VideoSplashScreen(),
              //   ),
              //   (Route<dynamic> route) => false, // condition to stop removing
              // );
            });
        resetForm();
      } else {
        // Error flow
        final errors = result['errors'] as Map<String, dynamic>;
        final errorMessages = errors.values
            .expand((e) => e) // flatten lists
            .join("\n"); // join into a string

        showErrorDialog(
          message: errorMessages,
          context: context,
        );
      }
    } catch (e) {
      showErrorDialog(
        message: 'An unexpected error occurred ',
        context: context,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Future<void> submitForm(
  //     {required CategoryServiceController categoryServiceController,
  //     required BuildContext context}) async {
  //   if (!formKey.currentState!.validate()) return;
  //   isLoading = true;
  //   update();
  //   try {
  //     final request = CateringRequest(
  //       name: nameController.text,
  //       mobile: mobileController.text,
  //       alternativeMobile: alterMobileNumber.text,
  //       email: emailController.text.isEmpty ? null : emailController.text,
  //       place: placeController.text,
  //       date: selectedDate,
  //       guests: int.parse(guestsController.text),
  //       functionType: functionTypeController.text,
  //       mealPreference: mealPreference == "Veg"
  //           ? "veg"
  //           : mealPreference == "Non-Veg"
  //               ? "non_veg"
  //               : mealPreference == "Both"
  //                   ? "both"
  //                   : "veg",
  //       vegCount: int.parse(vegCountController.text),
  //       nonvegCount: int.parse(nonvegCountController.text),
  //       specialRequirements: specialRequirementsController.text.isEmpty
  //           ? null
  //           : specialRequirementsController.text,
  //     );
  //
  //     final result =
  //         await categoryServiceController.submitCateringRequest(request);
  //     if (result['success'] == true) {
  //       showSuccessDialog(context: context);
  //       resetForm();
  //     } else {
  //       showErrorDialog(
  //         message: result['errors'],
  //         context: context,
  //       );
  //     }
  //   } catch (e) {
  //     showErrorDialog(
  //         message: 'An unexpected error occurred', context: context);
  //   } finally {
  //     isLoading = false;
  //     update();
  //   }
  // }
}
