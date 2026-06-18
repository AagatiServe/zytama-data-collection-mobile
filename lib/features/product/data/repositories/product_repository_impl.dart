import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../../../../core/local/app_database.dart';
import '../../../../core/network/connectivity_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final AppDatabase db;
  final ConnectivityService connectivity;

  ProductRepositoryImpl(this.remoteDataSource, this.db, this.connectivity);

  @override
  Future<({bool matched, bool captureRequired, String? productName, String? brandName})>
      checkBarcodeExists(String barcode) async {
    if (connectivity.isOnline) {
      final result = await remoteDataSource.checkBarcode(barcode);
      return (
        matched: result.matched,
        captureRequired: result.captureRequired,
        productName: result.productName,
        brandName: result.brandName,
      );
    } else {
      // Offline — check local cache
      final cached = await db.getCachedProduct(barcode);
      if (cached != null) {
        // found=true in cache means product existed → no need to capture
        return (
          matched: cached.found,
          captureRequired: !cached.found,
          productName: null,
          brandName: null,
        );
      }
      return (matched: false, captureRequired: true, productName: null, brandName: null);
    }
  }

  @override
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  }) async {
    if (connectivity.isOnline) {
      final result = await remoteDataSource.uploadProduct(
        barcode: barcode,
        productImage: productImage,
        ingredientsImage: ingredientsImage,
        nutritionImage: nutritionImage,
      );
      return result.message;
    } else {
      // Save images to permanent app storage so they survive app restarts
      final dir = await getApplicationDocumentsDirectory();
      final offlineDir =
          Directory(p.join(dir.path, 'offline_uploads', barcode));
      await offlineDir.create(recursive: true);

      final savedProduct =
          await productImage.copy(p.join(offlineDir.path, 'product.jpg'));
      final savedIngredients = await ingredientsImage
          .copy(p.join(offlineDir.path, 'ingredients.jpg'));
      final savedNutrition =
          await nutritionImage.copy(p.join(offlineDir.path, 'nutrition.jpg'));

      await db.insertPendingUpload(PendingUploadsCompanion(
        barcode: Value(barcode),
        productImagePath: Value(savedProduct.path),
        ingredientsImagePath: Value(savedIngredients.path),
        nutritionImagePath: Value(savedNutrition.path),
        createdAt: Value(DateTime.now()),
      ));

      return '__offline__';
    }
  }
}
