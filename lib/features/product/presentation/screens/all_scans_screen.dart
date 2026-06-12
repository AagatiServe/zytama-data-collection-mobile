import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/dashboard_bloc.dart';

class AllScansScreen extends StatelessWidget {
  const AllScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardBloc(sl())..add(DashboardLoadRequested()),
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
    ('all', 'All'),
    ('captured', 'Captured'),
    ('review_pending', 'Pending'),
    ('approved', 'Approved'),
    ('not_approved', 'Rejected'),
    ('failed', 'Failed'),
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
          search: search ?? (_searchCtrl.text.trim().isEmpty
              ? null
              : _searchCtrl.text.trim()),
          statusFilter: statusFilter ??
              (_selectedStatus == 'all' ? null : _selectedStatus),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5FAF5),
      appBar: AppBar(
        title: const Text('All Scans'),
        backgroundColor: const Color(0xff0B7285),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Search + filter bar ────────────────────────────────────
          Container(
            color: const Color(0xff0B7285),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      prefixIcon:
                          Icon(Icons.search, size: 20, color: Colors.grey),
                      hintText: 'Search by product name or brand…',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Status filter chips
                SizedBox(
                  height: 32,
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
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? const Color(0xff0B7285)
                                  : Colors.white,
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
                            child: const Text('Retry'),
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
                              size: 64,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text('No scans found',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xff0B7285),
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: item.frontUrl as String,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.qr_code,
                          size: 12, color: Colors.grey),
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
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
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
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 76,
        height: 76,
        color: const Color(0xffD9F0EC),
        child: const Icon(Icons.inventory_2_rounded,
            color: Color(0xff0B7285), size: 28),
      );

  String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'approved' =>
        ('Approved', const Color(0xffE5F6EE), const Color(0xff0E9F6E)),
      'review_pending' =>
        ('Pending', const Color(0xffFFF3E0), const Color(0xffF57C00)),
      'not_approved' =>
        ('Rejected', const Color(0xffFEECEC), const Color(0xffE53935)),
      'failed' => ('Failed', const Color(0xffF5F5F5), Colors.black54),
      _ => ('Captured', const Color(0xffE3F2FD), const Color(0xff1976D2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }
}
