part of 'product_bloc.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductScanning extends ProductState {}

class ProductChecking extends ProductState {
  final String barcode;
  ProductChecking(this.barcode);
}

class ProductExists extends ProductState {
  final String barcode;
  ProductExists(this.barcode);
}

class ProductNotExists extends ProductState {
  final String barcode;
  ProductNotExists(this.barcode);
}

class CapturingBarcodeImage extends ProductState {
  final String barcode;
  final File productImage;
  CapturingBarcodeImage(this.barcode, this.productImage);
}

class CapturingIngredientsImage extends ProductState {
  final String barcode;
  final File productImage;
  final File barcodeImage;
  CapturingIngredientsImage(this.barcode, this.productImage, this.barcodeImage);
}

class ReadyToReview extends ProductState {
  final String barcode;
  final File productImage;
  final File barcodeImage;
  final File ingredientsImage;
  ReadyToReview(
    this.barcode,
    this.productImage,
    this.barcodeImage,
    this.ingredientsImage,
  );
}

class ProductUploading extends ProductState {}

class ProductUploadSuccess extends ProductState {
  final String message;
  ProductUploadSuccess(this.message);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
