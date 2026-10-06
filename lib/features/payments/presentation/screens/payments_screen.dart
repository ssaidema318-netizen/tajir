import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:tajir/core/services/installment_notification_service.dart';
import 'package:tajir/core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/hive/hive_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../installments/data/datasources/installment_local_data_source.dart';
import '../../../installments/data/models/installment_model.dart';
import '../../../installments/data/repositories/installment_repository_impl.dart';
import '../../data/datasources/payment_local_data_source.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_filter.dart';
import '../cubit/payment_state.dart';
import '../widgets/installment_card.dart';
import '../widgets/payment_header.dart';
import '../widgets/payment_methods_card.dart';
import '../widgets/payment_sections.dart';
import '../widgets/payment_summary_cards.dart';
import '../widgets/recent_payments_card.dart';

class PaymentsScreen extends StatelessWidget {
  final PaymentFilter filter;
  final VoidCallback? onClearFilter;
  final VoidCallback? onPaymentSaved;
  const PaymentsScreen({
    super.key,
    this.filter = PaymentFilter.all,
    this.onClearFilter,
    this.onPaymentSaved,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final paymentRepository = PaymentRepositoryImpl(
          PaymentLocalDataSource(HiveService.paymentsBox),
        );
        final installmentRepository = InstallmentRepositoryImpl(
          InstallmentLocalDataSource(
            plansBox: Hive.box(AppConstants.installmentPlansBox),
            installmentsBox: Hive.box(AppConstants.installmentsBox),
          ),
        );
        final installmentNotificationService = InstallmentNotificationService(
          installmentRepository: installmentRepository,
          notificationService: NotificationService.instance,
        );
        final cubit = PaymentCubit(
          paymentRepository: paymentRepository,
          installmentRepository: installmentRepository,
          installmentNotificationService: installmentNotificationService,
        );

        cubit.loadPayments();
        return cubit;
      },
      child: _PaymentsView(
        filter: filter,
        onClearFilter: onClearFilter,
        onPaymentSaved: onPaymentSaved,
      ),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  final PaymentFilter filter;
  final VoidCallback? onClearFilter;
  final VoidCallback? onPaymentSaved;
  const _PaymentsView({
    required this.filter,
    this.onClearFilter,
    this.onPaymentSaved,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        title: _buildAppBarTitle(context),
        actions: [
          if (filter != PaymentFilter.all)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('الكل'),
              ),
            ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: _handleStateChange,
        builder: _buildBody,
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTitle(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          _getSubtitle(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _handleStateChange(BuildContext context, PaymentState state) {
    if (state is PaymentSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('تم تسجيل التحصيل بنجاح'),
          ),
        );
      onPaymentSaved?.call();
      return;
    }
    if (state is PaymentError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(state.message),
          ),
        );
    }
  }

  Widget _buildBody(BuildContext context, PaymentState state) {
    if (state is PaymentInitial || state is PaymentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PaymentLoaded) {
      return _PaymentsContent(payments: state.payments, filter: filter);
    }
    if (state is PaymentSuccess) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PaymentError) {
      return PaymentErrorView(message: state.message);
    }
    return const SizedBox.shrink();
  }

  String _getTitle() {
    switch (filter) {
      case PaymentFilter.today:
        return 'تحصيل اليوم';
      case PaymentFilter.overdue:
        return 'الأقساط المتأخرة';
      case PaymentFilter.all:
        return 'التحصيل';
    }
  }

  String _getSubtitle() {
    switch (filter) {
      case PaymentFilter.today:
        return 'الأقساط التي تحتاج إلى تحصيل اليوم';
      case PaymentFilter.overdue:
        return 'الأقساط التي تجاوزت موعد الاستحقاق';
      case PaymentFilter.all:
        return 'متابعة الأقساط والتحصيلات';
    }
  }
}

