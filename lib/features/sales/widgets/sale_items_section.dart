import 'package:flutter/material.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_cubit.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_state.dart';

import '../../../../core/theme/app_spacing.dart';


class SaleItemsSection extends StatelessWidget {
  final CreateSaleLoaded state;
  final CreateSaleCubit cubit;

  const SaleItemsSection({
    super.key,
    required this.state,
    required this.cubit,
  });

  Future<void> _showAddItemDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return const _AddItemDialog();
      },
    );

    if (result == null) return;

    cubit.addItem(
      productName: result['name'] as String,
      quantity: result['quantity'] as int,
      unitPrice: result['price'] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الأصناف',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'إضافة بند',
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            if (state.selectedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: Text(
                    'لم تتم إضافة أي بنود بعد',
                  ),
                ),
              ),

            ...state.selectedItems.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final item = entry.value;

                return _SaleItemTile(
                  item: item,
                  onDelete: () => cubit.removeItem(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    quantityController = TextEditingController(text: '1');
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();

    super.dispose();
  }

  void _add() {
    final name = nameController.text.trim();

    final quantity = int.tryParse(
      quantityController.text.trim(),
    );

    final price = int.tryParse(
      priceController.text.trim(),
    );

    if (name.isEmpty) {
      _showError('اكتب اسم الحاجة');
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showError('أدخل كمية صحيحة');
      return;
    }

    if (price == null || price <= 0) {
      _showError('أدخل سعرًا صحيحًا');
      return;
    }

    Navigator.pop(
      context,
      {
        'name': name,
        'quantity': quantity,
        'price': price,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'إضافة بند',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'اسم الحاجة',
                prefixIcon: Icon(
                  Icons.shopping_bag_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                prefixIcon: Icon(
                  Icons.numbers,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(
                labelText: 'سعر الوحدة',
                prefixIcon: Icon(
                  Icons.payments_outlined,
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'إلغاء',
          ),
        ),

        FilledButton.icon(
          onPressed: _add,
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'إضافة',
          ),
        ),
      ],
    );
  }
}

class _SaleItemTile extends StatelessWidget {
  final CreateSaleItem item;
  final VoidCallback onDelete;

  const _SaleItemTile({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
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
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${item.quantity} × ${_formatAmount(item.unitPrice)}',
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'الإجمالي: ${_formatAmount(item.total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
            ),
            tooltip: 'حذف',
          ),
        ],
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