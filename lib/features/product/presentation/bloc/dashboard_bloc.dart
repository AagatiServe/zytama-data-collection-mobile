import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/data/models/dashboard_model.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUseCase _useCase;

  DashboardBloc(this._useCase) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardLoadMoreRequested>(_onLoadMore);
    on<DashboardRefreshRequested>(_onRefresh);
    on<DashboardLocalIncrementRequested>(_onLocalIncrement);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _useCase(
      search: event.search,
      status: event.statusFilter,
    );
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (page) => emit(DashboardLoaded(
        totalProducts: page.totalProducts,
        successfulCaptures: page.successfulCaptures,
        reviewPending: page.reviewPending,
        items: List.unmodifiable(page.items),
        nextCursor: page.nextCursor,
        currentSearch: event.search,
        currentStatusFilter: event.statusFilter,
      )),
    );
  }

  Future<void> _onLoadMore(
    DashboardLoadMoreRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final current = state;
    if (current is! DashboardLoaded || current.nextCursor == null) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _useCase(
      cursor: current.nextCursor,
      search: current.currentSearch,
      status: current.currentStatusFilter,
    );
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(current.copyWith(
        items: List.unmodifiable([...current.items, ...page.items]),
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isLoadingMore: false,
        totalProducts: page.totalProducts,
        successfulCaptures: page.successfulCaptures,
        reviewPending: page.reviewPending,
      )),
    );
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

  void _onLocalIncrement(
    DashboardLocalIncrementRequested event,
    Emitter<DashboardState> emit,
  ) {
    final current = state;
    if (current is DashboardLoaded) {
      emit(current.copyWith(
        totalProducts: current.totalProducts + 1,
        successfulCaptures: current.successfulCaptures + 1,
      ));
    }
  }
}
