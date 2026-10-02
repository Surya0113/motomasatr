import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/theme/app_colors.dart';

class PaymentQrController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> garageOwner = <String, dynamic>{}.obs;
  final RxList<dynamic> paymentMethods = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGarageProfile();
  }

  Future<void> fetchGarageProfile() async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;
    
    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      final response = await _apiService.get('/garage/profile/$ownerId');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        garageOwner.value = Map<String, dynamic>.from(data);
        paymentMethods.value = List<dynamic>.from(data['paymentMethods'] ?? []);
        
        // Cache the updated user map
        _apiService.saveUser(data);
      } else {
        // Fallback to cached user if response is not successful
        garageOwner.value = cachedUser;
        paymentMethods.value = List<dynamic>.from(cachedUser['paymentMethods'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching garage profile: $e');
      // Fallback
      garageOwner.value = cachedUser;
      paymentMethods.value = List<dynamic>.from(cachedUser['paymentMethods'] ?? []);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPaymentMethod({
    required String label,
    required String bankName,
    required String upiId,
    String? qrCodeImage,
  }) async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;

    try {
      // Create new payment method map
      final newMethod = {
        'label': label.trim(),
        'bankName': bankName.trim(),
        'upiId': upiId.trim(),
        'qrCodeImage': qrCodeImage ?? '',
      };

      // Append to local list copy
      final updatedList = List<dynamic>.from(paymentMethods)..add(newMethod);

      // Save via the general update API
      final response = await _apiService.put(
        '/garage/update/$ownerId',
        data: {
          'paymentMethods': updatedList,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final updatedUser = response.data['data'];
        garageOwner.value = Map<String, dynamic>.from(updatedUser);
        paymentMethods.value = List<dynamic>.from(updatedUser['paymentMethods'] ?? []);
        
        // Save in storage
        _apiService.saveUser(updatedUser);

        Get.snackbar(
          'Success',
          'Payment method added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      }
    } catch (e) {
      debugPrint('Error adding payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePaymentMethod(int index) async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;

    try {
      final updatedList = List<dynamic>.from(paymentMethods)..removeAt(index);

      final response = await _apiService.put(
        '/garage/update/$ownerId',
        data: {
          'paymentMethods': updatedList,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final updatedUser = response.data['data'];
        garageOwner.value = Map<String, dynamic>.from(updatedUser);
        paymentMethods.value = List<dynamic>.from(updatedUser['paymentMethods'] ?? []);
        
        // Save in storage
        _apiService.saveUser(updatedUser);

        Get.snackbar(
          'Removed',
          'Payment method deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.delete_outline, color: Colors.white),
        );
      }
    } catch (e) {
      debugPrint('Error deleting payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
