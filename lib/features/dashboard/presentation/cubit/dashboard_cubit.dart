import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';
import 'package:tajir/features/payments/data/models/payment_model.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final PaymentRepositoryImpl paymentRepository;
  final InstallmentRepositoryImpl installmentRepository;

  DashboardCubit({
    required this.paymentRepository,
    required this.installmentRepository,
  }) : super(DashboardInitial());

  void loadDashboard() {
    try {
      emit(DashboardLoading());

      final payments = paymentRepository.getPayments();
      final installments = installmentRepository.getInstallments();

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final tomorrow = today.add(const Duration(days: 1));

      // السبت = 6 في DateTime
      final daysFromSaturday = (now.weekday + 1) % 7;

      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(days: daysFromSaturday),
      );

      final monthStart = DateTime(
        now.year,
        now.month,
        1,
      );

      final todayCollected = _sumPayments(
        payments,
        (payment) =>
            !payment.paidAt.isBefore(today) &&
            payment.paidAt.isBefore(tomorrow),
      );

      final weekCollected = _sumPayments(
        payments,
        (payment) => !payment.paidAt.isBefore(weekStart),
      );

      final monthCollected = _sumPayments(
        payments,
        (payment) => !payment.paidAt.isBefore(monthStart),
      );

      final todayInstallments = installments.where(
        (installment) {
          final dueDate = DateTime(
            installment.dueDate.year,
            installment.dueDate.month,
            installment.dueDate.day,
          );

          return dueDate == today &&
              installment.status != 'paid';
        },
      ).toList();

      final overdueInstallments = installments.where(
        (installment) {
          final dueDate = DateTime(
            installment.dueDate.year,
            installment.dueDate.month,
            installment.dueDate.day,
          );

          return dueDate.isBefore(today) &&
              installment.status != 'paid';
        },
      ).toList();

      final overdueAmount = overdueInstallments.fold<int>(
        0,
        (sum, installment) {
          final remaining =
              installment.dueAmount - installment.paidAmount;

          return sum + (remaining > 0 ? remaining : 0);
        },
      );

      final cashCollected = _sumPayments(
        payments,
        (payment) =>
            payment.paymentMethod == 'cash' &&
            !payment.paidAt.isBefore(monthStart),
      );

      final orangeMoneyCollected = _sumPayments(
        payments,
        (payment) =>
            payment.paymentMethod == 'orange_money' &&
            !payment.paidAt.isBefore(monthStart),
      );

      final mtnMomoCollected = _sumPayments(
        payments,
        (payment) =>
            payment.paymentMethod == 'mtn_momo' &&
            !payment.paidAt.isBefore(monthStart),
      );

      final recentPayments = List<PaymentModel>.from(payments)
        ..sort(
          (a, b) => b.paidAt.compareTo(a.paidAt),
        );

      final limitedRecentPayments =
          recentPayments.take(5).toList();

      emit(
        DashboardLoaded(
          todayCollected: todayCollected,
          weekCollected: weekCollected,
          monthCollected: monthCollected,
          todayInstallmentsCount: todayInstallments.length,
          overdueInstallmentsCount:
              overdueInstallments.length,
          overdueAmount: overdueAmount,
          cashCollected: cashCollected,
          orangeMoneyCollected: orangeMoneyCollected,
          mtnMomoCollected: mtnMomoCollected,
          recentPayments: limitedRecentPayments,
        ),
      );
    } catch (e) {
      emit(
        DashboardError(e.toString()),
      );
    }
  }

  int _sumPayments(
    List<PaymentModel> payments,
    bool Function(PaymentModel payment) condition,
  ) {
    return payments
        .where(condition)
        .fold<int>(
          0,
          (sum, payment) => sum + payment.amount,
        );
  }
}
