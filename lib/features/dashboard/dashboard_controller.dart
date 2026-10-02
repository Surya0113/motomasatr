import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/data/models/garage_owner_model.dart';
import '../../../app/data/models/stats_model.dart';
import '../../../app/routes/app_routes.dart';

import '../reminders/service_reminders_controller.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final Rxn<GarageOwnerModel> garageOwner = Rxn<GarageOwnerModel>();
  final Rx<StatsModel> stats = StatsModel.empty().obs;
  final RxBool isLoading = false.obs;

  // Selected tab index for bottom navigation
  final RxInt selectedIndex = 0.obs;

  // Search Job Cards state
  final RxList<dynamic> jobCards = <dynamic>[].obs;
  final RxList<dynamic> filteredJobCards = <dynamic>[].obs;
  final RxBool isJobCardsLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  // Banners
  final RxList<dynamic> banners = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileAndFetchStats();
  }

  void changeTab(int index) {
    if (index == 2) {
      // Wrench floating button clicked -> navigate to Create JobCard screen
      Get.toNamed(AppRoutes.createJobCard);
      return;
    }
    selectedIndex.value = index;
    if (index == 1) {
      fetchJobCards();
    }
  }

  void _loadProfileAndFetchStats() {
    final cachedUser = _apiService.getUser();
    if (cachedUser != null) {
      garageOwner.value = GarageOwnerModel.fromJson(cachedUser);
      fetchStats();
    } else {
      // Safety redirect to Welcome if session is empty
      _apiService.logout();
    }
  }

  Future<void> fetchStats() async {
    if (garageOwner.value == null) return;
    
    isLoading.value = true;
    try {
      final ownerId = garageOwner.value!.id;

      // Sync the latest profile dynamically from the backend on load/refresh
      try {
        final profileResponse = await _apiService.get(
          '${ApiConstants.garageProfile}/$ownerId',
          showError: false,
        );
        if (profileResponse.data != null && profileResponse.data['success'] == true) {
          final profileData = profileResponse.data['data'];
          garageOwner.value = GarageOwnerModel.fromJson(profileData);
          _apiService.saveUser(profileData); // Update cache so all screens are completely in sync
        }
      } catch (profileErr) {
        debugPrint('Error syncing profile in dashboard: $profileErr');
      }

      final response = await _apiService.get(
        '${ApiConstants.jobCardStats}/$ownerId',
        showError: false,
      );

      if (response.data != null && response.data['success'] == true) {
        final dataMap = response.data['data'];
        stats.value = StatsModel.fromJson(dataMap);
      }

      // Automatically refresh active reminders and their counts from the API too!
      if (Get.isRegistered<ServiceRemindersController>()) {
        Get.find<ServiceRemindersController>().fetchReminders();
      }

      fetchBanners();
    } catch (e) {
      debugPrint('Error fetching job card stats in controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchJobCards() async {
    if (garageOwner.value == null) return;
    
    isJobCardsLoading.value = true;
    try {
      final ownerId = garageOwner.value!.id;
      final response = await _apiService.get(
        '${ApiConstants.jobCardAll}/$ownerId',
        showError: false,
      );

      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        jobCards.value = list;
        performLocalSearch(searchController.text);
      }
    } catch (e) {
      debugPrint('Error fetching job cards in controller: $e');
    } finally {
      isJobCardsLoading.value = false;
    }
  }

  Future<void> fetchBanners() async {
    if (garageOwner.value == null) return;
    try {
      final ownerId = garageOwner.value!.id;
      final response = await _apiService.get(
        '/admin/banners/combined/$ownerId',
        showError: false,
      );
      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        // Only keep banners that have a non-empty imageUrl
        banners.value = list.where((b) {
          final url = b['imageUrl']?.toString() ?? '';
          return url.isNotEmpty;
        }).toList();
        debugPrint('🏷️ Banners loaded: ${banners.length} — ${banners.map((b) => b['imageUrl']).toList()}');
      } else {
        banners.value = [];
      }
    } catch (e) {
      debugPrint('Error fetching banners in controller: $e');
    }
  }

  void performLocalSearch(String query) {
    if (query.isEmpty) {
      filteredJobCards.value = jobCards;
    } else {
      final q = query.toLowerCase();
      filteredJobCards.value = jobCards.where((card) {
        final customerName = (card['customerName'] ?? '').toString().toLowerCase();
        final vehicleNo = (card['vehicleNumber'] ?? '').toString().toLowerCase();
        final customerPhone = (card['customerPhone'] ?? '').toString().toLowerCase();
        final jcNumber = (card['jobCardNumber'] ?? '').toString().toLowerCase();
        return customerName.contains(q) ||
               vehicleNo.contains(q) ||
               customerPhone.contains(q) ||
               jcNumber.contains(q);
      }).toList();
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Motomaster?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _apiService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
