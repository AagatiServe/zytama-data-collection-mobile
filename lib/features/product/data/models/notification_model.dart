class NotificationItemModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime raisedAt;

  const NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.raisedAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      raisedAt: DateTime.parse(json['raised_at'] as String),
    );
  }
}

class NotificationsPageModel {
  final List<NotificationItemModel> items;
  final String? nextCursor;
  final int unreadCount;

  const NotificationsPageModel({
    required this.items,
    required this.nextCursor,
    required this.unreadCount,
  });

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NotificationsPageModel(
      items: (data['items'] as List)
          .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: data['next_cursor'] as String?,
      unreadCount: data['unread_count'] as int? ?? 0,
    );
  }
}
