import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_uts/features/notification/domain/notification_model.dart';
import 'package:project_uts/core/constant/api_endpoints.dart';
import 'package:project_uts/core/network/supabase_client.dart';

class NotificationProvider extends ChangeNotifier {
  final _client = SupabaseClientHelper.client;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  RealtimeChannel? _channel;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // =========================
  // LOAD NOTIFICATIONS
  // =========================
  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from(ApiEndpoints.notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _notifications = (response as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('LOAD NOTIFICATIONS ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // SUBSCRIBE REALTIME
  // =========================
  void subscribeToNotifications(String userId) {
    // Unsubscribe dulu kalau sudah ada channel
    unsubscribe();

    _channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: ApiEndpoints.notificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final newNotif =
                  NotificationModel.fromJson(payload.newRecord);
              _notifications.insert(0, newNotif);
              notifyListeners();
            } catch (e) {
              debugPrint('REALTIME NOTIF ERROR: $e');
            }
          },
        )
        .subscribe();
  }

  // =========================
  // UNSUBSCRIBE
  // =========================
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  // =========================
  // MARK AS READ
  // =========================
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(ApiEndpoints.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);

      _notifications = _notifications.map((n) {
        if (n.id == notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('MARK AS READ ERROR: $e');
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from(ApiEndpoints.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('MARK ALL READ ERROR: $e');
    }
  }

  // =========================
  // INSERT NOTIFIKASI (dipanggil saat status tiket berubah)
  // =========================
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? ticketId,
  }) async {
    try {
      await SupabaseClientHelper.client
          .from(ApiEndpoints.notificationsTable)
          .insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'ticket_id': ticketId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SEND NOTIFICATION ERROR: $e');
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}