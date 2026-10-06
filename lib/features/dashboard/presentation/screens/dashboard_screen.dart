
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tajir/core/database/hive/hive_service.dart';

import 'package:tajir/features/installments/data/datasources/installment_local_data_source.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';

import 'package:tajir/features/payments/data/datasources/payment_local_data_source.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';

import 'package:tajir/features/payments/presentation/cubit/payment_filter.dart';

import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/dashboard_payment_methods.dart';
import '../widgets/dashboard_recent_payments.dart';
import '../widgets/dashboard_quick_actions.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenPayments;
  final VoidCallback? onOpenCustomers;
  final VoidCallback? onAddSale;
  final void Function(PaymentFilter filter)? onOpenPaymentsWithFilter;

  const DashboardScreen({
    super.key,
    this.onOpenPayments,
    this.onOpenCustomers,
    this.onAddSale,
    this.onOpenPaymentsWithFilter,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit dashboardCubit;

  @override
  void initState() {
    super.initState();

    final installmentRepository = InstallmentRepositoryImpl(
      InstallmentLocalDataSource(
        plansBox: HiveService.installmentPlansBox,
        installmentsBox: HiveService.installmentsBox,
      ),
    );

    final paymentRepository = PaymentRepositoryImpl(
      PaymentLocalDataSource(
        HiveService.paymentsBox,
      ),
    );

    dashboardCubit = DashboardCubit(
      paymentRepository: paymentRepository,
      installmentRepository: installmentRepository,
    );

    dashboardCubit.loadDashboard();
  }

  /// إعادة تحميل بيانات الـ Dashboard من Hive
  void refreshDashboard() {
    dashboardCubit.loadDashboard();
  }

  @override
  void dispose() {
    dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: dashboardCubit,
      child: _DashboardView(
        onOpenPayments: widget.onOpenPayments,
        onOpenCustomers: widget.onOpenCustomers,
        onAddSale: widget.onAddSale,
        onOpenPaymentsWithFilter:
            widget.onOpenPaymentsWithFilter,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final VoidCallback? onOpenPayments;
  final VoidCallback? onOpenCustomers;
  final VoidCallback? onAddSale;
  final void Function(PaymentFilter filter)?
      onOpenPaymentsWithFilter;

  const _DashboardView({
    this.onOpenPayments,
    this.onOpenCustomers,
    this.onAddSale,
    this.onOpenPaymentsWithFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          // =========================
          // Loading
          // =========================

          if (state is DashboardInitial ||
              state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =========================
          // Error
          // =========================

          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'حدث خطأ أثناء تحميل البيانات',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        context
                            .read<DashboardCubit>()
                            .loadDashboard();
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =========================
          // Loaded
          // =========================

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardCubit>().loadDashboard();
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ),
                children: [
                  // =====================
                  // Header
                  // =====================

                  const DashboardHeader(),

                  const SizedBox(height: 20),

                  // =====================
                  // Quick Actions
                  // =====================

                  DashboardQuickActions(
                    onAddSale:
                        onAddSale ?? () {},
                    onCustomers:
                        onOpenCustomers ?? () {},
                    onPayments:
                        onOpenPayments ?? () {},
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // Summary
                  // =====================

                  DashboardSummary(
                    todayCollected:
                        state.todayCollected,
                    weekCollected:
                        state.weekCollected,
                    monthCollected:
                        state.monthCollected,
                    todayInstallmentsCount:
                        state.todayInstallmentsCount,
                    overdueInstallmentsCount:
                        state.overdueInstallmentsCount,
                    overdueAmount:
                        state.overdueAmount,

                    // ===================
                    // Today installments
                    // ===================

                    onTodayInstallments: () {
                      onOpenPaymentsWithFilter
                          ?.call(
                        PaymentFilter.today,
                      );
                    },

                    // ===================
                    // Overdue
                    // ===================

                    onOverdueInstallments: () {
                      onOpenPaymentsWithFilter
                          ?.call(
                        PaymentFilter.overdue,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // Payment Methods
                  // =====================

                  DashboardPaymentMethods(
                    cashCollected:
                        state.cashCollected,
                    orangeMoneyCollected:
                        state.orangeMoneyCollected,
                    mtnMomoCollected:
                        state.mtnMomoCollected,
                  ),

                  const SizedBox(height: 24),

                  // =====================
                  // Recent Payments
                  // =====================

                  DashboardRecentPayments(
                    payments:
                        state.recentPayments,
                    onOpenPayments:
                        onOpenPayments,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
