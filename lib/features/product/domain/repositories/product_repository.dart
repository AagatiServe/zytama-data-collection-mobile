import 'dart:io';

abstract class ProductRepository {
  Future<({bool matched, bool captureRequired, String? productName, String? brandName})> checkBarcodeExists(String barcode);
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  });
}
