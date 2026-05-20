import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  String? _nextCursor;
  final List<NotificationItemModel> _items = [];

  NotificationBloc(this.getNotificationsUseCase)
      : super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    _nextCursor = null;
    _items.clear();
    emit(const NotificationLoading());
    try {
      final page = await getNotificationsUseCase(cursor: null);
      _items.addAll(page.items);
      _nextCursor = page.nextCursor;
      emit(NotificationLoaded(
        items: List.unmodifiable(_items),
        nextCursor: _nextCursor,
        unreadCount: page.unreadCount,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(NotificationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    NotificationLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (_nextCursor == null) return;
    final current = state;
    if (current is! NotificationLoaded) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await getNotificationsUseCase(cursor: _nextCursor);
      _items.addAll(page.items);
      _nextCursor = page.nextCursor;
      emit(NotificationLoaded(
        items: List.unmodifiable(_items),
        nextCursor: _nextCursor,
        unreadCount: page.unreadCount,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Keep existing items, surface error via a transient flag
      emit(current.copyWith(isLoadingMore: false, loadMoreError: e.toString()));
    }
  }
}
