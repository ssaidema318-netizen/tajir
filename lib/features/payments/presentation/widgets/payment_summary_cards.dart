import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class PaymentSummaryCards extends StatelessWidget {
  final int todayDueAmount;
  final int overdueAmount;
  final int todayCollected;

  const PaymentSummaryCards({
    super.key,
    required this.todayDueAmount,
    required this.overdueAmount,
    required this.todayCollected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryCard(
          title: 'مستحق اليوم',
          amount: todayDueAmount,
          icon: Icons.today_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryCard(
          title: 'متأخر',
          amount: overdueAmount,
          icon: Icons.warning_amber_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryCard(
          title: 'تم تحصيله اليوم',
          amount: todayCollected,
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(
              width: AppSpacing.md,
            ),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
            ),
            Text(
              _formatAmount(amount),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
  }
}