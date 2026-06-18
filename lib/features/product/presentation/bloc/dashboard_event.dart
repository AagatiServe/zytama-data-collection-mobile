part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class DashboardLoadRequested extends DashboardEvent {
  final String? search;
  final String? statusFilter;
  DashboardLoadRequested({this.search, this.statusFilter});
}

class DashboardLoadMoreRequested extends DashboardEvent {}

class DashboardRefreshRequested extends DashboardEvent {
  final String? search;
  final String? statusFilter;
  DashboardRefreshRequested({this.search, this.statusFilter});
}

class DashboardLocalIncrementRequested extends DashboardEvent {}
