import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class DashboardSummary extends StatelessWidget {
  final int todayCollected;
  final int weekCollected;
  final int monthCollected;
  final int todayInstallmentsCount;
  final int overdueInstallmentsCount;
  final int overdueAmount;

  final VoidCallback? onTodayInstallments;
  final VoidCallback? onOverdueInstallments;

  const DashboardSummary({
    super.key,
    required this.todayCollected,
    required this.weekCollected,
    required this.monthCollected,
    required this.todayInstallmentsCount,
    required this.overdueInstallmentsCount,
    required this.overdueAmount,
    this.onTodayInstallments,
    this.onOverdueInstallments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainCollectionCard(
          amount: todayCollected,
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Row(
          children: [
            Expanded(
              child: _SmallSummaryCard(
                icon: Icons.calendar_view_week_rounded,
                title: 'هذا الأسبوع',
                amount: weekCollected,
              ),
            ),
            const SizedBox(
              width: AppSpacing.md,
            ),
            Expanded(
              child: _SmallSummaryCard(
                icon: Icons.calendar_month_rounded,
                title: 'هذا الشهر',
                amount: monthCollected,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Row(
          children: [
            Expanded(
              child: _ActionSummaryCard(
                icon: Icons.today_rounded,
                title: 'أقساط اليوم',
                value:
                    '$todayInstallmentsCount قسط',
                color: AppColors.warning,
                onTap: onTodayInstallments,
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: _ActionSummaryCard(
                icon: Icons.warning_amber_rounded,
                title: 'الأقساط المتأخرة',
                value:
                    '$overdueInstallmentsCount قسط',
                subtitle:
                    '${_formatAmount(overdueAmount)} FCFA',
                color: AppColors.error,
                onTap: onOverdueInstallments,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MainCollectionCard extends StatelessWidget {
  final int amount;

  const _MainCollectionCard({
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.20,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              const Text(
                'تحصيل اليوم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Text(
            '${_formatAmount(amount)} FCFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'إجمالي المبالغ المحصلة اليوم',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.75,
              ),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;

  const _SmallSummaryCard({
    required this.icon,
    required this.title,
    required this.amount,
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.primary,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            '${_formatAmount(amount)} FCFA',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionSummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(
                alpha: 0.20,
              ),
            ),
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
                      color: color.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 21,
                    ),
                  ),

                  const Spacer(),

                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color:
                          AppColors.textSecondary,
                    ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(
                  height: 3,
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final position = text.length - i;

    buffer.write(text[i]);

    if (position > 1 &&
        position % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}
