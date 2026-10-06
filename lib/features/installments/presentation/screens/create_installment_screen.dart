import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class CreateInstallmentScreen extends StatefulWidget {
  final String customerId;
  final String saleId;
  final int totalAmount;

  const CreateInstallmentScreen({
    super.key,
    required this.customerId,
    required this.saleId,
    required this.totalAmount,
  });

  @override
  State<CreateInstallmentScreen> createState() =>
      _CreateInstallmentScreenState();
}

class _CreateInstallmentScreenState
    extends State<CreateInstallmentScreen> {
  String frequency = 'weekly';

  final List<_InstallmentInput> installments = [];

  @override
  void initState() {
    super.initState();

    // نبدأ بقسطين بشكل افتراضي
    _addInstallment();
    _addInstallment();
  }

  void _addInstallment() {
    setState(() {
      installments.add(
        _InstallmentInput(
          amountController: TextEditingController(),
          date: DateTime.now().add(
            Duration(
              days: 7 * (installments.length + 1),
            ),
          ),
        ),
      );
    });
  }

  void _removeInstallment(int index) {
    if (installments.length <= 1) {
      return;
    }

    final installment = installments.removeAt(index);

    installment.dispose();

    setState(() {});
  }

  int get enteredTotal {
    return installments.fold(
      0,
      (sum, installment) {
        return sum +
            (int.tryParse(
                  installment.amountController.text,
                ) ??
                0);
      },
    );
  }

  int get remaining {
    return widget.totalAmount - enteredTotal;
  }

  Future<void> _selectDate(int index) async {
    final installment = installments[index];

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: installment.date.isBefore(DateTime.now())
          ? DateTime.now()
          : installment.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      installment.date = selectedDate;
    });
  }

  void _save() {
    FocusScope.of(context).unfocus();

    if (installments.isEmpty) {
      _showError('يجب إضافة قسط واحد على الأقل');
      return;
    }

    final amounts = <int>[];

    for (final installment in installments) {
      final amount = int.tryParse(
        installment.amountController.text.trim(),
      );

      if (amount == null || amount <= 0) {
        _showError(
          'تأكد من إدخال قيمة صحيحة لكل قسط',
        );
        return;
      }

      amounts.add(amount);
    }

    if (enteredTotal != widget.totalAmount) {
      _showError(
        'مجموع الأقساط ($enteredTotal) لا يساوي المبلغ المطلوب (${widget.totalAmount})',
      );
      return;
    }

    final dates = installments
        .map((installment) => installment.date)
        .toList();

    Navigator.pop(
      context,
      {
        'frequency': frequency,
        'amounts': amounts,
        'dates': dates,
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
  }

  @override
  void dispose() {
    for (final installment in installments) {
      installment.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة التقسيط'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        children: [
          _buildTotalCard(),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _buildFrequencySection(),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _buildInstallmentsSection(),

          const SizedBox(
            height: AppSpacing.xxl,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(
              Icons.check,
            ),
            label: const Text(
              'تأكيد خطة التقسيط',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    final remainingAmount = remaining;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          children: [
            const Text(
              'المبلغ المطلوب تقسيطه',
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              _formatAmount(widget.totalAmount),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي الأقساط'),
                Text(
                  _formatAmount(enteredTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('المتبقي للتوزيع'),
                Text(
                  _formatAmount(
                    remainingAmount < 0
                        ? 0
                        : remainingAmount,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingAmount == 0
                        ? Colors.green
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'دورية الأقساط',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            DropdownButtonFormField<String>(
              initialValue: frequency,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_month_outlined,
                ),
                labelText: 'الدورية',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text('أسبوعي'),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Text('شهري'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  frequency = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentsSection() {
    return Card(
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
                Expanded(
                  child: Text(
                    'الأقساط',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _addInstallment,
                  icon: const Icon(
                    Icons.add,
                  ),
                  tooltip: 'إضافة قسط',
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            ...installments.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final installment = entry.value;

                return _buildInstallmentCard(
                  index,
                  installment,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentCard(
    int index,
    _InstallmentInput installment,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'القسط ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (installments.length > 1)
                IconButton(
                  onPressed: () {
                    _removeInstallment(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          TextField(
            controller: installment.amountController,
            keyboardType:
                TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'قيمة القسط',
              prefixIcon: Icon(
                Icons.payments_outlined,
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          InkWell(
            onTap: () => _selectDate(index),
            borderRadius:
                BorderRadius.circular(12),
            child: InputDecorator(
              decoration:
                  const InputDecoration(
                labelText: 'موعد القسط',
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
              child: Text(
                '${installment.date.day}/'
                '${installment.date.month}/'
                '${installment.date.year}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallmentInput {
  final TextEditingController amountController;
  DateTime date;

  _InstallmentInput({
    required this.amountController,
    required this.date,
  });

  void dispose() {
    amountController.dispose();
  }
}