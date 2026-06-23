import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductCheckModel> checkBarcode(String barcode);
  Future<UploadResponseModel> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;
  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProductCheckModel> checkBarcode(String barcode) async {
    try {
      final response = await apiClient.get(
        ApiConstants.checkBarcodeEndpoint(barcode),
      );
      final body = response.data as Map<String, dynamic>;
      return ProductCheckModel.fromJson(body);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          'Barcode check failed';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(msg);
      }
      throw ServerException(msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UploadResponseModel> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'gtin': barcode,
        'front_image': await MultipartFile.fromFile(
          productImage.path,
          filename: 'front_image.jpg',
        ),
        'ingredients_image': await MultipartFile.fromFile(
          ingredientsImage.path,
          filename: 'ingredients_image.jpg',
        ),
        'nutrition_image': await MultipartFile.fromFile(
          nutritionImage.path,
          filename: 'nutrition_image.jpg',
        ),
      });

      final response = await apiClient.postMultipart(
        ApiConstants.uploadProductEndpoint,
        formData,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Upload failed');
      }
      return UploadResponseModel.fromJson(body);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          'Upload failed';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(msg);
      }
      throw ServerException(msg, statusCode: e.response?.statusCode);
    }
  }
}
