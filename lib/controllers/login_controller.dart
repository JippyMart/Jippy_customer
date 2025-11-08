
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/services/final_deep_link_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;

  RxBool passwordVisible = true.obs;

  // --- OTP Login Logic (Custom Backend) ---
  Rx<TextEditingController> phoneEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> otpEditingController = TextEditingController().obs;
  RxBool isOtpSent = false.obs;
  RxBool isVerifying = false.obs;
  RxString authToken = ''.obs;
  RxString countryCode = '+91'.obs;
  RxString phoneNumber = ''.obs;

  RxInt resendSeconds = 0.obs;
  bool resendTimerStarted = false;
  void startResendTimer() {
    if (resendTimerStarted) return;
    resendTimerStarted = true;
    resendSeconds.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendSeconds.value--;
      if (resendSeconds.value <= 0) {
        resendTimerStarted = false;
        return false;
      }
      return true;
    });
  }

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void onInit() {
    FireStoreUtils.backendUserId = null;
    // TODO: implement onInit
    super.onInit();
  }

  loginWithEmailAndPassword() async {
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.value.text.trim(),
        password: passwordEditingController.value.text.trim(),
      );
      UserModel? userModel =
      await FireStoreUtils.getUserProfile(credential.user!.uid);
      log("Login :: ${userModel?.toJson()}");
      if (userModel?.role == Constant.userRoleCustomer) {
        if (userModel?.active == true) {
          userModel?.fcmToken = await NotificationService.getToken();
          await FireStoreUtils.updateUser(userModel!);
          if (userModel.shippingAddress != null &&
              userModel.shippingAddress!.isNotEmpty) {
            if (userModel.shippingAddress!
                .where((element) => element.isDefault == true)
                .isNotEmpty) {
              Constant.selectedLocation = userModel.shippingAddress!
                  .where((element) => element.isDefault == true)
                  .single;
            } else {
              Constant.selectedLocation = userModel.shippingAddress!.first;
            }
            // Clear any existing cart data for new user session
            try {
              await DatabaseHelper.instance.deleteAllCartProducts();
              print('DEBUG: Login - Cart cleared for new user session');
            } catch (e) {
              print('DEBUG: Login - Error clearing cart: $e');
            }

            // DashBoardController already registered in main.dart
            Get.offAll(const DashBoardScreen());

            // Process any pending deep links after successful login
            try {
              final deepLinkService = FinalDeepLinkService();
              deepLinkService.processPendingDeepLinkAfterLogin();
              print('🔗 [LOGIN] Processing pending deep link after login...');
            } catch (e) {
              print('❌ [LOGIN] Error processing pending deep link: $e');
            }
          } else {
            Get.offAll(const LocationPermissionScreen());
          }
        } else {
          await FirebaseAuth.instance.signOut();
          ShowToastDialog.showToast(
              "This user is disable please contact to administrator".tr);
        }
      } else {
        await FirebaseAuth.instance.signOut();
        // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        ShowToastDialog.showToast("No user found for that email.".tr);
      } else if (e.code == 'wrong-password') {
        ShowToastDialog.showToast("Wrong password provided for that user.".tr);
      } else if (e.code == 'invalid-email') {
        ShowToastDialog.showToast("Invalid Email.");
      } else {
        ShowToastDialog.showToast("${e.message}");
      }
    }
    ShowToastDialog.closeLoader();
  }

  loginWithGoogle() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithGoogle().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.firstName = value.user!.displayName?.split(' ').first;
          userModel.lastName = value.user!.displayName?.split(' ').last;
          userModel.provider = 'google';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "google",
          });
        } else {
          await FireStoreUtils.userExistOrNot(value.user!.uid)
              .then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel =
              await FireStoreUtils.getUserProfile(value.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null &&
                      userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!
                        .where((element) => element.isDefault == true)
                        .isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!
                          .where((element) => element.isDefault == true)
                          .single;
                    } else {
                      Constant.selectedLocation =
                          userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast(
                      "This user is disable please contact to administrator"
                          .tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.firstName = value.user!.displayName?.split(' ').first;
              userModel.lastName = value.user!.displayName?.split(' ').last;
              userModel.provider = 'google';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "google",
              });
            }
          });
        }
      }
    });
  }

  loginWithApple() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithApple().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];
        if (userCredential.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = userCredential.user!.uid;
          userModel.email = appleCredential.email;
          userModel.firstName = appleCredential.givenName;
          userModel.lastName = appleCredential.familyName;
          userModel.provider = 'apple';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "apple",
          });
        } else {
          await FireStoreUtils.userExistOrNot(userCredential.user!.uid)
              .then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel =
              await FireStoreUtils.getUserProfile(userCredential.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null &&
                      userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!
                        .where((element) => element.isDefault == true)
                        .isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!
                          .where((element) => element.isDefault == true)
                          .single;
                    } else {
                      Constant.selectedLocation =
                          userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast(
                      "This user is disable please contact to administrator"
                          .tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = userCredential.user!.uid;
              userModel.email = appleCredential.email;
              userModel.firstName = appleCredential.givenName;
              userModel.lastName = appleCredential.familyName;
              userModel.provider = 'apple';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "apple",
              });
            }
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn with scopes for v6.2.1
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign in using the correct API
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("something_went_wrong".tr);
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential using the correct API
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {
        "appleCredential": appleCredential,
        "userCredential": userCredential
      };
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> sendOtp() async {
    print(
        '[DEBUG] sendOtp() error:  ${phoneEditingController.value.text.trim()}');
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      phoneNumber.value = phoneEditingController.value.text.trim();

      final response = await http.post(
        Uri.parse('https://jippymart.in/api/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneEditingController.value.text.trim()}),
      );

      print(
          '[DEBUG] sendOtp() response: ${response.statusCode} ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        isOtpSent.value = true;
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("OTP sent successfully".tr);
        Get.to(() => OtpScreen());
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            responseData['message'] ?? "Failed to send OTP".tr);
      }
    } catch (e) {
      print('[DEBUG] sendOtp() error: ${e.toString()}');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error sending OTP".tr);
    }
  }

  /// Call this after OTP is verified by your backend
  Future<void> handleOtpLogin({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    print('[DEBUG] handleOtpLogin: phone=$countryCode$phoneNumber, otp=$otp');
    await loginWithCustomToken(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      otp: otp,
    );
  }

  Future<void> verifyOtp(BuildContext context) async {
    print(
        '[DEBUG] verifyOtp() called with phone: ${phoneEditingController.value.text.trim()}, otp: ${otpEditingController.value.text.trim()}');
    ShowToastDialog.showLoader("Verifying OTP...".tr);
    isVerifying.value = true;
    try {
      final response = await http.post(
        Uri.parse('https://jippymart.in/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneEditingController.value.text.trim(),
          'otp': otpEditingController.value.text.trim(),
        }),
      );

      print(
          '[DEBUG] verifyOtp() response: ${response.statusCode} ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        authToken.value = responseData['token'] ?? '';
        await secureStorage.write(key: 'api_token', value: authToken.value);
        if (responseData['firebase_custom_token'] != null) {
          await FirebaseAuth.instance
              .signInWithCustomToken(responseData['firebase_custom_token']);
        }
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          print('[DEBUG] Firebase sign-in failed, forcing logout');
          await FirebaseAuth.instance.signOut();
          FireStoreUtils.backendUserId = null;
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast('Login failed, please try again.');
          Get.offAllNamed('/LoginScreen');
          return;
        }
        if (responseData['user'] != null &&
            responseData['user']['id'] != null) {
          FireStoreUtils.backendUserId = responseData['user']['id'].toString();
        }
        // Check Firestore for user profile by phone number
        final phone = phoneEditingController.value.text.trim();
        UserModel? userModel = await FireStoreUtils.getUserByPhoneNumber(phone);
        if (userModel == null ||
            userModel.active != true ||
            userModel.role?.toLowerCase() !=
                Constant.userRoleCustomer.toLowerCase()) {
          // User not found, inactive, or not customer
          UserModel newUser = UserModel();
          newUser.phoneNumber = phone;
          newUser.countryCode = countryCode.value;
          newUser.email = responseData['user']?['email']?.toString();
          ShowToastDialog.closeLoader();
          Get.offAll(() => SignupScreen(),
              arguments: {"userModel": newUser, "type": "mobileNumber"});
          print(" user not exited ");
          return;
        }
        if ((userModel.firstName == null || userModel.firstName!.isEmpty) ||
            (userModel.email == null || userModel.email!.isEmpty)) {
          // Profile incomplete
          ShowToastDialog.closeLoader();
          Get.offAll(() => SignupScreen(),
              arguments: {"userModel": userModel, "type": "mobileNumber"});
          return;
        }

        // ✅ UPDATED FCM TOKEN HANDLING SECTION - PLACE THIS CODE HERE
        String? fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          userModel.fcmToken = fcmToken;
          await FireStoreUtils.updateUser(userModel);
          log('DEBUG: FCM token updated successfully');
        } else {
          // Update user without FCM token - don't fail the login
          await FireStoreUtils.updateUser(userModel);
          log('DEBUG: User updated without FCM token - push notifications unavailable');
        }

        // Profile exists and complete
        Constant.userModel = userModel;
        if (userModel.shippingAddress != null &&
            userModel.shippingAddress!.isNotEmpty) {
          if (userModel.shippingAddress!
              .where((element) => element.isDefault == true)
              .isNotEmpty) {
            Constant.selectedLocation = userModel.shippingAddress!
                .where((element) => element.isDefault == true)
                .single;
          } else {
            Constant.selectedLocation = userModel.shippingAddress!.first;
          }
        }
        ShowToastDialog.closeLoader();
        Get.offAll(() => const DashBoardScreen());
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            responseData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      print('[DEBUG] verifyOtp() error: ${e.toString()}');
      ShowToastDialog.closeLoader();

      // Enhanced error handling with more specific messages
      if (e is http.ClientException) {
        ShowToastDialog.showToast(
            "Network error occurred. Please check your connection and try again.");
      } else {
        ShowToastDialog.showToast("Error verifying OTP. Please try again.");
      }
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendOtp() async {
    print(
        '[DEBUG] resendOtp() called with phone: ${phoneEditingController.value.text.trim()}');
    ShowToastDialog.showLoader("Resending OTP...".tr);
    try {
      final response = await http.post(
        Uri.parse('https://jippymart.in/api/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneEditingController.value.text.trim()}),
      );

      print(
          '[DEBUG] resendOtp() response: ${response.statusCode} ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("OTP resent successfully".tr);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            responseData['message'] ?? "Failed to resend OTP".tr);
      }
    } catch (e) {
      print('[DEBUG] resendOtp() error: ${e.toString()}');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error resending OTP".tr);
    }
  }

  /// Custom Token Login Flow (for custom SMS/OTP backend)
  Future<void> loginWithCustomToken({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    ShowToastDialog.showLoader("Please wait");
    try {
      // 1. Call your backend to verify OTP and get custom token
      final response = await http.post(
        Uri.parse('https://your-backend.com/generateCustomToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'countryCode': countryCode,
          'otp': otp,
        }),
      );
      if (response.statusCode != 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Failed to get custom token: \n${response.body}');
        return;
      }
      final data = jsonDecode(response.body);
      final customToken = data['customToken'];
      final uid = data['uid'];

      // 2. Sign in with custom token
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      // 3. Check if user exists in Firestore
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      UserModel? userModel;
      if (userDoc.exists) {
        // Existing user: load from Firestore using your model
        userModel = UserModel.fromJson(userDoc.data()!);
        // Proceed to dashboard or wherever needed
        Get.offAll(() => DashBoardScreen());
      } else {
        // New user: create Firestore user document using your model
        userModel = UserModel(
          id: uid,
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          createdAt: Timestamp.now(),
          active: true,
          isActive: true,
          role: 'customer',
          walletAmount: 0,
          isDocumentVerify: false,
          appIdentifier: 'android', // or 'ios'
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userModel.toJson());
        // Proceed to registration flow or dashboard
        Get.offAll(() => SignupScreen(), arguments: {
          "userModel": userModel,
          "type": "mobileNumber",
        });
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Login failed: \n$e');
    }
    ShowToastDialog.closeLoader();
  }

  Future<void> logout() async {
    // Clear cart data before logout
    print('DEBUG: LoginController logout - Starting cart clearing process');
    try {
      if (Get.isRegistered<CartController>()) {
        print(
            'DEBUG: LoginController logout - CartController found, clearing cart');
        final cartController = Get.find<CartController>();
        await cartController.clearCart();
        print('DEBUG: LoginController logout - Cart cleared successfully');
      } else {
        print('DEBUG: LoginController logout - CartController not registered');
      }
    } catch (e) {
      print('DEBUG: LoginController logout - Error clearing cart: $e');
    }

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    // Remove API token from secure storage
    await secureStorage.delete(key: 'api_token');
    // Optionally clear any other user-related state here
    // Navigate to login screen
    Get.offAllNamed('/LoginScreen');
  }
}

// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:crypto/crypto.dart';
// import 'package:customer/app/auth_screen/otp_screen.dart';
// import 'package:customer/app/auth_screen/signup_screen.dart';
// import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
// import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
// import 'package:customer/constant/constant.dart';
// import 'package:customer/constant/show_toast_dialog.dart';
// import 'package:customer/controllers/cart_controller.dart';
// import 'package:customer/models/user_model.dart';
// import 'package:customer/services/database_helper.dart';
// import 'package:customer/services/final_deep_link_service.dart';
// import 'package:customer/utils/fire_store_utils.dart';
// import 'package:customer/utils/notification_service.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//
// class LoginController extends GetxController {
//   Rx<TextEditingController> emailEditingController =
//       TextEditingController().obs;
//   Rx<TextEditingController> passwordEditingController =
//       TextEditingController().obs;
//
//   RxBool passwordVisible = true.obs;
//
//   // --- OTP Login Logic (Custom Backend) ---
//   Rx<TextEditingController> phoneEditingController =
//       TextEditingController().obs;
//   Rx<TextEditingController> otpEditingController = TextEditingController().obs;
//   RxBool isOtpSent = false.obs;
//   RxBool isVerifying = false.obs;
//   RxString authToken = ''.obs;
//   RxString countryCode = '+91'.obs;
//   RxString phoneNumber = ''.obs;
//
//   RxInt resendSeconds = 0.obs;
//   bool resendTimerStarted = false;
//   void startResendTimer() {
//     if (resendTimerStarted) return;
//     resendTimerStarted = true;
//     resendSeconds.value = 60;
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 1));
//       resendSeconds.value--;
//       if (resendSeconds.value <= 0) {
//         resendTimerStarted = false;
//         return false;
//       }
//       return true;
//     });
//   }
//
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//
//   @override
//   void onInit() {
//     FireStoreUtils.backendUserId = null;
//     // TODO: implement onInit
//     super.onInit();
//   }
//
//   loginWithEmailAndPassword() async {
//     ShowToastDialog.showLoader("Please wait".tr);
//     try {
//       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailEditingController.value.text.trim(),
//         password: passwordEditingController.value.text.trim(),
//       );
//       UserModel? userModel =
//           await FireStoreUtils.getUserProfile(credential.user!.uid);
//       log("Login :: ${userModel?.toJson()}");
//       if (userModel?.role == Constant.userRoleCustomer) {
//         if (userModel?.active == true) {
//           userModel?.fcmToken = await NotificationService.getToken();
//           await FireStoreUtils.updateUser(userModel!);
//           if (userModel.shippingAddress != null &&
//               userModel.shippingAddress!.isNotEmpty) {
//             if (userModel.shippingAddress!
//                 .where((element) => element.isDefault == true)
//                 .isNotEmpty) {
//               Constant.selectedLocation = userModel.shippingAddress!
//                   .where((element) => element.isDefault == true)
//                   .single;
//             } else {
//               Constant.selectedLocation = userModel.shippingAddress!.first;
//             }
//             // Clear any existing cart data for new user session
//             try {
//               await DatabaseHelper.instance.deleteAllCartProducts();
//               print('DEBUG: Login - Cart cleared for new user session');
//             } catch (e) {
//               print('DEBUG: Login - Error clearing cart: $e');
//             }
//
//             // DashBoardController already registered in main.dart
//             Get.offAll(const DashBoardScreen());
//
//             // Process any pending deep links after successful login
//             try {
//               final deepLinkService = FinalDeepLinkService();
//               deepLinkService.processPendingDeepLinkAfterLogin();
//               print('🔗 [LOGIN] Processing pending deep link after login...');
//             } catch (e) {
//               print('❌ [LOGIN] Error processing pending deep link: $e');
//             }
//           } else {
//             Get.offAll(const LocationPermissionScreen());
//           }
//         } else {
//           await FirebaseAuth.instance.signOut();
//           ShowToastDialog.showToast(
//               "This user is disable please contact to administrator".tr);
//         }
//       } else {
//         await FirebaseAuth.instance.signOut();
//         // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
//       }
//     } on FirebaseAuthException catch (e) {
//       print(e.code);
//       if (e.code == 'user-not-found') {
//         ShowToastDialog.showToast("No user found for that email.".tr);
//       } else if (e.code == 'wrong-password') {
//         ShowToastDialog.showToast("Wrong password provided for that user.".tr);
//       } else if (e.code == 'invalid-email') {
//         ShowToastDialog.showToast("Invalid Email.");
//       } else {
//         ShowToastDialog.showToast("${e.message}");
//       }
//     }
//     ShowToastDialog.closeLoader();
//   }
//
//   loginWithGoogle() async {
//     ShowToastDialog.showLoader("please wait...".tr);
//     await signInWithGoogle().then((value) async {
//       ShowToastDialog.closeLoader();
//       if (value != null) {
//         if (value.additionalUserInfo!.isNewUser) {
//           UserModel userModel = UserModel();
//           userModel.id = value.user!.uid;
//           userModel.email = value.user!.email;
//           userModel.firstName = value.user!.displayName?.split(' ').first;
//           userModel.lastName = value.user!.displayName?.split(' ').last;
//           userModel.provider = 'google';
//
//           ShowToastDialog.closeLoader();
//           Get.off(const SignupScreen(), arguments: {
//             "userModel": userModel,
//             "type": "google",
//           });
//         } else {
//           await FireStoreUtils.userExistOrNot(value.user!.uid)
//               .then((userExit) async {
//             ShowToastDialog.closeLoader();
//             if (userExit == true) {
//               UserModel? userModel =
//                   await FireStoreUtils.getUserProfile(value.user!.uid);
//               if (userModel!.role == Constant.userRoleCustomer) {
//                 if (userModel.active == true) {
//                   userModel.fcmToken = await NotificationService.getToken();
//                   await FireStoreUtils.updateUser(userModel);
//                   if (userModel.shippingAddress != null &&
//                       userModel.shippingAddress!.isNotEmpty) {
//                     if (userModel.shippingAddress!
//                         .where((element) => element.isDefault == true)
//                         .isNotEmpty) {
//                       Constant.selectedLocation = userModel.shippingAddress!
//                           .where((element) => element.isDefault == true)
//                           .single;
//                     } else {
//                       Constant.selectedLocation =
//                           userModel.shippingAddress!.first;
//                     }
//                     Get.offAll(const DashBoardScreen());
//                   } else {
//                     Get.offAll(const LocationPermissionScreen());
//                   }
//                 } else {
//                   await FirebaseAuth.instance.signOut();
//                   ShowToastDialog.showToast(
//                       "This user is disable please contact to administrator"
//                           .tr);
//                 }
//               } else {
//                 await FirebaseAuth.instance.signOut();
//                 // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
//               }
//             } else {
//               UserModel userModel = UserModel();
//               userModel.id = value.user!.uid;
//               userModel.email = value.user!.email;
//               userModel.firstName = value.user!.displayName?.split(' ').first;
//               userModel.lastName = value.user!.displayName?.split(' ').last;
//               userModel.provider = 'google';
//
//               Get.off(const SignupScreen(), arguments: {
//                 "userModel": userModel,
//                 "type": "google",
//               });
//             }
//           });
//         }
//       }
//     });
//   }
//
//   loginWithApple() async {
//     ShowToastDialog.showLoader("please wait...".tr);
//     await signInWithApple().then((value) async {
//       ShowToastDialog.closeLoader();
//       if (value != null) {
//         Map<String, dynamic> map = value;
//         AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
//         UserCredential userCredential = map['userCredential'];
//         if (userCredential.additionalUserInfo!.isNewUser) {
//           UserModel userModel = UserModel();
//           userModel.id = userCredential.user!.uid;
//           userModel.email = appleCredential.email;
//           userModel.firstName = appleCredential.givenName;
//           userModel.lastName = appleCredential.familyName;
//           userModel.provider = 'apple';
//
//           ShowToastDialog.closeLoader();
//           Get.off(const SignupScreen(), arguments: {
//             "userModel": userModel,
//             "type": "apple",
//           });
//         } else {
//           await FireStoreUtils.userExistOrNot(userCredential.user!.uid)
//               .then((userExit) async {
//             ShowToastDialog.closeLoader();
//             if (userExit == true) {
//               UserModel? userModel =
//                   await FireStoreUtils.getUserProfile(userCredential.user!.uid);
//               if (userModel!.role == Constant.userRoleCustomer) {
//                 if (userModel.active == true) {
//                   userModel.fcmToken = await NotificationService.getToken();
//                   await FireStoreUtils.updateUser(userModel);
//                   if (userModel.shippingAddress != null &&
//                       userModel.shippingAddress!.isNotEmpty) {
//                     if (userModel.shippingAddress!
//                         .where((element) => element.isDefault == true)
//                         .isNotEmpty) {
//                       Constant.selectedLocation = userModel.shippingAddress!
//                           .where((element) => element.isDefault == true)
//                           .single;
//                     } else {
//                       Constant.selectedLocation =
//                           userModel.shippingAddress!.first;
//                     }
//                     Get.offAll(const DashBoardScreen());
//                   } else {
//                     Get.offAll(const LocationPermissionScreen());
//                   }
//                 } else {
//                   await FirebaseAuth.instance.signOut();
//                   ShowToastDialog.showToast(
//                       "This user is disable please contact to administrator"
//                           .tr);
//                 }
//               } else {
//                 await FirebaseAuth.instance.signOut();
//                 // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
//               }
//             } else {
//               UserModel userModel = UserModel();
//               userModel.id = userCredential.user!.uid;
//               userModel.email = appleCredential.email;
//               userModel.firstName = appleCredential.givenName;
//               userModel.lastName = appleCredential.familyName;
//               userModel.provider = 'apple';
//
//               Get.off(const SignupScreen(), arguments: {
//                 "userModel": userModel,
//                 "type": "apple",
//               });
//             }
//           });
//         }
//       }
//     });
//   }
//
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Initialize GoogleSignIn with scopes for v6.2.1
//       final GoogleSignIn googleSignIn = GoogleSignIn(
//         scopes: ['email', 'profile'],
//       );
//
//       // Sign in using the correct API
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//
//       if (googleUser == null) {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast("something_went_wrong".tr);
//         return null;
//       }
//
//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//
//       // Create a new credential using the correct API
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Once signed in, return the UserCredential
//       return await FirebaseAuth.instance.signInWithCredential(credential);
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   String sha256ofString(String input) {
//     final bytes = utf8.encode(input);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }
//
//   Future<Map<String, dynamic>?> signInWithApple() async {
//     try {
//       final rawNonce = generateNonce();
//       final nonce = sha256ofString(rawNonce);
//
//       // Request credential for the currently signed in Apple account.
//       AuthorizationCredentialAppleID appleCredential =
//           await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         nonce: nonce,
//         // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
//       );
//
//       // Create an `OAuthCredential` from the credential returned by Apple.
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: appleCredential.identityToken,
//         rawNonce: rawNonce,
//         accessToken: appleCredential.authorizationCode,
//       );
//
//       // Sign in the user with Firebase. If the nonce we generated earlier does
//       // not match the nonce in `appleCredential.identityToken`, sign in will fail.
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//       return {
//         "appleCredential": appleCredential,
//         "userCredential": userCredential
//       };
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }
//
//   // --- Deprecated: Firebase Phone Auth (replaced by custom backend OTP API) ---
//   // The following code is commented out as we now use our own backend for OTP verification.
//   //
//   // Example:
//   // await FirebaseAuth.instance.verifyPhoneNumber(
//   //   phoneNumber: phoneNumber,
//   //   verificationCompleted: (PhoneAuthCredential credential) async {
//   //     await FirebaseAuth.instance.signInWithCredential(credential);
//   //   },
//   //   verificationFailed: (FirebaseAuthException e) {
//   //     // Handle error
//   //   },
//   //   codeSent: (String verificationId, int? resendToken) {
//   //     // Save verificationId for later use
//   //   },
//   //   codeAutoRetrievalTimeout: (String verificationId) {},
//   // );
//   //
//   // To verify OTP:
//   // PhoneAuthCredential credential = PhoneAuthProvider.credential(
//   //   verificationId: verificationId,
//   //   smsCode: otp,
//   // );
//   // await FirebaseAuth.instance.signInWithCredential(credential);
//
//   Future<void> sendOtp() async {
//     print(
//         '[DEBUG] sendOtp() error:  ${phoneEditingController.value.text.trim()}');
//     ShowToastDialog.showLoader("Please wait".tr);
//     try {
//       phoneNumber.value = phoneEditingController.value.text.trim();
//       final response = await Dio().post(
//         'https://jippymart.in/api/send-otp',
//         data: {'phone': phoneEditingController.value.text.trim()},
//       );
//       print(
//           '[DEBUG] sendOtp() response: ${response.statusCode} ${response.data}');
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         isOtpSent.value = true;
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast("OTP sent successfully".tr);
//         Get.to(() => OtpScreen());
//       } else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             response.data['message'] ?? "Failed to send OTP".tr);
//       }
//     } catch (e) {
//       print('[DEBUG] sendOtp() error: ${e.toString()}');
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast("Error sending OTP".tr);
//     }
//   }
//
//   /// Call this after OTP is verified by your backend
//   Future<void> handleOtpLogin({
//     required String phoneNumber,
//     required String countryCode,
//     required String otp,
//   }) async {
//     print('[DEBUG] handleOtpLogin: phone=$countryCode$phoneNumber, otp=$otp');
//     await loginWithCustomToken(
//       phoneNumber: phoneNumber,
//       countryCode: countryCode,
//       otp: otp,
//     );
//   }
//
//   Future<void> verifyOtp(BuildContext context) async {
//     print(
//         '[DEBUG] verifyOtp() called with phone: ${phoneEditingController.value.text.trim()}, otp: ${otpEditingController.value.text.trim()}');
//     ShowToastDialog.showLoader("Verifying OTP...".tr);
//     isVerifying.value = true;
//     try {
//       final response = await Dio().post(
//         'https://jippymart.in/api/verify-otp',
//         data: {
//           'phone': phoneEditingController.value.text.trim(),
//           'otp': otpEditingController.value.text.trim(),
//         },
//       );
//       // final response = await Dio().post(
//       //   'https://jippymart.in/api/verify-otp',
//       //   data: {
//       //     'phone': phoneEditingController.value.text.trim(),
//       //     'otp': otpEditingController.value.text.trim(),
//       //   },
//       //   options: Options(
//       //     headers: {'Accept': 'application/json'},
//       //   ),
//       // );
//       print(
//           '[DEBUG] verifyOtp() response: ${response.statusCode} ${response.data}');
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         authToken.value = response.data['token'] ?? '';
//         await secureStorage.write(key: 'api_token', value: authToken.value);
//         if (response.data['firebase_custom_token'] != null) {
//           await FirebaseAuth.instance
//               .signInWithCustomToken(response.data['firebase_custom_token']);
//         }
//         final firebaseUser = FirebaseAuth.instance.currentUser;
//         if (firebaseUser == null) {
//           print('[DEBUG] Firebase sign-in failed, forcing logout');
//           await FirebaseAuth.instance.signOut();
//           FireStoreUtils.backendUserId = null;
//           ShowToastDialog.closeLoader();
//           ShowToastDialog.showToast('Login failed, please try again.');
//           Get.offAllNamed('/LoginScreen');
//           return;
//         }
//         if (response.data['user'] != null &&
//             response.data['user']['id'] != null) {
//           FireStoreUtils.backendUserId = response.data['user']['id'].toString();
//         }
//         // Check Firestore for user profile by phone number
//         final phone = phoneEditingController.value.text.trim();
//         UserModel? userModel = await FireStoreUtils.getUserByPhoneNumber(phone);
//         if (userModel == null ||
//             userModel.active != true ||
//             userModel.role?.toLowerCase() !=
//                 Constant.userRoleCustomer.toLowerCase()) {
//           // if (userModel?.role?.toLowerCase() == 'customer') {
//           // User not found, inactive, or not customer
//           UserModel newUser = UserModel();
//           newUser.phoneNumber = phone;
//           newUser.countryCode = countryCode.value;
//           newUser.email = response.data['user']?['email']?.toString();
//           ShowToastDialog.closeLoader();
//           Get.offAll(() => SignupScreen(),
//               arguments: {"userModel": newUser, "type": "mobileNumber"});
//           print(" user not exited ");
//           return;
//           // } else {
//           //   print('[DEBUG] Firebase sign-in failed, forcing logout');
//           //
//           //   await FirebaseAuth.instance.signOut();
//           //   FireStoreUtils.backendUserId = null;
//           //   ShowToastDialog.closeLoader();
//           //   ShowToastDialog.showToast(
//           //     "${userModel?.role?.toUpperCase()} Account Already Exited",
//           //   );
//           //   Get.offAll(
//           //     () => const PhoneNumberScreen(),
//           //     transition: Transition.fadeIn,
//           //     duration: const Duration(milliseconds: 1200),
//           //   );
//           //   return;
//           // }
//         }
//         if ((userModel.firstName == null || userModel.firstName!.isEmpty) ||
//             (userModel.email == null || userModel.email!.isEmpty)) {
//           // Profile incomplete
//           ShowToastDialog.closeLoader();
//           Get.offAll(() => SignupScreen(),
//               arguments: {"userModel": userModel, "type": "mobileNumber"});
//           return;
//         }
//         // Profile exists and complete
//         userModel.fcmToken = await NotificationService.getToken();
//         await FireStoreUtils.updateUser(userModel);
//         Constant.userModel = userModel;
//         if (userModel.shippingAddress != null &&
//             userModel.shippingAddress!.isNotEmpty) {
//           if (userModel.shippingAddress!
//               .where((element) => element.isDefault == true)
//               .isNotEmpty) {
//             Constant.selectedLocation = userModel.shippingAddress!
//                 .where((element) => element.isDefault == true)
//                 .single;
//           } else {
//             Constant.selectedLocation = userModel.shippingAddress!.first;
//           }
//         }
//         ShowToastDialog.closeLoader();
//         Get.offAll(() => const DashBoardScreen());
//       } else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             response.data['message'] ?? 'OTP verification failed');
//       }
//     } catch (e) {
//       print('[DEBUG] verifyOtp() error: ${e.toString()}');
//       ShowToastDialog.closeLoader();
//
//       // Enhanced error handling with more specific messages
//       if (e is DioException) {
//         if (e.response != null) {
//           print(
//               '[DEBUG] API Error Response: ${e.response?.statusCode} - ${e.response?.data}');
//           String errorMessage =
//               e.response?.data?['message'] ?? 'Server error occurred';
//           ShowToastDialog.showToast("Error: $errorMessage");
//         } else if (e.type == DioExceptionType.connectionTimeout ||
//             e.type == DioExceptionType.receiveTimeout) {
//           ShowToastDialog.showToast(
//               "Connection timeout. Please check your internet connection.");
//         } else if (e.type == DioExceptionType.connectionError) {
//           ShowToastDialog.showToast(
//               "No internet connection. Please check your network.");
//         } else {
//           ShowToastDialog.showToast(
//               "Network error occurred. Please try again.");
//         }
//       } else {
//         ShowToastDialog.showToast("Error verifying OTP. Please try again.");
//       }
//     } finally {
//       isVerifying.value = false;
//     }
//   }
//
//   Future<void> resendOtp() async {
//     print(
//         '[DEBUG] resendOtp() called with phone: ${phoneEditingController.value.text.trim()}');
//     ShowToastDialog.showLoader("Resending OTP...".tr);
//     try {
//       final response = await Dio().post(
//         'https://jippymart.in/api/resend-otp',
//         data: {'phone': phoneEditingController.value.text.trim()},
//       );
//       print(
//           '[DEBUG] resendOtp() response: ${response.statusCode} ${response.data}');
//       if (response.statusCode == 200 && response.data['success'] == true) {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast("OTP resent successfully".tr);
//       } else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             response.data['message'] ?? "Failed to resend OTP".tr);
//       }
//     } catch (e) {
//       print('[DEBUG] resendOtp() error: ${e.toString()}');
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast("Error resending OTP".tr);
//     }
//   }
//
//   /// Custom Token Login Flow (for custom SMS/OTP backend)
//   Future<void> loginWithCustomToken({
//     required String phoneNumber,
//     required String countryCode,
//     required String otp,
//   }) async {
//     ShowToastDialog.showLoader("Please wait");
//     try {
//       // 1. Call your backend to verify OTP and get custom token
//       final response = await http.post(
//         Uri.parse('https://your-backend.com/generateCustomToken'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'phoneNumber': phoneNumber,
//           'countryCode': countryCode,
//           'otp': otp,
//         }),
//       );
//       if (response.statusCode != 200) {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             'Failed to get custom token: \n${response.body}');
//         return;
//       }
//       final data = jsonDecode(response.body);
//       final customToken = data['customToken'];
//       final uid = data['uid'];
//
//       // 2. Sign in with custom token
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCustomToken(customToken);
//
//       // 3. Check if user exists in Firestore
//       final userDoc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//
//       UserModel? userModel;
//       if (userDoc.exists) {
//         // Existing user: load from Firestore using your model
//         userModel = UserModel.fromJson(userDoc.data()!);
//         // Proceed to dashboard or wherever needed
//         Get.offAll(() => DashBoardScreen());
//       } else {
//         // New user: create Firestore user document using your model
//         userModel = UserModel(
//           id: uid,
//           phoneNumber: phoneNumber,
//           countryCode: countryCode,
//           createdAt: Timestamp.now(),
//           active: true,
//           isActive: true,
//           role: 'customer',
//           walletAmount: 0,
//           isDocumentVerify: false,
//           appIdentifier: 'android', // or 'ios'
//         );
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .set(userModel.toJson());
//         // Proceed to registration flow or dashboard
//         Get.offAll(() => SignupScreen(), arguments: {
//           "userModel": userModel,
//           "type": "mobileNumber",
//         });
//       }
//     } catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast('Login failed: \n$e');
//     }
//     ShowToastDialog.closeLoader();
//   }
//
//   Future<void> logout() async {
//     // Clear cart data before logout
//     print('DEBUG: LoginController logout - Starting cart clearing process');
//     try {
//       if (Get.isRegistered<CartController>()) {
//         print(
//             'DEBUG: LoginController logout - CartController found, clearing cart');
//         final cartController = Get.find<CartController>();
//         await cartController.clearCart();
//         print('DEBUG: LoginController logout - Cart cleared successfully');
//       } else {
//         print('DEBUG: LoginController logout - CartController not registered');
//       }
//     } catch (e) {
//       print('DEBUG: LoginController logout - Error clearing cart: $e');
//     }
//
//     // Sign out from Firebase
//     await FirebaseAuth.instance.signOut();
//     // Remove API token from secure storage
//     await secureStorage.delete(key: 'api_token');
//     // Optionally clear any other user-related state here
//     // Navigate to login screen
//     Get.offAllNamed('/LoginScreen');
//   }
// }
