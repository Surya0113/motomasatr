import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/core/theme/app_themes.dart';
import 'app/data/services/api_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/values/app_translations.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage local caching
  await GetStorage.init();

  // Inject the ApiService network singleton into GetX DI
  await Get.putAsync<ApiService>(() => ApiService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = Get.find<ApiService>();
    final storage = GetStorage();

    // Load active locale from storage on boot (default is English)
    final String savedLang = storage.read('lang_code') ?? 'en';
    final String savedCountry = storage.read('country_code') ?? 'US';
    final Locale activeLocale = Locale(savedLang, savedCountry);

    // Determine the starting route based on a valid local session
    final bool hasValidSession = apiService.isLoggedIn();
    final String initialRoute = hasValidSession
        ? AppRoutes.dashboard
        : AppRoutes.welcome;

    return GetMaterialApp(
      title: 'Motomaster',
      debugShowCheckedModeBanner: false,
      
      // Language Localization setup
      translations: AppTranslations(),
      locale: activeLocale,
      fallbackLocale: const Locale('en', 'US'),
      
      // Theme settings
      theme: AppThemes.lightTheme,
      
      // Page routing tables
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
