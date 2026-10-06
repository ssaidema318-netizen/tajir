import 'package:flutter/material.dart';
import 'package:tajir/core/theme/app_colors.dart';

class DashboardPaymentMethods extends StatelessWidget {
  final int cashCollected;
  final int orangeMoneyCollected;
  final int mtnMomoCollected;

  const DashboardPaymentMethods({
    super.key,
    required this.cashCollected,
    required this.orangeMoneyCollected,
    required this.mtnMomoCollected,
  });

  // String _formatAmount(int amount) {
  //   return '$amount FCFA';
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحصيل حسب طريقة الدفع',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Column(
            children: [
              _PaymentMethodRow(
                icon: Icons.money_rounded,
                title: 'نقدي',
                amount: cashCollected,
              ),
              const Divider(height: 1),
              _PaymentMethodRow(
                icon: Icons.phone_android_rounded,
                title: 'Orange Money',
                amount: orangeMoneyCollected,
              ),
              const Divider(height: 1),
              _PaymentMethodRow(
                icon: Icons.account_balance_wallet_rounded,
                title: 'MTN MoMo',
                amount: mtnMomoCollected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;

  const _PaymentMethodRow({
    required this.icon,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
      title: Text(title),
      trailing: Text(
        '$amount FCFA',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
