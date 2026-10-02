import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showJobCardStatusDialog(String status) async {
  final isClosed = status == 'closed';
  final color = isClosed ? const Color(0xFF28A745) : const Color(0xFF007BFF);
  final label = isClosed ? 'closed'.tr : 'complete'.tr;

  Get.dialog<void>(
    Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: color, width: 5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'job_cards'.tr.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );

  await Future<void>.delayed(const Duration(milliseconds: 1800));
  if (Get.isDialogOpen ?? false) {
    Get.back<void>();
  }
}
