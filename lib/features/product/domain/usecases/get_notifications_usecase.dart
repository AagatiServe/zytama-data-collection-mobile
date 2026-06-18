import '../repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<NotificationsPageModel> call({
    int limit = 20,
    String? cursor,
  }) =>
      repository.getNotifications(limit: limit, cursor: cursor);
}
