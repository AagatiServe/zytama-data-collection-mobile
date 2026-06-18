import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/dashboard_bloc.dart';

class AllScansScreen extends StatelessWidget {
  const AllScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(sl())..add(DashboardLoadRequested()),
      child: const _AllScansView(),
    );
  }
}

class _AllScansView extends StatefulWidget {
  const _AllScansView();

  @override
  State<_AllScansView> createState() => _AllScansViewState();
}

class _AllScansViewState extends State<_AllScansView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;
  String _selectedStatus = 'all';

  static const _statusOptions = [
    ('all', AppStrings.all),
    ('captured', AppStrings.captured),
    ('review_pending', AppStrings.pending),
    ('approved', AppStrings.approved),
    ('not_approved', AppStrings.rejected),
    ('failed', AppStrings.failed),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final state = context.read<DashboardBloc>().state;
      if (state is DashboardLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<DashboardBloc>().add(DashboardLoadMoreRequested());
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _reload(search: value.trim().isEmpty ? null : value.trim());
    });
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _reload(statusFilter: status == 'all' ? null : status);
  }

  void _reload({String? search, String? statusFilter}) {
    context.read<DashboardBloc>().add(DashboardLoadRequested(
          search: search ??
              (_searchCtrl.text.trim().isEmpty
                  ? null
                  : _searchCtrl.text.trim()),
          statusFilter: statusFilter ??
              (_selectedStatus == 'all' ? null : _selectedStatus),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashBg,
      appBar: AppBar(
        title: const Text(AppStrings.allScans),
        backgroundColor: AppColors.dashBg,
        foregroundColor: const Color(0xff1A1A1A),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // ── Search + filter bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              children: [
                // Search field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      prefixIcon: Icon(Icons.search,
                          size: 22, color: Color(0xff0B7285)),
                      hintText: AppStrings.searchByProductNameOrBrand,
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Status filter chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final (value, label) = _statusOptions[i];
                      final active = _selectedStatus == value;
                      return GestureDetector(
                        onTap: () => _onStatusChanged(value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                active ? const Color(0xff0B7285) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? const Color(0xff0B7285)
                                  : const Color(0xff0B7285)
                                      .withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: active ? 0.08 : 0.04),
                                blurRadius: active ? 8 : 5,
                              ),
                            ],
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : const Color(0xff0B7285),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff0B7285)),
                  );
                }

                if (state is DashboardError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _reload(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff0B7285),
                                foregroundColor: Colors.white),
                            child: const Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DashboardLoaded) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(AppStrings.noScansFound,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xff0B7285),
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xff0B7285), strokeWidth: 2),
                            ),
                          );
                        }
                        final item = state.items[index];
                        return _ScanListItem(item: item);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan List Item ────────────────────────────────────────────────────────────

class _ScanListItem extends StatelessWidget {
  final dynamic item;
  const _ScanListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item.productName?.isNotEmpty == true)
        ? item.productName as String
        : item.gtin as String;
    final brand = item.brandName as String?;
    final category = item.category as String?;
    final hasImage =
        item.frontUrl != null && (item.frontUrl as String).isNotEmpty;
    final captureTime = item.captureTime as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: item.frontUrl as String,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (brand != null && brand.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.gtin as String,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (category != null && category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ],
            ),
          ),

          // Status + time
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: item.status as String),
                const SizedBox(height: 6),
                Text(
                  _formatTime(captureTime),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 54,
        height: 54,
        color: const Color(0xffD9F0EC),
        child: const Icon(Icons.inventory_2_rounded,
            color: Color(0xff0B7285), size: 22),
      );

  String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return AppStrings.justNow;
    if (d.inMinutes < 60) return AppStrings.minutesAgo(d.inMinutes);
    if (d.inHours < 24) return AppStrings.hoursAgo(d.inHours);
    return AppStrings.daysAgo(d.inDays);
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'approved' => (
          AppStrings.approved,
          const Color(0xffE5F6EE),
          const Color(0xff0E9F6E)
        ),
      'review_pending' => (
          AppStrings.pending,
          const Color(0xffFFF3E0),
          const Color(0xffF57C00)
        ),
      'not_approved' => (
          AppStrings.rejected,
          const Color(0xffFEECEC),
          const Color(0xffE53935)
        ),
      'failed' => (AppStrings.failed, const Color(0xffF5F5F5), Colors.black54),
      _ => (
          AppStrings.captured,
          const Color(0xffE3F2FD),
          const Color(0xff1976D2)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}
