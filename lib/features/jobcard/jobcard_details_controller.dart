import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/core/job_card_status_dialog.dart';
import '../../../app/data/services/api_service.dart';
import '../dashboard/dashboard_controller.dart';
import '../reminders/service_reminders_controller.dart';

class JobCardDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxMap<String, dynamic> jobCard = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> garageProfile = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;

  late String jobCardId;
  final GlobalKey boundaryKey = GlobalKey();

  // Bottom sheet variables for adding parts
  final RxList<dynamic> inventoryItems = <dynamic>[].obs;
  final RxList<dynamic> filteredInventoryItems = <dynamic>[].obs;
  final searchInventoryController = TextEditingController();
  final RxString activeInventoryTab = 'inventory'.obs; // 'inventory' or 'manual'
  final manualItemNameController = TextEditingController();
  final manualItemQtyController = TextEditingController(text: '1');
  final manualItemRateController = TextEditingController();
  final manualItemDiscountController = TextEditingController(text: '0');
  final RxString manualDiscountType = 'currency'.obs; // 'currency' (₹) or 'percent' (%)
  final RxList<Map<String, dynamic>> selectedSpares = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchInventoryController.addListener(applyInventoryFilters);
    final arg = Get.arguments;
    if (arg is String) {
      jobCardId = arg;
    } else if (arg is Map && arg['_id'] != null) {
      jobCardId = arg['_id'];
    } else {
      jobCardId = '';
    }
    fetchJobCardDetails();
  }

  Future<void> fetchJobCardDetails() async {
    if (jobCardId.isEmpty) {
      Get.snackbar('Error', 'Invalid Job Card ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.get('/jobcard/$jobCardId');
      if (response.data != null && response.data['success'] == true) {
        jobCard.value = response.data['data'] ?? {};
        
        // Fetch matching garage owner details
        final ownerId = jobCard['garageOwner'];
        if (ownerId != null) {
          await fetchGarageProfile(ownerId.toString());
        }
      }
    } catch (e) {
      debugPrint('Error fetching job card details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGarageProfile(String ownerId) async {
    try {
      final response = await _apiService.get('/garage/profile/$ownerId');
      if (response.data != null && response.data['success'] == true) {
        garageProfile.value = response.data['data'] ?? {};
      }
    } catch (e) {
      debugPrint('Error fetching garage profile: $e');
    }
  }

  /// Computes the outstanding balance (total - advance already paid)
  double get computedBalance {
    double subtotal = 0.0;
    for (final part in (jobCard['spareParts'] as List? ?? [])) {
      subtotal += double.tryParse(part['amount']?.toString() ?? '0') ?? 0.0;
    }
    for (final job in (jobCard['jobs'] as List? ?? [])) {
      subtotal += double.tryParse(job['amount']?.toString() ?? '0') ?? 0.0;
    }
    for (final lube in (jobCard['lubricants'] as List? ?? [])) {
      subtotal += double.tryParse(lube['amount']?.toString() ?? '0') ?? 0.0;
    }
    final discount = double.tryParse(jobCard['discount']?.toString() ?? '0') ?? 0.0;
    final advance  = double.tryParse(jobCard['advancePayment']?.toString() ?? '0') ?? 0.0;
    final tax      = double.tryParse(jobCard['tax']?.toString() ?? '0') ?? 0.0;
    return (subtotal + tax - discount) - advance;
  }

  /// Records payment then changes status in one go
  Future<void> completeWithPayment(
    String status,
    double amountPaid,
    String paymentMode, {
    double? advance,
    double? discount,
  }) async {
    if (jobCardId.isEmpty) return;
    isLoading.value = true;
    try {
      if (advance != null || discount != null) {
        await _apiService.put('/jobcard/$jobCardId', data: {
          if (advance != null) 'advancePayment': advance,
          if (discount != null) 'discount': discount,
        });
      }
      if (amountPaid > 0) {
        await _apiService.put('/jobcard/$jobCardId/payment', data: {
          'amountPaid': amountPaid,
          'paymentStatus': 'paid',
          'paymentMode': paymentMode,
        });
      }
      final response = await _apiService.put('/jobcard/$jobCardId/status', data: {
        'status': status,
      });
      if (response.data != null && response.data['success'] == true) {
        jobCard.value = Map<String, dynamic>.from(response.data['data'] ?? {});
        await fetchJobCardDetails();
        await showJobCardStatusDialog(status);

        // A completed job card must remain completed until the user explicitly
        // chooses a separate close action. Do not auto-close it here.
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
          Get.find<DashboardController>().fetchJobCards();
        }
        if (Get.isRegistered<ServiceRemindersController>()) {
          Get.find<ServiceRemindersController>().fetchReminders();
        }
      }
    } catch (e) {
      debugPrint('Error completing job card with payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateJobCardStatus(String status) async {
    if (jobCardId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _apiService.put('/jobcard/$jobCardId/status', data: {
        'status': status,
      });

      if (response.data != null && response.data['success'] == true) {
        jobCard.value = response.data['data'] ?? {};
        await showJobCardStatusDialog(status);

        // Refresh dashboard and listings lists
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
          Get.find<DashboardController>().fetchJobCards();
        }

        // Refresh reminders count from the API instantly!
        if (Get.isRegistered<ServiceRemindersController>()) {
          Get.find<ServiceRemindersController>().fetchReminders();
        }
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _buildMessage() {
    final workshopName = garageProfile['workshopName'] ?? jobCard['customerVoiceItems']?.first ?? 'Garage';
    final workshopPhone = garageProfile['mobileNumber'] ?? '';
    final make = jobCard['vehicleMake'] ?? '';
    final model = jobCard['vehicleModel'] ?? '';
    final variant = jobCard['vehicleVariant'] ?? '';
    final vehNo = jobCard['vehicleNumber'] ?? '';
    
    // Parse parts & items to get computed subtotal purely on the client side
    double computedSubTotal = 0.0;
    if (jobCard['spareParts'] != null && jobCard['spareParts'] is List) {
      for (final part in jobCard['spareParts']) {
        computedSubTotal += double.tryParse(part['amount']?.toString() ?? '0.0') ?? 0.0;
      }
    }
    if (jobCard['jobs'] != null && jobCard['jobs'] is List) {
      for (final job in jobCard['jobs']) {
        computedSubTotal += double.tryParse(job['amount']?.toString() ?? '0.0') ?? 0.0;
      }
    }
    if (jobCard['lubricants'] != null && jobCard['lubricants'] is List) {
      for (final lube in jobCard['lubricants']) {
        computedSubTotal += double.tryParse(lube['amount']?.toString() ?? '0.0') ?? 0.0;
      }
    }
    
    final discount = double.tryParse(jobCard['discount']?.toString() ?? '0') ?? 0.0;
    final advance = double.tryParse(jobCard['advancePayment']?.toString() ?? '0') ?? 0.0;
    final tax = double.tryParse(jobCard['tax']?.toString() ?? '0') ?? 0.0;
    
    final balance = (computedSubTotal + tax - discount) - advance;
    final totalStr = balance.toStringAsFixed(2);

    return "Dear Customer, Message from $workshopName\n$workshopPhone\nYour vehicle\n$make $model $variant\nVeh. No: $vehNo\nis ready for pickup.\n\nBill Total: $totalStr/-";
  }

  Future<void> launchWhatsApp() async {
    final phone = jobCard['customerPhone'] ?? '';
    if (phone.isEmpty) {
      Get.snackbar('WhatsApp Error', 'Customer phone number not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white);
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final targetPhone = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    final message = _buildMessage();

    // Try native WhatsApp scheme first (more reliable on Android)
    final nativeUri = Uri.parse("whatsapp://send?phone=$targetPhone&text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      return;
    }
    // Fallback: wa.me web link
    final webUri = Uri.parse("https://wa.me/$targetPhone?text=${Uri.encodeComponent(message)}");
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('WhatsApp Error', 'Could not open WhatsApp application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  Future<void> shareReceipt() async {
    try {
      final RenderRepaintBoundary? boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar('Share Error', 'Could not render invoice screenshot',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      isLoading.value = true;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        isLoading.value = false;
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/receipt_${jobCard['jobCardNumber'] ?? 'JC'}.png').create();
      await file.writeAsBytes(pngBytes);

      isLoading.value = false;

      final message = _buildMessage();
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
      );
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error sharing receipt: $e');
      Get.snackbar('Share Error', 'An error occurred while sharing the receipt',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  void makeCall() async {
    final phone = jobCard['customerPhone'] ?? '';
    if (phone.isEmpty) return;
    
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void onClose() {
    searchInventoryController.dispose();
    manualItemNameController.dispose();
    manualItemQtyController.dispose();
    manualItemRateController.dispose();
    manualItemDiscountController.dispose();
    super.onClose();
  }

  Future<void> loadInventoryItems() async {
    final user = _apiService.getUser();
    final ownerId = user?['id'] ?? user?['_id'] ?? jobCard['garageOwner'];
    if (ownerId == null) return;

    try {
      final response = await _apiService.get('/inventory/$ownerId');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        inventoryItems.value = data.map((raw) => {
          'id': raw['_id']?.toString() ?? raw['id']?.toString() ?? '',
          'name': raw['name'] ?? '',
          'brand': raw['brand'] ?? 'Generic',
          'category': raw['category'] ?? 'parts',
          'qty': (raw['qty'] as num?)?.toInt() ?? 0,
          'unit': raw['unit'] ?? 'pieces',
          'sellPrice': (raw['sellPrice'] as num?)?.toDouble() ?? 0.0,
        }).toList();
        applyInventoryFilters();
      }
    } catch (e) {
      debugPrint('Error loading inventory from API: $e');
    }
  }

  void applyInventoryFilters() {
    final query = searchInventoryController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredInventoryItems.value = inventoryItems;
    } else {
      filteredInventoryItems.value = inventoryItems.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final brand = item['brand']?.toString().toLowerCase() ?? '';
        return name.contains(query) || brand.contains(query);
      }).toList();
    }
  }

  Future<void> addManualItem() async {
    final name = manualItemNameController.text.trim();
    final qtyText = manualItemQtyController.text.trim();
    final rateText = manualItemRateController.text.trim();
    final discText = manualItemDiscountController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Item Name Required',
        'Please enter item name to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final qty = double.tryParse(qtyText) ?? 1.0;
    final rate = double.tryParse(rateText) ?? 0.0;
    final discount = double.tryParse(discText) ?? 0.0;

    final user = _apiService.getUser();
    final ownerId = user?['id'] ?? user?['_id'] ?? jobCard['garageOwner'];

    if (ownerId == null) {
      Get.snackbar(
        'Error',
        'Failed to retrieve garage owner details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      // 1. Upload this item as a real inventory item in the database!
      final response = await _apiService.post('/inventory', data: {
        'garageOwnerId': ownerId,
        'name': name,
        'brand': 'Manual Entry',
        'category': 'parts',
        'qty': qty.toInt(), // stock qty
        'unit': 'pieces',
        'minLevel': 5,
        'buyPrice': rate, // default buy price same as rate
        'sellPrice': rate,
      });

      if (response.data != null && response.data['success'] == true) {
        final raw = response.data['data'];
        final realItem = {
          'id': raw['_id']?.toString() ?? raw['id']?.toString() ?? '',
          'name': raw['name'] ?? name,
          'brand': raw['brand'] ?? 'Manual Entry',
          'category': raw['category'] ?? 'parts',
          'qty': qty, // quantity to add to job card
          'sellPrice': rate,
          'discount': discount,
          'discountType': manualDiscountType.value,
        };

        // 2. Clear current selection, add this real item, and save it to the jobcard in the database!
        selectedSpares.clear();
        selectedSpares.add(realItem);

        // 3. Clear fields
        manualItemNameController.clear();
        manualItemQtyController.text = '1';
        manualItemRateController.clear();
        manualItemDiscountController.text = '0';
        manualDiscountType.value = 'currency';

        // 4. Reload local inventory items so that it instantly shows up in the search list too!
        await loadInventoryItems();

        Get.back();
        await saveSelectedSparesToJobCard();
      }
    } catch (e) {
      debugPrint('Error uploading manual entry item: $e');
      Get.snackbar(
        'Upload Error',
        'Failed to upload manual item to inventory database.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addSpareItem(Map<String, dynamic> item) {
    final itemId = item['id']?.toString() ?? '';
    final itemName = item['name']?.toString().trim().toLowerCase() ?? '';
    final itemBrand = item['brand']?.toString().trim().toLowerCase() ?? '';
    final inventoryIndex = inventoryItems.indexWhere(
      (inventoryItem) => inventoryItem['id']?.toString() == itemId,
    );
    final availableStock = inventoryIndex == -1
        ? (item['qty'] as num?)?.toDouble() ?? 0
        : (inventoryItems[inventoryIndex]['qty'] as num?)?.toDouble() ?? 0;
    final existingIndex = selectedSpares.indexWhere((existing) {
      final existingId = existing['id']?.toString() ?? '';
      if (itemId.isNotEmpty && existingId.isNotEmpty) {
        return existingId == itemId;
      }
      return existing['name']?.toString().trim().toLowerCase() == itemName &&
          existing['brand']?.toString().trim().toLowerCase() == itemBrand;
    });
    if (existingIndex != -1) {
      final existing = Map<String, dynamic>.from(selectedSpares[existingIndex]);
      final currentQuantity =
          (existing['qty'] as num?)?.toDouble() ?? 1;
      if (currentQuantity >= availableStock) return;
      existing['qty'] = currentQuantity + 1;
      selectedSpares[existingIndex] = existing;
    } else {
      if (availableStock <= 0) return;
      final newItem = Map<String, dynamic>.from(item);
      newItem['qty'] = 1;
      newItem['discount'] = newItem['discount'] ?? 0.0;
      newItem['discountType'] = newItem['discountType'] ?? 'currency';
      selectedSpares.add(newItem);
    }
    selectedSpares.refresh();
  }

  void removeSpareItem(String itemId) {
    selectedSpares.removeWhere((x) => x['id'] == itemId);
    selectedSpares.refresh();
  }

  Future<void> saveSelectedSparesToJobCard() async {
    if (jobCardId.isEmpty) return;
    if (selectedSpares.isEmpty) return;

    isLoading.value = true;
    try {
      final selectedSnapshot = selectedSpares
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // 1. Get the current list of spare parts
      final List<dynamic> currentSpares = List<dynamic>.from(jobCard['spareParts'] ?? []);

      // 2. Map the new selected spares into backend format
      final List<Map<String, dynamic>> newSpares = selectedSpares.map((item) {
        final rate = item['sellPrice'] ?? 0.0;
        final qty = item['qty'] ?? 1;
        final disc = double.tryParse(item['discount']?.toString() ?? '0.0') ?? 0.0;
        final discType = item['discountType'] ?? 'currency';
        double amount = rate * qty;
        if (discType == 'percent') {
          amount = amount * (1.0 - (disc / 100.0));
        } else {
          amount = amount - disc;
        }
        if (amount < 0) amount = 0.0;

        return {
          'inventoryItemId': item['id']?.toString() ?? '',
          'name': item['name'],
          'partNumber': item['brand'] ?? '',
          'quantity': qty,
          'rate': rate,
          'discount': disc,
          'discountType': discType,
          'amount': amount,
          'itemType': item['category'] == 'oil' ? 'other' : (item['category'] ?? 'parts'),
        };
      }).toList();

      // Merge identical products into one row and increase their quantity.
      final mergedSpares = <String, Map<String, dynamic>>{};
      for (final rawItem in [...currentSpares, ...newSpares]) {
        final item = Map<String, dynamic>.from(rawItem as Map);
        final name = item['name']?.toString().trim() ?? '';
        final partNumber =
            item['partNumber']?.toString().trim() ?? '';
        final rate =
            double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
        final discount =
            double.tryParse(item['discount']?.toString() ?? '0') ?? 0;
        final discountType =
            item['discountType']?.toString() ?? 'currency';
        final itemType = item['itemType']?.toString() ?? 'parts';
        final quantity =
            double.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        final key = [
          name.toLowerCase(),
          partNumber.toLowerCase(),
          rate.toStringAsFixed(2),
          discount.toStringAsFixed(2),
          discountType,
          itemType,
        ].join('|');

        if (mergedSpares.containsKey(key)) {
          final existing = mergedSpares[key]!;
          final existingQuantity =
              double.tryParse(existing['quantity']?.toString() ?? '0') ?? 0;
          existing['quantity'] = existingQuantity + quantity;
        } else {
          mergedSpares[key] = {
            ...item,
            'name': name,
            'partNumber': partNumber,
            'quantity': quantity,
            'rate': rate,
            'discount': discount,
            'discountType': discountType,
            'itemType': itemType,
          };
        }
      }

      for (final item in mergedSpares.values) {
        final rate = (item['rate'] as num).toDouble();
        final quantity = (item['quantity'] as num).toDouble();
        final discount = (item['discount'] as num).toDouble();
        final discountType = item['discountType']?.toString() ?? 'currency';
        var amount = rate * quantity;
        amount = discountType == 'percent'
            ? amount * (1 - discount / 100)
            : amount - discount;
        item['amount'] = amount < 0 ? 0.0 : amount;
      }

      // 4. Send updated spare parts array to the backend
      final response = await _apiService.put('/jobcard/$jobCardId', data: {
        'spareParts': mergedSpares.values.toList(),
      });

      if (response.data != null && response.data['success'] == true) {
        jobCard.value = response.data['data'] ?? {};
        await _deductInventoryStock(selectedSnapshot);
        selectedSpares.clear();
        
        Get.snackbar(
          'Invoice Updated', 
          'Successfully added items to invoice.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh dashboard and listings lists
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
          Get.find<DashboardController>().fetchJobCards();
        }
      }
    } catch (e) {
      debugPrint('Error updating job card items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _deductInventoryStock(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    for (final selected in selectedItems) {
      final itemId = selected['id']?.toString() ?? '';
      if (itemId.isEmpty) continue;

      final inventoryIndex = inventoryItems.indexWhere(
        (item) => item['id']?.toString() == itemId,
      );
      if (inventoryIndex == -1) continue;

      final currentStock =
          (inventoryItems[inventoryIndex]['qty'] as num?)?.toInt() ?? 0;
      final usedQuantity =
          (selected['qty'] as num?)?.toInt() ?? 0;
      final remainingStock =
          (currentStock - usedQuantity).clamp(0, currentStock);

      try {
        await _apiService.put(
          '/inventory/$itemId',
          data: {'qty': remainingStock},
        );
      } catch (error) {
        debugPrint('Error reducing inventory stock for $itemId: $error');
      }
    }

    await loadInventoryItems();
  }

  void resetForm() {
    manualItemNameController.clear();
    manualItemQtyController.text = '1';
    manualItemRateController.clear();
    manualItemDiscountController.text = '0';
    manualDiscountType.value = 'currency';
  }
}
