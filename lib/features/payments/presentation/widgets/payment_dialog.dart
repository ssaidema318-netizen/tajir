import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../installments/data/models/installment_model.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

Future<void> showPaymentDialog(
  BuildContext context,
  InstallmentModel installment,
) {
  return showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<PaymentCubit>(),
        child: PaymentDialog(
          installment: installment,
        ),
      );
    },
  );
}

class PaymentDialog extends StatefulWidget {
  final InstallmentModel installment;

  const PaymentDialog({
    super.key,
    required this.installment,
  });

  @override
  State<PaymentDialog> createState() =>
      _PaymentDialogState();
}

class _PaymentDialogState
    extends State<PaymentDialog> {
  late final TextEditingController amountController;

  String paymentMethod = 'cash';

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final remaining =
        widget.installment.dueAmount -
        widget.installment.paidAmount;

    amountController = TextEditingController(
      text: remaining.toString(),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isSaving) return;

    final amount = int.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل مبلغًا صحيحًا'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final success =
        await context.read<PaymentCubit>().addPayment(
              installment: widget.installment,
              amount: amount,
              paymentMethod: paymentMethod,
            );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Text(
          'تحصيل دفعة',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              enabled: !isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(
                  Icons.payments_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            DropdownButtonFormField<String>(
              initialValue: paymentMethod,
              decoration: const InputDecoration(
                labelText: 'طريقة الدفع',
                prefixIcon: Icon(
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('Cash'),
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
              onChanged: isSaving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        paymentMethod = value;
                      });
                    },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isSaving
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text('إلغاء'),
          ),

          FilledButton(
            onPressed: isSaving ? null : _submit,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'تأكيد التحصيل',
                  ),
          ),
        ],
      ),
    );
  }
}