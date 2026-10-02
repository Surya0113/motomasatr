import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jobcard_details_controller.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/uppercase_text_formatter.dart';
import '../../../app/core/values/api_constants.dart';
import '../../../app/routes/app_routes.dart';

class JobCardDetailsView extends GetView<JobCardDetailsController> {
  const JobCardDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final isClosed = controller.jobCard['status'] == 'closed';
          return Text(
            isClosed ? 'receipt'.tr : 'estimate'.tr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );
        }),
        actions: [
          // Edit action
          Obx(() {
            final isClosed = controller.jobCard['status'] == 'closed';
            if (isClosed) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textPrimary),
              onPressed: () => Get.toNamed(
                AppRoutes.createJobCard,
                arguments: controller.jobCard,
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
            onPressed: () => controller.shareReceipt(),
          ),
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.textPrimary),
            onPressed: () {
              Get.snackbar(
                'Print JobCard',
                'Connecting to wireless thermal printer ...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.jobCard.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final jobCard = Map<String, dynamic>.from(controller.jobCard);
        final profile = Map<String, dynamic>.from(controller.garageProfile);
        final itemsList = <Map<String, dynamic>>[];

        for (final part in (jobCard['spareParts'] as List? ?? [])) {
          itemsList.add({
            'name': part['name'] ?? 'Part',
            'qty': part['quantity'] ?? part['qty'] ?? 1,
            'rate': double.tryParse(part['rate']?.toString() ?? '0.0') ?? 0.0,
            'discount': double.tryParse(part['discount']?.toString() ?? '0.0') ?? 0.0,
            'amount': double.tryParse(part['amount']?.toString() ?? '0.0') ?? 0.0,
          });
        }
        for (final job in (jobCard['jobs'] as List? ?? [])) {
          itemsList.add({
            'name': job['name'] ?? 'Service',
            'qty': job['quantity'] ?? job['qty'] ?? 1,
            'rate': double.tryParse(job['rate']?.toString() ?? '0.0') ?? 0.0,
            'discount': double.tryParse(job['discount']?.toString() ?? '0.0') ?? 0.0,
            'amount': double.tryParse(job['amount']?.toString() ?? '0.0') ?? 0.0,
          });
        }
        if (jobCard['lubricants'] != null && jobCard['lubricants'] is List) {
          for (final lube in jobCard['lubricants']) {
            itemsList.add({
              'name': lube['name'] ?? 'Lubricant',
              'qty': lube['quantity'] ?? 1,
              'rate': double.tryParse(lube['rate']?.toString() ?? '0.0') ?? 0.0,
              'discount':
                  double.tryParse(lube['discount']?.toString() ?? '0.0') ?? 0.0,
              'amount':
                  double.tryParse(lube['amount']?.toString() ?? '0.0') ?? 0.0,
            });
          }
        }

        // Totals (computed dynamically inside the Flutter app logic)
        double computedSubTotal = 0.0;
        for (final item in itemsList) {
          computedSubTotal += item['amount'] as double;
        }

        final estimateVal =
            double.tryParse(jobCard['estimateAmount']?.toString() ?? '0') ??
            0.0;
        final discount = double.tryParse(
            (jobCard['discount'] ?? jobCard['discountAmount'])?.toString() ??
              '0',
          ) ??
          0.0;
        final advance =
            double.tryParse(jobCard['advancePayment']?.toString() ?? '0') ??
            0.0;
        final serverGrandTotal = double.tryParse(
            (jobCard['grandTotal'] ?? jobCard['totalAmount'])?.toString() ??
              '',
          ) ??
          0.0;
        final serverBalance = double.tryParse(
            jobCard['balanceAmount']?.toString() ?? '',
          ) ??
          0.0;
        final directPaidAmount = double.tryParse(
            (jobCard['paidAmount'] ??
                jobCard['amountPaid'] ??
                jobCard['totalPaid'])
              ?.toString() ??
              '',
          ) ??
          0.0;
        final payments = jobCard['payments'] ?? jobCard['paymentHistory'];
        final paymentHistoryTotal = payments is List
          ? payments.fold<double>(
            0.0,
            (sum, payment) =>
              sum +
              (double.tryParse(
                  (payment['amountPaid'] ?? payment['amount'])
                      ?.toString() ??
                    '0',
                ) ??
                0.0),
            )
          : 0.0;
        final paidAmount = directPaidAmount > 0
          ? directPaidAmount
          : (paymentHistoryTotal > 0
            ? paymentHistoryTotal
            : (serverGrandTotal > 0
              ? serverGrandTotal - serverBalance
              : 0.0));
        final tax = double.tryParse(jobCard['tax']?.toString() ?? '0') ?? 0.0;

        final grandTotal = computedSubTotal + tax - discount;
        final balance = grandTotal - advance - paidAmount;

        final formattedEstimate = estimateVal.toStringAsFixed(0);
        final formattedTotal = grandTotal.toStringAsFixed(0);
        final formattedAdvance = advance.toStringAsFixed(0);
        final formattedPaidAmount = paidAmount.toStringAsFixed(0);
        final formattedDiscount = discount.toStringAsFixed(0);
        final formattedBalance = balance.toStringAsFixed(0);
        final totalItems = itemsList.fold<int>(
          0,
          (sum, item) => sum + (item['qty'] as num).toInt(),
        );

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: RepaintBoundary(
                  key: controller.boundaryKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGarageHeader(profile),
                        const SizedBox(height: 8),

                        _buildJobCardMetadata(jobCard),
                        const SizedBox(height: 8),
                        _buildBillToCard(jobCard),
                        const SizedBox(height: 8),
                        _buildVehicleInfoCard(jobCard),
                        const SizedBox(height: 8),
                        _buildItemsTable(itemsList),
                        const SizedBox(height: 8),
                        _buildPricingSummary(
                          estimate: formattedEstimate,
                          grandTotal: formattedTotal,
                          advance: formattedAdvance,
                          paidAmount: formattedPaidAmount,
                          discount: formattedDiscount,
                          balance: formattedBalance,
                          totalItems: totalItems > 0
                              ? totalItems.toString()
                              : '-',
                        ),
                        const SizedBox(height: 6),

                        // Amount in Words
                        _buildAmountInWords(balance),
                        const SizedBox(height: 8),

                        // 8. T&C and Signatures
                        _buildTermsAndSignatures(profile),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom action buttons based on status
            _buildBottomActionButtons(context, jobCard['status'] ?? 'pending'),
          ],
        );
      }),
    );
  }

  Widget _buildBillHeader(Map<String, dynamic> profile) {
    final billHeader = profile['billHeader']?.toString().trim() ?? '';

    if (billHeader.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Text(
        billHeader,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGarageHeader(Map<String, dynamic> profile) {
    final baseRoot = ApiConstants.baseUrl.replaceAll('/api', '');

    // Right avatar (customBanner) keeps mechanic fallback
    Widget buildAvatar(String? path) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: (path == null || path.isEmpty)
            ? Image.asset(
                'assets/images/welcome_mechanic.png',
                fit: BoxFit.cover,
              )
            : Image.network(
                path.startsWith('http') ? path : '$baseRoot$path',
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/welcome_mechanic.png',
                  fit: BoxFit.cover,
                ),
              ),
      );
    }

    // Left avatar (workshop logo)
    Widget buildLogoAvatar(String? path, String name) {
      final initials = name.trim().isNotEmpty
          ? name
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .join()
          : 'WS';

      Widget fallback = Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: (path == null || path.isEmpty)
            ? fallback
            : Image.network(
                path.startsWith('http') ? path : '$baseRoot$path',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      );
    }

    final garageName = profile['workshopName'] ?? 'Workshop';
    final phone1 = profile['mobileNumber'] ?? 'N/A';
    final phone2 = profile['phoneNumber2'] ?? '';
    final email = profile['email'] ?? 'N/A';
    final address = profile['address'] ?? '';
    final city = profile['city'] ?? '';
    final state = profile['state'] ?? '';
    final pincode = profile['pincode'] ?? '';
    final fullAddress = [
      address,
      city,
      state,
      pincode,
    ].where((x) => x.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0E6), Color(0xFFE6F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBillHeader(profile),
          const SizedBox(height: 2),

          // Top Row: Logo | Phone Numbers | Image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Avatar
              Padding(
                padding: EdgeInsets.zero,
                child: buildLogoAvatar(profile['customLogo'], garageName),
              ),
              
              // Center: Phone Numbers
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      // Garage Name
                      Text(
                        garageName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Phone Numbers
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Primary Phone
                          _buildContactItemCompact(
                            icon: Icons.phone_outlined,
                            iconBgColor: Colors.blue[50]!,
                            iconColor: Colors.blue[600]!,
                            label: 'Primary',
                            value: phone1,
                          ),
                          const SizedBox(width: 2),
                          // Alternate Phone (if exists)
                          if (phone2.isNotEmpty)
                            _buildContactItemCompact(
                              icon: Icons.phone_outlined,
                              iconBgColor: Colors.green[50]!,
                              iconColor: Colors.green[600]!,
                              label: 'Alternate',
                              value: phone2,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right Avatar with by MotoMaster label
              Transform.translate(
                offset: const Offset(0, -8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildAvatar(profile['customBanner']),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'by MotoMaster',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),

          // Contact Information (Email & Address)
          SizedBox(
            height: 18,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: 50,
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Center(
                  child: Column(
                    children: [
                      // Email
                      _buildContactItemCompact(
                        icon: Icons.email_outlined,
                        iconBgColor: Colors.purple[50]!,
                        iconColor: Colors.purple[600]!,
                        label: 'Email',
                        value: email,
                        maxWidth: 300,
                      ),
                      const SizedBox(height: 0),
                      // Address
                      Transform.translate(
                        offset: const Offset(0, 8),
                        child: _buildContactItemCompact(
                          icon: Icons.location_on_outlined,
                          iconBgColor: Colors.orange[50]!,
                          iconColor: Colors.orange[600]!,
                          label: 'Address',
                          value: fullAddress.isEmpty ? 'N/A' : fullAddress,
                          maxLines: 2,
                          maxWidth: 300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItemCompact({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    int maxLines = 1,
    double? maxWidth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 8, color: iconColor),
          ),
          const SizedBox(width: 4),
          // Value Only (No Label)
          ConstrainedBox(
            constraints: maxWidth == null
                ? const BoxConstraints()
                : BoxConstraints(maxWidth: maxWidth),
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCardMetadata(Map<String, dynamic> jobCard) {
    final jcNumber = jobCard['jobCardNumber'] ?? 'JC0000000';

    // Parse Date & Time
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'No: ${jcNumber.toString()}',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ); /*
                  text: jcNumber.toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  // Center: Phone Numbers
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          // Garage Name
                          Text(
                            garageName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Phone Numbers
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Primary Phone
              ],
            ),
                                iconBgColor: Colors.blue[50]!,
                                iconColor: Colors.blue[600]!,
                                label: 'Primary',
                                value: phone1,
                              ),
                              const SizedBox(width: 2),
                              // Alternate Phone (if exists)
                              if (phone2.isNotEmpty)
                                _buildContactItemCompact(
                                  icon: Icons.phone_outlined,
                                  iconBgColor: Colors.green[50]!,
                                  iconColor: Colors.green[600]!,
                                  label: 'Alternate',
                                  value: phone2,
                                ),
                            ],
              width: 1,
              thickness: 1,
                      ),
                    ),
          RichText(
            text: TextSpan(
              text: 'Time: ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: timeStr.isEmpty ? 'N/A' : timeStr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  */
  }

  Widget _buildBillToCard(Map<String, dynamic> jobCard) {
    final customerName = jobCard['customerName'] ?? 'Walk-In Customer';
    final customerPhone = jobCard['customerPhone'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Subtle pink theme from screenshot
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BILL TO',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: customerName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      const TextSpan(
                        text: '  |  ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: customerPhone,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: Call & WhatsApp
          Row(
            children: [
              // WhatsApp green icon card
              InkWell(
                onTap: () => controller.launchWhatsApp(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF25D366), // Green color matching WhatsApp
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Call blue icon card
              InkWell(
                onTap: () => controller.makeCall(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD2E3FC)),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF1A73E8), // Phone blue
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(Map<String, dynamic> jobCard) {
    final vehicleNo = jobCard['vehicleNumber'] ?? 'N/A';
    final make = jobCard['vehicleMake'] ?? '';
    final model = jobCard['vehicleModel'] ?? '';
    final variant = jobCard['vehicleVariant'] ?? '';
    final km = jobCard['odometerReading'] ?? '0';
    final fuel = jobCard['fuelLevel'] ?? '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Subtle pink theme matching screenshot
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VEHICLE INFO',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.speed, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    '$km km',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.local_gas_station_outlined,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$fuel%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              text: '$vehicleNo  ',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(
                  text: '|  ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextSpan(
                  text: '$make  $model  $variant',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<Map<String, dynamic>> itemsList) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: const Color(0xFFFFEBEE),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () {
                      final isClosed = controller.jobCard['status'] == 'closed';
                      if (isClosed) return;
                      _showAddItemsBottomSheet(Get.context!);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF007BFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Items',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Qt.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Rate',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Disc',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Amt',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Content rows
          if (itemsList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: Text(
                  'No items added',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsList.length,
              separatorBuilder: (c, i) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = itemsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item['qty'].toString(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${(item['rate'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '-₹${(item['discount'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${(item['amount'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary({
    required String estimate,
    required String grandTotal,
    required String advance,
    required String paidAmount,
    required String discount,
    required String balance,
    required String totalItems,
  }) {
    Widget buildRow(
      String leftTitle,
      String leftVal,
      String rightTitle,
      String rightVal, {
      bool isRedRight = false,
      bool isTotal = false,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: isTotal
            ? const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left block
            Expanded(
              child: Row(
                children: [
                  Text(
                    leftTitle,
                    style: TextStyle(
                      color: isTotal
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      fontSize: isTotal ? 14 : 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    leftVal,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      fontSize: isTotal ? 14 : 12,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Right block
            Expanded(
              child: Row(
                children: [
                  Text(
                    rightTitle,
                    style: TextStyle(
                      color: isTotal
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      fontSize: isTotal ? 14 : 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rightVal,
                    style: TextStyle(
                      color: isRedRight
                          ? const Color(0xFF10B981)
                          : AppColors.textPrimary, // green if discount -₹0
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      fontSize: isTotal ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 4),
          buildRow('Estimate', '₹$estimate', 'Total Items', totalItems),
          buildRow(
            'advance'.tr,
            '₹$advance',
            'Paid Amount',
            '₹$paidAmount',
          ),
          buildRow(
            'discount'.tr,
            '-₹$discount',
            '',
            '',
            isRedRight: true,
          ),
          buildRow('total_amount'.tr, '₹$balance', '', '', isTotal: true),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildAmountInWords(double number) {
    String text = numberToWords(number);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Amount: $text',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildTermsAndSignatures(Map<String, dynamic> profile) {
    final tAndC = profile['termsAndConditions'] ?? 'true';
    final garageName = profile['workshopName'] ?? 'Workshop';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Thank you for choosing our service.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tAndC,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
        const SizedBox(height: 48),

        // Signature Pads
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 1,
                    color: const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Customer Signature',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    garageName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 1,
                    color: const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Authorized Signature',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(BuildContext context, String status) {
    if (status == 'closed') {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Job Card Closed',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Complete button for both pending and in-progress job cards.
          if (status == 'pending' || status == 'in-progress')
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showPaymentDialog(context, 'completed'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF007BFF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'complete_job_card'.tr,
                  style: const TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          if (status == 'pending' || status == 'in-progress')
            const SizedBox(width: 12),

          // Close button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showPaymentDialog(context, 'closed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF28A745,
                ), // Green color matching close action
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'close_job_card'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String newStatus) {
    final total = controller.computedBalance;
    final advanceController = TextEditingController(text: '0');
    final discountController = TextEditingController(text: '0');
    final paidController = TextEditingController(text: '0');
    final monthsController = TextEditingController(text: '4 Months');
    final kmController = TextEditingController(text: '3000 KM');
    final paymentTypeController = TextEditingController(text: 'Online');
    final priorityController = TextEditingController(text: 'Servicing');
    bool payFullAmount = false;
    bool smsAlert = true;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.22),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final advance = double.tryParse(advanceController.text) ?? 0;
          final discount = double.tryParse(discountController.text) ?? 0;
          final payable = total - advance - discount;
          final paid = payFullAmount ? payable : (double.tryParse(paidController.text) ?? 0);

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .88),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: Colors.red, size: 28),
                        label: const Text('Close', style: TextStyle(color: Colors.red, fontSize: 18)),
                      ),
                    ),
                    _paymentDialogAmountRow('TOTAL AMOUNT', total, 26),
                    const SizedBox(height: 12),
                    _paymentDialogInputRow('Advance', advanceController, () => setState(() {})),
                    const SizedBox(height: 8),
                    _paymentDialogInputRow('Discount', discountController, () => setState(() {}), isDiscount: true),
                    const SizedBox(height: 12),
                    _paymentDialogAmountRow('Payable Amount', payable, 22),
                    const SizedBox(height: 8),
                    _paymentDialogInputRow('Paid Amount', paidController, () => setState(() {})),
                    Row(
                      children: [
                        Checkbox(value: payFullAmount, activeColor: Colors.teal, onChanged: (v) => setState(() => payFullAmount = v ?? false)),
                        const Text('Pay Full Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Center(child: Text('Select Date: ${DateTime.now().toString().substring(0, 19)}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 15, fontWeight: FontWeight.w700))),
                    const SizedBox(height: 10),
                    _paymentDialogAmountRow('Balance', payable - paid, 18),
                    const SizedBox(height: 12),
                    const Text('Service Reminder Setting', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Row(children: [Expanded(child: _paymentDialogSmallInput(monthsController)), const SizedBox(width: 12), Expanded(child: _paymentDialogSmallInput(kmController))]),
                    const SizedBox(height: 12),
                    const Text('Payment Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    _paymentDialogSelectInput(paymentTypeController),
                    const SizedBox(height: 8),
                    const Text('Reminder Priority', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    _paymentDialogSelectInput(priorityController),
                    Row(children: [const Expanded(child: Text('SMS Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))), Switch(value: smsAlert, onChanged: (v) => setState(() => smsAlert = v))]),
                    SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.completeWithPayment(
                          newStatus,
                          paid,
                          paymentTypeController.text,
                          advance: advance,
                          discount: discount,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: newStatus == 'closed' ? const Color(0xFF28A745) : const Color(0xFF007BFF), padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(newStatus == 'closed' ? 'Confirm & Close' : 'Confirm & Complete', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _paymentDialogAmountRow(String label, double value, double fontSize) {
    return Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: AppColors.textPrimary))), Text('₹${value.toStringAsFixed(0)}', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: AppColors.primary))]);
  }

  Widget _paymentDialogInputRow(String label, TextEditingController controller, VoidCallback onChanged, {bool isDiscount = false}) {
    return Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDiscount ? Colors.red : AppColors.textPrimary))), SizedBox(width: 140, child: TextField(controller: controller, onChanged: (_) => onChanged(), keyboardType: TextInputType.number, textAlign: TextAlign.right, decoration: const InputDecoration(filled: true, fillColor: Colors.white, hintText: '0', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder())))]);
  }

  Widget _paymentDialogSmallInput(TextEditingController controller) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF7E3EE), borderRadius: BorderRadius.circular(8)), child: TextField(controller: controller, textAlign: TextAlign.center, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero)));
  }

  Widget _paymentDialogSelectInput(TextEditingController controller) {
    return TextField(controller: controller, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF7E3EE), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), suffixIcon: const Icon(Icons.arrow_drop_down)));
  }

  // Number to Words in Indian numbering format
  static String numberToWords(double number) {
    if (number == 0) return 'Zero Rupees Only.';
    final isNegative = number < 0;
    final intAmount = number.abs().toInt();

    final units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen",
    ];
    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety",
    ];

    String convert(int n) {
      if (n < 20) return units[n];
      if (n < 100)
        return tens[n ~/ 10] + (n % 10 != 0 ? " ${units[n % 10]}" : "");
      if (n < 1000)
        return "${units[n ~/ 100]} Hundred" +
            (n % 100 != 0 ? " and ${convert(n % 100)}" : "");
      if (n < 100000)
        return "${convert(n ~/ 1000)} Thousand" +
            (n % 1000 != 0 ? " ${convert(n % 1000)}" : "");
      if (n < 10000000)
        return "${convert(n ~/ 100000)} Lakh" +
            (n % 100000 != 0 ? " ${convert(n % 100000)}" : "");
      return "${convert(n ~/ 10000000)} Crore" +
          (n % 10000000 != 0 ? " ${convert(n % 10000000)}" : "");
    }

    return "${isNegative ? 'Minus ' : ''}${convert(intAmount)} Rupees Only.";
  }

  void _showAddItemsBottomSheet(BuildContext context) {
    controller.loadInventoryItems();
    controller.selectedSpares.clear();

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
          final spares = controller.selectedSpares.value;
          final isInventoryTab =
              controller.activeInventoryTab.value == 'inventory';

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

              // Tab Selector
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
                        onTap: () =>
                            controller.activeInventoryTab.value = 'inventory',
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isInventoryTab
                                ? const Color(0xFF0091FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'From Inventory',
                            style: TextStyle(
                              color: isInventoryTab
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            controller.activeInventoryTab.value = 'manual',
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isInventoryTab
                                ? const Color(0xFF0091FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Manual Entry',
                            style: TextStyle(
                              color: !isInventoryTab
                                  ? Colors.white
                                  : AppColors.textSecondary,
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
                // Inventory search
                TextField(
                  controller: controller.searchInventoryController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UppercaseTextFormatter()],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    hintText: 'Search parts...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (c, idx) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final name = item['name'] ?? 'N/A';
                            final brand = item['brand'] ?? 'Generic';
                            final price = item['sellPrice'] ?? 0.0;
                            final qty = item['qty'] ?? 0;
                            final unit = item['unit'] ?? 'pieces';
                            final id = item['id'];

                            final addedIndex = spares.indexWhere(
                              (x) => x['id'] == id,
                            );
                            final isAdded = addedIndex != -1;
                            final addedQty = isAdded
                                ? spares[addedIndex]['qty']
                                : 0;
                            final selectedQty =
                                (addedQty as num?)?.toDouble() ?? 0;
                            final availableQty = (qty as num?)?.toDouble() ?? 0;
                            final remainingQty = (availableQty - selectedQty)
                                .clamp(0, availableQty);

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          'Stock: ${remainingQty % 1 == 0 ? remainingQty.toInt() : remainingQty} $unit',
                                          style: TextStyle(
                                            color: remainingQty == 0
                                                ? Colors.red
                                                : Colors.green[800],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(
                                            minWidth: 34,
                                            minHeight: 34,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.remove,
                                            color: isAdded
                                                ? Colors.red
                                                : Colors.grey[400],
                                            size: 20,
                                          ),
                                          onPressed: !isAdded
                                              ? null
                                              : () {
                                                  final existing =
                                                      Map<String, dynamic>.from(
                                                        spares[addedIndex],
                                                      );
                                                  final currentQty =
                                                      (existing['qty'] as num?)
                                                          ?.toDouble() ??
                                                      1;
                                                  if (currentQty <= 1) {
                                                    controller.removeSpareItem(
                                                      id.toString(),
                                                    );
                                                  } else {
                                                    existing['qty'] =
                                                        currentQty - 1;
                                                    spares[addedIndex] =
                                                        existing;
                                                    controller.selectedSpares
                                                        .refresh();
                                                  }
                                                },
                                        ),
                                        SizedBox(
                                          width: 28,
                                          child: Text(
                                            selectedQty % 1 == 0
                                                ? selectedQty.toInt().toString()
                                                : selectedQty.toStringAsFixed(
                                                    1,
                                                  ),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(
                                            minWidth: 34,
                                            minHeight: 34,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.add,
                                            color: selectedQty < availableQty
                                                ? const Color(0xFF0D6EFD)
                                                : Colors.grey[400],
                                            size: 20,
                                          ),
                                          onPressed: selectedQty < availableQty
                                              ? () => controller.addSpareItem(
                                                  item,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    Get.back();
                    if (controller.selectedSpares.isNotEmpty) {
                      await controller.saveSelectedSparesToJobCard();
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                // Manual Entry Form
                TextField(
                  controller: controller.manualItemNameController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: const [UppercaseTextFormatter()],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Item Name',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemQtyController,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: const [UppercaseTextFormatter()],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemRateController,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: const [UppercaseTextFormatter()],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rate (₹)',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.manualItemDiscountController,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: const [UppercaseTextFormatter()],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.local_offer,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                            onTap: () => controller.manualDiscountType.value =
                                'currency',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    controller.manualDiscountType.value ==
                                        'currency'
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
                                  color:
                                      controller.manualDiscountType.value ==
                                          'currency'
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                controller.manualDiscountType.value = 'percent',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    controller.manualDiscountType.value ==
                                        'percent'
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
                                  color:
                                      controller.manualDiscountType.value ==
                                          'percent'
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => controller.addManualItem(),
                  child: const Text(
                    'Add to Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
}
