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
  final String? message;
  final String? productImageUrl;
  ProductExists(this.barcode, {this.message, this.productImageUrl});
}

class ProductNotExists extends ProductState {
  final String barcode;
  ProductNotExists(this.barcode);
}

class CapturingIngredientsImage extends ProductState {
  final String barcode;
  final File productImage;
  CapturingIngredientsImage(this.barcode, this.productImage);
}

class CapturingNutritionImage extends ProductState {
  final String barcode;
  final File productImage;
  final File ingredientsImage;
  CapturingNutritionImage(this.barcode, this.productImage, this.ingredientsImage);
}

class ReadyToReview extends ProductState {
  final String barcode;
  final File productImage;
  final File ingredientsImage;
  final File nutritionImage;
  ReadyToReview(
    this.barcode,
    this.productImage,
    this.ingredientsImage,
    this.nutritionImage,
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
