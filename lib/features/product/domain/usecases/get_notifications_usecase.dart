import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, NotificationsPageModel>> call({String? cursor}) =>
      repository.getNotifications(cursor: cursor);
}
