class DashboardItemModel {
  final String submissionId;
  final String gtin;
  final String? frontUrl;
  final String? productName;
  final String? brandName;
  final String? category;
  final String status;
  final DateTime captureTime;

  const DashboardItemModel({
    required this.submissionId,
    required this.gtin,
    this.frontUrl,
    this.productName,
    this.brandName,
    this.category,
    required this.status,
    required this.captureTime,
  });

  factory DashboardItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardItemModel(
      submissionId: (json['submission_id'] as String?) ?? '',
      gtin: (json['gtin'] as String?) ?? '',
      frontUrl: json['front_url'] as String?,
      productName: json['product_name'] as String?,
      brandName: json['brand_name'] as String?,
      category: json['category'] as String?,
      status: (json['status'] as String?) ?? 'failed',
      captureTime: json['capture_time'] != null
          ? DateTime.parse(json['capture_time'] as String)
          : DateTime.now(),
    );
  }
}

class DashboardPageModel {
  final int totalProducts;
  final int successfulCaptures;
  final int reviewPending;
  final List<DashboardItemModel> items;
  final String? nextCursor;

  const DashboardPageModel({
    required this.totalProducts,
    required this.successfulCaptures,
    required this.reviewPending,
    required this.items,
    this.nextCursor,
  });

  factory DashboardPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return DashboardPageModel(
      totalProducts: (data['total_products'] as num?)?.toInt() ?? 0,
      successfulCaptures: (data['successful_captures'] as num?)?.toInt() ?? 0,
      reviewPending: (data['review_pending'] as num?)?.toInt() ?? 0,
      items: rawItems
          .map((e) => DashboardItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: data['next_cursor'] as String?,
    );
  }
}
