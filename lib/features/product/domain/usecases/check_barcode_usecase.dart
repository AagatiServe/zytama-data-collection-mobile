import '../repositories/product_repository.dart';

class CheckBarcodeUseCase {
  final ProductRepository repository;
  CheckBarcodeUseCase(this.repository);

  Future<({bool found, String? message, String? productImageUrl})> call(String barcode) =>
      repository.checkBarcodeExists(barcode);
}
