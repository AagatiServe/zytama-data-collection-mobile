class AppStrings {
  AppStrings._();

  static const appTitle = 'Zytama';
  static const appName = 'Zytama Data';

  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const close = 'Close';
  static const retry = 'Retry';
  static const done = 'Done';
  static const replace = 'Replace';
  static const zoom = 'Zoom';
  static const openWebPortal = 'Open Web Portal';

  static const success = 'Success';
  static const error = 'Error';
  static const productExists = 'Product Exists';
  static const alreadyExists = 'Already Exists';
  static const logout = 'Logout';
  static const logoutConfirmation = 'Are you sure you want to sign out?';

  static const backOnlineSyncing = 'Back online. Syncing data...';
  static const noInternetConnection = 'No internet connection.';
  static const offlineScanSaved =
      'No internet - scan saved offline. Will sync automatically when back online.';
  static const firstSyncBeforeLogout = 'First sync offline data before logout.';
  static const logoutAfterSyncCompletes = 'Logout after sync completes.';
  static const stillSyncing = 'still syncing.';
  static const pendingSync = 'pending sync.';

  static const savedOffline = 'Saved Offline';
  static const uploaded = 'Uploaded!';
  static const productSavedOffline =
      'Product saved locally. It will sync automatically when internet is restored.';
  static const productUploaded = 'Product images uploaded successfully.';

  static const syncOfflineData = 'Syncing offline data';
  static const synced = 'Synced';
  static const successfully = 'successfully';
  static const item = 'item';
  static const items = 'items';

  static const helloFallbackName = 'Agent';
  static const dashboardSubtitle = "Let's collect accurate ingredient data.";
  static const summary = 'Today Summary';
  static const searchProductsHint = 'Search products...';
  static const newScan = 'New Scan';
  static const processing = 'Processing...';
  static const pleaseWait = 'Please wait';
  static const scanIngredientLabel = 'Scan ingredient label using camera';
  static const recentScans = 'Recent Scans';
  static const viewAll = 'View All';
  static const productsScanned = 'Products\nScanned';
  static const successfullyCaptured = 'Successfully\nCaptured';
  static const pendingSyncLabel = 'Pending\nSync';
  static const noScansYet = 'No scans yet. Tap New Scan to start.';
  static const checkingProduct = 'Checking product...';
  static const justNow = 'Just now';
  static const captured = 'Captured';
  static const approved = 'Approved';
  static const pending = 'Pending';
  static const rejected = 'Rejected';
  static const failed = 'Failed';
  static const all = 'All';
  static const today = 'Today';
  static const yesterday = 'Yesterday';
  static const barcodeSeparator = '  •  ';
  static const productAlreadyInDatabase =
      'This product is already in the database.';
  static const loginFailed = 'Login failed';
  static const barcodeCheckFailed = 'Barcode check failed';
  static const uploadSuccessful = 'Upload successful';
  static const failedToLoadDashboard = 'Failed to load dashboard';
  static const failedToFetchNotifications = 'Failed to fetch notifications';
  static const monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const scanBarcode = 'Scan Barcode';
  static const toggleFlash = 'Toggle flash';
  static const flipCamera = 'Flip camera';
  static const alignBarcodeWithinFrame = 'Align the barcode within the frame';
  static const cameraPermissionRequired = 'Camera permission required';
  static const allowCameraAccess =
      'Please allow camera access to scan barcodes.';
  static const openSettings = 'Open Settings';
  static const allScans = 'All Scans';
  static const searchByProductNameOrBrand =
      'Search by product name or brand...';
  static const noScansFound = 'No scans found';
  static const scannedSuccessfully = 'Scanned Successfully';
  static const scannedBarcode = 'Scanned Barcode';
  static const reviewProduct = 'Review Product';
  static const submitProduct = 'Submit Product';
  static const capturedImages = 'Captured Images';
  static const productPhoto = 'Product\nPhoto';
  static const ingredientsPhoto = 'Ingredients\nPhoto';
  static const nutritionPhoto = 'Nutrition\nPhoto';
  static const productPhotoPlain = 'Product Photo';
  static const ingredientsPhotoPlain = 'Ingredients Photo';
  static const nutritionPhotoPlain = 'Nutrition Photo';
  static const productPhotoInstruction = 'Photograph the\nfront of the product';
  static const ingredientsPhotoInstruction =
      'Photograph the\ningredients label';
  static const nutritionPhotoInstruction =
      'Photograph the\nnutrition facts label';
  static const openCamera = 'Open Camera';
  static const uploading = 'Uploading...';
  static const pinchToZoom = 'Pinch to zoom';

  static const noNotificationsYet = 'No notifications yet';
  static const allCaughtUp = "You're all caught up!";
  static const markAllRead = 'Mark all read';
  static const notifications = 'Notifications';
  static const am = 'AM';
  static const pm = 'PM';

  static String itemText(int count) => count == 1 ? item : items;

  static String syncProgress(int current, int total) =>
      '$syncOfflineData ($current of $total)';

  static String syncComplete(int total) =>
      '$synced $total ${itemText(total)} $successfully';

  static String hello(String name) => 'Hello, $name';

  static String minutesAgo(int minutes) => '${minutes}m ago';

  static String hoursAgo(int hours) => '${hours}h ago';

  static String daysAgo(int days) => '${days}d ago';

  static String minutesAgoLong(int minutes) => '$minutes min ago';

  static String hoursAgoLong(int hours) => '$hours hr ago';

  static String stepOf(int current, int total, String label) =>
      'Step $current of $total$barcodeSeparator$label';

  static String notificationTimeToday(String time) => '$today, $time';

  static String notificationTimeYesterday(String time) => '$yesterday, $time';

  static String logoutPendingMessage({
    required int pendingCount,
    required bool isOnline,
  }) {
    final suffix = isOnline ? stillSyncing : pendingSync;
    final prefix = isOnline
        ? 'Please wait. $pendingCount offline ${itemText(pendingCount)}'
        : '$firstSyncBeforeLogout $pendingCount offline ${itemText(pendingCount)}';
    return '$prefix $suffix ${isOnline ? logoutAfterSyncCompletes : ''}'.trim();
  }
}
