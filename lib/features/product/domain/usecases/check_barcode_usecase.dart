import '../repositories/product_repository.dart';

class CheckBarcodeUseCase {
  final ProductRepository repository;
  CheckBarcodeUseCase(this.repository);

  Future<bool> call(String barcode) => repository.checkBarcodeExists(barcode);
}
