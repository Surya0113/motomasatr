import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/services/api_service.dart';

class InventoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Reactive parts array
  final RxList<dynamic> allItems = <dynamic>[].obs;
  final RxList<dynamic> filteredItems = <dynamic>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;

  // Counters
  final RxInt totalItems = 0.obs;
  final RxInt lowStock = 0.obs;
  final RxInt outOfStock = 0.obs;

  // Filters and queries
  final RxString selectedFilterCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Add Item Form States
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final qtyController = TextEditingController();
  final unitController = TextEditingController(text: 'pieces');
  final minStockController = TextEditingController(text: '5');
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();

  final RxString activeFormCategory = 'parts'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    qtyController.dispose();
    unitController.dispose();
    minStockController.dispose();
    buyPriceController.dispose();
    sellPriceController.dispose();
    super.onClose();
  }

  /// Fetch all active inventory items from the backend for the logged-in garage
  Future<void> fetchItems() async {
    final user = _apiService.getUser();
    if (user == null) return;

    final ownerId = user['id'] ?? user['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      final response = await _apiService.get('/inventory/$ownerId');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        allItems.value = data.map((item) => _mapItem(item)).toList();
        calculateStats();
        applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching inventory items: $e');
      // Fallback: keep list as is (empty or previous)
    } finally {
      isLoading.value = false;
    }
  }

  /// Map raw backend item to the UI-ready format
  Map<String, dynamic> _mapItem(dynamic raw) {
    return {
      'id': raw['_id']?.toString() ?? raw['id']?.toString() ?? '',
      'name': raw['name'] ?? '',
      'brand': raw['brand'] ?? 'Generic',
      'category': raw['category'] ?? 'parts',
      'qty': (raw['qty'] is int) ? raw['qty'] : (raw['qty'] as num?)?.toInt() ?? 0,
      'unit': raw['unit'] ?? 'pieces',
      'minLevel': (raw['minLevel'] is int) ? raw['minLevel'] : (raw['minLevel'] as num?)?.toInt() ?? 5,
      'buyPrice': (raw['buyPrice'] as num?)?.toDouble() ?? 0.0,
      'sellPrice': (raw['sellPrice'] as num?)?.toDouble() ?? 0.0,
    };
  }

  void calculateStats() {
    totalItems.value = allItems.length;

    int lowCount = 0;
    int outCount = 0;

    for (final item in allItems) {
      final qty = ((item['qty'] ?? 0) as num).toInt();
      final minLevel = ((item['minLevel'] ?? 5) as num).toInt();

      if (qty == 0) {
        outCount++;
      } else if (qty <= minLevel) {
        lowCount++;
      }
    }

    lowStock.value = lowCount;
    outOfStock.value = outCount;
  }

  void changeFilter(String categoryKey) {
    selectedFilterCategory.value = categoryKey;
    applyFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final cat = selectedFilterCategory.value;
    final query = searchQuery.value.toLowerCase().trim();

    var results = allItems.toList();

    if (cat != 'all') {
      results = results.where((item) => item['category'] == cat).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final brand = (item['brand'] ?? '').toString().toLowerCase();
        return name.contains(query) || brand.contains(query);
      }).toList();
    }

    filteredItems.value = results;
  }

  void resetForm() {
    nameController.clear();
    brandController.clear();
    qtyController.clear();
    unitController.text = 'pieces';
    minStockController.text = '5';
    buyPriceController.clear();
    sellPriceController.clear();
    activeFormCategory.value = 'parts';
  }

  /// Create a new inventory item via backend API
  Future<void> addNewItem() async {
    final name = nameController.text.trim();
    final brand = brandController.text.trim();
    final qtyText = qtyController.text.trim();
    final unit = unitController.text.trim();
    final minLevelText = minStockController.text.trim();
    final buyPriceText = buyPriceController.text.trim();
    final sellPriceText = sellPriceController.text.trim();

    if (name.isEmpty || qtyText.isEmpty || buyPriceText.isEmpty || sellPriceText.isEmpty) {
      Get.snackbar(
        'Required Fields',
        'Please enter all required (*) fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final qty = int.tryParse(qtyText) ?? -1;
    final minLevel = int.tryParse(minLevelText) ?? 5;
    final buyPrice = double.tryParse(buyPriceText) ?? -1.0;
    final sellPrice = double.tryParse(sellPriceText) ?? -1.0;

    if (qty < 0 || buyPrice < 0 || sellPrice < 0) {
      Get.snackbar(
        'Invalid Value',
        'Please enter positive numbers for numeric inputs.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final user = _apiService.getUser();
    if (user == null) return;
    final ownerId = user['id'] ?? user['_id'];

    isAdding.value = true;
    try {
      final response = await _apiService.post('/inventory', data: {
        'garageOwnerId': ownerId,
        'name': name,
        'brand': brand.isEmpty ? 'Generic' : brand,
        'category': activeFormCategory.value,
        'qty': qty,
        'unit': unit.isEmpty ? 'pieces' : unit,
        'minLevel': minLevel,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
      });

      if (response.data != null && response.data['success'] == true) {
        resetForm();
        Get.back(); // Pop Add Screen
        Get.snackbar(
          'Item Added',
          'Spare part saved to inventory successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh the list from backend
        await fetchItems();
      }
    } catch (e) {
      debugPrint('Error adding inventory item: $e');
    } finally {
      isAdding.value = false;
    }
  }

  /// Soft-delete an item via the backend
  Future<void> deleteItem(String itemId) async {
    try {
      final response = await _apiService.delete('/inventory/$itemId');
      if (response.data != null && response.data['success'] == true) {
        allItems.removeWhere((x) => x['id']?.toString() == itemId);
        calculateStats();
        applyFilters();
        Get.snackbar(
          'Item Removed',
          'Inventory item deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
    }
  }

  /// Update qty for an existing item
  Future<void> updateItemQty(String itemId, int newQty) async {
    try {
      final response = await _apiService.put('/inventory/$itemId', data: {'qty': newQty});
      if (response.data != null && response.data['success'] == true) {
        final idx = allItems.indexWhere((x) => x['id']?.toString() == itemId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(allItems[idx]);
          updated['qty'] = newQty;
          allItems[idx] = updated;
          calculateStats();
          applyFilters();
        }
      }
    } catch (e) {
      debugPrint('Error updating inventory item qty: $e');
    }
  }
}
