class ProductCheckModel {
  final bool found;
  final String? message;
  final String? productImageUrl;

  const ProductCheckModel({
    required this.found,
    this.message,
    this.productImageUrl,
  });

  factory ProductCheckModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final product = data?['product'] as Map<String, dynamic>?;
    return ProductCheckModel(
      found: data?['found'] as bool? ?? false,
      message: json['message'] as String?,
      productImageUrl: product?['product_image'] as String?,
    );
  }
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
