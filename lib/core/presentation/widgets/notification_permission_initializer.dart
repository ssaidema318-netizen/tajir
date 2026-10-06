import 'package:flutter/material.dart';
import 'package:tajir/core/services/notification_service.dart';

class NotificationPermissionInitializer extends StatefulWidget {
  const NotificationPermissionInitializer({required this.child, super.key});
  final Widget child;
  @override
  State<NotificationPermissionInitializer> createState() =>
      _NotificationPermissionInitializerState();
}

class _NotificationPermissionInitializerState
    extends State<NotificationPermissionInitializer> {
  bool _requested = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testNotification();
    });
  }

  Future<void> _testNotification() async {
    if (_requested) {
      return;
    }
    _requested = true;
    final service = NotificationService.instance;
    try {
      final permission = await service.requestNotificationPermission();
      debugPrint('🔔 Notification permission: $permission');
      
      final pending = await service.getPendingNotifications();
      debugPrint(
        '📋 Pending notifications: '
        '${pending.map((notification) => notification.id).toList()}',
      );
      debugPrint('✅ Scheduled notification successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Notification test error: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
