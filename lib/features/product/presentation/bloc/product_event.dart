part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ScanBarcodeRequested extends ProductEvent {
  const ScanBarcodeRequested();
}

class BarcodeScanned extends ProductEvent {
  final String barcode;
  const BarcodeScanned(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ProductImageCaptured extends ProductEvent {
  final File image;
  const ProductImageCaptured(this.image);

  @override
  List<Object?> get props => [image];
}

class IngredientsImageCaptured extends ProductEvent {
  final File image;
  const IngredientsImageCaptured(this.image);

  @override
  List<Object?> get props => [image];
}

class NutritionImageCaptured extends ProductEvent {
  final File image;
  const NutritionImageCaptured(this.image);

  @override
  List<Object?> get props => [image];
}

class SubmitProduct extends ProductEvent {
  final File productImage;
  final File ingredientsImage;
  final File nutritionImage;
  const SubmitProduct({
    required this.productImage,
    required this.ingredientsImage,
    required this.nutritionImage,
  });

  @override
  List<Object?> get props => [productImage, ingredientsImage, nutritionImage];
}

class AllImagesCaptured extends ProductEvent {
  final File productImage;
  final File ingredientsImage;
  final File nutritionImage;
  const AllImagesCaptured({
    required this.productImage,
    required this.ingredientsImage,
    required this.nutritionImage,
  });

  @override
  List<Object?> get props => [productImage, ingredientsImage, nutritionImage];
}

class ResetProduct extends ProductEvent {
  const ResetProduct();
}
