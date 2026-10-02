import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';

class BookingsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Rx State variables
  final RxList<dynamic> bookings = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString vehicleNumber = ''.obs; // For real-time validation feedback

  // Form Controllers
  final vehicleNumberController = TextEditingController();
  final customerNameController = TextEditingController();
  final mobileNumberController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  // Has first selection flags
  final RxBool hasSelectedDate = false.obs;
  final RxBool hasSelectedTime = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listener for real-time validation feedback
    vehicleNumberController.addListener(() {
      vehicleNumber.value = vehicleNumberController.text.trim();
    });
    fetchBookings();
  }

  @override
  void onClose() {
    vehicleNumberController.dispose();
    customerNameController.dispose();
    mobileNumberController.dispose();
    super.onClose();
  }

  void resetForm() {
    vehicleNumberController.clear();
    customerNameController.clear();
    mobileNumberController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
    hasSelectedDate.value = false;
    hasSelectedTime.value = false;
  }

  // Fetch Bookings list from Backend API
  Future<void> fetchBookings() async {
    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isLoading.value = true;
    try {
      final response = await _apiService.get('/bookings?garageOwner=$ownerId');
      if (response.data != null && response.data['success'] == true) {
        bookings.value = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Pick Date Dialog
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      hasSelectedDate.value = true;
    }
  }

  // Pick Time Dialog
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
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
      selectedTime.value = picked;
      hasSelectedTime.value = true;
    }
  }

  String getFormattedDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String getFormattedTime(TimeOfDay tod, BuildContext context) {
    return tod.format(context);
  }

  // Validate vehicle number format: 2 letters + 2 digits + 1-2 letters + 4 digits
  // Example: AB12C2345
  bool isValidVehicleNumber(String vehicleNo) {
    final pattern = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
    return pattern.hasMatch(vehicleNo);
  }

  // Create Booking
  Future<void> createBooking(BuildContext context) async {
    final vehicle = vehicleNumberController.text.trim().toUpperCase();
    final name = customerNameController.text.trim();
    final phone = mobileNumberController.text.trim();

    if (vehicle.isEmpty || name.isEmpty || phone.isEmpty || !hasSelectedDate.value || !hasSelectedTime.value) {
      Get.snackbar(
        'Required Fields',
        'Please fill in all the details, select date and time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!isValidVehicleNumber(vehicle)) {
      Get.snackbar(
        'Invalid Vehicle Number',
        'Format: 2 letters + 2 digits + 1-2 letters + 4 digits (e.g., AB12C2345)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (phone.length < 10) {
      Get.snackbar(
        'Invalid Mobile',
        'Please enter a valid 10-digit mobile number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final owner = _apiService.getUser();
    if (owner == null) return;
    final ownerId = owner['id'] ?? owner['_id'];

    isSubmitting.value = true;
    try {
      final requestBody = {
        'garageOwner': ownerId,
        'vehicleNumber': vehicle,
        'customerName': name,
        'mobileNumber': phone,
        'bookingDate': getFormattedDate(selectedDate.value),
        'bookingTime': getFormattedTime(selectedTime.value, context),
        'notes': ''
      };

      final response = await _apiService.post('/bookings', data: requestBody);

      if (response.data != null && (response.data['success'] == true || response.statusCode == 201)) {
        Get.snackbar(
          'Booking Created',
          'Successfully scheduled appointment for $vehicle.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        resetForm();
        fetchBookings(); // Refresh bookings
      } else {
        final msg = response.data != null ? response.data['message'] : 'Failed to save booking';
        Get.snackbar('Error', msg ?? 'Failed to save',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error creating booking: $e');
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
