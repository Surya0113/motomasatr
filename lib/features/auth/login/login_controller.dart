import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/core/theme/app_colors.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void navigateToSignup() {
    Get.offNamed(AppRoutes.signup);
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['garageOwner'];

        // Save session locally
        _apiService.saveToken(token);
        _apiService.saveUser(user);

        // Success snackbar
        Get.snackbar(
          'Welcome Back!',
          'Login successful.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          duration: const Duration(seconds: 2),
        );

        // Route to Dashboard
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'Login Failed',
          response.data['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      // Errors are caught and presented as visual dialogs inside ApiService's Dio interceptor
      debugPrint('Error executing login request: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
