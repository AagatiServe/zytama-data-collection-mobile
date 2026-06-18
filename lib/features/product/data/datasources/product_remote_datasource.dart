import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
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
  // Plain Dio — no auth interceptor; presigned S3 URLs carry auth in query params
  final Dio _s3Dio = Dio();

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
      String? msg;
      if (body is Map) {
        msg = (body['error'] as Map?)?['message'] as String?;
      }
      throw Exception(msg ?? e.message ?? AppStrings.barcodeCheckFailed);
    }
  }

  @override
  Future<UploadResponseModel> uploadProduct({
    required String barcode,
    required File productImage,
    required File ingredientsImage,
    required File nutritionImage,
  }) async {
    // Build file entries with stable client IDs for this request
    final files = [
      _FileEntry('front_label', productImage),
      _FileEntry('ingredients_label', ingredientsImage),
      _FileEntry('nutrition_table', nutritionImage),
    ];

    // ── Step 1: Presign ────────────────────────────────────────────────────
    final presignResponse = await apiClient.post(
      ApiConstants.presignEndpoint,
      data: {
        'gtin': barcode,
        'files': files
            .map((f) => {
                  'client_file_id': f.clientId,
                  'file_type': f.fileType,
                  'mime_type': 'image/jpeg',
                  'size_bytes': f.file.lengthSync(),
                })
            .toList(),
      },
    );

    final presignData = (presignResponse.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    final uploadBatchId = presignData['upload_batch_id'] as String;
    final presignedFiles =
        (presignData['files'] as List).cast<Map<String, dynamic>>();

    // Map client_file_id → server response entry
    final fileMap = <String, Map<String, dynamic>>{
      for (final pf in presignedFiles) pf['client_file_id'] as String: pf,
    };

    // ── Step 2: Upload to S3 (parallel) ───────────────────────────────────
    await Future.wait(files.map((f) async {
      final pf = fileMap[f.clientId]!;
      final presignedUrl = pf['presigned_url'] as String;
      final bytes = await f.file.readAsBytes();
      await _s3Dio.put(
        presignedUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          contentType: 'image/jpeg',
          headers: {'Content-Length': bytes.length},
        ),
      );
    }));

    // ── Step 3: Submit ─────────────────────────────────────────────────────
    final uploadFileIds = files
        .map((f) => fileMap[f.clientId]!['upload_file_id'] as String)
        .toList();

    final submitResponse = await apiClient.post(
      ApiConstants.submitEndpoint,
      data: {
        'upload_batch_id': uploadBatchId,
        'upload_file_ids': uploadFileIds,
      },
      options: Options(headers: {'Idempotency-Key': _uuid()}),
    );

    final submitData = (submitResponse.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>;

    return UploadResponseModel(
      success: true,
      message: AppStrings.uploadSuccessful,
      submissionId: submitData['submission_id'] as String?,
    );
  }

  String _uuid() {
    final rng = math.Random.secure();
    final b = List.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
        '-${h.substring(16, 20)}-${h.substring(20)}';
  }
}

class _FileEntry {
  final String fileType;
  final File file;
  final String clientId;

  _FileEntry(this.fileType, this.file) : clientId = _genId();

  static String _genId() {
    final rng = math.Random.secure();
    return List.generate(16, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
