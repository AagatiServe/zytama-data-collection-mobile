import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_barcode_usecase.dart';
import '../../domain/usecases/upload_product_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final CheckBarcodeUseCase checkBarcodeUseCase;
  final UploadProductUseCase uploadProductUseCase;

  ProductBloc(this.checkBarcodeUseCase, this.uploadProductUseCase)
      : super(const ProductInitial()) {
    on<ScanBarcodeRequested>(_onScanBarcodeRequested);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ProductImageCaptured>(_onProductImageCaptured);
    on<IngredientsImageCaptured>(_onIngredientsImageCaptured);
    on<NutritionImageCaptured>(_onNutritionImageCaptured);
    on<AllImagesCaptured>(_onAllImagesCaptured);
    on<SubmitProduct>(_onSubmitProduct);
    on<ResetProduct>(_onResetProduct);
  }

  void _onScanBarcodeRequested(
    ScanBarcodeRequested event,
    Emitter<ProductState> emit,
  ) => emit(const ProductScanning());

  Future<void> _onBarcodeScanned(
    BarcodeScanned event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductChecking(event.barcode));
    final result = await checkBarcodeUseCase(event.barcode);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (data) => emit(data.found
          ? ProductExists(event.barcode,
              message: data.message,
              productImageUrl: data.productImageUrl)
          : ProductNotExists(event.barcode)),
    );
  }

  void _onProductImageCaptured(
    ProductImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    final current = state;
    if (current is ProductNotExists) {
      emit(CapturingIngredientsImage(current.barcode, event.image));
    }
  }

  void _onIngredientsImageCaptured(
    IngredientsImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    final current = state;
    if (current is CapturingIngredientsImage) {
      emit(CapturingNutritionImage(
          current.barcode, current.productImage, event.image));
    }
  }

  void _onNutritionImageCaptured(
    NutritionImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    final current = state;
    if (current is CapturingNutritionImage) {
      emit(ReadyToReview(
        current.barcode,
        current.productImage,
        current.ingredientsImage,
        event.image,
      ));
    }
  }

  void _onAllImagesCaptured(
    AllImagesCaptured event,
    Emitter<ProductState> emit,
  ) {
    final barcode = _barcodeFromState();
    if (barcode != null) {
      emit(ReadyToReview(
        barcode,
        event.productImage,
        event.ingredientsImage,
        event.nutritionImage,
      ));
    }
  }

  Future<void> _onSubmitProduct(
    SubmitProduct event,
    Emitter<ProductState> emit,
  ) async {
    final barcode = _barcodeFromState();
    if (barcode == null) return;

    emit(const ProductUploading());
    final result = await uploadProductUseCase(
      barcode: barcode,
      productImage: event.productImage,
      ingredientsImage: event.ingredientsImage,
      nutritionImage: event.nutritionImage,
    );
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (message) => emit(message == '__offline__'
          ? const ProductUploadSavedOffline()
          : ProductUploadSuccess(message)),
    );
  }

  void _onResetProduct(ResetProduct event, Emitter<ProductState> emit) {
    emit(const ProductInitial());
  }

  String? _barcodeFromState() {
    final s = state;
    if (s is ProductNotExists) return s.barcode;
    if (s is CapturingIngredientsImage) return s.barcode;
    if (s is CapturingNutritionImage) return s.barcode;
    if (s is ReadyToReview) return s.barcode;
    if (s is ProductChecking) return s.barcode;
    if (s is ProductExists) return s.barcode;
    return null;
  }
}
