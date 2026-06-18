import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource dataSource;
  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<NotificationsPageModel> getNotifications({
    int limit = 20,
    String? cursor,
  }) =>
      dataSource.getNotifications(limit: limit, cursor: cursor);
}
