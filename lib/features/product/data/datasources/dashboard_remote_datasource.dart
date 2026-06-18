import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardPageModel> getDashboard({
    int limit,
    String? cursor,
    String? search,
    String? status,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;
  DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DashboardPageModel> getDashboard({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.dashboardEndpoint,
      );
      final page =
          DashboardPageModel.fromJson(response.data as Map<String, dynamic>);
      return _filterPage(page, search: search, status: status);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          AppStrings.failedToLoadDashboard;
      throw Exception(msg);
    }
  }

  DashboardPageModel _filterPage(
    DashboardPageModel page, {
    String? search,
    String? status,
  }) {
    final normalizedSearch = search?.trim().toLowerCase();
    final normalizedStatus = status?.trim();
    final filteredItems = page.items.where((item) {
      final matchesStatus = normalizedStatus == null ||
          normalizedStatus.isEmpty ||
          normalizedStatus == 'all' ||
          item.status == normalizedStatus;
      final matchesSearch = normalizedSearch == null ||
          normalizedSearch.isEmpty ||
          item.gtin.toLowerCase().contains(normalizedSearch) ||
          (item.productName?.toLowerCase().contains(normalizedSearch) ??
              false) ||
          (item.brandName?.toLowerCase().contains(normalizedSearch) ?? false);
      return matchesStatus && matchesSearch;
    }).toList();

    return DashboardPageModel(
      totalProducts: page.totalProducts,
      successfulCaptures: page.successfulCaptures,
      reviewPending: page.reviewPending,
      items: filteredItems,
      nextCursor: null,
    );
  }
}
