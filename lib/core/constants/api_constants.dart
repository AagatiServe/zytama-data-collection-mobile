class ApiConstants {
  static const String baseUrl =
      'https://distinguished-robby-aagati-15819a4f.koyeb.app/api/v1/';
  static const String loginEndpoint = 'agents/login';
  static String checkBarcodeEndpoint(String barcode) =>
      'products/lookup?gtin=$barcode';
  static const String uploadProductEndpoint = 'products/upload-file';
  static const String dashboardEndpoint = 'agents/dashboard';
  static const String notificationsEndpoint = 'notifications';
  static const int connectTimeoutMs = 120;
  static const int receiveTimeoutMs = 120;
}
