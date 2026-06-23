import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ProductRepository {
  Future<Either<Failure, ({bool found, String? message, String? productImageUrl})>>
      checkBarcodeExists(String barcode);
  Future<Either<Failure, String>> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  });
}
