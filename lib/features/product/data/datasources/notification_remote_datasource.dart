import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationsPageModel> getNotifications({
    int limit,
    String? cursor,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<NotificationsPageModel> getNotifications({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await apiClient.get(
        ApiConstants.notificationsEndpoint,
        queryParams: queryParams,
      );
      final body = response.data as Map<String, dynamic>;
      return NotificationsPageModel.fromJson(body);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          AppStrings.failedToFetchNotifications;
      throw Exception(msg);
    }
  }
}
