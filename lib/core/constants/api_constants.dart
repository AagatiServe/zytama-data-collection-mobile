class ApiConstants {
  static const String baseUrl =
      'https://distinguished-robby-aagati-15819a4f.koyeb.app/api/v2/';
  static const String loginEndpoint = 'auth/login';
  static String checkBarcodeEndpoint(String barcode) =>
      'products/by-gtin/$barcode';
  static const String presignEndpoint = 'captures/presign';
  static const String submitEndpoint = 'captures/submit';
  static const String dashboardEndpoint = 'dashboard';
  static const String notificationsEndpoint = 'notifications';
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
