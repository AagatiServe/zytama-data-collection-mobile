part of 'product_bloc.dart';

abstract class ProductEvent {}

class ScanBarcodeRequested extends ProductEvent {}

class BarcodeScanned extends ProductEvent {
  final String barcode;
  BarcodeScanned(this.barcode);
}

class ProductImageCaptured extends ProductEvent {
  final File image;
  ProductImageCaptured(this.image);
}

class IngredientsImageCaptured extends ProductEvent {
  final File image;
  IngredientsImageCaptured(this.image);
}

class NutritionImageCaptured extends ProductEvent {
  final File image;
  NutritionImageCaptured(this.image);
}

class SubmitProduct extends ProductEvent {
  final File productImage;
  final File ingredientsImage;
  final File nutritionImage;
  SubmitProduct({
    required this.productImage,
    required this.ingredientsImage,
    required this.nutritionImage,
  });
}

class ResetProduct extends ProductEvent {}
