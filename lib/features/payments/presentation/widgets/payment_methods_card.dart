import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class PaymentMethodsCard extends StatelessWidget {
  final int cash;
  final int orangeMoney;
  final int mtnMomo;

  const PaymentMethodsCard({
    super.key,
    required this.cash,
    required this.orangeMoney,
    required this.mtnMomo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .secondaryContainer,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    color: theme
                        .colorScheme
                        .onSecondaryContainer,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طرق الدفع',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      'تحصيل اليوم',
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

            const SizedBox(
              height: AppSpacing.md,
            ),

            _PaymentMethodRow(
              icon: Icons.payments_outlined,
              title: 'Cash',
              subtitle: 'نقدي',
              amount: cash,
            ),

            const Divider(
              height: AppSpacing.lg,
            ),

            _PaymentMethodRow(
              icon: Icons.phone_android_outlined,
              title: 'Orange Money',
              subtitle: 'Orange Money',
              amount: orangeMoney,
            ),

            const Divider(
              height: AppSpacing.lg,
            ),

            _PaymentMethodRow(
              icon: Icons
                  .account_balance_wallet_outlined,
              title: 'MTN MoMo',
              subtitle: 'MTN Mobile Money',
              amount: mtnMomo,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int amount;

  const _PaymentMethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme
                .colorScheme
                .surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 21,
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
                title,
                style: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
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

        Text(
          _formatAmount(amount),
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w800,
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