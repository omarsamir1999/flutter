import 'package:get/get.dart';

class UserDataController extends GetxController {
  int userId;

  UserDataController(this.userId);

  static UserDataController get to => Get.find<UserDataController>();
}
