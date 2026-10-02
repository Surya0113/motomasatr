import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';

class StaffAddView extends GetView<StaffController> {
  const StaffAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            controller.makeDefaultTechnician.value = false;
            Get.back();
          },
        ),
        title: Text(
          'add_staff_member'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.staffList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      // Section: Personal Details
                      _buildSectionCard(
                        title: 'personal_details'.tr,
                        icon: Icons.person_outline,
                        children: [
                          _buildInputField(
                            controller: controller.fullNameController,
                            label: '${'full_name'.tr} *',
                            icon: Icons.person,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter full name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.mobileNumberController,
                            label: '${'mobile_number'.tr} *',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Enter mobile number';
                              if (v.trim().length != 10)
                                return 'Must be 10 digits';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.alternateMobileController,
                            label: 'alternate_mobile'.tr,
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.emailController,
                            label: 'email_address'.tr,
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section: Employment Info
                      _buildSectionCard(
                        title: 'employment_scale'.tr,
                        icon: Icons.business_center_outlined,
                        children: [
                          _buildDropdownField(
                            label: '${'role_staff_type'.tr} *',
                            icon: Icons.work_outline,
                            value: controller.selectedStaffType,
                            options: controller.staffRoles,
                          ),
                          if (controller.selectedStaffType.value ==
                                  'Mechanic' ||
                              controller.selectedStaffType.value ==
                                  'Supervisor') ...[
                            const SizedBox(height: 14),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFD54F),
                                ),
                              ),
                              child: SwitchListTile(
                                value: controller.makeDefaultTechnician.value,
                                onChanged: (value) =>
                                    controller.makeDefaultTechnician.value =
                                        value,
                                activeThumbColor: Colors.amber[800],
                                secondary: Icon(
                                  controller.makeDefaultTechnician.value
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.amber[800],
                                ),
                                title: Text(
                                  'set_default_technician'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'default_technician_help'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.joiningDateController,
                            label: '${'date_of_joining'.tr} *',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.datetime,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter joining date'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.salaryController,
                                  label: '${'monthly_salary'.tr} *',
                                  icon: Icons.monetization_on_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Enter salary'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.incentiveController,
                                  label: 'incentive'.tr,
                                  icon: Icons.percent,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section: Physical Address
                      _buildSectionCard(
                        title: 'residence_address'.tr,
                        icon: Icons.location_on_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.addressController,
                            label: '${'address_details'.tr} *',
                            icon: Icons.home,
                            maxLines: 3,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter address details'
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom buttons
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.makeDefaultTechnician.value = false;
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final saving = controller.isLoading.value;
                      return ElevatedButton(
                        onPressed: saving
                            ? null
                            : () => controller.createStaffMember(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'add_staff'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Styled Header Banner Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0E2FF), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0056C6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [UppercaseTextFormatter()],
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required RxString value,
    required List<String> options,
  }) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonFormField<String>(
          value: value.value.isEmpty ? null : value.value,
          validator: (v) => null,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            labelText: label,
            labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (newValue) {
            value.value = newValue ?? '';
          },
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(opt.isEmpty ? 'Select Option' : opt),
            );
          }).toList(),
        ),
      );
    });
  }
}
