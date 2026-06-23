import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_repository.dart';

class CheckBarcodeUseCase {
  final ProductRepository repository;
  CheckBarcodeUseCase(this.repository);

  Future<Either<Failure, ({bool found, String? message, String? productImageUrl})>>
      call(String barcode) => repository.checkBarcodeExists(barcode);
}
