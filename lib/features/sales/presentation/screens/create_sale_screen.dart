import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../installments/presentation/screens/create_installment_screen.dart';
import '../../widgets/sale_customer_section.dart';
import '../../widgets/sale_items_section.dart';
import '../../widgets/sale_summary_section.dart';
import '../cubit/create_sale_cubit.dart';
import '../cubit/create_sale_state.dart';

class CreateSaleScreen extends StatefulWidget {
  final VoidCallback? onSaleSaved;

  const CreateSaleScreen({
    super.key,
    this.onSaleSaved,
  });

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CreateSaleCubit>().initialize();
    });
  }

  Future<void> _saveSale() async {
    FocusScope.of(context).unfocus();

    final cubit = context.read<CreateSaleCubit>();
    final preparedSale = cubit.prepareSale();

    if (preparedSale == null) {
      return;
    }

    final sale = preparedSale.sale;

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => CreateInstallmentScreen(
            customerId: sale.customerId,
            saleId: sale.id,
            totalAmount: sale.financedAmount,
          ),
        ),
      );

      if (!mounted || result == null) {
        return;
      }

      final frequency = result['frequency'] as String?;
      final amounts = (result['amounts'] as List?)?.cast<int>();
      final dates = (result['dates'] as List?)?.cast<DateTime>();

      if (frequency == null || amounts == null || dates == null) {
        _showError('بيانات خطة التقسيط غير مكتملة');
        return;
      }

      await cubit.saveSaleWithInstallments(
        sale: sale,
        newCustomer: preparedSale.newCustomer,
        frequency: frequency,
        amounts: amounts,
        dueDates: dates,
      );
    } catch (e) {
      if (!mounted) return;

      _showError('حدث خطأ أثناء حفظ عملية البيع');
      debugPrint('CreateSaleScreen error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _showSuccess() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ عملية البيع وخطة التقسيط بنجاح',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عملية بيع جديدة'),
      ),
      body: BlocConsumer<CreateSaleCubit, CreateSaleState>(
        listener: _handleStateChange,
        builder: _buildBody,
      ),
      bottomNavigationBar: BlocBuilder<CreateSaleCubit, CreateSaleState>(
        builder: (context, state) {
          if (state is! CreateSaleLoaded &&
              state is! CreateSaleSaving) {
            return const SizedBox.shrink();
          }

          final isSaving = state is CreateSaleSaving;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FilledButton.icon(
                onPressed: isSaving ? null : _saveSale,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  isSaving
                      ? 'جاري الحفظ...'
                      : 'متابعة إلى التقسيط',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleStateChange(
    BuildContext context,
    CreateSaleState state,
  ) {
    if (state is CreateSaleSuccess) {
      _showSuccess();

      // تحديث Dashboard بعد نجاح عملية البيع.
      widget.onSaleSaved?.call();

      // تجهيز الشاشة لعملية بيع جديدة.
      context.read<CreateSaleCubit>().initialize();
      return;
    }

    if (state is CreateSaleError) {
      _showError(state.message);
    }
  }

  Widget _buildBody(
    BuildContext context,
    CreateSaleState state,
  ) {
    if (state is CreateSaleInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is CreateSaleSaving) {
      return Stack(
        children: [
          _buildContent(
            context,
            state.data,
          ),
          const ColoredBox(
            color: Colors.black12,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (state is CreateSaleLoaded) {
      return _buildContent(
        context,
        state,
      );
    }

    if (state is CreateSaleError) {
      return _buildErrorState(
        context,
        state.message,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                context.read<CreateSaleCubit>().initialize();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CreateSaleLoaded state,
  ) {
    final cubit = context.read<CreateSaleCubit>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SaleCustomerSection(
          state: state,
          cubit: cubit,
        ),
        const SizedBox(height: AppSpacing.md),
        SaleItemsSection(
          state: state,
          cubit: cubit,
        ),
        const SizedBox(height: AppSpacing.md),
        SaleSummarySection(
          state: state,
          cubit: cubit,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
