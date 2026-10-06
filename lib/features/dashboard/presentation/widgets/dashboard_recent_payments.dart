
import 'package:flutter/material.dart';
import 'package:tajir/core/theme/app_colors.dart';
import 'package:tajir/features/payments/data/models/payment_model.dart';

class DashboardRecentPayments extends StatelessWidget {
  final List<PaymentModel> payments;
  final VoidCallback? onOpenPayments;

  const DashboardRecentPayments({
    super.key,
    required this.payments,
    this.onOpenPayments,
  });

  String _formatAmount(int amount) {
    return '$amount FCFA';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'آخر عمليات التحصيل',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: onOpenPayments,
              child: const Text('عرض الكل'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (payments.isEmpty)
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 42,
                      color:
                          AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد عمليات تحصيل بعد',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors
                                .textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (int i = 0;
                    i < payments.length;
                    i++) ...[
                  _PaymentRow(
                    payment: payments[i],
                    amount: _formatAmount(
                      payments[i].amount,
                    ),
                    method:
                        _paymentMethodLabel(
                      payments[i]
                          .paymentMethod,
                    ),
                    date: _formatDate(
                      payments[i].paidAt,
                    ),
                  ),
                  if (i !=
                      payments.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final PaymentModel payment;
  final String amount;
  final String method;
  final String date;

  const _PaymentRow({
    required this.payment,
    required this.amount,
    required this.method,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: CircleAvatar(
        backgroundColor:
            AppColors.success.withValues(
          alpha: 0.1,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
        ),
      ),
      title: Text(
        amount,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '$method • $date',
      ),
      trailing: const Icon(
        Icons.chevron_left_rounded,
      ),
    );
  }
}

