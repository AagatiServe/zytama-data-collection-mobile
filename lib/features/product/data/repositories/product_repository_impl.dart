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
  Future<({bool found, String? message, String? productImageUrl})>
      checkBarcodeExists(String barcode) async {
    if (connectivity.isOnline) {
      final result = await remoteDataSource.checkBarcode(barcode);
      return (
        found: result.found,
        message: result.message,
        productImageUrl: result.productImageUrl
      );
    } else {
      // Offline — check local cache
      final cached = await db.getCachedProduct(barcode);
      if (cached != null) {
        return (
          found: cached.found,
          message: cached.found ? 'Product found in local cache.' : null,
          productImageUrl: cached.productImageUrl
        );
      }
      return (found: false, message: null, productImageUrl: null);
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
