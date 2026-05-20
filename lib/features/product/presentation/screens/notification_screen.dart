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
      create: (_) => sl<NotificationBloc>()
        ..add(const NotificationLoadRequested()),
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
    // Wait until state leaves loading
    await context.read<NotificationBloc>().stream.firstWhere(
          (s) => s is! NotificationLoading,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: const _EmptyView(),
              );
            }

            final grouped = _groupByDate(state.items);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _itemCount(grouped, state.isLoadingMore),
                itemBuilder: (context, index) =>
                    _buildItem(context, grouped, index, state.isLoadingMore),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Grouping helpers ────────────────────────────────────────────────────────

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
        label =
            '${_monthName(day.month)} ${day.day}, ${day.year}';
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
      count += 1 + g.items.length + 1; // header + items + spacing
    }
    if (isLoadingMore) count += 1;
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    List<_Section> groups,
    int index,
    bool isLoadingMore,
  ) {
    int cursor = 0;
    for (final section in groups) {
      // Section header
      if (index == cursor) return _NotificationGroup(label: section.label);
      cursor++;
      // Items
      for (final item in section.items) {
        if (index == cursor) return _NotificationItem(item: item);
        cursor++;
      }
      // Spacer after section
      if (index == cursor) return const SizedBox(height: 20);
      cursor++;
    }
    // Bottom loading spinner
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        const Icon(Icons.notifications_none_rounded,
            size: 56, color: AppColors.outline),
        const SizedBox(height: 16),
        const Text(
          'No notifications yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You\'re all caught up!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
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
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _NotificationGroup extends StatelessWidget {
  final String label;
  const _NotificationGroup({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMedium,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Single notification card ──────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  final NotificationItemModel item;
  const _NotificationItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, iconBg) = _resolveIcon(item.type);
    final isUnread = !item.isRead;
    final timeLabel = _formatTime(item.raisedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.18), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnread ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            if (isUnread)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              item.body,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              timeLabel,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color, Color) _resolveIcon(String type) {
    switch (type) {
      case 'ocr_completed':
        return (
          Icons.document_scanner_rounded,
          AppColors.primary,
          AppColors.background,
        );
      case 'upload_success':
        return (
          Icons.check_circle_rounded,
          AppColors.primary,
          AppColors.background,
        );
      case 'duplicate_barcode':
        return (
          Icons.warning_amber_rounded,
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
        );
      case 'streak':
        return (
          Icons.local_fire_department_rounded,
          const Color(0xFFD84315),
          const Color(0xFFFBE9E7),
        );
      case 'goal_reached':
        return (
          Icons.emoji_events_rounded,
          const Color(0xFFF9A825),
          const Color(0xFFFFFDE7),
        );
      default:
        return (
          Icons.notifications_rounded,
          AppColors.secondary,
          AppColors.background,
        );
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
