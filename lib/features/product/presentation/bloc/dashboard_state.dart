part of 'dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalProducts;
  final int successfulCaptures;
  final int reviewPending;
  final List<DashboardItemModel> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final String? currentSearch;
  final String? currentStatusFilter;

  DashboardLoaded({
    required this.totalProducts,
    required this.successfulCaptures,
    required this.reviewPending,
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
    this.currentSearch,
    this.currentStatusFilter,
  });

  bool get hasMore => nextCursor != null;

  DashboardLoaded copyWith({
    int? totalProducts,
    int? successfulCaptures,
    int? reviewPending,
    List<DashboardItemModel>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    String? currentSearch,
    String? currentStatusFilter,
  }) {
    return DashboardLoaded(
      totalProducts: totalProducts ?? this.totalProducts,
      successfulCaptures: successfulCaptures ?? this.successfulCaptures,
      reviewPending: reviewPending ?? this.reviewPending,
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentSearch: currentSearch ?? this.currentSearch,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
