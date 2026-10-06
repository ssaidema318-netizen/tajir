import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../../customers/data/models/customer_model.dart';
import '../../../installments/data/models/installment_model.dart';
import '../../data/models/payment_model.dart';

class RecentPaymentsCard extends StatelessWidget {
  final List<PaymentModel> payments;
  final List<CustomerModel> customers;
  final List<InstallmentModel> installments;

  const RecentPaymentsCard({
    super.key,
    required this.payments,
    required this.customers,
    required this.installments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          for (int i = 0;
              i < payments.length;
              i++) ...[
            _RecentPaymentTile(
              payment: payments[i],
              customer: _findCustomer(
                customers,
                payments[i].customerId,
              ),
              installment: _findInstallment(
                installments,
                payments[i].installmentId,
              ),
            ),

            if (i != payments.length - 1)
              const Divider(
                height: 1,
              ),
          ],
        ],
      ),
    );
  }

  CustomerModel? _findCustomer(
    List<CustomerModel> customers,
    String id,
  ) {
    for (final customer in customers) {
      if (customer.id == id) {
        return customer;
      }
    }

    return null;
  }

  InstallmentModel? _findInstallment(
    List<InstallmentModel> installments,
    String? id,
  ) {
    if (id == null) {
      return null;
    }

    for (final installment in installments) {
      if (installment.id == id) {
        return installment;
      }
    }

    return null;
  }
}

class _RecentPaymentTile extends StatelessWidget {
  final PaymentModel payment;
  final CustomerModel? customer;
  final InstallmentModel? installment;

  const _RecentPaymentTile({
    required this.payment,
    required this.customer,
    required this.installment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primaryContainer,
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              _paymentIcon(
                payment.paymentMethod,
              ),
              color: theme
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.name ??
                      'عميل غير معروف',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _paymentMethodName(
                    payment.paymentMethod,
                  ),
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  'القسط #${installment?.installmentNumber ?? '-'} • ${_formatDateTime(payment.paidAt)}',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '+${_formatAmount(payment.amount)}',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                'تم التحصيل',
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'orange_money':
        return Icons.phone_android_outlined;

      case 'mtn_momo':
        return Icons
            .account_balance_wallet_outlined;

      case 'cash':
      default:
        return Icons.payments_outlined;
    }
  }

  String _paymentMethodName(String method) {
    switch (method) {
      case 'orange_money':
        return 'Orange Money';

      case 'mtn_momo':
        return 'MTN MoMo';

      case 'cash':
      default:
        return 'Cash';
    }
  }

  String _formatDateTime(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $hour:$minute';
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
}