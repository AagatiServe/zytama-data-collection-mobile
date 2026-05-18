class ProductCheckModel {
  final bool exists;
  final String? message;

  const ProductCheckModel({required this.exists, this.message});

  factory ProductCheckModel.fromJson(Map<String, dynamic> json) =>
      ProductCheckModel(
        exists: json['exists'] as bool,
        message: json['message'] as String?,
      );
}

class UploadResponseModel {
  final bool success;
  final String message;
  final String? productId;

  const UploadResponseModel({
    required this.success,
    required this.message,
    this.productId,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) =>
      UploadResponseModel(
        success: json['success'] as bool,
        message: json['message'] as String,
        productId: json['product_id'] as String?,
      );
}
