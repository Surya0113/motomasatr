import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/theme/app_colors.dart';

class StaffController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxList<dynamic> staffList = <dynamic>[].obs;
  final RxList<dynamic> filteredStaffList = <dynamic>[].obs;
  final RxString defaultTechnicianId = ''.obs;
  final RxString defaultTechnicianName = ''.obs;
  final GetStorage _storage = GetStorage();

  // Search & Filters
  final searchController = TextEditingController();
  final RxString selectedRoleFilter = 'All'.obs;

  // Form Controllers
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final alternateMobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final joiningDateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  final salaryController = TextEditingController(text: '0');
  final incentiveController = TextEditingController(text: '0');

  final RxString selectedStaffType = 'Mechanic'.obs;
  final RxBool makeDefaultTechnician = false.obs;

  final List<String> staffRoles = const [
    'Receptionist',
    'Spare',
    'Washing',
    'Helper',
    'Fitter',
    'Mechanic',
    'Supervisor',
  ];

  final List<String> roleFilterOptions = const [
    'All',
    'Receptionist',
    'Spare',
    'Washing',
    'Helper',
    'Fitter',
    'Mechanic',
    'Supervisor',
  ];

  // Stats
  final RxInt totalStaff = 0.obs;
  final RxInt activeStaff = 0.obs;
  final RxInt totalMechanics = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultTechnician();
    fetchStaffList();
    searchController.addListener(_onSearchChanged);
  }

  String _preferenceKey(String ownerId) => 'default_technician_$ownerId';

  void _loadDefaultTechnician() {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = (cachedUser['id'] ?? cachedUser['_id'])?.toString();
    if (ownerId == null || ownerId.isEmpty) return;

    final stored = _storage.read(_preferenceKey(ownerId));
    defaultTechnicianId.value =
        cachedUser['defaultTechnicianId']?.toString() ??
        (stored is Map ? stored['id']?.toString() : null) ??
        '';
    defaultTechnicianName.value =
        cachedUser['defaultTechnicianName']?.toString() ??
        (stored is Map ? stored['name']?.toString() : null) ??
        '';
  }

  Future<void> setDefaultTechnician(
    dynamic member, {
    bool showMessage = true,
  }) async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = (cachedUser['id'] ?? cachedUser['_id'])?.toString();
    final staffId = (member['_id'] ?? member['id'])?.toString();
    final name = member['fullName']?.toString() ?? '';
    final role = member['staffType']?.toString() ?? '';
    final isActive = member['isActive'] ?? true;

    if (ownerId == null ||
        ownerId.isEmpty ||
        staffId == null ||
        staffId.isEmpty ||
        !isActive ||
        (role != 'Mechanic' && role != 'Supervisor')) {
      return;
    }

    defaultTechnicianId.value = staffId;
    defaultTechnicianName.value = name;
    await _storage.write(_preferenceKey(ownerId), {
      'id': staffId,
      'name': name,
    });

    final updatedCache = Map<String, dynamic>.from(cachedUser)
      ..['defaultTechnicianId'] = staffId
      ..['defaultTechnicianName'] = name;
    _apiService.saveUser(updatedCache);

    try {
      final response = await _apiService.put(
        '/garage/update/$ownerId',
        data: {'defaultTechnicianId': staffId, 'defaultTechnicianName': name},
      );
      if (response.data != null && response.data['success'] == true) {
        final backendUser =
            Map<String, dynamic>.from(response.data['data'] ?? updatedCache)
              ..['defaultTechnicianId'] = staffId
              ..['defaultTechnicianName'] = name;
        _apiService.saveUser(backendUser);
      }
    } catch (e) {
      debugPrint('Error syncing default technician: $e');
    }

    if (showMessage) {
      Get.snackbar(
        'default_technician'.tr,
        '$name ${'default_technician'.tr.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.star_rounded, color: Colors.white),
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    joiningDateController.dispose();
    salaryController.dispose();
    incentiveController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    applyFilters();
  }

  Future<void> fetchStaffList() async {
    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;
    try {
      final response = await _apiService.get('/staff/all/$ownerId');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        staffList.value = data;
        applyFilters();
        _calculateStats();
      }
    } catch (e) {
      debugPrint('Error fetching staff list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    final role = selectedRoleFilter.value;

    var filtered = staffList.where((member) {
      final matchesSearch =
          member['fullName']?.toString().toLowerCase().contains(query) ?? false;
      final matchesRole = role == 'All' || member['staffType'] == role;
      return matchesSearch && matchesRole;
    }).toList();

    filteredStaffList.value = filtered;
  }

  void setRoleFilter(String role) {
    selectedRoleFilter.value = role;
    applyFilters();
  }

  void _calculateStats() {
    totalStaff.value = staffList.length;
    activeStaff.value = staffList.where((s) => s['isActive'] == true).length;
    totalMechanics.value = staffList
        .where((s) => s['staffType'] == 'Mechanic')
        .length;
  }

  Future<void> createStaffMember() async {
    if (!formKey.currentState!.validate()) return;

    final cachedUser = _apiService.getUser();
    if (cachedUser == null) return;

    final ownerId = cachedUser['id'] ?? cachedUser['_id'];
    if (ownerId == null) return;

    isLoading.value = true;

    final payload = {
      'garageOwnerId': ownerId,
      'staffType': selectedStaffType.value,
      'fullName': fullNameController.text.trim(),
      'mobileNumber': mobileNumberController.text.trim(),
      'alternateMobileNumber': alternateMobileController.text.trim(),
      'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'joiningDate': joiningDateController.text.trim(),
      'salary': double.tryParse(salaryController.text.trim()) ?? 0.0,
      'incentivePercentage':
          double.tryParse(incentiveController.text.trim()) ?? 0.0,
    };

    try {
      final response = await _apiService.post('/staff/create', data: payload);
      if (response.data != null && response.data['success'] == true) {
        final addedStaffName = fullNameController.text.trim();
        final addedMobile = mobileNumberController.text.trim();
        final addedRole = selectedStaffType.value;
        final shouldMakeDefault =
            makeDefaultTechnician.value &&
            (addedRole == 'Mechanic' || addedRole == 'Supervisor');

        // Reset fields
        fullNameController.clear();
        mobileNumberController.clear();
        alternateMobileController.clear();
        emailController.clear();
        addressController.clear();
        salaryController.text = '0';
        incentiveController.text = '0';
        makeDefaultTechnician.value = false;

        Get.back(); // Go back to staff list view
        await fetchStaffList();
        if (shouldMakeDefault) {
          dynamic createdStaff = response.data['data'];
          final createdId = createdStaff is Map
              ? (createdStaff['_id'] ?? createdStaff['id'])?.toString()
              : null;
          if (createdId == null || createdId.isEmpty) {
            createdStaff = staffList.firstWhereOrNull(
              (member) =>
                  member['fullName']?.toString() == addedStaffName &&
                  member['mobileNumber']?.toString() == addedMobile,
            );
          }
          if (createdStaff != null) {
            await setDefaultTechnician(createdStaff, showMessage: false);
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 150));
        _showStaffAddedPopup(addedStaffName);
      }
    } catch (e) {
      debugPrint('Error creating staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showStaffAddedPopup(String staffName) {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'staff_added_successfully'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (staffName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  staffName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back<void>(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'done'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> deactivateStaffMember(String staffId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.delete('/staff/$staffId');
      if (response.data != null && response.data['success'] == true) {
        Get.snackbar(
          'Staff Deactivated',
          'Staff member status updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        fetchStaffList();
      }
    } catch (e) {
      debugPrint('Error deactivating staff: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
