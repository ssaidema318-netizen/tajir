import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:tajir/core/constants/app_constants.dart';
import 'package:tajir/core/services/map_service.dart';
import 'package:tajir/core/theme/app_colors.dart';
import 'package:tajir/core/theme/app_spacing.dart';

import 'package:tajir/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';
import 'package:tajir/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_details_cubit.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_location_cubit.dart';
import 'package:tajir/features/customers/presentation/widgets/customer_header.dart';

import 'package:tajir/features/installments/data/models/installment_model.dart';
import 'package:tajir/features/payments/data/models/payment_model.dart';
import 'package:tajir/features/payments/presentation/widgets/payment_dialog.dart';
import 'package:tajir/features/sales/models/sale_model.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final customersBox = Hive.box<CustomerModel>(
      AppConstants.customersBox,
    );

    final customerLocalDataSource = CustomerLocalDataSource(
      customersBox: customersBox,
    );

    final customerRepository = CustomerRepositoryImpl(
      localDataSource: customerLocalDataSource,
    );

    return BlocProvider<CustomerLocationCubit>(
      create: (_) {
        return CustomerLocationCubit(
          customerRepository: customerRepository,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تفاصيل العميل'),
          centerTitle: false,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          actions: [
    IconButton(
      tooltip: 'حذف العميل',
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
      onPressed: () {
        _showDeleteCustomerDialog(context, customer);
      },
    ),
  ],
        ),
        body: SafeArea(
          child: BlocListener<
              CustomerLocationCubit,
              CustomerLocationState>(
            listener: (context, locationState) {
              if (locationState is CustomerLocationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم حفظ موقع العميل بنجاح',
                    ),
                  ),
                );

                context
                    .read<CustomerDetailsCubit>()
                    .loadCustomer(customer);
              }

              if (locationState is CustomerLocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      locationState.message,
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<
                CustomerDetailsCubit,
                CustomerDetailsState>(
              builder: (context, state) {
                if (state is CustomerDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is CustomerDetailsError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () {
                      context
                          .read<CustomerDetailsCubit>()
                          .loadCustomer(customer);
                    },
                  );
                }

                if (state is CustomerDetailsLoaded) {
                  return _CustomerDetailsContent(
                    state: state,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerDetailsContent extends StatelessWidget {
  final CustomerDetailsLoaded state;

  const _CustomerDetailsContent({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        CustomerHeader(
          customer: state.customer,
          onCall: () {
            // هنربط الاتصال لاحقًا.
          },
          onLocation: () {
            context
                .read<CustomerLocationCubit>()
                .getAndSaveLocation(
                  state.customer.id,
                );
          },
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        // =========================
        // موقع العميل
        // =========================
        _CustomerLocationCard(
          customer: state.customer,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        // =========================
        // الملخص المالي
        // =========================
        const _SectionTitle(
          icon: Icons.account_balance_wallet_outlined,
          title: 'الملخص المالي',
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        _FinancialSummaryCard(
          totalPurchases: state.totalPurchases,
          totalPaid: state.totalPaid,
          totalRemaining: state.totalRemaining,
        ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        // =========================
        // عمليات الشراء
        // =========================
        _SectionTitle(
          icon: Icons.receipt_long_outlined,
          title: 'عمليات الشراء',
          trailing: '${state.sales.length} عملية',
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        if (state.sales.isEmpty)
          const _EmptySectionCard(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد عمليات شراء',
            subtitle: 'ستظهر عمليات البيع الخاصة بالعميل هنا',
          )
        else
          ...state.sales.map(
            (sale) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: _SaleCard(
                sale: sale,
              ),
            ),
          ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        // =========================
        // الأقساط
        // =========================
        _SectionTitle(
          icon: Icons.event_note_outlined,
          title: 'الأقساط',
          trailing: '${state.installments.length} قسط',
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        if (state.installments.isEmpty)
          const _EmptySectionCard(
            icon: Icons.event_note_outlined,
            title: 'لا توجد أقساط',
            subtitle: 'ستظهر خطة الأقساط الخاصة بالعميل هنا',
          )
        else
          ...state.installments.map(
            (installment) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: _InstallmentCard(
                installment: installment,
                customer: state.customer,
              ),
            ),
          ),

        const SizedBox(
          height: AppSpacing.lg,
        ),

        // =========================
        // سجل المدفوعات
        // =========================
        _SectionTitle(
          icon: Icons.payments_outlined,
          title: 'سجل المدفوعات',
          trailing: '${state.payments.length} دفعة',
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        if (state.payments.isEmpty)
          const _EmptySectionCard(
            icon: Icons.payments_outlined,
            title: 'لا توجد مدفوعات',
            subtitle: 'ستظهر جميع دفعات العميل هنا',
          )
        else
          ...state.payments.reversed.map(
            (payment) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: _PaymentCard(
                payment: payment,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// موقع العميل
// ============================================================

class _CustomerLocationCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerLocationCard({
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        customer.latitude != null &&
        customer.longitude != null;

    final hasAddress =
        customer.address != null &&
        customer.address!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موقع العميل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'عنوان وإحداثيات العميل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          // العنوان النصي
          if (hasAddress) ...[
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.home_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Text(
                    customer.address!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
          ],

          // حالة الموقع
          if (hasLocation) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإحداثيات',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Latitude: ${customer.latitude!.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Longitude: ${customer.longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            // فتح الخرائط
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await MapService.openLocation(
                      latitude: customer.latitude!,
                      longitude: customer.longitude!,
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.map_outlined,
                ),
                label: const Text(
                  'فتح الموقع على الخريطة',
                ),
              ),
            ),
          ] else ...[
            // لا يوجد موقع
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(
                  alpha: 0.06,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    color: AppColors.warning,
                  ),
                  SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Expanded(
                    child: Text(
                      'لم يتم حفظ موقع العميل حتى الآن',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(
            height: AppSpacing.md,
          ),

          // زر حفظ / تحديث الموقع
          BlocBuilder<
              CustomerLocationCubit,
              CustomerLocationState>(
            builder: (context, locationState) {
              final isLoading =
                  locationState
                      is CustomerLocationLoading;

              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          context
                              .read<CustomerLocationCubit>()
                              .getAndSaveLocation(
                                customer.id,
                              );
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                        ),
                  label: Text(
                    isLoading
                        ? 'جاري تحديد الموقع...'
                        : hasLocation
                            ? 'تحديث موقع العميل'
                            : 'حفظ موقع العميل',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// عنوان القسم
// ============================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 19,
          ),
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ============================================================
// الملخص المالي
// ============================================================

class _FinancialSummaryCard extends StatelessWidget {
  final int totalPurchases;
  final int totalPaid;
  final int totalRemaining;

  const _FinancialSummaryCard({
    required this.totalPurchases,
    required this.totalPaid,
    required this.totalRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FinancialItem(
              icon: Icons.shopping_bag_outlined,
              title: 'المشتريات',
              value: _formatMoney(
                totalPurchases,
              ),
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _FinancialItem(
              icon: Icons.payments_outlined,
              title: 'المدفوع',
              value: _formatMoney(
                totalPaid,
              ),
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _FinancialItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'المتبقي',
              value: _formatMoney(
                totalRemaining,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _FinancialItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 58,
      color: AppColors.border,
    );
  }
}

// ============================================================
// عمليات الشراء
// ============================================================

class _SaleCard extends StatelessWidget {
  final SaleModel sale;

  const _SaleCard({
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'عملية ${sale.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${sale.items.length} منتج • ${_formatDate(sale.saleDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Text(
            _formatMoney(
              sale.totalAmount,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// الأقساط
// ============================================================

class _InstallmentCard extends StatelessWidget {
  final InstallmentModel installment;
  final CustomerModel customer;

  const _InstallmentCard({
    required this.installment,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        installment.dueAmount -
        installment.paidAmount;

    final isPaid =
        installment.status == 'paid' ||
        remaining <= 0;

    final isOverdue =
        installment.dueDate.isBefore(
          DateTime.now(),
        ) &&
        !isPaid;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withValues(
                  alpha: 0.25,
                )
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withValues(
                          alpha: 0.08,
                        )
                      : isOverdue
                          ? AppColors.error.withValues(
                              alpha: 0.08,
                            )
                          : AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_outline
                      : isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.event_note_outlined,
                  color: isPaid
                      ? AppColors.success
                      : isOverdue
                          ? AppColors.error
                          : AppColors.primary,
                ),
              ),
              const SizedBox(
                width: AppSpacing.md,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القسط رقم ${installment.installmentNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'الاستحقاق: ${_formatDate(installment.dueDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                text: isPaid
                    ? 'مسدد'
                    : isOverdue
                        ? 'متأخر'
                        : 'قادم',
                color: isPaid
                    ? AppColors.success
                    : isOverdue
                        ? AppColors.error
                        : AppColors.primary,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              Expanded(
                child: _SmallMoneyItem(
                  title: 'المطلوب',
                  value: _formatMoney(
                    installment.dueAmount,
                  ),
                ),
              ),
              Expanded(
                child: _SmallMoneyItem(
                  title: 'المدفوع',
                  value: _formatMoney(
                    installment.paidAmount,
                  ),
                ),
              ),
              Expanded(
                child: _SmallMoneyItem(
                  title: 'المتبقي',
                  value: _formatMoney(
                    remaining > 0
                        ? remaining
                        : 0,
                  ),
                ),
              ),
            ],
          ),

          if (!isPaid) ...[
            const SizedBox(
              height: AppSpacing.md,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await showPaymentDialog(
                    context,
                    installment,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  context
                      .read<CustomerDetailsCubit>()
                      .loadCustomer(customer);
                },
                icon: const Icon(
                  Icons.payments_outlined,
                ),
                label: const Text(
                  'تحصيل دفعة',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallMoneyItem extends StatelessWidget {
  final String title;
  final String value;

  const _SmallMoneyItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// المدفوعات
// ============================================================

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentCard({
    required this.payment,
  });

  String _paymentMethodName(
    String method,
  ) {
    switch (method) {
      case 'cash':
        return 'كاش';

      case 'orange_money':
        return 'Orange Money';

      case 'mtn_momo':
        return 'MTN MoMo';

      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColors.success,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _paymentMethodName(
                    payment.paymentMethod,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  _formatDateTime(
                    payment.paidAt,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(
              payment.amount,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================

class _EmptySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptySectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Error
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            const Text(
              'حدث خطأ أثناء تحميل بيانات العميل',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            FilledButton(
              onPressed: onRetry,
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Helpers
// ============================================================

String _formatMoney(int amount) {
  return '$amount FCFA';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} - '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
Future<void> _showDeleteCustomerDialog(
  BuildContext context,
  CustomerModel customer,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text('حذف العميل'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا العميل؟\n\n'
          'سيتم حذف جميع البيانات المرتبطة به نهائيًا، '
          'بما في ذلك المبيعات والأقساط والمدفوعات، '
          'ولا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('حذف نهائيًا'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  await _deleteCustomer(context, customer);
}
Future<void> _deleteCustomer(
  BuildContext context,
  CustomerModel customer,
) async {
  final success = await context.read<CustomerCubit>().deleteCustomer(
        customer.id,
      );

  if (!context.mounted) {
    return;
  }

  if (success) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف العميل وجميع بياناته بنجاح'),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر حذف العميل'),
      ),
    );
  }
}