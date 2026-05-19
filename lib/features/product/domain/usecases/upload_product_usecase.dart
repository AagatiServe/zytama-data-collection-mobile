import 'dart:io';
import '../repositories/product_repository.dart';

class UploadProductUseCase {
  final ProductRepository repository;
  UploadProductUseCase(this.repository);

  Future<String> call({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  }) =>
      repository.uploadProduct(
        barcode: barcode,
        productImage: productImage,
        ingredientsImage: ingredientsImage,
        nutritionImage: nutritionImage,
      );
}
