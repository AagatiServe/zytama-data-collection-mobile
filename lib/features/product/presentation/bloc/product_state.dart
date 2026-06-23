part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductScanning extends ProductState {
  const ProductScanning();
}

class ProductChecking extends ProductState {
  final String barcode;
  const ProductChecking(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ProductExists extends ProductState {
  final String barcode;
  final String? message;
  final String? productImageUrl;
  const ProductExists(this.barcode, {this.message, this.productImageUrl});

  @override
  List<Object?> get props => [barcode, message, productImageUrl];
}

class ProductNotExists extends ProductState {
  final String barcode;
  const ProductNotExists(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class CapturingIngredientsImage extends ProductState {
  final String barcode;
  final File productImage;
  const CapturingIngredientsImage(this.barcode, this.productImage);

  @override
  List<Object?> get props => [barcode, productImage];
}

class CapturingNutritionImage extends ProductState {
  final String barcode;
  final File productImage;
  final File ingredientsImage;
  const CapturingNutritionImage(this.barcode, this.productImage, this.ingredientsImage);

  @override
  List<Object?> get props => [barcode, productImage, ingredientsImage];
}

class ReadyToReview extends ProductState {
  final String barcode;
  final File productImage;
  final File ingredientsImage;
  final File nutritionImage;
  const ReadyToReview(
    this.barcode,
    this.productImage,
    this.ingredientsImage,
    this.nutritionImage,
  );

  @override
  List<Object?> get props => [barcode, productImage, ingredientsImage, nutritionImage];
}

class ProductUploading extends ProductState {
  const ProductUploading();
}

class ProductUploadSuccess extends ProductState {
  final String message;
  const ProductUploadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductUploadSavedOffline extends ProductState {
  const ProductUploadSavedOffline();
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
