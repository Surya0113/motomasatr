import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jobcard_create_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';

class JobCardCreateView extends GetView<JobCardCreateController> {
  const JobCardCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit JobCard' : 'Create JobCard',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary, size: 24),
            onPressed: () {
              Get.snackbar(
                'Create JobCard Help',
                'Fill in the vehicle number first to search existing client history.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Vehicle Number Field
              const Text(
                'Vehicle Number *',
                style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildGreenTextField(
                      controller: controller.vehicleNoController,
                      hintText: 'Vehicle Number *',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.green),
                        onPressed: controller.searchVehicle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildBlueAddButton(onTap: () => _showBookingSelectorBottomSheet(context)),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Full Name Field
              Row(
                children: [
                  Expanded(
                    child: _buildGreenTextField(
                      controller: controller.fullNameController,
                      hintText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildBlueAddButton(onTap: () {
                    Get.snackbar('Quick Action', 'Add premium garage customer logic triggered.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white);
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Mobile Number Field
              _buildGreenTextField(
                controller: controller.mobileController,
                hintText: 'Mobile Number *',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.teal),
              ),
              const SizedBox(height: 12),

              // 4. KM Reading & Fuel Level Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KM Reading
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KM Reading *',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        _buildGreenTextField(
                          controller: controller.kmReadingController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Fuel Level
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fuel Level',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.redAccent.withOpacity(0.4),
                                  inactiveTrackColor: Colors.grey[200],
                                  thumbColor: Colors.redAccent,
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: controller.fuelLevel.value,
                                  min: 0.0,
                                  max: 100.0,
                                  onChanged: (val) => controller.fuelLevel.value = val,
                                ),
                              ),
                            ),
                            Text(
                              '${controller.fuelLevel.value.toInt()}%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Dropdown selections Row 1 (Service Type, Number, Oil Change)
              Row(
                children: [
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Service Type',
                      value: controller.serviceType.value,
                      items: controller.serviceTypes,
                      borderColor: Colors.purple[300]!,
                      onChanged: (val) => controller.serviceType.value = val!,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Number',
                      value: controller.selectedNumber.value,
                      items: controller.numbersList,
                      borderColor: Colors.teal[300]!,
                      onChanged: (val) => controller.selectedNumber.value = val!,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Oil Change',
                      value: controller.oilChange.value,
                      items: controller.oilChangeOptions,
                      borderColor: Colors.red[300]!,
                      onChanged: (val) => controller.oilChange.value = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6. Dropdown selections Row 2 (Make, Model, Variant)
              Row(
                children: [
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Make',
                      value: controller.make.value,
                      items: controller.makes,
                      borderColor: Colors.blue[300]!,
                      onChanged: (val) => controller.make.value = val!,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Model',
                      value: controller.model.value,
                      items: controller.models,
                      borderColor: Colors.teal[300]!,
                      onChanged: (val) => controller.model.value = val!,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFormDropdown(
                      label: 'Variant',
                      value: controller.variant.value,
                      items: controller.variants,
                      borderColor: Colors.orange[300]!,
                      onChanged: (val) => controller.variant.value = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 7. Estimations Row (Estimate, Advance, Discount)
              Row(
                children: [
                  Expanded(
                    child: _buildColoredTextField(
                      label: 'Total Amount',
                      controller: controller.estimateController,
                      borderColor: Colors.blue[300]!,
                      prefixIcon: const Icon(
                        Icons.currency_rupee,
                        color: Colors.blue,
                        size: 16,
                      ),
                      onChanged: controller.onEstimateChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildColoredTextField(
                      label: 'Advance',
                      controller: controller.advanceController,
                      borderColor: Colors.green[300]!,
                      prefixIcon: const Icon(Icons.wallet, color: Colors.green, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildColoredTextField(
                      label: 'Discount',
                      controller: controller.discountController,
                      borderColor: Colors.orange[300]!,
                      prefixIcon: const Icon(Icons.local_offer, color: Colors.orange, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 8. Horizontal Sub-actions Row (Dent Marks, Customer Problem, Add Items)
              Row(
                children: [
                  Expanded(
                    child: _buildOutlineActionButton(
                      icon: Icons.car_crash,
                      label: 'Dent\nMarks',
                      borderColor: Colors.teal[300]!,
                      textColor: Colors.teal,
                      onTap: () => _showDentMarksBottomSheet(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildOutlineActionButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'Customer Problem',
                      borderColor: Colors.orange[400]!,
                      textColor: Colors.orange[800]!,
                      onTap: () => _showCustomerProblemBottomSheet(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOutlineActionButton(
                      icon: Icons.build,
                      label: 'Add\nItems',
                      borderColor: Colors.blue[400]!,
                      textColor: Colors.blue,
                      onTap: () => _showAddItemsBottomSheet(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Spares Estimate Preview
              Obx(() {
                final spares = controller.selectedSpares;
                if (spares.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: Colors.blue[600], size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Estimate Spares Preview',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${spares.length} items',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: spares.length,
                        separatorBuilder: (c, idx) => const Divider(height: 16, thickness: 0.5, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, idx) {
                          final item = spares[idx];
                          final name = item['name'] ?? 'N/A';
                          final brand = item['brand'] ?? 'Generic';
                          final qty = item['qty'] ?? 1;
                          final rate = item['sellPrice'] ?? 0.0;
                          final disc = double.tryParse(item['discount']?.toString() ?? '0') ?? 0.0;
                          final discType = item['discountType'] ?? 'currency';

                          double amt = rate * qty;
                          if (discType == 'percent') {
                            amt = amt * (1.0 - (disc / 100.0));
                          } else {
                            amt = amt - disc;
                          }
                          if (amt < 0) amt = 0;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} x ₹${rate.toStringAsFixed(0)}  •  $brand',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  if (disc > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '-₹${disc.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    '₹${amt.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                    onPressed: () => controller.removeSpareItem(item['id']),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 9. Date/Time & Mechanic Assignment Cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Delivery Date/Time Card
                    Expanded(
                      child: _buildOutlineCard(
                        borderColor: Colors.blue[300]!,
                        onTap: () => controller.pickDateTime(context),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue[800], size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Delivery Date & Time',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${controller.deliveryDateTime.value.day} ${_getMonthName(controller.deliveryDateTime.value.month)} ${controller.deliveryDateTime.value.year}\n${controller.deliveryDateTime.value.hour.toString().padLeft(2, '0')}:${controller.deliveryDateTime.value.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
  
                    // Add Mechanic Card
                    Expanded(
                      child: _buildOutlineCard(
                        borderColor: Colors.orange[300]!,
                        onTap: () => _showMechanicSelectorBottomSheet(context),
                        child: Row(
                          children: [
                            Icon(Icons.person_add_alt_1, color: Colors.orange[800], size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Add Mechanic',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.assignedMechanic.value,
                                    style: TextStyle(
                                      color: controller.assignedMechanic.value == 'Tap to assign' 
                                          ? Colors.orange[800] 
                                          : AppColors.textPrimary,
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.orange[300], size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 10. Footer Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.submitJobCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[650] ?? Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 2,
                      ),
                      child: Obx(
                        () => Text(
                          controller.isEditMode.value
                              ? 'Save Activity'
                              : 'Create JobCard',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (controller.isEditMode.value) {
                          controller.submitJobCard();
                          return;
                        }

                        Get.snackbar(
                          'Reminder Set',
                          'Job card status SMS alert set successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.teal,
                          colorText: Colors.white,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Obx(
                        () => Text(
                          controller.isEditMode.value ? 'Update' : 'Set Reminder',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }

  // Green Text Field Widget
  Widget _buildGreenTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [UppercaseTextFormatter()],
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.withOpacity(0.6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 1.8),
        ),
      ),
    );
  }

  // Blue Search "+" Square Button Widget
  Widget _buildBlueAddButton({required VoidCallback onTap}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // Color Styled Border Input Field Helper
  Widget _buildColoredTextField({
    required String label,
    required TextEditingController controller,
    required Color borderColor,
    required Widget prefixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: const [UppercaseTextFormatter()],
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor.withOpacity(0.7), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  // Reactive Read-Only Amount Display Field
  Widget _buildReactiveAmountField({
    required String label,
    required String value,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dropdown Form Widget Helper
  Widget _buildFormDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Color borderColor,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  menuWidth: constraints.maxWidth,
                  menuMaxHeight: 320,
                  alignment: Alignment.centerLeft,
                  icon: Icon(Icons.keyboard_arrow_down, color: borderColor),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                  items: items.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Outline Action Button Helper Widget
  Widget _buildOutlineActionButton({
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 15),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, height: 1.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Outline Details Cards (Date/Time & Mechanic) Helper Widget
  Widget _buildOutlineCard({
    required Color borderColor,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: child,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }


  void _showBookingSelectorBottomSheet(BuildContext context) {
    // Refresh the bookings list on sheet launch
    controller.fetchBookings();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Obx(() {
          final bookings = controller.filteredBookings;
          final count = controller.bookingsList.length;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Icon + Title + Count (Matches your screenshot exactly!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBF5FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_added_outlined,
                          color: Color(0xFF0D6EFD),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Booking',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$count bookings',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

              // Search Bar
              TextFormField(
                controller: controller.searchBookingController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [UppercaseTextFormatter()],
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  hintText: 'Search by vehicle, name, or mobile...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF3F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Content Area
              if (bookings.isEmpty)
                // Empty state (Matches your screenshot exactly!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey[400],
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No bookings found',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // List of active bookings
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: bookings.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = bookings[idx];
                      final vehicle = item['vehicleNumber'] ?? 'N/A';
                      final name = item['customerName'] ?? 'Walk-In Customer';
                      final phone = item['mobileNumber'] ?? 'N/A';
                      final date = item['bookingDate'] ?? 'N/A';
                      final time = item['bookingTime'] ?? 'N/A';

                      return InkWell(
                        onTap: () {
                          controller.selectedBookingId.value = item['_id'] ?? '';
                          controller.vehicleNoController.text = vehicle;
                          controller.fullNameController.text = name;
                          controller.mobileController.text = phone;
                          Get.back(); // close sheet
                          Get.snackbar(
                            'Booking Loaded',
                            'Loaded details for vehicle $vehicle successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          vehicle,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEBF5FF),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$date  •  $time',
                                            style: const TextStyle(
                                              color: Color(0xFF0D6EFD),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // 1. Mechanic Selector Bottom Sheet
  void _showMechanicSelectorBottomSheet(BuildContext context) {
    controller.fetchStaff();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Obx(() {
          var mechanics = controller.staffList
              .where((item) => item['staffType'] == 'Mechanic' || item['staffType'] == 'Supervisor')
              .toList();
          
          if (mechanics.isEmpty && controller.staffList.isNotEmpty) {
            mechanics = controller.staffList.toList();
          }

          final bool isLoad = controller.isLoadingStaff.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF0E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.engineering_outlined,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Mechanic',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${mechanics.length} mechanics',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

              if (controller.assignedMechanic.value != 'Tap to assign' && mechanics.isNotEmpty) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    controller.assignMechanicById('Tap to assign', '');
                    Get.back();
                    Get.snackbar(
                      'Mechanic Removed',
                      'Cleared assigned mechanic from job card.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orangeAccent,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 16),
                  label: const Text('Clear / Unassign Mechanic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],

              if (isLoad)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (mechanics.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      const Text(
                        'No staff mechanics registered in staff module yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.assignedMechanic.value != 'Tap to assign') ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            controller.assignMechanicById('Tap to assign', '');
                            Get.back();
                            Get.snackbar(
                              'Mechanic Removed',
                              'Cleared assigned mechanic from job card.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orangeAccent,
                              colorText: Colors.white,
                            );
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 16),
                          label: const Text('Clear Assigned Mechanic', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: mechanics.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = mechanics[idx];
                      final name = item['fullName'] ?? 'N/A';
                      final phone = item['mobileNumber'] ?? 'N/A';
                      final role = item['staffType'] ?? 'Mechanic';
                      final id = item['_id'] ?? item['id'] ?? '';

                      return InkWell(
                        onTap: () {
                          controller.assignMechanicById(name, id);
                          Get.back();
                          Get.snackbar(
                            'Mechanic Assigned',
                            'Assigned $name to this job card.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            colorText: Colors.white,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange[100],
                                child: Text(
                                  name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$role  •  $phone',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.check_circle_outline, color: Colors.orange, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // 2. Customer Problem Bottom Sheet
  void _showCustomerProblemBottomSheet(BuildContext context) {
    final customProblemController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Obx(() {
          final problems = controller.problemsList;
          final selected = controller.selectedProblems;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Customer Problem',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Voice Saved',
                        '${selected.length} customer issues captured successfully.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Items',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: problems.map((name) {
                      final isSel = selected.contains(name);
                      return ChoiceChip(
                        label: Text(
                          name,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: Colors.orange[800],
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSel ? Colors.transparent : const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                        ),
                        onSelected: (val) {
                          controller.toggleProblem(name);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customProblemController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: const [UppercaseTextFormatter()],
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Add custom issue...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: const Color(0xFFF3F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        final val = customProblemController.text.trim();
                        if (val.isNotEmpty) {
                          controller.addCustomProblem(val);
                          customProblemController.clear();
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showAddItemsBottomSheet(BuildContext context) {
    controller.loadInventoryItems();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Obx(() {
          final items = controller.filteredInventoryItems;
          final spares = controller.selectedSpares;
          final isInventoryTab = controller.activeInventoryTab.value == 'inventory';

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.lightBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Item to Invoice',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),

              // 1. Sliding Tab Selector Switch
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.activeInventoryTab.value = 'inventory',
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isInventoryTab ? const Color(0xFF0091FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isInventoryTab
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0091FF).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            'From Inventory',
                            style: TextStyle(
                              color: isInventoryTab ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.activeInventoryTab.value = 'manual',
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isInventoryTab ? const Color(0xFF0091FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: !isInventoryTab
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0091FF).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Manual Entry',
                            style: TextStyle(
                              color: !isInventoryTab ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (isInventoryTab) ...[
                // Tab 1: From Inventory
                TextField(
                  controller: controller.searchInventoryController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UppercaseTextFormatter()],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    hintText: 'Search parts...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: const Color(0xFFF3F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No parts matching search.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (c, idx) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final name = item['name'] ?? 'N/A';
                            final brand = item['brand'] ?? 'Generic';
                            final price = (item['sellPrice'] ?? 0.0) is int ? (item['sellPrice'] as int).toDouble() : (item['sellPrice'] ?? 0.0) as double;
                            final stockQty = item['qty'] ?? 0;
                            final unit = item['unit'] ?? 'pieces';
                            final id = item['id']?.toString() ?? '';

                            final addedIndex = spares.indexWhere((x) => x['id']?.toString() == id);
                            final isAdded = addedIndex != -1;
                            final addedQty = isAdded ? spares[addedIndex]['qty'] : 0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${price.toStringAsFixed(0)} / $unit',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '•  $brand',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stock: $stockQty $unit',
                                          style: TextStyle(
                                            color: stockQty == 0 ? Colors.red : Colors.green[800],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (isAdded) ...[
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                          onPressed: () {
                                            final existing = Map<String, dynamic>.from(spares[addedIndex]);
                                            final currentQty = (existing['qty'] is int)
                                                ? (existing['qty'] as int).toDouble()
                                                : (existing['qty'] ?? 1.0) as double;
                                            if (currentQty > 1) {
                                              existing['qty'] = currentQty - 1.0;
                                              spares[addedIndex] = existing;
                                              controller.updateSparesSum();
                                            } else {
                                              controller.removeSpareItem(id);
                                            }
                                          },
                                        ),
                                        Text(
                                          '$addedQty',
                                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                          onPressed: () {
                                            controller.addSpareItem(item);
                                          },
                                        ),
                                      ] else ...[
                                        // Not added yet: allow user to choose quantity before adding
                                        Builder(builder: (context) {
                                          final qtyNotifier = ValueNotifier<int>(1);
                                          return ValueListenableBuilder<int>(
                                            valueListenable: qtyNotifier,
                                            builder: (context, desiredQty, _) {
                                              return Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                                    onPressed: desiredQty > 1
                                                        ? () => qtyNotifier.value = desiredQty - 1
                                                        : null,
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '$desiredQty',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                                    onPressed: () => qtyNotifier.value = desiredQty + 1,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF0D6EFD),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      elevation: 0,
                                                    ),
                                                    onPressed: () {
                                                      controller.addSpareItem(item, qty: desiredQty.toDouble());
                                                      qtyNotifier.value = 1;
                                                    },
                                                    child: const Text(
                                                      'Add',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Items Selected',
                      'Successfully added selected parts to job card estimate.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // Tab 2: Manual Entry Form
                TextField(
                  controller: controller.manualItemNameController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UppercaseTextFormatter()],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Item Name',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: const Color(0xFFF3F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  Quantity',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemQtyController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  Rate (₹)',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemRateController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Rate (₹)',
                              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  Discount',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemDiscountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.local_offer, color: AppColors.textSecondary, size: 16),
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => controller.manualDiscountType.value = 'currency',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: controller.manualDiscountType.value == 'currency'
                                    ? const Color(0xFF0091FF)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                ),
                              ),
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  color: controller.manualDiscountType.value == 'currency'
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.manualDiscountType.value = 'percent',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: controller.manualDiscountType.value == 'percent'
                                    ? const Color(0xFF0091FF)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(13),
                                  bottomRight: Radius.circular(13),
                                ),
                              ),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  color: controller.manualDiscountType.value == 'percent'
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: SizedBox(height: 16),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0091FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: () => controller.addManualItem(),
                  child: const Text(
                    'Add to Invoice',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // 4. Dent & Damage Drawing Canvas Bottom Sheet
  void _showDentMarksBottomSheet(BuildContext context) {
    String activeTool = 'dent';
    String activeView = 'top';

    List<DamageLine> topLines = [];
    List<DamageLine> frontLines = [];
    List<DamageLine> backLines = [];
    List<Offset> currentPoints = [];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          List<DamageLine> getLinesForView() {
            if (activeView == 'top') return topLines;
            if (activeView == 'front') return frontLines;
            return backLines;
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 24),
                      onPressed: () => Get.back(),
                    ),
                    const Text(
                      'Dent & Damage Marking',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final List<Map<String, dynamic>> serialized = [];
                        for (final line in topLines) {
                          serialized.add({
                            'view': 'top',
                            'type': line.type,
                            'points': line.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
                          });
                        }
                        for (final line in frontLines) {
                          serialized.add({
                            'view': 'front',
                            'type': line.type,
                            'points': line.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
                          });
                        }
                        for (final line in backLines) {
                          serialized.add({
                            'view': 'back',
                            'type': line.type,
                            'points': line.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
                          });
                        }

                        controller.dentMarks.value = {
                          'marks': serialized,
                        };

                        Get.back();
                        Get.snackbar(
                          'Damage Saved',
                          'Marked vehicle body damages captured successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.teal,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => activeTool = 'dent'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeTool == 'dent' ? Colors.red[50] : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: activeTool == 'dent' ? Colors.red : Colors.grey[300]!, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 6, backgroundColor: Colors.red),
                            const SizedBox(width: 6),
                            Text('Dent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeTool == 'dent' ? Colors.red : Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () => setState(() => activeTool = 'scratch'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeTool == 'scratch' ? Colors.amber[50] : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: activeTool == 'scratch' ? Colors.amber[800]! : Colors.grey[300]!, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 6, backgroundColor: Colors.amber),
                            const SizedBox(width: 6),
                            Text('Scratch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeTool == 'scratch' ? Colors.amber[900] : Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () => setState(() => activeTool = 'break'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeTool == 'break' ? Colors.blue[50] : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: activeTool == 'break' ? Colors.blue : Colors.grey[300]!, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 6, backgroundColor: Colors.blue),
                            const SizedBox(width: 6),
                            Text('Break', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeTool == 'break' ? Colors.blue : Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () => setState(() => activeTool = 'erase'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeTool == 'erase' ? Colors.grey[100] : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: activeTool == 'erase' ? Colors.black87 : Colors.grey[300]!, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cleaning_services, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text('Erase Off', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeTool == 'erase' ? Colors.black87 : Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GestureDetector(
                        onPanStart: (details) {
                          final pos = details.localPosition;
                          if (activeTool == 'erase') {
                            setState(() {
                              getLinesForView().removeWhere((line) {
                                return line.points.any((p) => (p - pos).distance < 20.0);
                              });
                            });
                          } else {
                            setState(() {
                              currentPoints = [pos];
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          final pos = details.localPosition;
                          if (activeTool != 'erase') {
                            setState(() {
                              currentPoints.add(pos);
                            });
                          }
                        },
                        onPanEnd: (details) {
                          if (activeTool != 'erase' && currentPoints.isNotEmpty) {
                            setState(() {
                              getLinesForView().add(
                                DamageLine(
                                  points: List.from(currentPoints),
                                  type: activeTool,
                                ),
                              );
                              currentPoints.clear();
                            });
                          }
                        },
                        child: CustomPaint(
                          painter: CarCanvasPainter(
                            view: activeView,
                            lines: getLinesForView(),
                            currentPoints: currentPoints,
                            currentTool: activeTool,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: activeView == 'top' ? Colors.orange : Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: activeView == 'top' ? Colors.orange[50] : Colors.transparent,
                        ),
                        onPressed: () => setState(() => activeView = 'top'),
                        child: Text('Top View', style: TextStyle(color: activeView == 'top' ? Colors.orange[900] : Colors.grey[700], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: activeView == 'front' ? Colors.orange : Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: activeView == 'front' ? Colors.orange[50] : Colors.transparent,
                        ),
                        onPressed: () => setState(() => activeView = 'front'),
                        child: Text('Front View', style: TextStyle(color: activeView == 'front' ? Colors.orange[900] : Colors.grey[700], fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: activeView == 'back' ? Colors.orange : Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: activeView == 'back' ? Colors.orange[50] : Colors.transparent,
                        ),
                        onPressed: () => setState(() => activeView = 'back'),
                        child: Text('Back View', style: TextStyle(color: activeView == 'back' ? Colors.orange[900] : Colors.grey[700], fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

// Damage Marking Line Model
class DamageLine {
  final List<Offset> points;
  final String type; // 'dent', 'scratch', 'break'
  DamageLine({required this.points, required this.type});
}

// Programmatic Car Canvas Painter (Top, Front, Back Views)
class CarCanvasPainter extends CustomPainter {
  final String view;
  final List<DamageLine> lines;
  final List<Offset> currentPoints;
  final String currentTool;

  CarCanvasPainter({
    required this.view,
    required this.lines,
    required this.currentPoints,
    required this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Draw programmatic car shapes matching user mock screenshots
    if (view == 'top') {
      final wheelW = w * 0.12;
      final wheelH = h * 0.14;
      final wheelPaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill;
      
      // Tires
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.32, cy - h * 0.28), width: wheelW, height: wheelH), wheelPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.32, cy - h * 0.28), width: wheelW, height: wheelH), wheelPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.32, cy + h * 0.28), width: wheelW, height: wheelH), wheelPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.32, cy + h * 0.28), width: wheelW, height: wheelH), wheelPaint);

      // Body shape
      final bodyPaint = Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill;
      final borderPaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2.0;

      final carRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w * 0.64, height: h * 0.78),
        const Radius.circular(24),
      );
      canvas.drawRRect(carRect, bodyPaint);
      canvas.drawRRect(carRect, borderPaint);

      // Windshield & roof glass
      final glassPaint = Paint()..color = const Color(0xFFE0F2FE)..style = PaintingStyle.fill;
      final glassBorder = Paint()..color = const Color(0xFF7DD3FC)..style = PaintingStyle.stroke..strokeWidth = 1.5;
      final glassRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + h * 0.04), width: w * 0.48, height: h * 0.44),
        const Radius.circular(12),
      );
      canvas.drawRRect(glassRect, glassPaint);
      canvas.drawRRect(glassRect, glassBorder);

      // Details lines
      final detailPaint = Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawLine(Offset(cx - w * 0.3, cy - h * 0.16), Offset(cx + w * 0.3, cy - h * 0.16), detailPaint);
    } else if (view == 'front') {
      final bodyPaint = Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill;
      final borderPaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2;
      
      final tirePaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.3, cy + h * 0.25), width: w * 0.14, height: h * 0.18), const Radius.circular(6)), tirePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.3, cy + h * 0.25), width: w * 0.14, height: h * 0.18), const Radius.circular(6)), tirePaint);

      final hoodRRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + h * 0.1), width: w * 0.74, height: h * 0.34), const Radius.circular(16));
      canvas.drawRRect(hoodRRect, bodyPaint);
      canvas.drawRRect(hoodRRect, borderPaint);

      final windshieldPath = Path()
        ..moveTo(cx - w * 0.28, cy - h * 0.24)
        ..lineTo(cx + w * 0.28, cy - h * 0.24)
        ..lineTo(cx + w * 0.34, cy + h * 0.05)
        ..lineTo(cx - w * 0.34, cy + h * 0.05)
        ..close();
      canvas.drawPath(windshieldPath, Paint()..color = const Color(0xFFE0F2FE)..style = PaintingStyle.fill);
      canvas.drawPath(windshieldPath, Paint()..color = const Color(0xFF7DD3FC)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      canvas.drawCircle(Offset(cx - w * 0.25, cy + h * 0.08), 14, Paint()..color = Colors.amber[100]!..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx - w * 0.25, cy + h * 0.08), 14, borderPaint);
      canvas.drawCircle(Offset(cx + w * 0.25, cy + h * 0.08), 14, Paint()..color = Colors.amber[100]!..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx + w * 0.25, cy + h * 0.08), 14, borderPaint);
    } else {
      final bodyPaint = Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill;
      final borderPaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2;
      
      final tirePaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.3, cy + h * 0.25), width: w * 0.14, height: h * 0.18), const Radius.circular(6)), tirePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.3, cy + h * 0.25), width: w * 0.14, height: h * 0.18), const Radius.circular(6)), tirePaint);

      final trunkRRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + h * 0.1), width: w * 0.74, height: h * 0.34), const Radius.circular(16));
      canvas.drawRRect(trunkRRect, bodyPaint);
      canvas.drawRRect(trunkRRect, borderPaint);

      final windshieldPath = Path()
        ..moveTo(cx - w * 0.27, cy - h * 0.22)
        ..lineTo(cx + w * 0.27, cy - h * 0.22)
        ..lineTo(cx + w * 0.32, cy + h * 0.04)
        ..lineTo(cx - w * 0.32, cy + h * 0.04)
        ..close();
      canvas.drawPath(windshieldPath, Paint()..color = const Color(0xFFE0F2FE)..style = PaintingStyle.fill);
      canvas.drawPath(windshieldPath, Paint()..color = const Color(0xFF7DD3FC)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      final tailPaint = Paint()..color = Colors.red[800]!..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.32, cy + h * 0.03, w * 0.14, h * 0.07), const Radius.circular(6)), tailPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + w * 0.18, cy + h * 0.03, w * 0.14, h * 0.07), const Radius.circular(6)), tailPaint);
    }

    // Draw saved lines
    for (final line in lines) {
      final paint = Paint()
        ..color = _getToolColor(line.type)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (line.points.isNotEmpty) {
        final path = Path()..moveTo(line.points.first.dx, line.points.first.dy);
        for (int i = 1; i < line.points.length; i++) {
          path.lineTo(line.points[i].dx, line.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw active drawing line
    if (currentPoints.isNotEmpty) {
      final paint = Paint()
        ..color = _getToolColor(currentTool)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(currentPoints.first.dx, currentPoints.first.dy);
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  Color _getToolColor(String tool) {
    switch (tool) {
      case 'dent':
        return Colors.red;
      case 'scratch':
        return Colors.amber;
      case 'break':
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
