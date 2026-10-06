import 'package:flutter/material.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_cubit.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_state.dart';

import '../../../../core/theme/app_spacing.dart';

class SaleSummarySection extends StatefulWidget {
  final CreateSaleLoaded state;
  final CreateSaleCubit cubit;

  const SaleSummarySection({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<SaleSummarySection> createState() => _SaleSummarySectionState();
}

class _SaleSummarySectionState extends State<SaleSummarySection> {
  late final TextEditingController discountController;
  late final TextEditingController downPaymentController;

  @override
  void initState() {
    super.initState();

    discountController = TextEditingController(
      text: widget.state.discount == 0
          ? ''
          : widget.state.discount.toString(),
    );

    downPaymentController = TextEditingController(
      text: widget.state.downPayment == 0
          ? ''
          : widget.state.downPayment.toString(),
    );
  }

  @override
  void dispose() {
    discountController.dispose();
    downPaymentController.dispose();
    super.dispose();
  }

  void _updateDiscount(String value) {
    final amount = int.tryParse(value) ?? 0;
    widget.cubit.setDiscount(amount);
  }

  void _updateDownPayment(String value) {
    final amount = int.tryParse(value) ?? 0;
    widget.cubit.setDownPayment(amount);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص العملية',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: AppSpacing.md),

            _SummaryRow(
              title: 'المجموع',
              value: state.subtotal,
            ),

            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الخصم',
                prefixIcon: Icon(Icons.discount_outlined),
              ),
              onChanged: _updateDiscount,
            ),

            const SizedBox(height: AppSpacing.md),

            _SummaryRow(
              title: 'الإجمالي النهائي',
              value: state.totalAmount,
              isBold: true,
            ),

            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: downPaymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المقدم',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              onChanged: _updateDownPayment,
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: state.downPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'طريقة دفع المقدم',
                prefixIcon: Icon(
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('نقدي'),
                ),
                DropdownMenuItem(
                  value: 'orange_money',
                  child: Text('Orange Money'),
                ),
                DropdownMenuItem(
                  value: 'mtn_momo',
                  child: Text('MTN MoMo'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                widget.cubit.setDownPaymentMethod(value);
              },
            ),

            const SizedBox(height: AppSpacing.md),

            _SummaryRow(
              title: 'المتبقي',
              value: state.financedAmount,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final int value;
  final bool isBold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: style,
        ),
        Text(
          _formatAmount(value),
          style: style,
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
