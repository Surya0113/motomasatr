import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';

class ServiceRemindersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxInt selectedTab = 0.obs; // 0: All, 1: Today, 2: Upcoming, 3: Past
  final RxList<dynamic> reminders = <dynamic>[].obs;
  
  // Tab Counts
  final RxInt allCount = 0.obs;
  final RxInt todayCount = 0.obs;
  final RxInt upcomingCount = 0.obs;
  final RxInt pastCount = 0.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReminders();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      String tabParam = 'all';
      switch (selectedTab.value) {
        case 1:
          tabParam = 'today';
          break;
        case 2:
          tabParam = 'upcoming';
          break;
        case 3:
          tabParam = 'past';
          break;
      }

      final response = await _apiService.get('/reminders/$ownerId?tab=$tabParam&limit=100');

      if (response.data != null && response.data['success'] == true) {
        final resData = response.data['data'];
        reminders.value = resData['reminders'] as List<dynamic>;

        // Set counts dynamically from API
        final counts = resData['counts'];
        if (counts != null) {
          allCount.value = counts['all'] ?? 0;
          todayCount.value = counts['today'] ?? 0;
          upcomingCount.value = counts['upcoming'] ?? 0;
          pastCount.value = counts['past'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching reminders in controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    try {
      final response = await _apiService.put('/reminders/$reminderId/dismiss');
      if (response.data != null && response.data['success'] == true) {
        Get.snackbar('Reminder Dismissed', 'Service reminder was dismissed successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.teal,
            colorText: Colors.white);
        fetchReminders();
      }
    } catch (e) {
      debugPrint('Error dismissing reminder: $e');
    }
  }
}