class _PaymentsContent extends StatelessWidget {
  final List<PaymentModel> payments;
  final PaymentFilter filter;
  const _PaymentsContent({required this.payments, required this.filter});
  @override
  Widget build(BuildContext context) {
    final installments = Hive.box<InstallmentModel>(
      AppConstants.installmentsBox,
    ).values.toList();
    final customers = Hive.box<CustomerModel>(
      AppConstants.customersBox,
    ).values.toList();
    final customerMap = {
      for (final customer in customers) customer.id: customer,
    };
    final today = DateTime.now();
    final todayInstallments = _getTodayInstallments(installments, today);
    final overdueInstallments = _getOverdueInstallments(installments, today);
    final upcomingInstallments = _getUpcomingInstallments(installments, today);
    final todayPayments = payments
        .where((payment) => _isSameDay(payment.paidAt, today))
        .toList();
    final todayDueAmount = _calculateRemaining(todayInstallments);
    final overdueAmount = _calculateRemaining(overdueInstallments);
    final todayCollected = _calculatePaymentsTotal(todayPayments);
    final recentPayments = List<PaymentModel>.from(payments)
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    final visibleRecentPayments = recentPayments.take(5).toList();
    final cashCollected = _totalByMethod(todayPayments, 'cash');
    final orangeMoneyCollected = _totalByMethod(todayPayments, 'orange_money');
    final mtnMomoCollected = _totalByMethod(todayPayments, 'mtn_momo');
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PaymentCubit>().loadPayments();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),
        children: [
          if (filter == PaymentFilter.all) ...[
            PaymentHeader(
              todayCollected: todayCollected,
              todayDueAmount: todayDueAmount,
            ),
            const SizedBox(height: AppSpacing.lg),
            PaymentSummaryCards(
              todayDueAmount: todayDueAmount,
              overdueAmount: overdueAmount,
              todayCollected: todayCollected,
            ),
            const SizedBox(height: AppSpacing.md),
            PaymentMethodsCard(
              cash: cashCollected,
              orangeMoney: orangeMoneyCollected,
              mtnMomo: mtnMomoCollected,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildRecentPaymentsSection(
              context,
              visibleRecentPayments,
              customerMap,
              installments,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildTodaySection(context, todayInstallments, customerMap),
            const SizedBox(height: AppSpacing.xl),
            _buildOverdueSection(context, overdueInstallments, customerMap),
            const SizedBox(height: AppSpacing.xl),
            _buildUpcomingSection(context, upcomingInstallments, customerMap),
          ],
          if (filter == PaymentFilter.today) ...[
            _buildFilterSummaryCard(
              context,
              icon: Icons.today_rounded,
              title: 'مستحق اليوم',
              subtitle: 'الأقساط التي تحتاج إلى تحصيل اليوم',
              count: todayInstallments.length,
              amount: todayDueAmount,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTodaySection(
              context,
              todayInstallments,
              customerMap,
              showHeader: false,
            ),
          ],
          if (filter == PaymentFilter.overdue) ...[
            _buildFilterSummaryCard(
              context,
              icon: Icons.warning_amber_rounded,
              title: 'أقساط متأخرة',
              subtitle: 'أقساط تجاوزت موعد الاستحقاق',
              count: overdueInstallments.length,
              amount: overdueAmount,
              isError: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOverdueSection(
              context,
              overdueInstallments,
              customerMap,
              showHeader: false,
            ),
          ],
        ],
      ),
    );
  }

  List<InstallmentModel> _getTodayInstallments(
    List<InstallmentModel> installments,
    DateTime today,
  ) {
    final startOfToday = DateTime(today.year, today.month, today.day);
    final tomorrow = startOfToday.add(const Duration(days: 1));
    final result = installments.where((installment) {
      final dueDate = _dateOnly(installment.dueDate);
      return !dueDate.isBefore(startOfToday) &&
          dueDate.isBefore(tomorrow) &&
          _hasRemaining(installment);
    }).toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<InstallmentModel> _getOverdueInstallments(
    List<InstallmentModel> installments,
    DateTime today,
  ) {
    final startOfToday = _dateOnly(today);
    final result = installments.where((installment) {
      return _dateOnly(installment.dueDate).isBefore(startOfToday) &&
          _hasRemaining(installment);
    }).toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<InstallmentModel> _getUpcomingInstallments(
    List<InstallmentModel> installments,
    DateTime today,
  ) {
    final startOfToday = _dateOnly(today);
    final result = installments.where((installment) {
      return _dateOnly(installment.dueDate).isAfter(startOfToday) &&
          _hasRemaining(installment);
    }).toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  Widget _buildRecentPaymentsSection(
    BuildContext context,
    List<PaymentModel> recentPayments,
    Map<String, CustomerModel> customerMap,
    List<InstallmentModel> installments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentSectionHeader(
          title: 'آخر التحصيلات',
          subtitle: 'آخر العمليات المسجلة',
          count: recentPayments.length,
          icon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recentPayments.isEmpty)
          const PaymentEmptyCard(
            icon: Icons.receipt_long_outlined,
            text: 'لا توجد عمليات تحصيل مسجلة بعد',
          )
        else
          RecentPaymentsCard(
            payments: recentPayments,
            customers: customerMap.values.toList(),
            installments: installments,
          ),
      ],
    );
  }

  Widget _buildTodaySection(
    BuildContext context,
    List<InstallmentModel> installments,
    Map<String, CustomerModel> customerMap, {
    bool showHeader = true,
  }) {
    return _buildInstallmentSection(
      title: 'مستحق اليوم',
      subtitle: installments.isEmpty
          ? 'لا توجد أقساط مستحقة'
          : 'أقساط تحتاج إلى تحصيل اليوم',
      icon: Icons.today_outlined,
      emptyIcon: Icons.check_circle_outline,
      emptyText: 'ممتاز! لا توجد أقساط مستحقة اليوم',
      installments: installments,
      customerMap: customerMap,
      isOverdue: false,
      showHeader: showHeader,
    );
  }

  Widget _buildOverdueSection(
    BuildContext context,
    List<InstallmentModel> installments,
    Map<String, CustomerModel> customerMap, {
    bool showHeader = true,
  }) {
    return _buildInstallmentSection(
      title: 'متأخر',
      subtitle: installments.isEmpty
          ? 'لا توجد أقساط متأخرة'
          : 'أقساط تجاوزت موعد الاستحقاق',
      icon: Icons.warning_amber_rounded,
      emptyIcon: Icons.verified_outlined,
      emptyText: 'لا توجد أقساط متأخرة حاليًا',
      installments: installments,
      customerMap: customerMap,
      isOverdue: true,
      showHeader: showHeader,
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context,
    List<InstallmentModel> installments,
    Map<String, CustomerModel> customerMap,
  ) {
    return _buildInstallmentSection(
      title: 'الأقساط القادمة',
      subtitle: installments.isEmpty
          ? 'لا توجد أقساط قادمة'
          : 'استعد للتحصيل القادم',
      icon: Icons.event_available_outlined,
      emptyIcon: Icons.event_busy_outlined,
      emptyText: 'لا توجد أقساط قادمة',
      installments: installments,
      customerMap: customerMap,
      isOverdue: false,
    );
  }

  Widget _buildInstallmentSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required IconData emptyIcon,
    required String emptyText,
    required List<InstallmentModel> installments,
    required Map<String, CustomerModel> customerMap,
    required bool isOverdue,
    bool showHeader = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          PaymentSectionHeader(
            title: title,
            subtitle: subtitle,
            count: installments.length,
            icon: icon,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (installments.isEmpty)
          PaymentEmptyCard(icon: emptyIcon, text: emptyText)
        else
          ...installments.map(
            (installment) => InstallmentCard(
              installment: installment,
              customer: customerMap[installment.customerId],
              isOverdue: isOverdue,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required int amount,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$count قسط',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatAmount(amount)} FCFA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRemaining(InstallmentModel installment) {
    return installment.paidAmount < installment.dueAmount;
  }

  int _calculateRemaining(List<InstallmentModel> installments) {
    return installments.fold<int>(
      0,
      (sum, installment) => sum + _remainingAmount(installment),
    );
  }

  int _calculatePaymentsTotal(List<PaymentModel> payments) {
    return payments.fold<int>(0, (sum, payment) => sum + payment.amount);
  }

  int _remainingAmount(InstallmentModel installment) {
    final remaining = installment.dueAmount - installment.paidAmount;
    return remaining > 0 ? remaining : 0;
  }

  int _totalByMethod(List<PaymentModel> payments, String method) {
    return payments
        .where((payment) => payment.paymentMethod == method)
        .fold<int>(0, (sum, payment) => sum + payment.amount);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatAmount(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
