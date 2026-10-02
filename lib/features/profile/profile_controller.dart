import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/values/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> garageOwner = <String, dynamic>{}.obs;

  // Form Controllers
  final formKey = GlobalKey<FormState>();

  // Workshop Banner
  final RxString customBanner = ''.obs;
  final bannerTitleController = TextEditingController();
  final bannerSubtitleController = TextEditingController();

  // Workshop Info
  final workshopNameController = TextEditingController();
  final billHeaderController = TextEditingController();
  final RxList<String> selectedWorkshopTypes = <String>[].obs; // '2 Wheeler', etc.

  // Business Categories
  final RxList<String> selectedCategories = <String>[].obs;

  // Establishment & Details
  final yearEstablishedController = TextEditingController();
  final RxString yearlyTurnover = ''.obs;
  final RxString numberOfEmployees = ''.obs;

  // Personal Information
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final RxString mobileNumber = ''.obs; // read-only
  final phoneNumber2Controller = TextEditingController();

  // Location Information
  final addressController = TextEditingController();
  final buildingNameController = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Business Timings
  final openingTimeController = TextEditingController(text: '09:00');
  final closingTimeController = TextEditingController(text: '18:00');
  final RxString weeklyOff = 'Sunday'.obs;
  final RxList<Map<String, dynamic>> weeklySchedule = <Map<String, dynamic>>[
    {'day': 'Monday',    'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Tuesday',   'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Wednesday', 'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Thursday',  'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Friday',    'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Saturday',  'isOpen': true,  'openingTime': '09:00', 'closingTime': '18:00'},
    {'day': 'Sunday',    'isOpen': false, 'openingTime': '09:00', 'closingTime': '18:00'},
  ].obs;

  // Vehicle & Service Specifics
  final RxList<String> selectedFuelTypes = <String>[].obs;
  final RxList<String> selectedServiceTypes = <String>[].obs;
  final RxList<String> selectedServicedMakes = <String>[].obs;

  // Payment Methods
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;

  // Online Presence
  final websiteUrlController = TextEditingController();
  final facebookUrlController = TextEditingController();
  final instagramUrlController = TextEditingController();
  final youtubeUrlController = TextEditingController();

  // KYC & Payment Details
  final panCardController = TextEditingController();
  final aadhaarCardController = TextEditingController();
  final gstNumberController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final upiIdController = TextEditingController();

  // Services & Pricing
  final servicesCardController = TextEditingController();
  final termsController = TextEditingController();

  // Multi-select Lists
  final List<String> workshopTypeOptions = const ['2 Wheeler', '3 Wheeler', '4 Wheeler', '6 Wheeler'];
  final List<String> categoryOptions = const [
    'Periodic Services', 'Brake Service', 'AC Repair', 'Washing & Detailing',
    'Engine Work', 'Electrical Work', 'Wheel Alignment', 'Body Repair'
  ];
  final List<String> turnoverOptions = const ['', '0-5L', '5-10L', '10-50L', '50L+'];
  final List<String> employeeOptions = const ['', '1-5', '5-10', '10-20', '20+'];
  final List<String> daysOfWeek = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'None'];
  final List<String> fuelTypeOptions = const ['Petrol', 'Diesel', 'CNG', 'Electric', 'LPG'];
  final List<String> serviceTypeOptions = const [
    'Gen Service', 'Engine Work', 'Brake Service', 'AC Repair', 'Washing & Detailing',
    'Electrical Work', 'Wheel Alignment', 'Body Repair', 'Periodic Services',
  ];
  final List<String> servicedMakesOptions = const [
    'Maruti', 'Honda', 'Hyundai', 'Toyota', 'Tata', 'Mahindra', 'Ford',
    'Volkswagen', 'Skoda', 'Kia', 'MG', 'Renault', 'Nissan', 'Bajaj',
    'Hero', 'TVS', 'Royal Enfield',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchGarageProfile();
  }

  @override
  void onClose() {
    // Dispose text controllers
    bannerTitleController.dispose();
    bannerSubtitleController.dispose();
    workshopNameController.dispose();
    billHeaderController.dispose();
    yearEstablishedController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumber2Controller.dispose();
    addressController.dispose();
    buildingNameController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    websiteUrlController.dispose();
    facebookUrlController.dispose();
    instagramUrlController.dispose();
    youtubeUrlController.dispose();
    panCardController.dispose();
    aadhaarCardController.dispose();
    gstNumberController.dispose();
    bankAccountNumberController.dispose();
    ifscCodeController.dispose();
    upiIdController.dispose();
    servicesCardController.dispose();
    termsController.dispose();
    super.onClose();
  }

  Map<String, dynamic> _normalizeGarageProfile(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final workshopName = normalized['workshopName'] ?? normalized['garageName'] ?? '';
    final customLogo = normalized['customLogo'] ?? normalized['logoUrl'] ?? normalized['logo'] ?? '';
    final customBanner = normalized['customBanner'] ?? normalized['bannerUrl'] ?? normalized['coverImage'] ?? '';

    if (workshopName.toString().isNotEmpty) {
      normalized['workshopName'] = workshopName;
    }
    if (customLogo.toString().isNotEmpty) {
      normalized['customLogo'] = customLogo;
    }
    if (customBanner.toString().isNotEmpty) {
      normalized['customBanner'] = customBanner;
    }

    return normalized;
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
        final data = _normalizeGarageProfile(Map<String, dynamic>.from(response.data['data']));
        garageOwner.value = data;
        _apiService.saveUser(data); // Sync local storage cache
        
        _populateFields(data);
      } else {
        final normalizedCache = _normalizeGarageProfile(cachedUser);
        garageOwner.value = normalizedCache;
        _populateFields(normalizedCache);
      }
    } catch (e) {
      debugPrint('Error fetching garage profile: $e');
      final normalizedCache = _normalizeGarageProfile(cachedUser);
      garageOwner.value = normalizedCache;
      _populateFields(normalizedCache);
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    final normalizedData = _normalizeGarageProfile(data);
    // Workshop Banner
    final String bannerPath = normalizedData['customBanner'] ?? '';
    String resolvedBanner = '';
    if (bannerPath.isNotEmpty) {
      if (bannerPath.startsWith('http')) {
        resolvedBanner = bannerPath;
      } else {
        resolvedBanner = ApiConstants.baseUrl.replaceAll('/api', '') + bannerPath;
      }
    }
    customBanner.value = resolvedBanner;
    debugPrint('🖼️ customBanner resolved: "$resolvedBanner"');
    bannerTitleController.text = data['bannerTitle'] ?? '';
    bannerSubtitleController.text = data['bannerSubtitle'] ?? '';

    // Workshop Info
    workshopNameController.text = data['workshopName'] ?? '';
    billHeaderController.text = data['billHeader'] ?? '';
    selectedWorkshopTypes.value = List<String>.from(data['workshopType'] ?? []);

    // Business Categories
    selectedCategories.value = List<String>.from(data['businessCategories'] ?? []);

    // Establishment & Details
    yearEstablishedController.text = data['yearEstablished'] != null ? data['yearEstablished'].toString() : '';
    yearlyTurnover.value = data['yearlyTurnover'] ?? '';
    numberOfEmployees.value = data['numberOfEmployees'] ?? '';

    // Personal Information
    firstNameController.text = data['firstName'] ?? '';
    lastNameController.text = data['lastName'] ?? '';
    emailController.text = data['email'] ?? '';
    mobileNumber.value = data['mobileNumber'] ?? '';
    phoneNumber2Controller.text = data['phoneNumber2'] ?? '';

    // Location Information
    addressController.text = data['address'] ?? '';
    buildingNameController.text = data['buildingName'] ?? '';
    landmarkController.text = data['landmark'] ?? '';
    cityController.text = data['city'] ?? '';
    stateController.text = data['state'] ?? '';
    pincodeController.text = data['pincode'] ?? '';
    latitudeController.text = data['latitude'] != null ? data['latitude'].toString() : '';
    longitudeController.text = data['longitude'] != null ? data['longitude'].toString() : '';

    // Business Timings
    openingTimeController.text = data['openingTime'] ?? '09:00';
    closingTimeController.text = data['closingTime'] ?? '18:00';
    weeklyOff.value = data['weeklyOff'] ?? 'Sunday';

    // Online Presence
    websiteUrlController.text = data['websiteUrl'] ?? '';
    facebookUrlController.text = data['facebookUrl'] ?? '';
    instagramUrlController.text = data['instagramUrl'] ?? '';
    youtubeUrlController.text = data['youtubeUrl'] ?? '';

    // KYC & Payment Details
    panCardController.text = data['panCard'] ?? '';
    aadhaarCardController.text = data['aadhaarCard'] ?? '';
    gstNumberController.text = data['gstNumber'] ?? '';
    bankAccountNumberController.text = data['bankAccountNumber'] ?? '';
    ifscCodeController.text = data['ifscCode'] ?? '';
    upiIdController.text = data['upiId'] ?? '';

    // Services & Pricing
    servicesCardController.text = data['rateCard'] ?? '';
    termsController.text = data['termsAndConditions'] ?? '';

    // Fuel Types, Service Types, Serviced Makes
    selectedFuelTypes.value = List<String>.from(data['fuelTypes'] ?? []);
    selectedServiceTypes.value = List<String>.from(data['serviceTypes'] ?? []);
    selectedServicedMakes.value = List<String>.from(data['servicedMakes'] ?? []);

    // Weekly Schedule
    if (data['weeklySchedule'] != null) {
      final List rawSchedule = data['weeklySchedule'] as List;
      weeklySchedule.value = rawSchedule
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      final String open = data['openingTime'] ?? '09:00';
      final String close = data['closingTime'] ?? '18:00';
      final String off = data['weeklyOff'] ?? 'Sunday';
      weeklySchedule.value = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
          .map((d) => <String, dynamic>{'day': d, 'isOpen': d != off, 'openingTime': open, 'closingTime': close})
          .toList();
    }

    // Payment Methods
    if (data['paymentMethods'] != null) {
      final List rawPayments = data['paymentMethods'] as List;
      paymentMethods.value = rawPayments
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  void toggleWorkshopType(String type) {
    if (selectedWorkshopTypes.contains(type)) {
      selectedWorkshopTypes.remove(type);
    } else {
      selectedWorkshopTypes.add(type);
    }
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  void toggleFuelType(String type) {
    if (selectedFuelTypes.contains(type)) {
      selectedFuelTypes.remove(type);
    } else {
      selectedFuelTypes.add(type);
    }
  }

  void toggleServiceType(String type) {
    if (selectedServiceTypes.contains(type)) {
      selectedServiceTypes.remove(type);
    } else {
      selectedServiceTypes.add(type);
    }
  }

  void toggleServicedMake(String make) {
    if (selectedServicedMakes.contains(make)) {
      selectedServicedMakes.remove(make);
    } else {
      selectedServicedMakes.add(make);
    }
  }

  void updateScheduleDay(int index, {bool? isOpen, String? openingTime, String? closingTime}) {
    final day = Map<String, dynamic>.from(weeklySchedule[index]);
    if (isOpen != null) day['isOpen'] = isOpen;
    if (openingTime != null) day['openingTime'] = openingTime;
    if (closingTime != null) day['closingTime'] = closingTime;
    weeklySchedule[index] = day;
  }

  Future<void> updateGarageProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Form Invalid',
        'Please correct the highlighted fields before saving.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final ownerId = garageOwner['id'] ?? garageOwner['_id'];
    if (ownerId == null) return;

    isLoading.value = true;

    // Assemble payload
    final String bannerToSend = customBanner.value.startsWith(ApiConstants.baseUrl.replaceAll('/api', ''))
        ? customBanner.value.replaceAll(ApiConstants.baseUrl.replaceAll('/api', ''), '')
        : customBanner.value;

    final payload = {
      'customBanner': bannerToSend,
      'bannerTitle': bannerTitleController.text.trim(),
      'bannerSubtitle': bannerSubtitleController.text.trim(),
      
      'workshopName': workshopNameController.text.trim(),
      'billHeader': billHeaderController.text.trim(),
      'workshopType': selectedWorkshopTypes,
      
      'businessCategories': selectedCategories,
      
      'yearEstablished': int.tryParse(yearEstablishedController.text.trim()),
      'yearlyTurnover': yearlyTurnover.value,
      'numberOfEmployees': numberOfEmployees.value,
      
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phoneNumber2': phoneNumber2Controller.text.trim(),
      
      'address': addressController.text.trim(),
      'buildingName': buildingNameController.text.trim(),
      'landmark': landmarkController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'pincode': pincodeController.text.trim(),
      'latitude': double.tryParse(latitudeController.text.trim()),
      'longitude': double.tryParse(longitudeController.text.trim()),
      
      'weeklySchedule': weeklySchedule.toList(),
      
      'websiteUrl': websiteUrlController.text.trim(),
      'facebookUrl': facebookUrlController.text.trim(),
      'instagramUrl': instagramUrlController.text.trim(),
      'youtubeUrl': youtubeUrlController.text.trim(),
      
      'panCard': panCardController.text.trim(),
      'aadhaarCard': aadhaarCardController.text.trim(),
      'gstNumber': gstNumberController.text.trim(),
      'bankAccountNumber': bankAccountNumberController.text.trim(),
      'ifscCode': ifscCodeController.text.trim(),
      'upiId': upiIdController.text.trim(),
      
      'fuelTypes': selectedFuelTypes.toList(),
      'serviceTypes': selectedServiceTypes.toList(),
      'servicedMakes': selectedServicedMakes.toList(),
      'paymentMethods': paymentMethods.toList(),
      'rateCard': servicesCardController.text.trim(),
      'termsAndConditions': termsController.text.trim(),
    };

    try {
      final response = await _apiService.put('/garage/update/$ownerId', data: payload);

      if (response.data != null && response.data['success'] == true) {
        final updatedData = response.data['data'];
        garageOwner.value = Map<String, dynamic>.from(updatedData);
        _apiService.saveUser(updatedData);

        Get.snackbar(
          'Profile Saved',
          'Workshop profile updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );

        Get.back(); // Return to view profile screen
      }
    } catch (e) {
      debugPrint('Error updating garage profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void simulateBannerUpload() {
    // Show a mockup list of high-quality workshop banner options
    final mockBannerUrls = [
      'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1517524206127-48bbd363f3d7?auto=format&fit=crop&w=800&q=80',
    ];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Custom Banner', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a mockup workshop banner for your digital front store:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...List.generate(mockBannerUrls.length, (idx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    customBanner.value = mockBannerUrls[idx];
                    Get.back();
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(mockBannerUrls[idx]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_outlined, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> uploadRealBanner(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final ownerId = garageOwner['id'] ?? garageOwner['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      final dio.FormData formData = dio.FormData.fromMap({
        'banner': await dio.MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      final response = await _apiService.post(
        '/garage/profile/$ownerId/banner',
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        final newBannerPath = response.data['data']['customBanner'];
        
        // Resolve path to full URL immediately
        customBanner.value = ApiConstants.baseUrl.replaceAll('/api', '') + newBannerPath;
        
        // Update user state and cache
        final updatedData = Map<String, dynamic>.from(garageOwner);
        updatedData['customBanner'] = newBannerPath;
        garageOwner.value = updatedData;
        _apiService.saveUser(updatedData);

        Get.snackbar(
          'Banner Uploaded',
          'Workshop custom banner uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      }
    } catch (e) {
      debugPrint('Error uploading banner in controller: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not upload banner. Please ensure the backend is running.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadRealLogo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final ownerId = garageOwner['id'] ?? garageOwner['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      final dio.FormData formData = dio.FormData.fromMap({
        'logo': await dio.MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      final response = await _apiService.post(
        '/garage/profile/$ownerId/logo',
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        final newLogoPath = response.data['data']['logoUrl'] ?? response.data['data']['customLogo'] ?? '';
        final resolvedLogoUrl = newLogoPath.toString().startsWith('http')
            ? newLogoPath.toString()
            : ApiConstants.baseUrl.replaceAll('/api', '') + newLogoPath.toString();

        // Update user state and cache
        final updatedData = Map<String, dynamic>.from(garageOwner);
        updatedData['customLogo'] = resolvedLogoUrl;
        garageOwner.value = updatedData;
        _apiService.saveUser(updatedData);

        Get.snackbar(
          'Logo Uploaded',
          'Workshop custom logo uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      }
    } catch (e) {
      debugPrint('Error uploading logo in controller: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not upload logo. Please ensure the backend is running.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showBannerUploadSelection(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Workshop Banner Option',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                uploadRealBanner(context);
              },
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Get.back();
                simulateBannerUpload();
              },
              icon: const Icon(Icons.image_search_outlined, color: AppColors.primary),
              label: const Text('Choose Mockup Banner'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
