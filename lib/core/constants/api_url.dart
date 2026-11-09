class ApiUrl {
  // Adjust base url according to physical device or emulator
  // static const String baseUrl =
  //     'https://nazrul-academy-alumni.com/showoff/api';
  // static const String socketUrl = 'https://nazrul-academy-alumni.com';

  static const String baseUrl = 'https://show-off-gamma.vercel.app/api';
  static const String socketUrl = 'https://show-off-gamma.vercel.app';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String forgetPassword = '$baseUrl/auth/forgot-password';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String resetPassword = '$baseUrl/auth/reset-password';

  // User endpoints
  static const String updateProfile = '$baseUrl/users/profile';
  static const String updateFcmToken = '$baseUrl/users/fcm-token';
  static const String discoverUsers = '$baseUrl/users/discover';
  static const String searchUsers = '$baseUrl/users/search';
  static const String deleteAccount = '$baseUrl/users/me';
  static const String acceptPrivacyPolicy =
      '$baseUrl/users/accept-privacy-policy';

  // Chat endpoints
  static const String fetchChats = '$baseUrl/chats';
  static const String createGroup = '$baseUrl/chats/group';
  static const String uploadMedia = '$baseUrl/upload';

  // Show off endpoints
  static const String showOff = '$baseUrl/showoff';
  static const String showOffFeed = '$baseUrl/showoff/feed';
  static const String showOffChoose = '$baseUrl/showoff/choose';
  static String showOffById(String id) => '$baseUrl/showoff/$id';
  static String showOffReportById(String id) => '$baseUrl/showoff/$id/report';

  // Music endpoints
  static const String searchMusic = '$baseUrl/music/search';
}
