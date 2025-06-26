class NotificationModel {
  final int id;
  final int receiveId;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.receiveId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      receiveId: json['receiveId'] ?? json['receive_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
    );
  }

  NotificationModel copyWith({
    int? id,
    int? receiveId,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      receiveId: receiveId ?? this.receiveId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
