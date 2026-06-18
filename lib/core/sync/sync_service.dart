import 'dart:async';
import 'dart:io';
import '../local/app_database.dart';
import '../network/connectivity_service.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';

enum SyncStatus { idle, syncing, completed, failed }

class SyncProgress {
  final SyncStatus status;
  final int total;
  final int synced;
  final int failed;

  const SyncProgress({
    this.status = SyncStatus.idle,
    this.total = 0,
    this.synced = 0,
    this.failed = 0,
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

  void startListening() {
    _cancelled = false;
    _sub?.cancel();
    _sub = _connectivity.onStatusChange.listen((isOnline) {
      if (isOnline && !_cancelled) _syncAll();
    });

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
    int synced = 0;
    int failed = 0;

    _progressController.add(SyncProgress(
      status: SyncStatus.syncing,
      total: total,
      synced: 0,
      failed: 0,
    ));

    for (final record in pending) {
      if (_cancelled) return;
      final success = await _syncRecord(record);
      if (success) {
        synced++;
      } else {
        failed++;
      }
      _progressController.add(SyncProgress(
        status: SyncStatus.syncing,
        total: total,
        synced: synced,
        failed: failed,
      ));
    }

    _progressController.add(SyncProgress(
      status: failed == total ? SyncStatus.failed : SyncStatus.completed,
      total: total,
      synced: synced,
      failed: failed,
    ));
  }

  Future<bool> _syncRecord(PendingUpload record) async {
    try {
      if (_cancelled) return false;

      final check = await _remoteDataSource.checkBarcode(record.barcode);

      if (check.found) {
        await _markSyncedAndDelete(record);
        return true;
      }

      if (_cancelled) return false;

      final productFile = File(record.productImagePath);
      final ingredientsFile = File(record.ingredientsImagePath);
      final nutritionFile = File(record.nutritionImagePath);

      if (!productFile.existsSync() ||
          !ingredientsFile.existsSync() ||
          !nutritionFile.existsSync()) {
        await _markSyncedAndDelete(record);
        return true;
      }

      await _remoteDataSource.uploadProduct(
        barcode: record.barcode,
        productImage: productFile,
        ingredientsImage: ingredientsFile,
        nutritionImage: nutritionFile,
      );

      await _markSyncedAndDelete(record);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _markSyncedAndDelete(PendingUpload record) async {
    await _db.markAsSynced(record.id);
    _tryDelete(record.productImagePath);
    _tryDelete(record.ingredientsImagePath);
    _tryDelete(record.nutritionImagePath);
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
