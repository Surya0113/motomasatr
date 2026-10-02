import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';

class ReportsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Rx state variables
  final RxString selectedPeriod = '6months'.obs; // week, month, 6months, year
  final RxBool isLoading = false.obs;

  final RxDouble partsRevenue = 0.0.obs;
  final RxDouble oilRevenue = 0.0.obs;
  final RxDouble labourRevenue = 0.0.obs;
  final RxDouble accessoriesRevenue = 0.0.obs;
  final RxDouble tyreRevenue = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final periodKey = selectedPeriod.value;
      final response = await _apiService.get('/analytics/workshop/$ownerId?period=$periodKey');

      if (response.data != null && response.data['success'] == true) {
        final revenue = response.data['revenue'];
        if (revenue != null) {
          final breakdown = revenue['categoryBreakdown'];
          if (breakdown != null) {
            partsRevenue.value = _toDouble(breakdown['parts']?['total']);
            oilRevenue.value = _toDouble(breakdown['oil']?['total']);
            labourRevenue.value = _toDouble(breakdown['labour']?['total']);
            accessoriesRevenue.value = _toDouble(breakdown['accessories']?['total']);
            tyreRevenue.value = _toDouble(breakdown['tyre']?['total']);
            grandTotal.value = _toDouble(breakdown['grandTotal']);
          } else {
            _clearBreakdown();
          }
        } else {
          _clearBreakdown();
        }
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      _clearBreakdown();
    } finally {
      isLoading.value = false;
    }
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  void _clearBreakdown() {
    partsRevenue.value = 0.0;
    oilRevenue.value = 0.0;
    labourRevenue.value = 0.0;
    accessoriesRevenue.value = 0.0;
    tyreRevenue.value = 0.0;
    grandTotal.value = 0.0;
  }
}
