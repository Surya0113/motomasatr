import 'dart:convert';
import 'package:dio/dio.dart' as dio_lib;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response; // Avoid naming conflict with Dio's Response
import 'package:get_storage/get_storage.dart';
import '../../core/values/api_constants.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final _storage = GetStorage();

  // Storage Keys
  static const String keyToken = 'token';
  static const String keyUser = 'user';

  Future<ApiService> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read<String>(keyToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌐 API REQUEST [${options.method}] ➔ ${options.uri}');
          if (options.data != null) {
            if (options.data is dio_lib.FormData) {
              debugPrint('📦 BODY: [FormData - multipart upload]');
            } else {
              try {
                debugPrint('📦 BODY: ${jsonEncode(options.data)}');
              } catch (_) {
                debugPrint('📦 BODY: [non-encodable data]');
              }
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ API RESPONSE [${response.statusCode}] ➔ ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ API ERROR [${e.response?.statusCode}] ➔ ${e.requestOptions.uri}');
          debugPrint('💬 ERROR MSG: ${e.message}');
          debugPrint('💬 ERROR RESPONSE: ${e.response?.data}');
          
          _handleError(e);
          return handler.next(e);
        },
      ),
    );

    return this;
  }

  // Generic Request Handlers
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool showError = true,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'showError': showError}),
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool showError = true,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'showError': showError}),
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool showError = true,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(extra: {'showError': showError}),
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool showError = true,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'showError': showError}),
      );
    } on DioException {
      rethrow;
    }
  }

  // Local Storage Helpers
  void saveToken(String token) {
    _storage.write(keyToken, token);
  }

  String? getToken() {
    return _storage.read<String>(keyToken);
  }

  void saveUser(Map<String, dynamic> userMap) {
    userMap = Map<String, dynamic>.from(userMap);

    if (userMap['id'] == null && userMap['_id'] != null) {
      userMap['id'] = userMap['_id'];
    }

    final normalizedWorkshopName = userMap['workshopName'] ?? userMap['garageName'] ?? '';
    final normalizedCustomLogo = userMap['customLogo'] ?? userMap['logoUrl'] ?? userMap['logo'] ?? '';
    final normalizedCustomBanner = userMap['customBanner'] ?? userMap['bannerUrl'] ?? userMap['coverImage'] ?? '';

    if (normalizedWorkshopName.toString().isNotEmpty) {
      userMap['workshopName'] = normalizedWorkshopName;
    }
    if (normalizedCustomLogo.toString().isNotEmpty) {
      userMap['customLogo'] = normalizedCustomLogo;
    }
    if (normalizedCustomBanner.toString().isNotEmpty) {
      userMap['customBanner'] = normalizedCustomBanner;
    }

    _storage.write(keyUser, userMap);
  }

  Map<String, dynamic>? getUser() {
    final user = _storage.read(keyUser);
    if (user != null) {
      if (user is Map) {
        return Map<String, dynamic>.from(user);
      }
    }
    return null;
  }

  void logout() {
    _storage.remove(keyToken);
    _storage.remove(keyUser);
    Get.offAllNamed('/welcome');
  }

  bool isLoggedIn() {
    final token = getToken();
    final user = getUser();

    return token != null &&
        token.toString().trim().isNotEmpty &&
        user != null &&
        user.isNotEmpty;
  }

  // Beautiful UI Error Toast / Snackbar
  void _handleError(DioException error) {
    final showErrorSnackbar = error.requestOptions.extra['showError'] as bool? ?? true;

    if (error.response?.statusCode == 401 && isLoggedIn()) {
      logout();
    }

    if (!showErrorSnackbar) return;

    String title = 'Network Error';
    String message = 'Something went wrong. Please try again.';

    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot reach server. Please ensure the backend is running.';
    } else if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          message = data['message'].toString();
        } else if (data['errors'] != null && data['errors'] is List) {
          final errorList = data['errors'] as List;
          if (errorList.isNotEmpty) {
            final firstError = errorList[0];
            if (firstError is Map && firstError['msg'] != null) {
              message = firstError['msg'].toString();
            } else {
              message = firstError.toString();
            }
          }
        }
      }
      
      switch (error.response?.statusCode) {
        case 400:
          title = 'Bad Request';
          break;
        case 401:
          title = 'Unauthorized';
          break;
        case 403:
          title = 'Forbidden';
          break;
        case 404:
          title = 'Not Found';
          break;
        case 500:
          title = 'Server Error';
          message = 'Internal server fault. Please contact support.';
          break;
      }
    }

    // Display beautiful glassmorphic animated error snackbar
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
