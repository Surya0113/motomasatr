import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/core/values/asset_constants.dart';

class GarageProfileView extends GetView<ProfileController> {
  const GarageProfileView({super.key});

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
          'garage_profile'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.profileEdit),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.garageOwner.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final owner = controller.garageOwner;
        if (owner.isEmpty) {
          return const Center(child: Text('No profile data available.'));
        }

        final workshopName =
            owner['workshopName'] ?? owner['garageName'] ?? 'Garage';
        final firstName = owner['firstName'] ?? 'Garage';
        final lastName = owner['lastName'] ?? 'Owner';
        final email = owner['email'] ?? 'email@gmail.com';
        final bannerImg = controller.customBanner.value;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Cover Card & Profile Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Cover Banner Image
                        Container(
                          height: 160,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                        // Shop Details centered bottom
                        Positioned(
                          top: 100,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => controller.uploadRealLogo(context),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppColors.primary,
                                        child: (() {
                                          final rawLogo = owner['customLogo']?.toString() ?? '';
                                          final resolvedLogo = rawLogo.isNotEmpty
                                              ? (rawLogo.startsWith('http')
                                                  ? rawLogo
                                                  : ApiConstants.baseUrl.replaceAll('/api', '') + rawLogo)
                                              : '';
                                          final initials = workshopName.isNotEmpty
                                              ? workshopName
                                                  .trim()
                                                  .split(RegExp(r'\s+'))
                                                  .take(2)
                                                  .map((word) => word[0].toUpperCase())
                                                  .join()
                                              : 'G';

                                          if (resolvedLogo.isEmpty) {
                                            return Text(
                                              initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }

                                          return ClipOval(
                                            child: Image.network(
                                              resolvedLogo,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        })(),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                workshopName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBF5FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Workshop Owner',
                                  style: TextStyle(
                                    color: Color(0xFF0056C6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120), // Spacing for avatar stacking
                    // 2. Sections Lists
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Section: Workshop Information
                          _buildSectionCard(
                            title: 'workshop_information'.tr,
                            icon: Icons.storefront_outlined,
                            children: [
                              _buildInfoRow('Workshop Name', workshopName),
                              _buildInfoRow(
                                'billing_header'.tr,
                                owner['billHeader'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Workshop Type',
                                List<String>.from(
                                  owner['workshopType'] ?? [],
                                ).join(', '),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Business Categories
                          _buildSectionCard(
                            title: 'business_categories'.tr,
                            icon: Icons.category_outlined,
                            children: [
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    List<String>.from(
                                      owner['businessCategories'] ?? [],
                                    ).map((cat) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F5F9),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Text(
                                          cat,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              if (List<String>.from(
                                owner['businessCategories'] ?? [],
                              ).isEmpty)
                                const Text(
                                  'No categories specified.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Custom Banner details
                          _buildSectionCard(
                            title: 'Custom Workshop Banner',
                            icon: Icons.photo_size_select_actual_outlined,
                            children: [
                              _buildInfoRow(
                                'Banner Title',
                                owner['bannerTitle'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Banner Subtitle',
                                owner['bannerSubtitle'] ?? 'N/A',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Personal Information
                          _buildSectionCard(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            children: [
                              _buildInfoRow('First Name', firstName),
                              _buildInfoRow('Last Name', lastName),
                              _buildInfoRow('Email Address', email),
                              _buildInfoRow(
                                'Mobile Phone',
                                owner['mobileNumber'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Alternate Phone',
                                owner['phoneNumber2'] ?? 'N/A',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Location Information
                          _buildSectionCard(
                            title: 'location_information'.tr,
                            icon: Icons.location_on_outlined,
                            children: [
                              _buildInfoRow(
                                'Street Address',
                                owner['address'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Building/Shop Name',
                                owner['buildingName'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Landmark',
                                owner['landmark'] ?? 'N/A',
                              ),
                              _buildInfoRow('City', owner['city'] ?? 'N/A'),
                              _buildInfoRow('State', owner['state'] ?? 'N/A'),
                              _buildInfoRow(
                                'Pincode',
                                owner['pincode'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Latitude',
                                owner['latitude']?.toString() ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Longitude',
                                owner['longitude']?.toString() ?? 'N/A',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Timings & Offs
                          _buildSectionCard(
                            title: 'business_timings'.tr,
                            icon: Icons.access_time_outlined,
                            children: [
                              _buildInfoRow(
                                'Opening Time',
                                owner['openingTime'] ?? '09:00',
                              ),
                              _buildInfoRow(
                                'Closing Time',
                                owner['closingTime'] ?? '18:00',
                              ),
                              _buildInfoRow(
                                'Weekly Off Day',
                                owner['weeklyOff'] ?? 'Sunday',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Online Presence
                          _buildSectionCard(
                            title: 'online_presence'.tr,
                            icon: Icons.public_outlined,
                            children: [
                              _buildInfoRow(
                                'Website URL',
                                owner['websiteUrl'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Facebook URL',
                                owner['facebookUrl'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Instagram URL',
                                owner['instagramUrl'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'YouTube URL',
                                owner['youtubeUrl'] ?? 'N/A',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: KYC & Payments
                          _buildSectionCard(
                            title: 'kyc_payment_details'.tr,
                            icon: Icons.verified_user_outlined,
                            children: [
                              _buildInfoRow(
                                'PAN Card',
                                owner['panCard'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Aadhaar Card',
                                owner['aadhaarCard'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'GST Number',
                                owner['gstNumber'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Bank Account',
                                owner['bankAccountNumber'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'IFSC Code',
                                owner['ifscCode'] ?? 'N/A',
                              ),
                              _buildInfoRow('UPI ID', owner['upiId'] ?? 'N/A'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Section: Services & T&C
                          _buildSectionCard(
                            title: 'services_pricing'.tr,
                            icon: Icons.description_outlined,
                            children: [
                              _buildInfoRow(
                                'Rate / Service Card',
                                owner['rateCard'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Terms & Conditions',
                                owner['termsAndConditions'] ?? 'N/A',
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Button
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
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.profileEdit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_note, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'edit_profile'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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

  Widget _buildInfoRow(String label, String value) {
    final cleanVal = value.trim();
    final displayVal = cleanVal.isNotEmpty ? cleanVal : 'Not Provided';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              displayVal,
              style: TextStyle(
                color: displayVal == 'Not Provided'
                    ? Colors.grey[400]
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
