import 'dart:async';
import 'dart:io';
import '../local/app_database.dart';
import '../network/connectivity_service.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';

class SyncProgress {
  final int current;
  final int total;
  final bool isDone;
  const SyncProgress({
    required this.current,
    required this.total,
    this.isDone = false,
  });
}

class SyncService {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final ProductRemoteDataSource _remoteDataSource;

  StreamSubscription<bool>? _sub;
  bool _cancelled = false;

  final _progressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get syncProgress$ => _progressController.stream;

  SyncService(this._db, this._connectivity, this._remoteDataSource);

  Stream<int> get pendingCount$ => _db.watchPendingCount();

  Future<int> pendingUploadCount() async {
    final pending = await _db.getPendingUploads();
    return pending.length;
  }

  void startListening() {
    _cancelled = false;
    _sub?.cancel();
    _sub = _connectivity.onStatusChange.listen((isOnline) {
      if (isOnline && !_cancelled) _syncAll();
    });

    // Also attempt sync immediately if already online at start
    if (_connectivity.isOnline) _syncAll();
  }

  void stop() {
    _cancelled = true;
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _syncAll() async {
    final pending = await _db.getPendingUploads();
    if (pending.isEmpty) return;

    final total = pending.length;
    _progressController.add(SyncProgress(current: 0, total: total));

    int processed = 0;
    for (final record in pending) {
      if (_cancelled) return; // stop mid-loop on logout
      await _syncRecord(record);
      processed++;
      _progressController.add(SyncProgress(current: processed, total: total));
    }

    _progressController
        .add(SyncProgress(current: total, total: total, isDone: true));
  }

  Future<void> _syncRecord(PendingUpload record) async {
    try {
      if (_cancelled) return;

      // Check if someone else already uploaded this barcode
      final check = await _remoteDataSource.checkBarcode(record.barcode);

      if (check.matched && !check.captureRequired) {
        // Already exists on server — discard local copy
        await _deleteRecord(record);
        return;
      }

      if (_cancelled) return;

      // Safe to upload
      final productFile = File(record.productImagePath);
      final ingredientsFile = File(record.ingredientsImagePath);
      final nutritionFile = File(record.nutritionImagePath);

      // Skip if any image was deleted from device
      if (!productFile.existsSync() ||
          !ingredientsFile.existsSync() ||
          !nutritionFile.existsSync()) {
        await _deleteRecord(record);
        return;
      }

      await _remoteDataSource.uploadProduct(
        barcode: record.barcode,
        productImage: productFile,
        ingredientsImage: ingredientsFile,
        nutritionImage: nutritionFile,
      );

      await _deleteRecord(record);
    } catch (_) {
      // Keep the record; will retry on next connectivity restore
    }
  }

  Future<void> _deleteRecord(PendingUpload record) async {
    // Delete image files from device storage
    _tryDelete(record.productImagePath);
    _tryDelete(record.ingredientsImagePath);
    _tryDelete(record.nutritionImagePath);

    // Remove from DB
    await _db.deletePendingUpload(record.id);
  }

  void _tryDelete(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }

  void dispose() {
    stop();
    _progressController.close();
  }
}
