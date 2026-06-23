import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationsPageModel> getNotifications({String? cursor});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<NotificationsPageModel> getNotifications({String? cursor}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await apiClient.get(
        ApiConstants.notificationsEndpoint,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      final body = response.data as Map<String, dynamic>;
      return NotificationsPageModel.fromJson(body);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map ? body['message'] : null) ??
          e.message ??
          'Failed to fetch notifications';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(msg);
      }
      throw ServerException(msg, statusCode: e.response?.statusCode);
    }
  }
}
