import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import '../../../app/routes/app_routes.dart';
import 'inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F5F9,
      ), // Light background matching screenshot
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'inventory_management'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // 1. Search Bar on top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: controller.updateSearch,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [UppercaseTextFormatter()],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'search_inventory'.tr,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2. Metrics indicators row (Total | Low | Out)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'total_items'.tr,
                      '${controller.totalItems.value}',
                      Icons.inventory_2_outlined,
                      const Color(0xFFEBF5FF),
                      const Color(0xFF0072FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'low_stock'.tr,
                      '${controller.lowStock.value}',
                      Icons.warning_amber_outlined,
                      const Color(0xFFFEF3C7),
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'out_of_stock'.tr,
                      '${controller.outOfStock.value}',
                      Icons.remove_circle_outline,
                      const Color(0xFFFEE2E2),
                      const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Category Filter Chips (All, Accessories, Battery, Oil, Tyre, Parts)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('all', 'all'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('accessories', 'accessories'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('battery', 'battery'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('oil', 'oil'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('tyre', 'tyre'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('parts', 'parts'.tr),
                ],
              ),
            ),

            // 4. Spare Parts Cards list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.calculateStats();
                  controller.applyFilters();
                },
                color: AppColors.primary,
                child: controller.filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return _buildInventoryItemCard(item);
                        },
                      ),
              ),
            ),
          ],
        );
      }),

      // Floating Action Button to Add New Item
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.resetForm();
          Get.toNamed(AppRoutes.inventoryAdd);
        },
        backgroundColor: const Color(0xFF005FFF), // vibrant blue
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_new_item'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Summary Metric Card visual helper
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Filter Chip builder
  Widget _buildFilterChip(String key, String label) {
    final isSelected = controller.selectedFilterCategory.value == key;
    return GestureDetector(
      onTap: () => controller.changeFilter(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state visual state
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting filters or tap + Add Item',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Individual Part Card visual builder
  Widget _buildInventoryItemCard(dynamic item) {
    final name = item['name'] ?? 'N/A';
    final brand = item['brand'] ?? 'N/A';
    final qty = (item['qty'] as num).toInt();
    final unit = item['unit'] ?? 'pieces';
    final sellPrice = (item['sellPrice'] as num).toDouble();
    final minLevel = (item['minLevel'] as num).toInt();

    final isOutOfStock = qty == 0;
    final isLowStock = qty > 0 && qty <= minLevel;

    // Determine stock status color pills
    Color qtyColorBg = const Color(0xFFE8F8EE);
    Color qtyColorText = const Color(0xFF10B981);
    if (isOutOfStock) {
      qtyColorBg = const Color(0xFFFEE2E2);
      qtyColorText = const Color(0xFFEF4444);
    } else if (isLowStock) {
      qtyColorBg = const Color(0xFFFEF3C7);
      qtyColorText = const Color(0xFFD97706);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Circular icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF5FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF0D6EFD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Product name & Brand
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      brand,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Options ellipsis button
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Double color pills row
          Row(
            children: [
              // Quantity Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: qtyColorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOutOfStock
                          ? Icons.remove_circle
                          : (isLowStock ? Icons.warning : Icons.check_circle),
                      color: qtyColorText,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$qty $unit',
                      style: TextStyle(
                        color: qtyColorText,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Sell Price Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${sellPrice.toStringAsFixed(0)}/$unit',
                  style: const TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          // Out/Low Stock Notice Banner
          if (isOutOfStock) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else if (isLowStock) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.amber[700],
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Low Stock (Min: $minLevel)',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
