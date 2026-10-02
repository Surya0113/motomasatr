import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/theme/app_colors.dart';
import 'reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

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
        centerTitle: true,
        title: Text(
          'reports_analytics'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: controller.fetchAnalytics,
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // 1. Horizontal Capsule Filter Tabs Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCapsuleFilter('week', 'Week'),
                    const SizedBox(width: 8),
                    _buildCapsuleFilter('month', 'Month'),
                    const SizedBox(width: 8),
                    _buildCapsuleFilter('6months', '6 Months'),
                    const SizedBox(width: 8),
                    _buildCapsuleFilter('year', 'Year'),
                    const SizedBox(width: 8),
                    _buildCustomFilterButton(),
                  ],
                ),
              ),
            ),

            // 2. Main Scroll Body
            Expanded(
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Revenue Card
                          _buildRevenueCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // Capsule Filter Button Helper
  Widget _buildCapsuleFilter(String key, String label) {
    final isSelected = controller.selectedPeriod.value == key;
    // Capsule color is Crimson Red when pre-selected, grey text with border when idle
    return GestureDetector(
      onTap: () => controller.changePeriod(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF4444) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFEF4444) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Capsule Custom Filter (with calendar icon)
  Widget _buildCustomFilterButton() {
    final isSelected = controller.selectedPeriod.value == 'custom';
    return GestureDetector(
      onTap: () => controller.changePeriod('custom'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF4444) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFEF4444) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Custom',
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

  // Revenue Card Visual Builder
  Widget _buildRevenueCard() {
    final grand = controller.grandTotal.value;
    final parts = controller.partsRevenue.value;
    final oil = controller.oilRevenue.value;
    final labour = controller.labourRevenue.value;
    final acc = controller.accessoriesRevenue.value;
    final tyre = controller.tyreRevenue.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Revenue by Category',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Parts • Oil • Labour • Accessories • Tyre',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // Doughnut Chart Container
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: DoughnutChartPainter(
                      parts: parts,
                      oil: oil,
                      labour: labour,
                      accessories: acc,
                      tyre: tyre,
                    ),
                  ),
                  // Center Summary texts
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${grand.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Colored circular Legends Row
          _buildLegendsRow(),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Category Detail List Rows
          _buildCategoryItem(
            'Parts',
            parts,
            const Color(0xFF2563EB),
            const Color(0xFFEBF5FF),
            Icons.settings,
          ),
          _buildCategoryItem(
            'Oil',
            oil,
            const Color(0xFFEA580C),
            const Color(0xFFFFF3EB),
            Icons.opacity,
          ),
          _buildCategoryItem(
            'Labour',
            labour,
            const Color(0xFF06B6D4),
            const Color(0xFFECFEFF),
            Icons.build,
          ),
          _buildCategoryItem(
            'Accessories',
            acc,
            const Color(0xFFD946EF),
            const Color(0xFFFDF4FF),
            Icons.auto_awesome,
          ),
          _buildCategoryItem(
            'Tyre',
            tyre,
            const Color(0xFF10B981),
            const Color(0xFFE8F8EE),
            Icons.circle_outlined,
          ),
        ],
      ),
    );
  }

  // Colored Legends Builder
  Widget _buildLegendsRow() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendDot('Parts', Color(0xFF2563EB)),
        _LegendDot('Oil', Color(0xFFEA580C)),
        _LegendDot('Labour', Color(0xFF06B6D4)),
        _LegendDot('Accessories', Color(0xFFD946EF)),
        _LegendDot('Tyre', Color(0xFF10B981)),
      ],
    );
  }

  // Category Item list row with progress tracks
  Widget _buildCategoryItem(
    String title,
    double val,
    Color color,
    Color bg,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Circle wrapper
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              // Name text
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Value text
              Text(
                '₹${val.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtly colored background track
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    flex: (val * 100).toInt(),
                    child: Container(color: color),
                  ),
                  Expanded(
                    flex: max(
                      1,
                      (controller.grandTotal.value - val) * 100,
                    ).toInt(),
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Legend Dot Row Helper
class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom Painter drawing the Doughnut segments
class DoughnutChartPainter extends CustomPainter {
  final double parts;
  final double oil;
  final double labour;
  final double accessories;
  final double tyre;

  DoughnutChartPainter({
    required this.parts,
    required this.oil,
    required this.labour,
    required this.accessories,
    required this.tyre,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 24.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final total = parts + oil + labour + accessories + tyre;

    // Draw grey circle if total is 0
    if (total == 0) {
      paint.color = Colors.grey[200]!;
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -pi / 2;

    // Segment drawing routine
    _drawSegment(
      canvas,
      rect,
      paint,
      parts,
      total,
      const Color(0xFF2563EB),
      startAngle,
      (angle) => startAngle = angle,
    );
    _drawSegment(
      canvas,
      rect,
      paint,
      oil,
      total,
      const Color(0xFFEA580C),
      startAngle,
      (angle) => startAngle = angle,
    );
    _drawSegment(
      canvas,
      rect,
      paint,
      labour,
      total,
      const Color(0xFF06B6D4),
      startAngle,
      (angle) => startAngle = angle,
    );
    _drawSegment(
      canvas,
      rect,
      paint,
      accessories,
      total,
      const Color(0xFFD946EF),
      startAngle,
      (angle) => startAngle = angle,
    );
    _drawSegment(
      canvas,
      rect,
      paint,
      tyre,
      total,
      const Color(0xFF10B981),
      startAngle,
      (angle) => startAngle = angle,
    );
  }

  void _drawSegment(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double value,
    double total,
    Color color,
    double start,
    Function(double) nextAngle,
  ) {
    if (value <= 0) return;
    final sweepAngle = (value / total) * 2 * pi;
    paint.color = color;
    canvas.drawArc(rect, start, sweepAngle, false, paint);
    nextAngle(start + sweepAngle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
