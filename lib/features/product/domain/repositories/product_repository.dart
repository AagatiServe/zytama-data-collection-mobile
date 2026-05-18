import 'dart:io';

abstract class ProductRepository {
  Future<bool> checkBarcodeExists(String barcode);
  Future<String> uploadProduct({
    required String barcode,
    required File productImage,
    required File barcodeImage,
    required File ingredientsImage,
  });
}
