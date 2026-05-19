import 'dart:io';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<({bool found, String? message, String? productImageUrl})> checkBarcodeExists(String barcode) async {
    final result = await remoteDataSource.checkBarcode(barcode);
    return (found: result.found, message: result.message, productImageUrl: result.productImageUrl);
  }

  @override
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  }) async {
    final result = await remoteDataSource.uploadProduct(
      barcode: barcode,
      productImage: productImage,
      ingredientsImage: ingredientsImage,
      nutritionImage: nutritionImage,
    );
    return result.message;
  }
}
