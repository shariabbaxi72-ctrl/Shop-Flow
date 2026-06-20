class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // order_update, general
  final String orderId;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.orderId,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'orderId': orderId,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        type: map['type'] ?? '',
        orderId: map['orderId'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
        isRead: map['isRead'] ?? false,
      );
}