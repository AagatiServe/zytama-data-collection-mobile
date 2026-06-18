import '../repositories/product_repository.dart';

class CheckBarcodeUseCase {
  final ProductRepository repository;
  CheckBarcodeUseCase(this.repository);

  Future<({bool matched, bool captureRequired, String? productName, String? brandName})> call(String barcode) =>
      repository.checkBarcodeExists(barcode);
}
