import 'dart:io';

abstract class ProductRepository {
  Future<({bool found, String? message, String? productImageUrl})> checkBarcodeExists(String barcode);
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  });
}
