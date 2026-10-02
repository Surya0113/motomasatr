import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/core/values/asset_constants.dart';

class GarageProfileEditView extends GetView<ProfileController> {
  const GarageProfileEditView({super.key});

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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'edit_profile'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.garageOwner.isEmpty) {
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
                      // 1. Custom Banner Section Card
                      _buildSectionCard(
                        title: 'Workshop Banner',
                        icon: Icons.photo_size_select_actual_outlined,
                        children: [
                          const Text(
                            'Upload your workshop banner to display on search profiles and public catalogs.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final banner = controller.customBanner.value;
                            return Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                                image: banner.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(banner),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: AssetImage(
                                          AssetConstants.defaultBanner,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: banner.isEmpty ? null : null,
                            );
                          }),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                controller.showBannerUploadSelection(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Workshop Banner',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: controller.bannerTitleController,
                            label: 'Banner Title',
                            icon: Icons.title,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.bannerSubtitleController,
                            label: 'Banner Subtitle',
                            icon: Icons.subtitles,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. Workshop Logo Card
                      _buildSectionCard(
                        title: 'Workshop Logo',
                        icon: Icons.image_outlined,
                        children: [
                          const Text(
                            'Upload the logo that appears in your workshop profile and dashboard.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final logo = controller.garageOwner['customLogo'] ?? '';
                            final safeLogo = logo.toString();
                            final workshopName = controller.workshopNameController.text.trim();
                            final initials = workshopName.isNotEmpty
                                ? workshopName
                                    .split(RegExp(r'\s+'))
                                    .take(2)
                                    .map((word) => word[0].toUpperCase())
                                    .join()
                                : 'G';
                            final resolvedLogo = safeLogo.isNotEmpty
                                ? (safeLogo.startsWith('http')
                                    ? safeLogo
                                    : ApiConstants.baseUrl.replaceAll('/api', '') + safeLogo)
                                : '';

                            return Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.1),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: resolvedLogo.isEmpty
                                    ? Center(
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.network(
                                          resolvedLogo,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => controller.uploadRealLogo(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Workshop Logo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Workshop Information Card
                      _buildSectionCard(
                        title: 'workshop_information'.tr,
                        icon: Icons.storefront_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.workshopNameController,
                            label: 'Workshop Name *',
                            icon: Icons.store,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter workshop name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.billHeaderController,
                            label: 'billing_header'.tr,
                            icon: Icons.receipt_long,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Workshop Type *',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(() {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.workshopTypeOptions.map((
                                type,
                              ) {
                                final isSelected = controller
                                    .selectedWorkshopTypes
                                    .contains(type);
                                return ChoiceChip(
                                  label: Text(type),
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
                                  onSelected: (_) =>
                                      controller.toggleWorkshopType(type),
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Business Categories Card
                      _buildSectionCard(
                        title: 'business_categories'.tr,
                        icon: Icons.category_outlined,
                        children: [
                          const Text(
                            'Select categories your workshop operates in:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.categoryOptions.map((cat) {
                                final isSelected = controller.selectedCategories
                                    .contains(cat);
                                return FilterChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.15,
                                  ),
                                  checkmarkColor: AppColors.primary,
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
                                  onSelected: (_) =>
                                      controller.toggleCategory(cat),
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Establishment Card
                      _buildSectionCard(
                        title: 'Establishment & Details',
                        icon: Icons.business_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.yearEstablishedController,
                            label: 'year_establishment'.tr,
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            label: 'yearly_turnover'.tr,
                            icon: Icons.monetization_on,
                            value: controller.yearlyTurnover,
                            options: controller.turnoverOptions,
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            label: 'number_employees'.tr,
                            icon: Icons.people,
                            value: controller.numberOfEmployees,
                            options: controller.employeeOptions,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. Personal Information Card
                      _buildSectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          _buildInputField(
                            controller: controller.firstNameController,
                            label: 'First Name *',
                            icon: Icons.person,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter first name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.lastNameController,
                            label: 'Last Name *',
                            icon: Icons.person,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter last name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.emailController,
                            label: 'Email Address *',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Enter email';
                              if (!v.contains('@') || !v.contains('.'))
                                return 'Invalid email format';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          // Mobile phone - read only prefilled
                          Obx(() {
                            return TextFormField(
                              initialValue: controller.mobileNumber.value,
                              enabled: false,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                ),
                                labelText: 'Mobile Phone (Primary)',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.phoneNumber2Controller,
                            label: 'Alternate Phone',
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 6. Location Information Card
                      _buildSectionCard(
                        title: 'location_information'.tr,
                        icon: Icons.location_on_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.addressController,
                            label: 'Street Address *',
                            icon: Icons.home,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter street address'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.buildingNameController,
                            label: 'Shop / Building Name',
                            icon: Icons.apartment,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.landmarkController,
                            label: 'Landmark',
                            icon: Icons.explore,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.cityController,
                                  label: 'City *',
                                  icon: Icons.location_city,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Enter city'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.stateController,
                                  label: 'State *',
                                  icon: Icons.map,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Enter state'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.pincodeController,
                            label: 'Pincode *',
                            icon: Icons.pin_drop,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Enter pincode';
                              if (v.trim().length != 6)
                                return 'Pincode must be 6 digits';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.latitudeController,
                                  label: 'Latitude',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.longitudeController,
                                  label: 'Longitude',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 7. Business Timings Card
                      _buildSectionCard(
                        title: 'business_timings'.tr,
                        icon: Icons.access_time_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.openingTimeController,
                                  label: 'Opening Time',
                                  icon: Icons.login,
                                  keyboardType: TextInputType.datetime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: controller.closingTimeController,
                                  label: 'Closing Time',
                                  icon: Icons.logout,
                                  keyboardType: TextInputType.datetime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            label: 'Weekly Off Day',
                            icon: Icons.today,
                            value: controller.weeklyOff,
                            options: controller.daysOfWeek,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 8. Online Presence Card
                      _buildSectionCard(
                        title: 'online_presence'.tr,
                        icon: Icons.public_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.websiteUrlController,
                            label: 'Website URL',
                            icon: Icons.language,
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.facebookUrlController,
                            label: 'Facebook URL',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.instagramUrlController,
                            label: 'Instagram URL',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.youtubeUrlController,
                            label: 'YouTube URL',
                            icon: Icons.link,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 9. KYC & Payments Card
                      _buildSectionCard(
                        title: 'kyc_payment_details'.tr,
                        icon: Icons.verified_user_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.panCardController,
                            label: 'PAN Card Number',
                            icon: Icons.credit_card,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.aadhaarCardController,
                            label: 'Aadhaar Card Number',
                            icon: Icons.credit_card,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.gstNumberController,
                            label: 'GST Number (Optional)',
                            icon: Icons.corporate_fare,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.bankAccountNumberController,
                            label: 'Bank Account Number',
                            icon: Icons.account_balance,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.ifscCodeController,
                            label: 'IFSC Code',
                            icon: Icons.code,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.upiIdController,
                            label: 'UPI ID',
                            icon: Icons.wallet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 10. Services & Pricing Card
                      _buildSectionCard(
                        title: 'services_pricing'.tr,
                        icon: Icons.description_outlined,
                        children: [
                          _buildInputField(
                            controller: controller.servicesCardController,
                            label: 'Services Offered / Rate Card',
                            icon: Icons.list_alt,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: controller.termsController,
                            label: 'Terms & Conditions',
                            icon: Icons.rule,
                            maxLines: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom Row Buttons
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
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
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
                            : () => controller.updateGarageProfile(),
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
                                'save_profile'.tr,
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
