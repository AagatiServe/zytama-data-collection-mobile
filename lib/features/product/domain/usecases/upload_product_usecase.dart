import 'dart:io';
import '../repositories/product_repository.dart';

class UploadProductUseCase {
  final ProductRepository repository;
  UploadProductUseCase(this.repository);

  Future<String> call({
    required String barcode,
    required File productImage,
    required File barcodeImage,
    required File ingredientsImage,
  }) =>
      repository.uploadProduct(
        barcode: barcode,
        productImage: productImage,
        barcodeImage: barcodeImage,
        ingredientsImage: ingredientsImage,
      );
}
