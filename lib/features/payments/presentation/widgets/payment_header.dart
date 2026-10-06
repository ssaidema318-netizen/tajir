import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class PaymentHeader extends StatelessWidget {
  final int todayCollected;
  final int todayDueAmount;

  const PaymentHeader({
    super.key,
    required this.todayCollected,
    required this.todayDueAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متابعة التحصيل',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        Text(
          'تابع الأقساط والمدفوعات بسهولة',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.onPrimary,
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
                      'تحصيل اليوم',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      _formatAmount(todayCollected),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 42,
                color: theme
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.2),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    'متبقي اليوم',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    _formatAmount(todayDueAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
}
