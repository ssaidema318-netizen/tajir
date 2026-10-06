import 'package:flutter/material.dart';
import 'package:tajir/core/services/notification_service.dart';
import 'package:tajir/features/installments/data/models/installment_model.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';

class InstallmentNotificationService {
  InstallmentNotificationService({
    required this.installmentRepository,
    required this.notificationService,
  });

  final InstallmentRepositoryImpl installmentRepository;
  final NotificationService notificationService;

  static const int _notificationHour = 9;
  static const int _notificationMinute = 0;

  /// Synchronizes notifications for all installments.
  ///
  /// - Fully paid installments -> notification is cancelled.
  /// - Future installments -> notification is scheduled for 09:00.
  /// - Today's installment -> notification is scheduled immediately
  ///   if 09:00 has already passed, otherwise at 09:00.
  /// - Overdue installments -> notification is scheduled for the next
  ///   available 09:00 slot.
  Future<void> scheduleAllInstallmentNotifications() async {
    await notificationService.initialize();

    final installments = installmentRepository.getInstallments();

    for (final installment in installments) {
      await scheduleInstallmentNotification(installment);
    }
  }

  /// Creates or updates the notification for a single installment.
  Future<void> scheduleInstallmentNotification(
    InstallmentModel installment,
  ) async {
    final notificationId = _notificationId(installment.id);
    debugPrint(
  '🔔 Scheduling installment: '
  '${installment.id} | '
  'notificationId: $notificationId | '
  'dueDate: ${installment.dueDate} | '
  'paid: ${installment.paidAmount}/${installment.dueAmount}',
);

    // If the installment is fully paid, remove its notification.
    if (_isPaid(installment)) {
      await notificationService.cancel(notificationId);
      return;
    }

    final now = DateTime.now();

    // Always remove the previous scheduled notification first.
    // This prevents an old schedule from remaining after an update.
    await notificationService.cancel(notificationId);

    // ------------------------------------------------------------
    // 1. OVERDUE INSTALLMENT
    // ------------------------------------------------------------
    if (_isOverdue(installment.dueDate, now)) {
      await _scheduleOverdueNotification(
        installment: installment,
        notificationId: notificationId,
        now: now,
      );
      return;
    }

    // ------------------------------------------------------------
    // 2. TODAY'S INSTALLMENT
    // ------------------------------------------------------------
    if (_isToday(installment.dueDate, now)) {
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _notificationHour,
        _notificationMinute,
      );

      // If 09:00 has already passed, notify after 10 seconds.
      //
      // This is intentional:
      // the user opened the app after the normal notification time,
      // so we shouldn't silently lose today's installment notification.
      if (!scheduledDate.isAfter(now)) {
        scheduledDate = now.add(
          const Duration(seconds: 10),
        );
      }

      await notificationService.schedule(
        id: notificationId,
        title: 'قسط مستحق اليوم',
        body: _messageFor(installment),
        scheduledDate: scheduledDate,
        payload: _payload(installment),
      );
      debugPrint(
  '✅ Installment notification scheduled: $notificationId',
);
      return;
    }

    // ------------------------------------------------------------
    // 3. FUTURE INSTALLMENT
    // ------------------------------------------------------------
    final scheduledDate = DateTime(
      installment.dueDate.year,
      installment.dueDate.month,
      installment.dueDate.day,
      _notificationHour,
      _notificationMinute,
    );

    await notificationService.schedule(
      id: notificationId,
      title: 'قسط قادم',
      body: _messageFor(installment),
      scheduledDate: scheduledDate,
      payload: _payload(installment),
    );
  }

  /// Cancels the notification associated with one installment.
  Future<void> cancelInstallmentNotification(
    String installmentId,
  ) async {
    await notificationService.cancel(
      _notificationId(installmentId),
    );
  }

  /// Cancels notifications associated with multiple installments.
  Future<void> cancelInstallmentNotifications(
    List<String> installmentIds,
  ) async {
    for (final installmentId in installmentIds) {
      await cancelInstallmentNotification(installmentId);
    }
  }

  bool _isPaid(InstallmentModel installment) {
    return installment.paidAmount >= installment.dueAmount;
  }

  bool _isOverdue(
    DateTime dueDate,
    DateTime now,
  ) {
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final dueDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    return dueDay.isBefore(today);
  }

  Future<void> _scheduleOverdueNotification({
    required InstallmentModel installment,
    required int notificationId,
    required DateTime now,
  }) async {
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _notificationHour,
      _notificationMinute,
    );

    // If today's 09:00 has already passed,
    // notify after 10 seconds instead of waiting another day.
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = now.add(
        const Duration(seconds: 10),
      );
    }

    await notificationService.schedule(
      id: notificationId,
      title: 'قسط متأخر',
      body: _overdueMessage(installment),
      scheduledDate: scheduledDate,
      payload: _payload(installment),
    );
  }

  String _messageFor(InstallmentModel installment) {
    if (_isToday(installment.dueDate, DateTime.now())) {
      return 'القسط رقم ${installment.installmentNumber} مستحق اليوم بقيمة ${installment.dueAmount}';
    }

    return 'القسط رقم ${installment.installmentNumber} مستحق بتاريخ '
        '${_formatDate(installment.dueDate)} بقيمة ${installment.dueAmount}';
  }

  String _overdueMessage(InstallmentModel installment) {
    return 'القسط رقم ${installment.installmentNumber} متأخر بقيمة ${installment.dueAmount}';
  }

  bool _isToday(
    DateTime date,
    DateTime now,
  ) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _payload(InstallmentModel installment) {
    return 'installment:${installment.id}';
  }

  /// Converts the installment String ID into a deterministic
  /// positive integer required by flutter_local_notifications.
  int _notificationId(String installmentId) {
    var hash = 2166136261;

    for (final codeUnit in installmentId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }
}