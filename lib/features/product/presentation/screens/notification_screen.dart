import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF071e27)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF071e27),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Color(0xFF0d631b),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: const [
          _NotificationGroup(label: 'Today'),
          SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.check_circle_rounded,
            iconColor: Color(0xFF0d631b),
            iconBg: Color(0xFFE8F5E9),
            title: 'Product uploaded successfully',
            subtitle: 'Barcode 8901234567890 has been saved to the database.',
            time: '2 min ago',
            isUnread: true,
          ),
          _NotificationItem(
            icon: Icons.warning_amber_rounded,
            iconColor: Color(0xFFE65100),
            iconBg: Color(0xFFFFF3E0),
            title: 'Duplicate barcode scanned',
            subtitle: 'Barcode 000000000000 already exists in the system.',
            time: '18 min ago',
            isUnread: true,
          ),
          _NotificationItem(
            icon: Icons.local_fire_department_rounded,
            iconColor: Color(0xFFD84315),
            iconBg: Color(0xFFFBE9E7),
            title: '5-day streak maintained!',
            subtitle: 'Keep it up! You\'ve been scanning consistently.',
            time: '1 hr ago',
            isUnread: false,
          ),
          SizedBox(height: 20),
          _NotificationGroup(label: 'Yesterday'),
          SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.emoji_events_rounded,
            iconColor: Color(0xFFF9A825),
            iconBg: Color(0xFFFFFDE7),
            title: 'Daily goal reached!',
            subtitle: 'You scanned 60 products yesterday. Great work!',
            time: 'Yesterday, 6:42 PM',
            isUnread: false,
          ),
          _NotificationItem(
            icon: Icons.check_circle_rounded,
            iconColor: Color(0xFF0d631b),
            iconBg: Color(0xFFE8F5E9),
            title: 'Product uploaded successfully',
            subtitle: 'Barcode 9780201379624 has been saved to the database.',
            time: 'Yesterday, 3:15 PM',
            isUnread: false,
          ),
        ],
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
          color: Color(0xFF40493d),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Single notification card ──────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread
            ? Colors.white
            : Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(
                color: const Color(0xFF0d631b).withValues(alpha: 0.18),
                width: 1)
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
                    color: Color(0xFF0d631b),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF071e27),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF40493d),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
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
}
