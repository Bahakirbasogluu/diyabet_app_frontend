class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // Web / Desktop / iOS
  // static const String baseUrl = 'https://your-production-url.com'; // Production

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String mfaVerify = '/auth/mfa/verify';
  static const String mfaSetup = '/auth/mfa/setup';
  static const String mfaConfirm = '/auth/mfa/confirm';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/password/forgot';
  static const String resetPassword = '/auth/password/reset';
  static const String changePassword = '/auth/password/change';

  // Health
  static const String health = '/health';
  static const String healthHistory = '/health/history';
  static const String healthStats = '/health/stats';

  // Analytics
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsTrends = '/analytics/trends';

  // Chatbot
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';

  // Compliance
  static const String privacyPolicy = '/compliance/privacy-policy';
  static const String terms = '/compliance/terms';
  static const String consent = '/compliance/consent';

  // Users
  static const String userProfile = '/users/profile';
  static const String userExport = '/users/export';
  static const String userDelete = '/users/data';
}
