import 'dart:io';

import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController =
      TextEditingController(text: "+91").obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  getData() async {
    try {
      // First try to use the global user model if available
      if (Constant.userModel != null) {
        print(
            '[EDIT_PROFILE] Using global user model: ${Constant.userModel?.toJson()}');
        userModel.value = Constant.userModel!;
      } else {
        print(
            '[EDIT_PROFILE] Global user model is null, fetching from Firestore');
        final value =
            await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
        if (value != null) {
          userModel.value = value;
          // Also update the global user model
          Constant.userModel = value;
          print(
              '[EDIT_PROFILE] Loaded user model from Firestore: ${value.toJson()}');
        } else {
          print('[EDIT_PROFILE] Failed to load user model from Firestore');
        }
      }

      // Set the form fields
      if (userModel.value.id != null) {
        firstNameController.value.text =
            userModel.value.firstName?.toString() ?? "";
        lastNameController.value.text =
            userModel.value.lastName?.toString() ?? "";
        emailController.value.text = userModel.value.email?.toString() ?? "";
        phoneNumberController.value.text =
            userModel.value.phoneNumber?.toString() ?? "";
        countryCodeController.value.text =
            userModel.value.countryCode?.toString() ?? "+91";
        profileImage.value = userModel.value.profilePictureURL ?? "";
        print('[EDIT_PROFILE] Form fields populated successfully');
      } else {
        print('[EDIT_PROFILE] User model is null, cannot populate form fields');
      }
    } catch (e) {
      print('[EDIT_PROFILE] Error loading user data: $e');
    }

    isLoading.value = false;
  }

  saveData(BuildContext context) async {
    if (firstNameController.value.text.isEmpty) {
      // showSnackBar(
      //   "Please enter the first name",
      //   context,
      // );
      ShowToastDialog.showToast("Please enter the first name".tr);
    } else if (lastNameController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter the last name".tr);
      // Get.snackbar(
      //   "Error",
      //   "Please enter the last name",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } else if (emailController.value.text.isEmpty) {
      ShowToastDialog.showToast(
        "Please enter the email".tr,
      );
      // Get.snackbar(
      //   "Error",
      //   "Please enter the email",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } else if (!isValidEmail(emailController.value.text)) {
      ShowToastDialog.showToast(
        "Invalid email format".tr,
      );
    } else {
      ShowToastDialog.showLoader("Please wait".tr);
      if (Constant().hasValidUrl(profileImage.value) == false &&
          profileImage.value.isNotEmpty) {
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          File(profileImage.value).path.split('/').last,
        );
      }
      userModel.value.firstName = firstNameController.value.text;
      userModel.value.lastName = lastNameController.value.text;
      userModel.value.profilePictureURL = profileImage.value;
      userModel.value.phoneNumber = phoneNumberController.value.text;
      userModel.value.countryCode = countryCodeController.value.text;
      userModel.value.email = emailController.value.text;
      await FireStoreUtils.updateUser(userModel.value).then((value) {
        Constant.userModel = userModel.value;
        print(
            '[EDIT_PROFILE] Updated global user model: ${Constant.userModel?.toJson()}');
        ShowToastDialog.closeLoader();
        Get.back(result: true);
      });
      Get.back(result: "profile_updated");
    }
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
