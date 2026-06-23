part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int totalProducts;
  final int successfulCaptures;
  final int reviewPending;
  final List<DashboardItemModel> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final String? currentSearch;
  final String? currentStatusFilter;

  const DashboardLoaded({
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

  @override
  List<Object?> get props => [
        totalProducts,
        successfulCaptures,
        reviewPending,
        items,
        nextCursor,
        isLoadingMore,
        currentSearch,
        currentStatusFilter,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
