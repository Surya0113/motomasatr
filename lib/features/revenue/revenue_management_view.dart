import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'revenue_management_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';

class RevenueManagementView extends GetView<RevenueManagementController> {
  const RevenueManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'revenue_management'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return Column(
          children: [
            // 1. White Top Filters Block
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'all'.tr),
                    const SizedBox(width: 8),
                    _buildFilterChip('today', 'today'.tr),
                    const SizedBox(width: 8),
                    _buildFilterChip('week', 'This Week'),
                    const SizedBox(width: 8),
                    _buildFilterChip('month', 'This Month'),
                  ],
                ),
              ),
            ),

            // 2. Cash In / Cash Out Tabs Segment
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTransactionTypeTab(
                      'in',
                      'Cash In',
                      Icons.arrow_downward,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildTransactionTypeTab(
                      'out',
                      'Cash Out',
                      Icons.arrow_upward,
                      Colors.grey[700]!,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // 3. Main Scroll Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchRevenueData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // A. Revenue Summary Card
                      _buildSummaryCard(),
                      const SizedBox(height: 24),

                      // B. Transactions header label
                      Text(
                        controller.selectedTab.value == 'in'
                            ? 'Cash In Transactions'
                            : 'Cash Out Transactions',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // C. Dynamic transaction lists
                      _buildTransactionList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),

      // 4. FAB - Add Cash In / Add Cash Out
      floatingActionButton: Obx(() {
        final isIn = controller.selectedTab.value == 'in';
        return FloatingActionButton.extended(
          onPressed: () {
            controller.resetForm();
            _showAddTransactionSheet(context);
          },
          backgroundColor: Colors.green[600] ?? Colors.green,
          elevation: 4,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            isIn ? 'Add Cash In' : 'Add Cash Out',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  // Horizontal scrollable time filter chip builder
  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = controller.selectedFilter.value == filterKey;
    return GestureDetector(
      onTap: () => controller.changeFilter(filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cash In / Cash Out Tabs header builder
  Widget _buildTransactionTypeTab(
    String tabKey,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = controller.selectedTab.value == tabKey;
    final blueColor = AppColors.primary;

    return GestureDetector(
      onTap: () => controller.changeTab(tabKey),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? blueColor : Colors.grey[400],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : Colors.grey[500],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 3,
            width: double.infinity,
            color: isSelected ? blueColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // Revenue Summary Card Widget
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryMetric(
                'Cash In',
                '₹${controller.cashInTotal.value.toStringAsFixed(2)}',
                Colors.green[600]!,
              ),
              _buildSummaryMetric(
                'Cash Out',
                '₹${controller.cashOutTotal.value.toStringAsFixed(2)}',
                Colors.red[600]!,
              ),
              _buildSummaryMetric(
                'Net',
                '₹${controller.netTotal.value.toStringAsFixed(2)}',
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Dynamic Transaction list builder
  Widget _buildTransactionList(BuildContext context) {
    if (controller.isLoading.value) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final list = controller.transactions;
    final isIn = controller.selectedTab.value == 'in';

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.money_off_outlined, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                isIn ? 'No cash in transactions' : 'No cash out transactions',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tx = list[index];
        final amt = tx['amount'] ?? 0.0;
        final desc = tx['description'] ?? 'N/A';
        final categoryName = (tx['category'] ?? 'other')
            .toString()
            .replaceAll('_', ' ')
            .toUpperCase();
        final paymentMode = (tx['paymentMode'] ?? 'cash')
            .toString()
            .toUpperCase();

        DateTime? dateVal;
        if (tx['date'] != null) {
          dateVal = DateTime.tryParse(tx['date']);
        }
        final formattedDate = dateVal != null
            ? '${dateVal.day}/${dateVal.month}/${dateVal.year}'
            : 'N/A';

        // Check if transaction has an associated job card number (denormalized)
        String subDetails = paymentMode;
        if (tx['jobCard'] != null && tx['jobCard']['jobCardNumber'] != null) {
          subDetails += ' • ${tx['jobCard']['jobCardNumber']}';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // Colored icon indicator
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIn ? Colors.green[50] : Colors.red[50]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: (isIn ? Colors.green[700] : Colors.red[700]),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Descriptions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryName • $subDetails',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Date & Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${amt.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (isIn ? Colors.green[700] : Colors.red[700]),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case 'job_card':
        return 'Job Card';
      case 'additional_income':
        return 'Additional Income';
      case 'spare_parts_sale':
        return 'Spare Parts Sale';
      case 'service_charge':
        return 'Service Charge';
      case 'rent':
        return 'Rent';
      case 'salary':
        return 'Salary';
      case 'spare_parts_purchase':
        return 'Spare Parts Purchase';
      case 'utilities':
        return 'Utilities';
      case 'maintenance':
        return 'Maintenance';
      case 'equipment':
        return 'Equipment';
      case 'other':
      default:
        return 'Other';
    }
  }

  String _getPaymentModeLabel(String mode) {
    switch (mode) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      case 'online':
        return 'Online';
      case 'cheque':
        return 'Cheque';
      case 'other':
      default:
        return 'Other';
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: isMultiline ? 3 : 1,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [UppercaseTextFormatter()],
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF3F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required String Function(String) labelMapper,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF3F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            labelMapper(item),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Create bottom sheet for manual cash in / out entries
  void _showAddTransactionSheet(BuildContext context) {
    final isIn = controller.selectedTab.value == 'in';

    Get.bottomSheet(
      GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          // Allow bottom sheet to rise up when keyboard shows
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title
                Text(
                  isIn ? 'Add Cash In' : 'Add Cash Out',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Amount * field
                _buildTextField(
                  controller: controller.amountController,
                  hintText: 'Amount *',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Category selection
                Obx(() {
                  final categories = isIn
                      ? controller.cashInCategories
                      : controller.cashOutCategories;
                  // Ensure current category is in the categories list, or default it
                  if (!categories.contains(controller.category.value)) {
                    controller.category.value = categories.first;
                  }
                  return _buildDropdownField(
                    label: 'Category',
                    value: controller.category.value,
                    items: categories,
                    labelMapper: _getCategoryLabel,
                    onChanged: (val) => controller.category.value = val!,
                  );
                }),
                const SizedBox(height: 16),

                // 3. Payment Mode selection
                Obx(
                  () => _buildDropdownField(
                    label: 'Payment Mode',
                    value: controller.paymentMode.value,
                    items: controller.paymentModes,
                    labelMapper: _getPaymentModeLabel,
                    onChanged: (val) => controller.paymentMode.value = val!,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Transaction Number (Cash In only!)
                if (isIn) ...[
                  _buildTextField(
                    controller: controller.transactionNumberController,
                    hintText: 'Transaction Number',
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Description field
                _buildTextField(
                  controller: controller.descController,
                  hintText: isIn ? 'Description' : 'Description *',
                ),
                const SizedBox(height: 20),

                // 6. Custom interactive Date Selector
                const Text(
                  'Date',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => controller.selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            controller.getFormattedDate(
                              controller.selectedDate.value,
                            ),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 7. Actions Row: Cancel | Add
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(
                            0xFF0D6EFD,
                          ), // vibrant premium brand blue
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      final isSub = controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: isSub ? null : controller.addTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSub
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
