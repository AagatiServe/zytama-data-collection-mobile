part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final String? search;
  final String? statusFilter;
  const DashboardLoadRequested({this.search, this.statusFilter});

  @override
  List<Object?> get props => [search, statusFilter];
}

class DashboardLoadMoreRequested extends DashboardEvent {
  const DashboardLoadMoreRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  final String? search;
  final String? statusFilter;
  const DashboardRefreshRequested({this.search, this.statusFilter});

  @override
  List<Object?> get props => [search, statusFilter];
}

class DashboardLocalIncrementRequested extends DashboardEvent {
  const DashboardLocalIncrementRequested();
}
