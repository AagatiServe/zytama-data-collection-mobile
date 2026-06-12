import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
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
      final body = <String, dynamic>{'limit': limit};
      if (cursor != null) body['cursor'] = cursor;
      if (search != null && search.isNotEmpty) body['search'] = search;
      if (status != null && status != 'all') body['status'] = status;

      final response = await _apiClient.post(
        ApiConstants.dashboardEndpoint,
        data: body,
      );
      return DashboardPageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          'Failed to load dashboard';
      throw Exception(msg);
    }
  }
}
