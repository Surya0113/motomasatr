import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../dashboard/dashboard_controller.dart';
import 'jobcard_list_controller.dart';
import '../reminders/service_reminders_controller.dart';

class JobCardCreateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Edit Mode variables
  final RxBool isEditMode = false.obs;
  final RxString editJobCardId = ''.obs;

  // Input Controllers
  final vehicleNoController = TextEditingController();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final kmReadingController = TextEditingController(text: '0');
  
  final estimateController = TextEditingController(text: '0');
  final advanceController = TextEditingController(text: '0.0');
  final discountController = TextEditingController(text: '0');

  // Reactive Form Values
  final RxDouble fuelLevel = 10.0.obs;
  
  final RxString serviceType = 'General Service'.obs;
  final RxString selectedNumber = '-'.obs;
  final RxString oilChange = 'Yes'.obs;

  final RxString make = 'Select'.obs;
  final RxString model = 'Select'.obs;
  final RxString variant = 'Select'.obs;

  final Rx<DateTime> deliveryDateTime = DateTime.now().add(const Duration(days: 1)).obs;
  final RxString assignedMechanic = 'Tap to assign'.obs;
  final RxString mechanicId = ''.obs;

  final RxBool isLoading = false.obs;

  // Bookings Selector variables
  final searchBookingController = TextEditingController();
  final RxList<dynamic> bookingsList = <dynamic>[].obs;
  final RxList<dynamic> filteredBookings = <dynamic>[].obs;
  final RxString selectedBookingId = ''.obs;

  // Mechanic assignment from staff API
  final RxList<dynamic> staffList = <dynamic>[].obs;
  final RxBool isLoadingStaff = false.obs;

  // Customer Problems variables from API
  final RxList<String> problemsList = <String>[].obs;
  final RxList<String> selectedProblems = <String>[].obs;
  final RxBool isLoadingProblems = false.obs;

  // Added Items from Inventory parts selection
  final RxList<Map<String, dynamic>> selectedSpares = <Map<String, dynamic>>[].obs;
  final RxList<dynamic> inventoryItems = <dynamic>[].obs;
  final RxList<dynamic> filteredInventoryItems = <dynamic>[].obs;
  final searchInventoryController = TextEditingController();

  // Grand total (computed locally from selectedSpares)
  final RxDouble grandTotal = 0.0.obs;
  final RxBool isEstimateManuallyEdited = false.obs;

  // Dynamic Add Items bottom sheet states & controllers
  final RxString activeInventoryTab = 'inventory'.obs; // 'inventory' or 'manual'
  final manualItemNameController = TextEditingController();
  final manualItemQtyController = TextEditingController(text: '1');
  final manualItemRateController = TextEditingController();
  final manualItemDiscountController = TextEditingController(text: '0');
  final RxString manualDiscountType = 'currency'.obs; // 'currency' (₹) or 'percent' (%)

  // Dent Marks damage map
  final RxMap<String, dynamic> dentMarks = <String, dynamic>{}.obs;

  // Options List
  final List<String> serviceTypes = [
    'General Service',
    'Major Repair',
    'Minor Repairs',
    'Engine Work',
    'Accident Work',
  ];
  final List<String> numbersList = ['-', '1', '2', '3', '4', '5'];
  final List<String> oilChangeOptions = ['Yes', 'No'];
  
  final List<String> makes = ['Select', 'Honda', 'Yamaha', 'Suzuki', 'TVS', 'Hero', 'Royal Enfield', 'Hyundai', 'Tata', 'Maruti'];
  final List<String> models = ['Select', 'Activa', 'FZ', 'Access', 'Jupiter', 'Splendor', 'Classic 350', 'i20', 'Nexon', 'Swift'];
  final List<String> variants = ['Select', 'STD', 'DLX', 'Pro', 'Petrol', 'Diesel'];

  @override
  void onInit() {
    super.onInit();
    searchBookingController.addListener(_onSearchChanged);
    searchInventoryController.addListener(applyInventoryFilters);
    fetchStaff();
    fetchCustomerProblems();
    loadInventoryItems();

    // Prefill if editing
    final arg = Get.arguments;
    if (arg != null && arg is Map<String, dynamic>) {
      isEditMode.value = true;
      editJobCardId.value = arg['_id'] ?? '';
      
      vehicleNoController.text = arg['vehicleNumber'] ?? '';
      fullNameController.text = arg['customerName'] ?? '';
      mobileController.text = arg['customerPhone'] ?? '';
      kmReadingController.text = (arg['odometerReading'] ?? '0').toString();
      estimateController.text = (arg['estimateAmount'] ?? '0').toString();
      advanceController.text = (arg['advancePayment'] ?? '0.0').toString();
      discountController.text = (arg['discount'] ?? '0').toString();
      fuelLevel.value = double.tryParse(arg['fuelLevel']?.toString() ?? '10.0') ?? 10.0;
      
      if (makes.contains(arg['vehicleMake'])) make.value = arg['vehicleMake'];
      if (models.contains(arg['vehicleModel'])) model.value = arg['vehicleModel'];
      if (variants.contains(arg['vehicleVariant'])) variant.value = arg['vehicleVariant'];
      
      assignedMechanic.value = arg['assignedMechanic'] ?? 'Tap to assign';
      mechanicId.value = arg['mechanicId'] ?? '';
      
      if (arg['deliveryDateTime'] != null) {
        deliveryDateTime.value = DateTime.tryParse(arg['deliveryDateTime'].toString()) ?? DateTime.now();
      }
      
      if (arg['customerVoiceItems'] != null && arg['customerVoiceItems'] is List) {
        selectedProblems.value = List<String>.from(arg['customerVoiceItems']);
      }
      
      if (arg['dentMarks'] != null && arg['dentMarks'] is List && arg['dentMarks'].isNotEmpty) {
        dentMarks.value = Map<String, dynamic>.from(arg['dentMarks'][0]);
      }
      
      if (arg['spareParts'] != null && arg['spareParts'] is List) {
        selectedSpares.value = List<Map<String, dynamic>>.from(
          arg['spareParts'].map((x) => {
            'id': x['_id'] ?? x['id'] ?? '',
            'name': x['name'] ?? '',
            'brand': x['partNumber'] ?? '',
            'qty': double.tryParse(x['quantity']?.toString() ?? '1') ?? 1.0,
            'sellPrice': double.tryParse(x['rate']?.toString() ?? '0.0') ?? 0.0,
            'category': x['itemType'] == 'other' ? 'oil' : 'parts',
            'discount': double.tryParse(x['discount']?.toString() ?? '0.0') ?? 0.0,
            'discountType': 'currency',
          })
        );
        updateSparesSum();
      }
    }
  }

  void _onSearchChanged() {
    applyBookingFilters();
  }

  @override
  void onClose() {
    vehicleNoController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    kmReadingController.dispose();
    estimateController.dispose();
    advanceController.dispose();
    discountController.dispose();
    searchBookingController.dispose();
    searchInventoryController.dispose();
    manualItemNameController.dispose();
    manualItemQtyController.dispose();
    manualItemRateController.dispose();
    manualItemDiscountController.dispose();
    super.onClose();
  }

  // Fetch Bookings list from backend
  Future<void> fetchBookings() async {
    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final response = await _apiService.get('/bookings', queryParameters: {
        'garageOwner': ownerId,
      });

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        bookingsList.value = data;
        applyBookingFilters();
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyBookingFilters() {
    final query = searchBookingController.text.trim().toLowerCase();
    
    var filtered = bookingsList.where((item) {
      final matchesName = item['customerName']?.toString().toLowerCase().contains(query) ?? false;
      final matchesPhone = item['mobileNumber']?.toString().toLowerCase().contains(query) ?? false;
      final matchesVehicle = item['vehicleNumber']?.toString().toLowerCase().contains(query) ?? false;
      return matchesName || matchesPhone || matchesVehicle;
    }).toList();

    filteredBookings.value = filtered;
  }

  // Trigger search vehicle from backend when they search
  Future<void> searchVehicle() async {
    final vehicleNo = vehicleNoController.text.trim();
    if (vehicleNo.isEmpty) {
      Get.snackbar('Vehicle Search', 'Please enter a vehicle number first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white);
      return;
    }

    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final response = await _apiService.post('/jobcard/search-vehicle', data: {
        'garageOwnerId': ownerId,
        'vehicleNumber': vehicleNo,
      });

      if (response.data != null && response.data['success'] == true) {
        if (response.data['found'] == true) {
          final data = response.data['data'];
          final vehicle = data['vehicle'];
          final customer = vehicle['customer'];

          if (customer != null) {
            fullNameController.text = customer['name'] ?? '';
            mobileController.text = customer['phone'] ?? '';
          }
          
          make.value = vehicle['make'] ?? 'Select';
          model.value = vehicle['model'] ?? 'Select';
          variant.value = vehicle['variant'] ?? 'Select';
          kmReadingController.text = (vehicle['lastOdometerReading'] ?? '0').toString();

          Get.snackbar('Vehicle Found', 'Successfully loaded vehicle details and customer history.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } else {
          Get.snackbar('New Vehicle', 'Vehicle not found in database. You can register it fresh.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blueAccent,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint('Error searching vehicle: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create complete job card API trigger
  Future<void> submitJobCard() async {
    final vehicleNo = vehicleNoController.text.trim();
    final fullName = fullNameController.text.trim();
    final mobile = mobileController.text.trim();
    final kmReading = int.tryParse(kmReadingController.text) ?? 0;

    if (vehicleNo.isEmpty || fullName.isEmpty || mobile.isEmpty) {
      Get.snackbar('Required Fields', 'Please fill all fields marked with *',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final estimateVal =
          double.tryParse(estimateController.text.trim()) ?? grandTotal.value;
      final discountVal = double.tryParse(discountController.text) ?? 0.0;
      final advanceVal = double.tryParse(advanceController.text) ?? 0.0;

      final requestBody = {
        'garageOwnerId': ownerId,
        'customerName': fullName,
        'customerPhone': mobile,
        'vehicleNumber': vehicleNo,
        'vehicleType': '2W', // Default to 2-wheeler, can expand
        'odometerReading': kmReading,
        'fuelLevel': fuelLevel.value.toInt(),
        'deliveryDateTime': deliveryDateTime.value.toIso8601String(),
        'estimateAmount': estimateVal,
        'advancePayment': advanceVal,
        'discount': discountVal,
        'tax': 0.0,
        'assignedMechanic': assignedMechanic.value == 'Tap to assign' ? null : assignedMechanic.value,
        'mechanicId': mechanicId.value.isNotEmpty ? mechanicId.value : null,
        'customerVoiceItems': selectedProblems.isNotEmpty ? selectedProblems : [serviceType.value],
        'vehicleMake': make.value == 'Select' ? 'Honda' : make.value,
        'vehicleModel': model.value == 'Select' ? 'Activa' : model.value,
        'vehicleVariant': variant.value == 'Select' ? 'STD' : variant.value,
        'bookingId': selectedBookingId.value.isNotEmpty ? selectedBookingId.value : null,
        'dentMarks': dentMarks.isNotEmpty ? [dentMarks] : [],
        'spareParts': selectedSpares.map((item) {
          final rate = (item['sellPrice'] ?? 0.0) as double;
          final qty = (item['qty'] is int)
              ? (item['qty'] as int).toDouble()
              : (item['qty'] ?? 1.0) as double;
          final disc = double.tryParse(item['discount']?.toString() ?? '0.0') ?? 0.0;
          final discType = item['discountType'] ?? 'currency';
          double sub = rate * qty;
          if (discType == 'percent') {
            sub = sub * (1.0 - (disc / 100.0));
          } else {
            sub = sub - disc;
          }
          if (sub < 0) sub = 0;
          return {
            'name': item['name'],
            'partNumber': item['brand'] ?? '',
            'quantity': qty,
            'rate': rate,
            'discount': disc,
            'amount': sub,
            'itemType': item['category'] == 'oil' ? 'other' : (item['category'] ?? 'parts'),
          };
        }).toList(),
      };

      final response = isEditMode.value
          ? await _apiService.put('/jobcard/${editJobCardId.value}', data: requestBody)
          : await _apiService.post('/jobcard/create-complete', data: requestBody);

      if (response.data != null && response.data['success'] == true) {
        final jobCardNumber = response.data['data']?['jobCardNumber']?.toString() ?? '';

        // Refresh dashboard statistics
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchStats();
          Get.find<DashboardController>().fetchJobCards();
        }

        if (Get.isRegistered<JobCardListController>()) {
          Get.find<JobCardListController>().fetchJobCards();
          Get.find<JobCardListController>().fetchBalancePendingCards();
        }

        // Refresh reminders count from the API instantly!
        if (Get.isRegistered<ServiceRemindersController>()) {
          Get.find<ServiceRemindersController>().fetchReminders();
        }

        final title = isEditMode.value ? 'Updated' : 'JobCard Created';
        final msg = isEditMode.value
            ? 'Activity saved and job card updated successfully.'
            : jobCardNumber.isNotEmpty
                ? 'Job card created successfully with number $jobCardNumber'
                : 'Job card created successfully';

        // Return back first so the toast is visible after landing on dashboard/list tabs.
        Get.back();
        Get.snackbar(
          title,
          msg,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error creating job card: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Pick Delivery Date & Time
  Future<void> pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: deliveryDateTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(deliveryDateTime.value),
      );

      if (time != null) {
        deliveryDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  // Assign Mechanic sheet is launched from View directly
  void assignMechanic() {
    // Open mechanic selection sheet in View
  }

  void assignMechanicById(String name, String id) {
    assignedMechanic.value = name;
    mechanicId.value = id;
  }

  // API fetches & state functions
  Future<void> fetchStaff() async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;
    
    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoadingStaff.value = true;
    try {
      final response = await _apiService.get('/staff/all/$ownerId');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        staffList.value = data;
      }
    } catch (e) {
      debugPrint('Error fetching staff in jobcard: $e');
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> fetchCustomerProblems() async {
    isLoadingProblems.value = true;
    try {
      final response = await _apiService.get('/admin/customer-problems/active');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        problemsList.value = data.map((item) => item['name'].toString()).toList();
      } else {
        _setFallbackProblems();
      }
    } catch (e) {
      debugPrint('Error fetching customer problems: $e');
      _setFallbackProblems();
    } finally {
      isLoadingProblems.value = false;
    }
  }

  void _setFallbackProblems() {
    problemsList.value = [
      'Full Body Check', 'surya', 'Mileage Check', 'Vibration', 'Battery Check', 
      'Brake Check', 'Customization', 'Oil Check and Change', 'Washing', 
      'Balancing', 'Wheel Alignment', 'Accidental Repair', 'General Repair', 
      'Servicing', 'AC Repair', 'Tyre Replacement', 'Engine Check', 
      'Gear Issue', 'Suspension Issue', 'Clutch Repair', 'Exhaust Check'
    ];
  }

  Future<void> loadInventoryItems() async {
    final user = _apiService.getUser();
    if (user == null) return;
    final ownerId = user['id'] ?? user['_id'];
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
      // Keep list empty — user will see "No parts matching" message
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

  void toggleProblem(String problem) {
    if (selectedProblems.contains(problem)) {
      selectedProblems.remove(problem);
    } else {
      selectedProblems.add(problem);
    }
  }

  void addCustomProblem(String problem) {
    final trimmed = problem.trim();
    if (trimmed.isEmpty) return;
    if (!problemsList.contains(trimmed)) {
      problemsList.add(trimmed);
    }
    if (!selectedProblems.contains(trimmed)) {
      selectedProblems.add(trimmed);
    }
  }

  void onEstimateChanged(String value) {
    isEstimateManuallyEdited.value = true;
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
    final ownerId = user?['id'] ?? user?['_id'];

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

        // 2. Add it to selected spares using the real backend ID
        addSpareItem(realItem);

        // 3. Clear fields
        manualItemNameController.clear();
        manualItemQtyController.text = '1';
        manualItemRateController.clear();
        manualItemDiscountController.text = '0';
        manualDiscountType.value = 'currency';

        // 4. Reload local inventory items so that it instantly shows up in the search list too!
        await loadInventoryItems();

        Get.back();
        Get.snackbar(
          'Item Added & Uploaded',
          'Successfully saved to inventory and added to estimate.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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

  void addSpareItem(Map<String, dynamic> item, {double qty = 1.0}) {
    final itemId = item['id']?.toString() ?? '';
    final existingIndex = selectedSpares.indexWhere((x) => x['id']?.toString() == itemId);
    if (existingIndex != -1) {
      final existing = Map<String, dynamic>.from(selectedSpares[existingIndex]);
      final currentQty = (existing['qty'] is int)
          ? (existing['qty'] as int).toDouble()
          : (existing['qty'] ?? 1.0) as double;
      existing['qty'] = currentQty + qty;
      selectedSpares[existingIndex] = existing;
    } else {
      final newItem = Map<String, dynamic>.from(item);
      // Use provided qty for newly added item.
      newItem['qty'] = qty;
      newItem['discount'] = newItem['discount'] ?? 0.0;
      newItem['discountType'] = newItem['discountType'] ?? 'currency';
      selectedSpares.add(newItem);
    }
    updateSparesSum();
  }

  void removeSpareItem(String itemId) {
    selectedSpares.removeWhere((x) => x['id']?.toString() == itemId);
    updateSparesSum();
  }

  void updateSparesSum() {
    double total = 0.0;
    for (final item in selectedSpares) {
      final rate = (item['sellPrice'] is int)
          ? (item['sellPrice'] as int).toDouble()
          : (item['sellPrice'] ?? 0.0) as double;
      final qty = (item['qty'] is int)
          ? (item['qty'] as int).toDouble()
          : (item['qty'] ?? 1.0) as double;
      final disc = double.tryParse(item['discount']?.toString() ?? '0.0') ?? 0.0;
      final discType = item['discountType'] ?? 'currency';
      
      double itemSubtotal = rate * qty;
      if (discType == 'percent') {
        itemSubtotal = itemSubtotal * (1.0 - (disc / 100.0));
      } else {
        itemSubtotal = itemSubtotal - disc;
      }
      if (itemSubtotal < 0) itemSubtotal = 0;
      total += itemSubtotal;
    }
    grandTotal.value = total;
    if (!isEstimateManuallyEdited.value || estimateController.text.trim().isEmpty) {
      estimateController.text = total.toStringAsFixed(0);
    }
  }
}
