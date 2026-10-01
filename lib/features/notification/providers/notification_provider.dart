import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'request_received', 'request_approved', 'returned', 'new_item'

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier()
      : super([
          NotificationItem(
            id: 'notif_1',
            title: 'Request Approved! 🎉',
            message: 'Aarav Sharma approved your request for "Calculus: Early Transcendentals". Tap to view pickup QR code.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
            isRead: false,
            type: 'request_approved',
          ),
          NotificationItem(
            id: 'notif_2',
            title: 'New Resource Added',
            message: 'A TI-84 Plus CE Graphing Calculator was listed in Chennai Institute of Technology.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: false,
            type: 'new_item',
          ),
          NotificationItem(
            id: 'notif_3',
            title: 'Resource Handover Confirmed',
            message: 'QR Code scanned successfully! Handover complete.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            type: 'returned',
          ),
        ]);

  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item
    ];
  }

  void markAllAsRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }

  int get unreadCount => state.where((item) => !item.isRead).length;
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationNotifierProvider);
  return notifs.where((item) => !item.isRead).length;
});
