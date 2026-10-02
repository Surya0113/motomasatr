import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/values/asset_constants.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import 'widgets/stat_circle.dart';
import 'widgets/grid_card.dart';
import 'dashboard_controller.dart';
import '../jobcard/jobcard_list_controller.dart';
import '../reminders/service_reminders_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/core/values/api_constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;
      switch (index) {
        case 0:
          return _buildHomeTab(context);
        case 1:
          return _buildSearchTab(context);
        case 3:
          return _buildAlertsTab(context);
        case 4:
          return _buildMoreTab(context);
        default:
          return _buildHomeTab(context);
      }
    });
  }

  Widget _buildHomeTab(BuildContext context) {
    final remindersController = Get.find<ServiceRemindersController>();
    return RefreshIndicator(
      onRefresh: controller.fetchStats,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Profile Header Row (Clean White Background with Perfect Center Alignment)
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
              ),
              child: Obx(() {
                final owner = controller.garageOwner.value;
                final fallbackName = owner != null
                    ? [owner.firstName, owner.lastName]
                        .where((part) => part.trim().isNotEmpty)
                        .join(' ')
                    : 'Garage';
                final displayName = owner != null && owner.workshopName.trim().isNotEmpty
                    ? owner.workshopName
                    : fallbackName.isNotEmpty
                        ? fallbackName
                        : 'Garage';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFCBE5FF),
                            child: () {
                              final logo = owner?.customLogo ?? '';
                              if (logo.isNotEmpty) {
                                final logoUrl = logo.startsWith('http')
                                    ? logo
                                    : ApiConstants.baseUrl.replaceAll('/api', '') + logo;
                                return ClipOval(
                                  child: Image.network(
                                    logoUrl,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      final initials = displayName.isNotEmpty
                                          ? displayName
                                              .trim()
                                              .split(RegExp(r'\s+'))
                                              .take(2)
                                              .map((word) => word[0].toUpperCase())
                                              .join()
                                          : 'G';
                                      return Center(
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }

                              final initials = displayName.isNotEmpty
                                  ? displayName
                                      .trim()
                                      .split(RegExp(r'\s+'))
                                      .take(2)
                                      .map((word) => word[0].toUpperCase())
                                      .join()
                                  : 'G';

                              return Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Side: App Logo Button
                    GestureDetector(
                      onTap: () => _showHelpBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          AssetConstants.motomasterLogo,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            // 2. Banner Container (Carousel loaded dynamically from database)
            Obx(() {
              if (controller.banners.isEmpty) {
                // Default banner fallback
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    AssetConstants.defaultBanner,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                );
              }

              final validBanners = controller.banners.where((banner) {
                final imageUrl = (banner['imageUrl'] ?? '').toString();
                return imageUrl.isNotEmpty;
              }).toList();

              if (validBanners.isEmpty) {
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    AssetConstants.defaultBanner,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                );
              }

              return CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  autoPlay: validBanners.length > 1,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
                items: validBanners.map((banner) {
                  final customBanner = (banner['imageUrl'] ?? '').toString();
                  final imageUrl = customBanner.startsWith('http')
                      ? customBanner
                      : ApiConstants.baseUrl.replaceAll('/api', '') + customBanner;

                  return SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        AssetConstants.defaultBanner,
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

            // 2. Circular Stats Section (binds dynamically via Obx)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                final stats = controller.stats.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatCircle(
                      title: 'in_progress'.tr,
                      value: '${stats.inProgress}',
                      icon: Icons.assignment_outlined,
                      color: AppColors.statInProgress,
                      onTap: () => Get.toNamed(
                        AppRoutes.jobCardList,
                        arguments: 'in-progress',
                      ),
                    ),
                    StatCircle(
                      title: 'complete'.tr,
                      value: '${stats.completed}',
                      icon: Icons.build,
                      color: AppColors.statComplete,
                      onTap: () => Get.toNamed(
                        AppRoutes.jobCardList,
                        arguments: 'completed',
                      ),
                    ),
                    StatCircle(
                      title: 'closed'.tr,
                      value: '${stats.closed}',
                      icon: Icons.check_circle,
                      color: AppColors.statClosed,
                      onTap: () => Get.toNamed(
                        AppRoutes.jobCardList,
                        arguments: 'closed',
                      ),
                    ),
                    StatCircle(
                      title: 'balance_pending'.tr,
                      value: '',
                      icon: Icons.currency_rupee,
                      color: AppColors.statPending,
                      onTap: () => _showBalancePendingBottomSheet(context),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 10),

            // 3. Reminders & Revenue Pill Rows (adjacent cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Reminders card
                  Expanded(
                    child: Obx(() {
                      return _buildPillCard(
                        context,
                        icon: Icons.notifications_active,
                        iconColor: Colors.blue,
                        title: 'reminders'.tr,
                        badgeCount: remindersController.allCount.value,
                        onTap: () => Get.toNamed(AppRoutes.reminders),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),

                  // Revenue card
                  Expanded(
                    child: _buildPillCard(
                      context,
                      icon: Icons.payments,
                      iconColor: Colors.green,
                      title: 'revenue'.tr,
                      onTap: () => Get.toNamed(AppRoutes.revenue),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Action grid (8 customizable grid elements)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                mainAxisSpacing: 10,
                crossAxisSpacing: 8,
                childAspectRatio: 0.82,
                children: [
                  GridCard(
                    title: 'analytics'.tr,
                    icon: Icons.bar_chart_outlined,
                    iconColor: AppColors.iconAnalytics,
                    onTap: () => Get.toNamed(AppRoutes.reports),
                  ),
                  GridCard(
                    title: 'inventory'.tr,
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.iconInventory,
                    onTap: () => Get.toNamed(AppRoutes.inventory),
                  ),
                  GridCard(
                    title: 'rc_check'.tr,
                    icon: Icons.directions_car_outlined,
                    iconColor: AppColors.iconRcCheck,
                    onTap: () => _showRcCheckBottomSheet(context),
                  ),
                  GridCard(
                    title: 'bookings'.tr,
                    icon: Icons.app_registration,
                    iconColor: AppColors.iconBookings,
                    onTap: () => Get.toNamed(AppRoutes.bookings),
                  ),
                  GridCard(
                    title: 'add_staff'.tr,
                    icon: Icons.person_add_outlined,
                    iconColor: AppColors.iconStaff,
                    onTap: () => Get.toNamed(AppRoutes.staff),
                  ),
                  GridCard(
                    title: 'parts_store'.tr,
                    icon: Icons.storefront_outlined,
                    iconColor: AppColors.iconStore,
                    onTap: () => _showPartsStoreBottomSheet(context),
                  ),
                  GridCard(
                    title: 'payment_qr_code'.tr,
                    icon: Icons.qr_code_2_outlined,
                    iconColor: AppColors.iconPayment,
                    onTap: () => Get.toNamed(AppRoutes.paymentQr),
                  ),
                  GridCard(
                    title: 'garage_profile'.tr,
                    icon: Icons.garage_outlined,
                    iconColor: AppColors.iconProfile,
                    onTap: () => Get.toNamed(AppRoutes.profile),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Recent Activity Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'recent_activity'.tr,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card showing "No recent activity"
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'no_recent_activity'.tr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'search_job_cards'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.performLocalSearch,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UppercaseTextFormatter()],
                  decoration: InputDecoration(
                    hintText: 'search_job_cards_hint'.tr,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Search results list
              Expanded(
                child: Obx(() {
                  if (controller.isJobCardsLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 70, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'loading_job_cards'.tr,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final list = controller.filteredJobCards;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchController.text.isEmpty
                                ? 'no_job_cards_found'.tr
                                : 'no_matching_results'.tr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchJobCards,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final card = list[index];
                        final customerName = card['customerName'] ?? 'N/A';
                        final vehicleNo = card['vehicleNumber'] ?? 'N/A';
                        final makeModel =
                            '${card['vehicleMake'] ?? ''} ${card['vehicleModel'] ?? ''}'
                                .trim();
                        final jcNo = card['jobCardNumber'] ?? 'N/A';
                        final total = card['grandTotal'] ?? 0;
                        final status = (card['status'] ?? 'pending')
                            .toString()
                            .toUpperCase();

                        Color statusColor;
                        switch (card['status'] ?? 'pending') {
                          case 'pending':
                            statusColor = AppColors.statInProgress;
                            break;
                          case 'in-progress':
                            statusColor = AppColors.statInProgress;
                            break;
                          case 'completed':
                            statusColor = AppColors.statComplete;
                            break;
                          case 'closed':
                            statusColor = AppColors.statClosed;
                            break;
                          default:
                            statusColor = AppColors.textSecondary;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    jcNo,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                customerName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_car,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$vehicleNo ${makeModel.isNotEmpty ? "• $makeModel" : ""}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 0.5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Grand Total',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₹$total',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // Floating Action Button at Bottom Right as requested: "+ icon in blue circle"
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                controller.changeTab(2);
              },
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(BuildContext context) {
    final remindersController = Get.put(ServiceRemindersController());

    String getMonthName(int month) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[month - 1];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'alerts'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Dynamic Horizontal Tab Selector (All, Today, Upcoming, Past) with counts from API
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Obx(() {
              final idx = remindersController.selectedTab.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAlertTabItem(
                    remindersController,
                    0,
                    'all'.tr,
                    remindersController.allCount.value,
                    idx == 0,
                  ),
                  _buildAlertTabItem(
                    remindersController,
                    1,
                    'today'.tr,
                    remindersController.todayCount.value,
                    idx == 1,
                  ),
                  _buildAlertTabItem(
                    remindersController,
                    2,
                    'upcoming'.tr,
                    remindersController.upcomingCount.value,
                    idx == 2,
                  ),
                  _buildAlertTabItem(
                    remindersController,
                    3,
                    'past'.tr,
                    remindersController.pastCount.value,
                    idx == 3,
                  ),
                ],
              );
            }),
          ),
          Container(height: 1, color: Colors.grey[200]),

          // List Body
          Expanded(
            child: Obx(() {
              if (remindersController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final list = remindersController.reminders;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_activities_yet'.tr,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Service reminders and garage alerts will appear here when active.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: remindersController.fetchReminders,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final customerName = item['customerName'] ?? 'N/A';
                    final vehicleNo = item['vehicleNumber'] ?? 'N/A';
                    final makeModel =
                        '${item['vehicleMake'] ?? ''} ${item['vehicleModel'] ?? ''}'
                            .trim();
                    final label = item['reminderLabel'] ?? 'Service Reminder';
                    final priority = item['priority'] ?? 'Servicing';

                    DateTime? remDate;
                    if (item['reminderDate'] != null) {
                      remDate = DateTime.tryParse(item['reminderDate']);
                    }
                    final formattedDate = remDate != null
                        ? '${remDate.day} ${getMonthName(remDate.month)} ${remDate.year}'
                        : 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 8,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  priority.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => remindersController
                                    .dismissReminder(item['_id']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            customerName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$vehicleNo ${makeModel.isNotEmpty ? "• $makeModel" : ""}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(height: 20, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'reminder_date'.tr,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'more'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMoreItem(
              icon: Icons.storefront_outlined,
              title: 'workshop_profile'.tr,
              onTap: () => Get.toNamed(AppRoutes.profile),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.home_outlined,
              title: 'home'.tr,
              onTap: () => controller.changeTab(0),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.settings_outlined,
              title: 'settings_option'.tr,
              onTap: () => Get.toNamed(AppRoutes.profileEdit),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.share_outlined,
              title: 'share'.tr,
              onTap: () {
                Clipboard.setData(
                  const ClipboardData(
                    text:
                        'Download MotoMaster App: Manage your garage workshop, analytics, stocks, billing and staff instantly!',
                  ),
                );
                Get.snackbar(
                  'share'.tr,
                  'MotoMaster share invite message copied to clipboard!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.language_outlined,
              title: 'language'.tr,
              onTap: () => _showLanguageSelector(context),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.qr_code_2_outlined,
              title: 'payment_qr_code'.tr,
              onTap: () => Get.toNamed(AppRoutes.paymentQr),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.help_outline_outlined,
              title: 'help_and_support'.tr,
              onTap: () => _showHelpBottomSheet(context),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.security_outlined,
              title: 'privacy_policy'.tr,
              onTap: () => _showPrivacyPolicyDialog(context),
            ),
            const SizedBox(height: 12),
            _buildMoreItem(
              icon: Icons.logout,
              title: 'logout'.tr,
              isDestructive: true,
              onTap: controller.logout,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
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
        child: Column(
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
            Text(
              'select_language'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(
              langName: 'English',
              langCode: 'en',
              countryCode: 'US',
              isActive: Get.locale?.languageCode == 'en',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              langName: 'हिंदी (Hindi)',
              langCode: 'hi',
              countryCode: 'IN',
              isActive: Get.locale?.languageCode == 'hi',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              langName: 'मराठी (Marathi)',
              langCode: 'mr',
              countryCode: 'IN',
              isActive: Get.locale?.languageCode == 'mr',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildLanguageOption({
    required String langName,
    required String langCode,
    required String countryCode,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        final storage = GetStorage();
        storage.write('lang_code', langCode);
        storage.write('country_code', countryCode);

        Get.updateLocale(Locale(langCode, countryCode));
        Get.back();

        Get.snackbar(
          'language'.tr,
          'language_changed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langName,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'privacy_policy'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'MotoMaster values your security. All data relating to your workshop, employees, analytics, billing summaries, and transactions are kept fully encrypted and stored securely.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'Data Collection & Use',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '- Workshop details are used to show profile data and generate valid invoice billings.\n'
                '- Staff records are kept locally to map mechanics and work distribution.\n'
                '- Analytics calculations are processed in real-time inside your isolated garage sandbox.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Dismiss',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.redAccent : Colors.grey[600],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.redAccent
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreAlert(String title) {
    Get.snackbar(
      title,
      'Opening $title panel...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final remindersController = Get.put(ServiceRemindersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: null,
      body: _buildBody(context),

      // 6. Styled Bottom Navigation with Center Wrench FAB (BottomAppBar design matches screenshot)
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shadowColor: Colors.black26,
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 76,
          child: Obx(() {
            final idx = controller.selectedIndex.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'home'.tr, idx == 0, 0),
                _buildNavItem(Icons.search, 'search'.tr, idx == 1, 1),

                // Custom non-floating center button matching screenshot color scheme & design
                GestureDetector(
                  onTap: () => controller.changeTab(2),
                  child: Container(
                    width: 68,
                    height: 68,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Container(
                              width: 3.5,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                _buildNavItem(
                  Icons.notifications_outlined,
                  'alerts'.tr,
                  idx == 3,
                  3,
                  badgeCount: remindersController.allCount.value,
                ),
                _buildNavItem(Icons.history_outlined, 'more'.tr, idx == 4, 4),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Pill link helper card
  Widget _buildPillCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Container(
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
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Alerts dynamic horizontal tab selection item helper
  Widget _buildAlertTabItem(
    ServiceRemindersController controller,
    int index,
    String title,
    int count,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title ($count)',
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation item helper
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    int index, {
    int badgeCount = 0,
  }) {
    const activeColor = AppColors.primary;
    const inactiveColor = AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
                // Badge overlay
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGridAlert(String moduleName) {
    Get.snackbar(
      moduleName,
      'Opening the $moduleName module...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
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
        child: Column(
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

            // Cartoon Mechanic Avatar Box
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFCBE5FF,
                  ), // matching light blue square background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    AssetConstants.welcomeMechanic,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Help & Support',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            const Text(
              'We are here to help you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Email Support Card
            InkWell(
              onTap: () {
                Clipboard.setData(
                  const ClipboardData(text: 'motomastar007@gmail.com'),
                );
                Get.snackbar(
                  'Email Support',
                  'motomastar007@gmail.com copied to clipboard.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF), // soft blue background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCBE5FF), // soft blue border
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // circular icon wrapper
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9ECBFF), // circular icon background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF0056C6), // email icon color
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // texts
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Support',
                            style: TextStyle(
                              color: Color(0xFF0056C6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'motomastar007@gmail.com',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF0056C6),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. WhatsApp Support Card
            InkWell(
              onTap: () async {
                const phone = '917507403301'; // 91 = India country code
                final uri = Uri.parse('https://wa.me/$phone');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  Clipboard.setData(const ClipboardData(text: '7507403301'));
                  Get.snackbar(
                    'WhatsApp Support',
                    '7507403301 copied to clipboard.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF25D366),
                    colorText: Colors.white,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFC2F0D0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9FE2B5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_outlined,
                        color: Color(0xFF0A7C32),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WhatsApp Support',
                            style: TextStyle(
                              color: Color(0xFF0A7C32),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '7507403301',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF0A7C32),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bottom text helper
            const Text(
              'Tap to open WhatsApp/email',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showRcCheckBottomSheet(BuildContext context) {
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
        child: Column(
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

            // Visual Outlined Car Container
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0072FF).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info,
                        color: Color(0xFF0072FF),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'RC Check',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Coming Soon Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // light amber background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B), // amber border
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Color(0xFFD97706), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Instantly verify vehicle registration details, check ownership history, and validate RC authenticity — all in one tap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Checklist Items
            _buildRcCheckItem(
              'Instant RC Verification',
              Icons.verified,
              const Color(0xFF0072FF),
              const Color(0xFFEBF5FF),
            ),
            _buildRcCheckItem(
              'Ownership History',
              Icons.history,
              const Color(0xFF10B981),
              const Color(0xFFE8F8EE),
            ),
            _buildRcCheckItem(
              'Blacklist & Challan Check',
              Icons.gpp_maybe,
              const Color(0xFFEF4444),
              const Color(0xFFFEE2E2),
            ),
            _buildRcCheckItem(
              'Insurance & PUC Status',
              Icons.tag,
              const Color(0xFFF59E0B),
              const Color(0xFFFEF3C7),
            ),
            const SizedBox(height: 28),

            // Notify Button
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Subscription Added',
                  'We will notify you when RC Check is live!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF0D6EFD),
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Notify Me When Live',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showPartsStoreBottomSheet(BuildContext context) {
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
        child: Column(
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

            // Visual Outlined Red Storefront Container
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Parts Store',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Coming Soon Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // light amber background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B), // amber border
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Color(0xFFD97706), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Order genuine spare parts, accessories & consumables directly for your workshop — at wholesale prices, delivered to your door.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Checklist Items
            _buildRcCheckItem(
              'Genuine Spare Parts',
              Icons.settings,
              const Color(0xFFEF4444),
              const Color(0xFFFEE2E2),
            ),
            _buildRcCheckItem(
              'Fast Doorstep Delivery',
              Icons.local_shipping,
              const Color(0xFFF59E0B),
              const Color(0xFFFEF3C7),
            ),
            _buildRcCheckItem(
              'Wholesale Prices',
              Icons.attach_money,
              const Color(0xFF10B981),
              const Color(0xFFE8F8EE),
            ),
            _buildRcCheckItem(
              'Live Stock Updates',
              Icons.inventory_2,
              const Color(0xFF0072FF),
              const Color(0xFFEBF5FF),
            ),
            const SizedBox(height: 28),

            // Notify Button
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Subscription Added',
                  'We will notify you when Parts Store is live!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Notify Me When Live',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildRcCheckItem(String label, IconData icon, Color color, Color bg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.grey[200], size: 20),
        ],
      ),
    );
  }

  void _showBalancePendingBottomSheet(BuildContext context) {
    // Lazily inject/find the listings controller
    final JobCardListController listController =
        Get.isRegistered<JobCardListController>()
        ? Get.find<JobCardListController>()
        : Get.put(JobCardListController());

    // Trigger a refresh of the pending list on launch
    listController.fetchBalancePendingCards();

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
          final pendingCards = listController.pendingBalanceCards;
          final totalBalance = listController.totalPendingBalance.value;
          final count = pendingCards.length;

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

              // Bottom Sheet Header: Rupee Icon in Purple Box + Title + Stats (Matches the first screenshot exactly!)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF), // Light purple background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      color: Color(0xFFA855F7), // Purple color
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amt Pending',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count job cards  •  Total ₹${totalBalance.toStringAsFixed(0)}',
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
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

              // Content Area
              if (pendingCards.isEmpty)
                // Clean checkmark state (matches the first screenshot exactly!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFFE8F8EE,
                          ), // Soft green circle background
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF10B981), // Solid green checkmark
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No amt pending!',
                        style: TextStyle(
                          color: Color(0xFF10B981), // Green text
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'All payments are cleared.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // List of pending cards
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: pendingCards.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = pendingCards[idx];
                      final jcNum = item['jobCardNumber'] ?? 'JC0000';
                      final name = item['customerName'] ?? 'Walk-In Customer';
                      final vehicle = item['vehicleNumber'] ?? 'N/A';
                      final balance =
                          double.tryParse(
                            item['balanceAmount']?.toString() ?? '0',
                          ) ??
                          0.0;

                      return Container(
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
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$jcNum  •  $vehicle',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${balance.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {
                                    Get.back(); // Close bottom sheet
                                    listController.collectPendingPayment(
                                      item['_id'],
                                      balance,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F8EE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Clear Due',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
}
