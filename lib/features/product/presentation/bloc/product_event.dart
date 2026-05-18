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

class BarcodeImageCaptured extends ProductEvent {
  final File image;
  BarcodeImageCaptured(this.image);
}

class IngredientsImageCaptured extends ProductEvent {
  final File image;
  IngredientsImageCaptured(this.image);
}

class SubmitProduct extends ProductEvent {
  final File productImage;
  final File barcodeImage;
  final File ingredientsImage;
  SubmitProduct({
    required this.productImage,
    required this.barcodeImage,
    required this.ingredientsImage,
  });
}

class ResetProduct extends ProductEvent {}
