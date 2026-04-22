import 'package:flutter/foundation.dart';
import 'package:project_uts/features/notification/domain/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // =========================
  // LOAD DUMMY NOTIFICATIONS
  // =========================
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Tiket dibuat',
        body: 'Tiket kamu berhasil dibuat',
        isRead: false,
        createdAt: DateTime.now(),
      ),
      NotificationModel(
        id: '2',
        title: 'Status berubah',
        body: 'Tiket kamu sekarang In Progress',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        title: 'Tiket selesai',
        body: 'Tiket kamu sudah resolved',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // MARK AS READ
  // =========================
  void markAsRead(String notificationId) {
    _notifications = _notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    notifyListeners();
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  void markAllAsRead() {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();

    notifyListeners();
  }

  // =========================
  // ADD NOTIFICATION (OPTIONAL)
  // =========================
  void addNotification(NotificationModel notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }
}