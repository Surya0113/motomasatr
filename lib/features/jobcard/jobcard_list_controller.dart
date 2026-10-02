import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/job_card_status_dialog.dart';
import '../../../app/data/services/api_service.dart';
import '../dashboard/dashboard_controller.dart';
import '../../../app/core/theme/app_colors.dart';

class JobCardListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxList<dynamic> jobCardsList = <dynamic>[].obs;
  final RxList<dynamic> filteredJobCards = <dynamic>[].obs;

  // Search & Filters
  final searchController = TextEditingController();
  final RxString selectedStatusFilter = 'all'.obs; // 'all', 'in-progress', 'completed', 'closed'

  // Balance Pending List
  final RxList<dynamic> pendingBalanceCards = <dynamic>[].obs;
  final RxDouble totalPendingBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Set initial filter based on route parameters if any
    final String? statusArg = Get.arguments as String?;
    if (statusArg != null && ['all', 'in-progress', 'completed', 'closed'].contains(statusArg)) {
      selectedStatusFilter.value = statusArg;
    }

    fetchJobCards();
    fetchBalancePendingCards();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    applyFilters();
  }

  Future<void> fetchJobCards() async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;
    
    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      // Get all active job cards for the garage (limit 100 for offline search/filtering)
      final response = await _apiService.get('/jobcard/all/$ownerId', queryParameters: {
        'limit': 100,
      });
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        // Remove duplicates by keeping track of seen IDs
        final seenIds = <String>{};
        final uniqueData = <dynamic>[];
        for (final item in data) {
          final id = item['_id']?.toString() ?? '';
          // Only deduplicate items with IDs; keep items without IDs
          if (id.isEmpty) {
            uniqueData.add(item);
          } else if (!seenIds.contains(id)) {
            seenIds.add(id);
            uniqueData.add(item);
          }
        }
        
        jobCardsList.value = uniqueData;
        applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching job cards: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBalancePendingCards() async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;
    
    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    try {
      // Fetch stats to get balance pending total
      final statsResponse = await _apiService.get('/jobcard/stats/$ownerId');
      if (statsResponse.data != null && statsResponse.data['success'] == true) {
        final stats = statsResponse.data['data'];
        totalPendingBalance.value = double.tryParse(stats['balancePending']?.toString() ?? '0.0') ?? 0.0;
      }

      // Fetch all job cards and filter those with balanceAmount > 0
      final response = await _apiService.get('/jobcard/all/$ownerId', queryParameters: {
        'limit': 100,
      });
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        pendingBalanceCards.value = data.where((item) {
          final balance = double.tryParse(item['balanceAmount']?.toString() ?? '0') ?? 0.0;
          return balance > 0;
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching balance pending cards: $e');
    }
  }

  bool _matchesActiveProgressStatus(dynamic item) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    return status == 'pending' || status == 'in-progress';
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    final filter = selectedStatusFilter.value;

    var filtered = jobCardsList.where((item) {
      // Search matches customerName, customerPhone, vehicleNumber, or jobCardNumber
      final matchesName = item['customerName']?.toString().toLowerCase().contains(query) ?? false;
      final matchesPhone = item['customerPhone']?.toString().toLowerCase().contains(query) ?? false;
      final matchesVehicle = item['vehicleNumber']?.toString().toLowerCase().contains(query) ?? false;
      final matchesNumber = item['jobCardNumber']?.toString().toLowerCase().contains(query) ?? false;
      final matchesSearch = matchesName || matchesPhone || matchesVehicle || matchesNumber;

      // Filter matches status
      bool matchesStatus = true;
      if (filter == 'in-progress') {
        matchesStatus = _matchesActiveProgressStatus(item);
      } else if (filter == 'completed') {
        matchesStatus = (item['status'] ?? '').toString().toLowerCase() == 'completed';
      } else if (filter == 'closed') {
        matchesStatus = (item['status'] ?? '').toString().toLowerCase() == 'closed' || (item['status'] ?? '').toString().toLowerCase() == 'delivered';
      }

      return matchesSearch && matchesStatus;
    }).toList();

    filteredJobCards.value = filtered;
  }

  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    applyFilters();
  }

  Future<void> updateJobCardStatus(String jobCardId, String newStatus) async {
    isLoading.value = true;
    try {
      final response = await _apiService.put('/jobcard/$jobCardId/status', data: {
        'status': newStatus,
      });
      if (response.data != null && response.data['success'] == true) {
        await showJobCardStatusDialog(newStatus);
        fetchJobCards();
        fetchBalancePendingCards();

        // Also refresh dashboard controller stats
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
        }
      }
    } catch (e) {
      debugPrint('Error updating job card status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeFromCompleted(
    String jobCardId, {
    double advance = 0.0,
    double discount = 0.0,
    double amountPaid = 0.0,
    String paymentMode = 'Online',
  }) async {
    isLoading.value = true;
    try {
      final updateResponse = await _apiService.put('/jobcard/$jobCardId', data: {
        'advancePayment': advance,
        'discount': discount,
      });

      if (updateResponse.data != null && updateResponse.data['success'] == true) {
        debugPrint('Job card details updated before closing.');
      }

      if (amountPaid > 0) {
        await _apiService.put('/jobcard/$jobCardId/payment', data: {
          'amountPaid': amountPaid,
          'paymentStatus': 'paid',
          'paymentMode': paymentMode,
        });
      }

      final response = await _apiService.put('/jobcard/$jobCardId/status', data: {
        'status': 'closed',
      });

      if (response.data != null && response.data['success'] == true) {
        await showJobCardStatusDialog('closed');
        fetchJobCards();
        fetchBalancePendingCards();

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
        }
      }
    } catch (e) {
      debugPrint('Error closing completed job card: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeThenClose(
    String jobCardId, {
    double advance = 0.0,
    double discount = 0.0,
  }) async {
    isLoading.value = true;
    try {
      final updateResponse = await _apiService.put('/jobcard/$jobCardId', data: {
        'advancePayment': advance,
        'discount': discount,
      });

      if (updateResponse.data != null && updateResponse.data['success'] == true) {
        debugPrint('Job card advance and discount updated before completion.');
      }

      final completedResponse = await _apiService.put('/jobcard/$jobCardId/status', data: {
        'status': 'completed',
      });

      if (completedResponse.data != null && completedResponse.data['success'] == true) {
        await showJobCardStatusDialog('completed');
      }

      // A job card should only become 'closed' when the user explicitly chooses
      // the close action. Completing a card must not auto-close it immediately.
      fetchJobCards();
      fetchBalancePendingCards();

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchStats();
      }
    } catch (e) {
      debugPrint('Error completing job card: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> collectPendingPayment(String jobCardId, double amountPaid) async {
    isLoading.value = true;
    try {
      final response = await _apiService.put('/jobcard/$jobCardId/payment', data: {
        'amountPaid': amountPaid,
        'paymentStatus': 'paid', // Mark full payment
      });
      if (response.data != null && response.data['success'] == true) {
        Get.snackbar(
          'Payment Cleared',
          'Successfully cleared pending balance of ₹${amountPaid.toStringAsFixed(0)}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchJobCards();
        fetchBalancePendingCards();
        
        // Refresh dashboard controller stats
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
        }
      }
    } catch (e) {
      debugPrint('Error clearing balance payment: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
