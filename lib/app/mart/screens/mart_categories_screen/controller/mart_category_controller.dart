import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/services/mart_firestore_service.dart';

class MartCategoryController extends GetxController {



  final MartFirestoreService _firestoreService =
  Get.find<MartFirestoreService>();
  List<MartCategoryModel> martCategories = [];
 Future<void> loadCategories()async{
     martCategories = await _firestoreService.getCategories(limit: 100);
     update();
  }

  @override
  void onInit() {
    loadCategories();
    super.onInit();
  }


}