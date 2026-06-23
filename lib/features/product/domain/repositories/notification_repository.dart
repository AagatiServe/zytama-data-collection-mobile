import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationsPageModel>> getNotifications({String? cursor});
}
