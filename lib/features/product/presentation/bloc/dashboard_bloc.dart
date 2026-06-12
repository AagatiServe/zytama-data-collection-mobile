import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/data/models/dashboard_model.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUseCase _useCase;

  String? _nextCursor;
  final List<DashboardItemModel> _items = [];

  DashboardBloc(this._useCase) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardLoadMoreRequested>(_onLoadMore);
    on<DashboardRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    _nextCursor = null;
    _items.clear();
    emit(DashboardLoading());
    try {
      final page = await _useCase(
        search: event.search,
        status: event.statusFilter,
      );
      _items.addAll(page.items);
      _nextCursor = page.nextCursor;
      emit(DashboardLoaded(
        totalProducts: page.totalProducts,
        successfulCaptures: page.successfulCaptures,
        reviewPending: page.reviewPending,
        items: List.unmodifiable(_items),
        nextCursor: _nextCursor,
        currentSearch: event.search,
        currentStatusFilter: event.statusFilter,
      ));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    DashboardLoadMoreRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (_nextCursor == null) return;
    final current = state;
    if (current is! DashboardLoaded) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _useCase(
        cursor: _nextCursor,
        search: current.currentSearch,
        status: current.currentStatusFilter,
      );
      _items.addAll(page.items);
      _nextCursor = page.nextCursor;
      emit(current.copyWith(
        items: List.unmodifiable(_items),
        nextCursor: _nextCursor,
        clearCursor: _nextCursor == null,
        isLoadingMore: false,
        totalProducts: page.totalProducts,
        successfulCaptures: page.successfulCaptures,
        reviewPending: page.reviewPending,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(DashboardLoadRequested(
      search: event.search,
      statusFilter: event.statusFilter,
    ));
  }
}
