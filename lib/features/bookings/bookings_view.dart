import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import '../../../app/core/values/asset_constants.dart';
import 'bookings_controller.dart';

class BookingsView extends GetView<BookingsController> {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0D6EFD,
      ), // Branded blue top matching screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage(AssetConstants.motomasterLogo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'bookings'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchBookings,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(
            0xFFF3F5F9,
          ), // Subtle light grey background under top card
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. New Booking Card Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Header
                    const Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Color(0xFF0D6EFD),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'New Booking',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // A. Vehicle Number Field
                    _buildFieldHeader(
                      Icons.directions_car_outlined,
                      const Color(0xFF0D6EFD),
                      'Vehicle Number',
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      final vehicleNo = controller.vehicleNumber.value;
                      final isValid = vehicleNo.isEmpty || controller.isValidVehicleNumber(vehicleNo);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: controller.vehicleNumberController,
                            hintText: 'Format: AB12C2345',
                            prefixIcon: Icons.directions_car_outlined,
                            prefixColor: const Color(0xFF0D6EFD),
                          ),
                          if (vehicleNo.isNotEmpty && !isValid)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: Text(
                                'Format: 2 letters + 2 digits + 1-2 letters + 4 digits (e.g., AB12C2345)',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else if (vehicleNo.isNotEmpty && isValid)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: Text(
                                '✓ Valid format',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    // B. Full Name Field
                    _buildFieldHeader(
                      Icons.person_outline,
                      const Color(0xFF10B981),
                      'Full Name',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: controller.customerNameController,
                      hintText: 'Enter customer name',
                      prefixIcon: Icons.person_outline,
                      prefixColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 16),

                    // C. Mobile Number Field
                    _buildFieldHeader(
                      Icons.phone_outlined,
                      const Color(0xFFF59E0B),
                      'Mobile Number',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: controller.mobileNumberController,
                      hintText: 'Enter 10 digit number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      prefixColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 16),

                    // D. Booking Date Picker
                    _buildFieldHeader(
                      Icons.calendar_today_outlined,
                      const Color(0xFF8B5CF6),
                      'Booking Date',
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _buildPickerButton(
                        context: context,
                        onTap: () => controller.selectDate(context),
                        hasValue: controller.hasSelectedDate.value,
                        valueText: controller.getFormattedDate(
                          controller.selectedDate.value,
                        ),
                        hintText: 'Select booking date',
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // E. Booking Time Picker
                    _buildFieldHeader(
                      Icons.access_time_outlined,
                      const Color(0xFFEC4899),
                      'Booking Time',
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _buildPickerButton(
                        context: context,
                        onTap: () => controller.selectTime(context),
                        hasValue: controller.hasSelectedTime.value,
                        valueText: controller.getFormattedTime(
                          controller.selectedTime.value,
                          context,
                        ),
                        hintText: 'Select booking time',
                        icon: Icons.access_time_outlined,
                        iconColor: const Color(0xFFEC4899),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    Obx(() {
                      final isSub = controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: isSub
                            ? null
                            : () => controller.createBooking(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF3B56FF,
                          ), // vibrant blue matching button in image
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSub
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.app_registration,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. Recent Bookings header
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Bookings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${controller.bookings.length} total',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Bookings list content
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D6EFD),
                      ),
                    ),
                  );
                }

                if (controller.bookings.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.bookings.length,
                  itemBuilder: (context, index) {
                    final item = controller.bookings[index];
                    return _buildBookingCard(item);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Field Header helper
  Widget _buildFieldHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // TextField Helper
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required Color prefixColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [UppercaseTextFormatter()],
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(
          prefixIcon,
          color: prefixColor.withOpacity(0.5),
          size: 18,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // DateTime Picker Button Helper
  Widget _buildPickerButton({
    required BuildContext context,
    required VoidCallback onTap,
    required bool hasValue,
    required String valueText,
    required String hintText,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor.withOpacity(0.5), size: 18),
                const SizedBox(width: 12),
                Text(
                  hasValue ? valueText : hintText,
                  style: TextStyle(
                    color: hasValue ? AppColors.textPrimary : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: hasValue ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Empty list visual state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 54,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookings yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create your first booking above',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Standard booking card row
  Widget _buildBookingCard(dynamic item) {
    final vehicle = (item['vehicleNumber'] ?? 'N/A').toString().toUpperCase();
    final name = item['customerName'] ?? 'N/A';
    final phone = item['mobileNumber'] ?? '';
    final date = item['bookingDate'] ?? '';
    final time = item['bookingTime'] ?? '';
    final status = (item['status'] ?? 'pending').toString().toLowerCase();

    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green[600]!;
        break;
      case 'in_progress':
      case 'in-progress':
        statusColor = Colors.blue[600]!;
        break;
      case 'cancelled':
        statusColor = Colors.red[600]!;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange[600]!;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Blue circle icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Color(0xFF0D6EFD),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Core details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$name • $phone',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date @ $time',
                  style: const TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
