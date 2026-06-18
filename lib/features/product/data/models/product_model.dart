class ProductCheckModel {
  final bool matched;
  final bool captureRequired;
  final String? productName;
  final String? brandName;

  const ProductCheckModel({
    required this.matched,
    required this.captureRequired,
    this.productName,
    this.brandName,
  });

  factory ProductCheckModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final product = data?['product'] as Map<String, dynamic>?;
    return ProductCheckModel(
      matched: data?['matched'] as bool? ?? false,
      captureRequired: product?['capture_required'] as bool? ?? true,
      productName: product?['product_name'] as String?,
      brandName: product?['brand_name'] as String?,
    );
  }
}

class UploadResponseModel {
  final bool success;
  final String message;
  final String? submissionId;

  const UploadResponseModel({
    required this.success,
    required this.message,
    this.submissionId,
  });
}
