import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../installments/data/models/installment_model.dart';
import 'payment_dialog.dart';

class InstallmentCard extends StatelessWidget {
  final InstallmentModel installment;
  final CustomerModel? customer;
  final bool isOverdue;

  const InstallmentCard({
    super.key,
    required this.installment,
    required this.customer,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        installment.dueAmount - installment.paidAmount;

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم العميل + حالة التأخير
            Row(
              children: [
                Expanded(
                  child: Text(
                    customer?.name ?? 'عميل غير معروف',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isOverdue)
                  const Chip(
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                    ),
                    label: Text('متأخر'),
                  ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            // رقم القسط
            Text(
              'القسط #${installment.installmentNumber}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            // تاريخ الاستحقاق
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Text(
                    'موعد الاستحقاق: ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Expanded(
                    child: Text(
                      _formatDate(installment.dueDate),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            // المبلغ المطلوب
            _AmountRow(
              title: 'المطلوب',
              amount: installment.dueAmount,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            // المبلغ المدفوع
            _AmountRow(
              title: 'المدفوع',
              amount: installment.paidAmount,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            // المتبقي
            _AmountRow(
              title: 'المتبقي',
              amount: remaining,
              isBold: true,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            // زر التحصيل
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: remaining > 0
                    ? () {
                        showPaymentDialog(
                          context,
                          installment,
                        );
                      }
                    : null,
                icon: const Icon(
                  Icons.payments_outlined,
                ),
                label: const Text(
                  'تحصيل دفعة',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _AmountRow extends StatelessWidget {
  final String title;
  final int amount;
  final bool isBold;

  const _AmountRow({
    required this.title,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(
            fontWeight: FontWeight.bold,
          )
        : null;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: style,
        ),
        Text(
          _formatAmount(amount),
          style: style,
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(
        r'(\d)(?=(\d{3})+(?!\d))',
      ),
      (match) =>
          '${match.group(1)},',
    );
  }
}