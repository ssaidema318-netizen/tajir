import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajir/features/payments/presentation/cubit/payment_cubit.dart';

import '../../../../core/theme/app_spacing.dart';

class PaymentSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;

  const PaymentSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme
                .colorScheme
                .primaryContainer,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
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
                title,
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 2,
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

        if (count > 0)
          Container(
            constraints:
                const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primary,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: theme
                    .colorScheme
                    .onPrimary,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class PaymentEmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const PaymentEmptyCard({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              text,
              textAlign: TextAlign.center,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentErrorView extends StatelessWidget {
  final String message;

  const PaymentErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: theme
                    .colorScheme
                    .onErrorContainer,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              'حدث خطأ',
              style: theme
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            FilledButton.icon(
              onPressed: () {
                context.read<PaymentCubit>().loadPayments();
              },
              icon: const Icon(
                Icons.refresh,
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
}
