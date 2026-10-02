class ApiConstants {
  // Local dev  → 'http://192.168.1.16:5050/api'  (physical device on same WiFi)
  // Emulator   → 'http://10.0.2.2:5050/api'
  // Production → 'https://backend.motomastar.com/api'
  static const String baseUrl = 'https://backend.motomastar.com/api';

  // Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register-garage-owner';
  static const String login = '/auth/login';

  // Garage Profile
  static const String garageProfile = '/garage/profile';
  static const String garageUpdateProfile = '/garage/profile'; // PUT /garage/profile/:id

  // Job Cards
  static const String jobCardStats = '/jobcard/stats';
  static const String jobCardAll = '/jobcard/all';
}
