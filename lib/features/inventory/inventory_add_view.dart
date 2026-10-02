import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import 'inventory_controller.dart';

class InventoryAddView extends GetView<InventoryController> {
  const InventoryAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F5F9,
      ), // Light background matching image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'add_new_item'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Category Chips Selection Card
            _buildSectionCard(
              title: 'Category',
              child: Obx(() {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFormCategoryChip(
                      'accessories',
                      'accessories'.tr,
                      Icons.star,
                    ),
                    _buildFormCategoryChip('battery', 'battery'.tr, Icons.bolt),
                    _buildFormCategoryChip('oil', 'oil'.tr, Icons.opacity),
                    _buildFormCategoryChip('parts', 'parts'.tr, Icons.build),
                    _buildFormCategoryChip(
                      'tyre',
                      'tyre'.tr,
                      Icons.circle_outlined,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),

            // 2. Basic Information Card
            _buildSectionCard(
              title: 'Basic Information',
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.nameController,
                    hintText: 'Item Name *',
                    prefixIcon: Icons.label_important_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.brandController,
                    hintText: 'Brand',
                    prefixIcon: Icons.bookmark_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Quantity & Stock Card
            _buildSectionCard(
              title: 'Quantity & Stock',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Current Quantity
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: controller.qtyController,
                          hintText: 'Current Quantity *',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Unit (e.g. pieces)
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          controller: controller.unitController,
                          hintText: 'Unit *',
                          prefixIcon: Icons.grid_3x3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.minStockController,
                    hintText: 'Minimum Stock Level *',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.warning_amber_outlined,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Alert when stock falls below this level',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Pricing Card
            _buildSectionCard(
              title: 'Pricing',
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.buyPriceController,
                    hintText: 'Buy Price *',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: controller.sellPriceController,
                    hintText: 'Sell Price *',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Add Button
            ElevatedButton(
              onPressed: controller.addNewItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1D5CFF,
                ), // vibrant blue matching image
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Item',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Card Wrapper
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Form Category Selector Chip
  Widget _buildFormCategoryChip(String key, String label, IconData icon) {
    final isSelected = controller.activeFormCategory.value == key;
    return GestureDetector(
      onTap: () => controller.activeFormCategory.value = key,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D6EFD).withOpacity(0.1)
              : const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0D6EFD)
                  : AppColors.textSecondary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0D6EFD)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextField Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
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
        prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 18),
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
}
