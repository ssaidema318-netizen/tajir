import 'package:equatable/equatable.dart';

import 'package:tajir/features/payments/data/models/payment_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int todayCollected;
  final int weekCollected;
  final int monthCollected;

  final int todayInstallmentsCount;
  final int overdueInstallmentsCount;
  final int overdueAmount;

  final int cashCollected;
  final int orangeMoneyCollected;
  final int mtnMomoCollected;

  final List<PaymentModel> recentPayments;

  const DashboardLoaded({
    required this.todayCollected,
    required this.weekCollected,
    required this.monthCollected,
    required this.todayInstallmentsCount,
    required this.overdueInstallmentsCount,
    required this.overdueAmount,
    required this.cashCollected,
    required this.orangeMoneyCollected,
    required this.mtnMomoCollected,
    required this.recentPayments,
  });

  @override
  List<Object?> get props => [
        todayCollected,
        weekCollected,
        monthCollected,
        todayInstallmentsCount,
        overdueInstallmentsCount,
        overdueAmount,
        cashCollected,
        orangeMoneyCollected,
        mtnMomoCollected,
        recentPayments,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
