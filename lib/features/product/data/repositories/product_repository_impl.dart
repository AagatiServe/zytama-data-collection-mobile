import 'dart:io';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> checkBarcodeExists(String barcode) async {
    final result = await remoteDataSource.checkBarcode(barcode);
    return result.exists;
  }

  @override
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File barcodeImage,
    required File ingredientsImage,
  }) async {
    final result = await remoteDataSource.uploadProduct(
      barcode: barcode,
      productImage: productImage,
      barcodeImage: barcodeImage,
      ingredientsImage: ingredientsImage,
    );
    return result.message;
  }
}
