import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class WelcomeController extends GetxController {
  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }
}
