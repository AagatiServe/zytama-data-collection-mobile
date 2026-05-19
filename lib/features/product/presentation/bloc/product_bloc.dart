import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_barcode_usecase.dart';
import '../../domain/usecases/upload_product_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final CheckBarcodeUseCase checkBarcodeUseCase;
  final UploadProductUseCase uploadProductUseCase;

  String? _barcode;
  File? _productImage;
  File? _ingredientsImage;

  ProductBloc(this.checkBarcodeUseCase, this.uploadProductUseCase)
      : super(ProductInitial()) {
    on<ScanBarcodeRequested>(_onScanBarcodeRequested);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ProductImageCaptured>(_onProductImageCaptured);
    on<IngredientsImageCaptured>(_onIngredientsImageCaptured);
    on<NutritionImageCaptured>(_onNutritionImageCaptured);
    on<SubmitProduct>(_onSubmitProduct);
    on<ResetProduct>(_onResetProduct);
  }

  void _onScanBarcodeRequested(
    ScanBarcodeRequested event,
    Emitter<ProductState> emit,
  ) => emit(ProductScanning());

  Future<void> _onBarcodeScanned(
    BarcodeScanned event,
    Emitter<ProductState> emit,
  ) async {
    _barcode = event.barcode;
    emit(ProductChecking(event.barcode));
    try {
      final result = await checkBarcodeUseCase(event.barcode);
      emit(result.found
          ? ProductExists(event.barcode,
              message: result.message,
              productImageUrl: result.productImageUrl)
          : ProductNotExists(event.barcode));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onProductImageCaptured(
    ProductImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    _productImage = event.image;
    emit(CapturingIngredientsImage(_barcode!, event.image));
  }

  void _onIngredientsImageCaptured(
    IngredientsImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    _ingredientsImage = event.image;
    emit(CapturingNutritionImage(_barcode!, _productImage!, event.image));
  }

  void _onNutritionImageCaptured(
    NutritionImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    emit(ReadyToReview(
      _barcode!,
      _productImage!,
      _ingredientsImage!,
      event.image,
    ));
  }

  Future<void> _onSubmitProduct(
    SubmitProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductUploading());
    try {
      final message = await uploadProductUseCase(
        barcode: _barcode!,
        productImage: event.productImage,
        ingredientsImage: event.ingredientsImage,
        nutritionImage: event.nutritionImage,
      );
      emit(ProductUploadSuccess(message));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetProduct(ResetProduct event, Emitter<ProductState> emit) {
    _barcode = null;
    _productImage = null;
    _ingredientsImage = null;
    emit(ProductInitial());
  }
}
