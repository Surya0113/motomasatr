// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:motomastar/app/data/models/garage_owner_model.dart';
import 'package:motomastar/app/data/services/api_service.dart';
import 'package:motomastar/features/jobcard/jobcard_create_controller.dart';
import 'package:motomastar/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GarageOwnerModel resolves alternate profile fields', () {
    final model = GarageOwnerModel.fromJson({
      'garageName': 'Bike Garage',
      'logoUrl': 'https://example.com/logo.png',
      'firstName': 'Bike',
      'lastName': 'Garage',
      'email': 'test@example.com',
      'mobileNumber': '9999999999',
      'address': 'Main Road',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pincode': '400001',
      'workshopType': ['2 Wheeler'],
    });

    expect(model.workshopName, 'Bike Garage');
    expect(model.customLogo, 'https://example.com/logo.png');
  });

  test('Selected spare quantity updates and refreshes the list', () async {
    Get.reset();
    await GetStorage.init();
    Get.put(ApiService());

    final controller = JobCardCreateController();
    controller.selectedSpares.assignAll([
      {'id': '1', 'name': 'ENGINE OIL', 'brand': 'Castrol', 'qty': 1.0, 'sellPrice': 500.0},
    ]);

    controller.updateSelectedSpareQuantity(
      '1',
      delta: 1,
      maxQty: 5,
    );

    expect(controller.selectedSpares.first['qty'], 2.0);
    expect(controller.selectedSpares.length, 1);
  });

  testWidgets('MyApp builds successfully with profile data dependencies', (WidgetTester tester) async {
    Get.reset();
    await GetStorage.init();
    Get.put(ApiService());

    await tester.pumpWidget(const MyApp());

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
