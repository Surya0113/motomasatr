import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/core/theme/app_colors.dart';

class SignupController extends GetxController {
  final ownerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();

  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onClose() {
    ownerNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void navigateToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  // Step 1: Send OTP to Mobile Number
  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    
    try {
      final mobile = mobileController.text.trim();
      final email = emailController.text.trim();

      final response = await _apiService.post(
        ApiConstants.sendOtp,
        data: {
          'mobileNumber': mobile,
          'email': email,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        Get.snackbar(
          'OTP Sent',
          'A 6-digit OTP code has been sent to $email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // Reset OTP input controller and show verification dialog
        otpController.clear();
        _showOtpDialog();
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Step 2: Open OTP Input Dialogue and Register
  void _showOtpDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter Verification Code',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the 6-digit OTP sent to your email address.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit OTP',
                counterText: '',
                prefixIcon: Icon(Icons.security),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : _verifyOtpAndRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: isLoading.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Verify & Register'),
          )),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
      barrierDismissible: false,
    );
  }

  // Step 3: Verify OTP and Register Account
  Future<void> _verifyOtpAndRegister() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Get.snackbar('Invalid OTP', 'Please enter a 6-digit verification code.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final mobile = mobileController.text.trim();
      final name = ownerNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // 1. Verify OTP first
      final verifyResponse = await _apiService.post(
        ApiConstants.verifyOtp,
        data: {
          'mobileNumber': mobile,
          'otp': otp,
          'email': email,
        },
      );

      if (verifyResponse.data != null && verifyResponse.data['success'] == true) {
        // 2. Splitting names
        final nameParts = name.split(' ');
        final firstName = nameParts[0];
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Owner';

        // 3. Register user profile
        final registerResponse = await _apiService.post(
          ApiConstants.register,
          data: {
            'mobileNumber': mobile,
            'workshopName': '$firstName Garage',
            'workshopType': ['2 Wheeler', '4 Wheeler'],
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'address': 'Main Market Road',
            'city': 'Mumbai',
            'state': 'Maharashtra',
            'pincode': '400001',
            'password': password,
            'termsAndConditions': 'true'
          },
        );

        if (registerResponse.data != null && registerResponse.data['success'] == true) {
          final data = registerResponse.data['data'];
          final token = data['token'];
          final user = data['garageOwner'];

          // Save local session
          _apiService.saveToken(token);
          _apiService.saveUser(user);

          // Close OTP dialog
          Get.back();

          // Success notification
          Get.snackbar(
            'Registration Successful',
            'Welcome to GearUp, $firstName!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          );

          // Redirect to Dashboard
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    } catch (e) {
      debugPrint('Error verifying OTP & registering: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
