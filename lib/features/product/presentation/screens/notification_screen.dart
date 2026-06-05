import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zytama_data/core/constants/app_colors.dart';
import 'package:zytama_data/core/di/injection_container.dart';
import 'package:zytama_data/features/product/data/models/notification_model.dart';
import 'package:zytama_data/features/product/presentation/bloc/notification_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationBloc>()..add(const NotificationLoadRequested()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final bloc = context.read<NotificationBloc>();
      final state = bloc.state;
      if (state is NotificationLoaded &&
          state.nextCursor != null &&
          !state.isLoadingMore) {
        bloc.add(const NotificationLoadMoreRequested());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(const NotificationLoadRequested());
    await context
        .read<NotificationBloc>()
        .stream
        .firstWhere((s) => s is! NotificationLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FBF8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ──────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffDDF4E8), Color(0xffEEF9F0)],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoaded &&
                          state.unreadCount > 0) {
                        return OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_circle_outline,
                              size: 16),
                          label: const Text('Mark all read',
                              style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff0A6475),
                            side: const BorderSide(
                                color: Color(0xffB6E8DA)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xff0A6475)),
                    );
                  }

                  if (state is NotificationError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context
                          .read<NotificationBloc>()
                          .add(const NotificationLoadRequested()),
                    );
                  }

                  if (state is NotificationLoaded) {
                    if (state.items.isEmpty) {
                      return RefreshIndicator(
                        color: const Color(0xff0A6475),
                        onRefresh: _onRefresh,
                        child: const _EmptyView(),
                      );
                    }

                    final grouped = _groupByDate(state.items);

                    return RefreshIndicator(
                      color: const Color(0xff0A6475),
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount:
                            _itemCount(grouped, state.isLoadingMore),
                        itemBuilder: (context, index) => _buildItem(
                            context, grouped, index, state.isLoadingMore),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grouping helpers ───────────────────────────────────────────────────

  List<_Section> _groupByDate(List<NotificationItemModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<NotificationItemModel>> buckets = {};

    for (final item in items) {
      final d = item.raisedAt.toLocal();
      final day = DateTime(d.year, d.month, d.day);
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${_monthName(day.month)} ${day.day}, ${day.year}';
      }
      buckets.putIfAbsent(label, () => []).add(item);
    }

    return buckets.entries
        .map((e) => _Section(label: e.key, items: e.value))
        .toList();
  }

  int _itemCount(List<_Section> groups, bool isLoadingMore) {
    int count = 0;
    for (final g in groups) {
      count += 1 + g.items.length + 1;
    }
    if (isLoadingMore) count += 1;
    return count;
  }

  Widget _buildItem(BuildContext context, List<_Section> groups, int index,
      bool isLoadingMore) {
    int cursor = 0;
    for (final section in groups) {
      if (index == cursor) return _SectionHeader(label: section.label);
      cursor++;
      for (final item in section.items) {
        if (index == cursor) return _NotificationCard(item: item);
        cursor++;
      }
      if (index == cursor) return const SizedBox(height: 16);
      cursor++;
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              color: Color(0xff0A6475), strokeWidth: 2.5),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const names = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month];
  }
}

class _Section {
  final String label;
  final List<NotificationItemModel> items;
  const _Section({required this.label, required this.items});
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  Color get _color {
    if (label == 'Today') return const Color(0xff0A6475);
    if (label == 'Yesterday') return const Color(0xff4C63FF);
    return Colors.grey.shade500;
  }

  IconData get _icon {
    if (label == 'Today') return Icons.calendar_month;
    if (label == 'Yesterday') return Icons.calendar_today;
    return Icons.date_range;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1.5,
              color: _color.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationItemModel item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, iconBg) = _resolveIcon(item.type);
    final isUnread = !item.isRead;
    final timeLabel = _formatTime(item.raisedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnread ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon box
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              if (isUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xff0A6475),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isUnread ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12,
                        color: iconColor.withValues(alpha: 0.75)),
                    const SizedBox(width: 4),
                    Text(
                      timeLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: iconColor.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  static (IconData, Color, Color) _resolveIcon(String type) {
    switch (type) {
      case 'ocr_completed':
        return (Icons.document_scanner_rounded, AppColors.primary,
            AppColors.background);
      case 'upload_success':
        return (Icons.check_circle_rounded, AppColors.primary,
            AppColors.background);
      case 'duplicate_barcode':
        return (Icons.warning_amber_rounded, const Color(0xFFE65100),
            const Color(0xFFFFF3E0));
      case 'streak':
        return (Icons.local_fire_department_rounded,
            const Color(0xFFD84315), const Color(0xFFFBE9E7));
      case 'goal_reached':
        return (Icons.emoji_events_rounded, const Color(0xFFF9A825),
            const Color(0xFFFFFDE7));
      default:
        return (Icons.notifications_rounded, AppColors.secondary,
            AppColors.background);
    }
  }

  static String _formatTime(DateTime raisedAt) {
    final local = raisedAt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(local.year, local.month, local.day);
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$hour:$minute $period';

    if (day == today) return 'Today, $timeStr';
    if (day == yesterday) return 'Yesterday, $timeStr';
    return timeStr;
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        const Icon(Icons.notifications_none_rounded,
            size: 52, color: Colors.grey),
        const SizedBox(height: 14),
        const Text('No notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
        const SizedBox(height: 5),
        const Text("You're all caught up!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: Colors.grey),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff0A6475),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
