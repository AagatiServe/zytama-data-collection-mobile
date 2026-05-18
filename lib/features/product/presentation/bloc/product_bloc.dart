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
  File? _barcodeImage;

  ProductBloc(this.checkBarcodeUseCase, this.uploadProductUseCase)
      : super(ProductInitial()) {
    on<ScanBarcodeRequested>(_onScanBarcodeRequested);
    on<BarcodeScanned>(_onBarcodeScanned);
    on<ProductImageCaptured>(_onProductImageCaptured);
    on<BarcodeImageCaptured>(_onBarcodeImageCaptured);
    on<IngredientsImageCaptured>(_onIngredientsImageCaptured);
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
      final exists = await checkBarcodeUseCase(event.barcode);
      emit(exists ? ProductExists(event.barcode) : ProductNotExists(event.barcode));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onProductImageCaptured(
    ProductImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    _productImage = event.image;
    emit(CapturingBarcodeImage(_barcode!, event.image));
  }

  void _onBarcodeImageCaptured(
    BarcodeImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    _barcodeImage = event.image;
    emit(CapturingIngredientsImage(_barcode!, _productImage!, event.image));
  }

  void _onIngredientsImageCaptured(
    IngredientsImageCaptured event,
    Emitter<ProductState> emit,
  ) {
    emit(ReadyToReview(
      _barcode!,
      _productImage!,
      _barcodeImage!,
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
        barcodeImage: event.barcodeImage,
        ingredientsImage: event.ingredientsImage,
      );
      emit(ProductUploadSuccess(message));
    } catch (e) {
      emit(ProductError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetProduct(ResetProduct event, Emitter<ProductState> emit) {
    _barcode = null;
    _productImage = null;
    _barcodeImage = null;
    emit(ProductInitial());
  }
}
