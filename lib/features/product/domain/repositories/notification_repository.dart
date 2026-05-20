import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<NotificationsPageModel> getNotifications({String? cursor});
}
