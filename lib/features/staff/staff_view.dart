import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import '../../../app/routes/app_routes.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'staff_management'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => controller.fetchStaffList(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.staffList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            // 1. Search Bar & Horizontal Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 8,
              ),
              child: Column(
                children: [
                  // Search Input
                  TextFormField(
                    controller: controller.searchController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const [UppercaseTextFormatter()],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      hintText: 'search_staff_hint'.tr,
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scrolling filters row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Obx(() {
                      return Row(
                        children: controller.roleFilterOptions.map((role) {
                          final isSelected =
                              controller.selectedRoleFilter.value == role;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(role),
                              selected: isSelected,
                              selectedColor: AppColors.primary.withOpacity(
                                0.15,
                              ),
                              backgroundColor: const Color(0xFFF3F5F9),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              onSelected: (_) => controller.setRoleFilter(role),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 2. Metrics Info Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'total_staff'.tr,
                      '${controller.totalStaff.value}',
                      Icons.group_outlined,
                      const Color(0xFFEBF5FF),
                      const Color(0xFF0D6EFD),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'active'.tr,
                      '${controller.activeStaff.value}',
                      Icons.check_circle_outline,
                      const Color(0xFFE8F8EE),
                      const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'mechanics'.tr,
                      '${controller.totalMechanics.value}',
                      Icons.build_circle_outlined,
                      const Color(0xFFFEF3C7),
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Staff List Area
            Expanded(
              child: Obx(() {
                final staff = controller.filteredStaffList;
                if (staff.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Colors.grey[300],
                          size: 70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_staff_found'.tr,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap + button below to add your first staff member.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 80,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: staff.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = staff[index];
                    final fullName =
                        member['fullName']?.toString() ?? 'Staff Name';
                    final role = member['staffType']?.toString() ?? 'Role';
                    final phone = member['mobileNumber']?.toString() ?? 'N/A';
                    final address = member['address']?.toString() ?? 'N/A';
                    final isActive = member['isActive'] ?? true;
                    final salary = member['salary']?.toString() ?? '0';
                    final staffId = (member['_id'] ?? member['id'])?.toString();
                    final canBeDefault =
                        isActive &&
                        (role == 'Mechanic' || role == 'Supervisor') &&
                        staffId != null;
                    final isDefault =
                        staffId != null &&
                        controller.defaultTechnicianId.value == staffId;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDefault ? Colors.amber : Colors.grey[100]!,
                          width: isDefault ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left circle initials avatar
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _getRoleBgColor(role),
                            child: Text(
                              fullName[0].toUpperCase(),
                              style: TextStyle(
                                color: _getRoleTextColor(role),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Center text details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fullName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoleTag(role),
                                  ],
                                ),
                                if (isDefault) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7D6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'default_technician'.tr,
                                      style: TextStyle(
                                        color: Colors.amber[800],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Salary: ₹$salary',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFFE8F8EE)
                                            : const Color(0xFFF3F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive
                                              ? const Color(0xFF10B981)
                                              : Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canBeDefault)
                                Tooltip(
                                  message: isDefault
                                      ? 'default_technician'.tr
                                      : 'set_default_technician'.tr,
                                  child: IconButton(
                                    icon: Icon(
                                      isDefault
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: isDefault
                                          ? Colors.amber[700]
                                          : AppColors.textSecondary,
                                      size: 23,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 34,
                                      minHeight: 34,
                                    ),
                                    onPressed: isDefault
                                        ? null
                                        : () => controller.setDefaultTechnician(
                                            member,
                                          ),
                                  ),
                                ),
                              if (isActive)
                                IconButton(
                                  icon: const Icon(
                                    Icons.person_remove_outlined,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  onPressed: () => _confirmDeactivate(
                                    staffId ?? '',
                                    fullName,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.staffAdd),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _confirmDeactivate(String staffId, String name) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('remove_staff_member'.tr),
        content: Text('${'deactivate_confirm'.tr} $name?'),
        actions: [
          TextButton(
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text(
              'deactivate'.tr,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Get.back();
              controller.deactivateStaffMember(staffId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String val,
    IconData icon,
    Color bg,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  val,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTag(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleBgColor(role),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _getRoleTextColor(role),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleBgColor(String role) {
    switch (role) {
      case 'Receptionist':
        return const Color(0xFFEBF5FF);
      case 'Mechanic':
        return const Color(0xFFFEF3C7);
      case 'Supervisor':
        return const Color(0xFFE8F8EE);
      case 'Spare':
        return const Color(0xFFFEE2E2);
      case 'Washing':
        return const Color(0xFFE0F2FE);
      default:
        return const Color(0xFFF3F5F9);
    }
  }

  Color _getRoleTextColor(String role) {
    switch (role) {
      case 'Receptionist':
        return const Color(0xFF0D6EFD);
      case 'Mechanic':
        return const Color(0xFFD97706);
      case 'Supervisor':
        return const Color(0xFF10B981);
      case 'Spare':
        return const Color(0xFFEF4444);
      case 'Washing':
        return const Color(0xFF0284C7);
      default:
        return AppColors.textPrimary;
    }
  }
}
