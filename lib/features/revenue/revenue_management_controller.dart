import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';

class RevenueManagementController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Filter & Tab states
  final RxString selectedFilter = 'all'.obs; // all, today, week, month
  final RxString selectedTab = 'in'.obs; // in, out

  // Financial summary
  final RxDouble cashInTotal = 0.0.obs;
  final RxDouble cashOutTotal = 0.0.obs;
  final RxDouble netTotal = 0.0.obs;

  // Transactions list
  final RxList<dynamic> transactions = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  // Form Controllers for Cash In / Out manual entry
  final amountController = TextEditingController();
  final descController = TextEditingController();
  final transactionNumberController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString paymentMode = 'cash'.obs;
  final RxString category = 'additional_income'.obs; // or expense category
  final RxBool isSubmitting = false.obs;

  final List<String> paymentModes = ['cash', 'card', 'upi', 'online', 'cheque', 'other'];
  final List<String> cashInCategories = ['job_card', 'additional_income', 'spare_parts_sale', 'service_charge', 'other'];
  final List<String> cashOutCategories = ['rent', 'salary', 'spare_parts_purchase', 'utilities', 'maintenance', 'equipment', 'other'];

  @override
  void onInit() {
    super.onInit();
    fetchRevenueData();
  }

  @override
  void onClose() {
    amountController.dispose();
    descController.dispose();
    transactionNumberController.dispose();
    super.onClose();
  }

  void resetForm() {
    amountController.clear();
    descController.clear();
    transactionNumberController.clear();
    selectedDate.value = DateTime.now();
    paymentMode.value = 'cash';
    category.value = selectedTab.value == 'in' ? 'additional_income' : 'other';
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchRevenueData();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    // Pre-populate category default for selected tab
    category.value = tab == 'in' ? 'additional_income' : 'other';
    fetchRevenueData();
  }

  // Calculate start/end dates based on time filter
  Map<String, String> _getDateRange() {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (selectedFilter.value) {
      case 'today':
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case 'week':
        // Find Monday of this week
        final days = now.weekday - 1;
        start = DateTime(now.year, now.month, now.day - days, 0, 0, 0);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        break;
      case 'all':
      default:
        return {};
    }

    return {
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
    };
  }

  Future<void> fetchRevenueData() async {
    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final dateParams = _getDateRange();
      
      // 1. Fetch Revenue Summary
      String summaryUrl = '/revenue/summary/$ownerId';
      if (dateParams.isNotEmpty) {
        summaryUrl += '?startDate=${dateParams['startDate']}&endDate=${dateParams['endDate']}';
      }
      final summaryRes = await _apiService.get(summaryUrl);

      if (summaryRes.data != null && summaryRes.data['success'] == true) {
        final summary = summaryRes.data['data'];
        cashInTotal.value = (summary['totalCashIn'] ?? 0).toDouble();
        cashOutTotal.value = (summary['totalCashOut'] ?? 0).toDouble();
        netTotal.value = (summary['netRevenue'] ?? 0).toDouble();
      }

      // 2. Fetch Active Transactions
      final subPath = selectedTab.value == 'in' ? 'cash-in' : 'cash-out';
      String transactionsUrl = '/revenue/$subPath/$ownerId';
      
      if (dateParams.isNotEmpty) {
        transactionsUrl += '?startDate=${dateParams['startDate']}&endDate=${dateParams['endDate']}';
      }
      
      final txRes = await _apiService.get(transactionsUrl);

      if (txRes.data != null && txRes.data['success'] == true) {
        transactions.value = txRes.data['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching revenue data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // Create manual transaction (Cash In/Out)
  Future<void> addTransaction() async {
    final amountText = amountController.text.trim();
    final descText = descController.text.trim();
    final amt = double.tryParse(amountText) ?? 0.0;
    final isIn = selectedTab.value == 'in';

    if (amountText.isEmpty || amt <= 0) {
      Get.snackbar('Required Fields', 'Please enter a valid amount.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white);
      return;
    }

    if (!isIn && descText.isEmpty) {
      Get.snackbar('Required Fields', 'Please enter a description for Cash Out.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white);
      return;
    }

    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isSubmitting.value = true;
    try {
      final subPath = isIn ? 'cash-in' : 'cash-out';
      final requestBody = {
        'garageOwnerId': ownerId,
        'amount': amt,
        'paymentMode': paymentMode.value,
        'category': category.value,
        'description': descText.isEmpty ? (isIn ? 'Cash In Entry' : '') : descText,
        'date': selectedDate.value.toIso8601String(),
      };

      if (isIn) {
        final txNum = transactionNumberController.text.trim();
        if (txNum.isNotEmpty) {
          requestBody['transactionNumber'] = txNum;
        }
      }

      final response = await _apiService.post('/revenue/$subPath', data: requestBody);

      if (response.data != null && (response.data['success'] == true || response.statusCode == 201)) {
        Get.snackbar('Transaction Added', 'Successfully added transaction to revenue log.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        
        resetForm();
        Get.back(); // Close bottom sheet
        fetchRevenueData(); // Refresh summary/lists
      } else {
        final msg = response.data != null ? response.data['message'] : 'Failed to save transaction';
        Get.snackbar('Error', msg ?? 'Failed to save',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error adding revenue transaction: $e');
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final subPath = selectedTab.value == 'in' ? 'cash-in' : 'cash-out';
      final response = await _apiService.delete('/revenue/$subPath/$id');
      if (response.data != null && response.data['success'] == true) {
        Get.snackbar('Transaction Deleted', 'Revenue transaction deleted successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        fetchRevenueData();
      }
    } catch (e) {
      debugPrint('Error deleting revenue transaction: $e');
    }
  }
}
