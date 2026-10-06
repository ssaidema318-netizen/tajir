import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tajir/features/customers/data/models/customer_model.dart';

import 'package:tajir/features/sales/models/sale_model.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';

import 'package:tajir/features/installments/data/models/installment_model.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';

import 'package:tajir/features/payments/data/models/payment_model.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';

part 'customer_details_state.dart';

class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  final SaleRepositoryImpl saleRepository;
  final InstallmentRepositoryImpl installmentRepository;
  final PaymentRepositoryImpl paymentRepository;

  CustomerDetailsCubit({
    required this.saleRepository,
    required this.installmentRepository,
    required this.paymentRepository,
  }) : super(CustomerDetailsInitial());

  void loadCustomer(CustomerModel customer) {
    try {
      emit(CustomerDetailsLoading());

      // -----------------------------
      // Load data
      // -----------------------------

      final sales =
          saleRepository.getSalesByCustomer(customer.id);

      final installments =
          installmentRepository.getInstallmentsByCustomer(
        customer.id,
      );

      final payments =
          paymentRepository.getPaymentsByCustomer(
        customer.id,
      );

      // -----------------------------
      // Total purchases
      // -----------------------------

      final totalPurchases = sales.fold<int>(
        0,
        (sum, sale) => sum + sale.totalAmount,
      );

      // -----------------------------
      // Total paid
      // -----------------------------
      //
      // PaymentModel يحتوي على:
      // 1. المقدم
      // 2. دفعات الأقساط
      //
      // لذلك لا نحسب SaleModel.downPayment
      // مرة أخرى حتى لا يحدث Double Counting.
      //

      final totalPaid = payments.fold<int>(
        0,
        (sum, payment) => sum + payment.amount,
      );

      // -----------------------------
      // Total remaining
      // -----------------------------
      //
      // المتبقي = إجمالي الأقساط غير المدفوعة
      // بعد خصم ما تم دفعه على كل قسط.
      //

      final totalRemaining = installments.fold<int>(
        0,
        (sum, installment) {
          final remaining =
              installment.dueAmount -
              installment.paidAmount;

          return sum +
              (remaining > 0 ? remaining : 0);
        },
      );

      // -----------------------------
      // Current date
      // -----------------------------

      final now = DateTime.now();

      // -----------------------------
      // Overdue installments
      // -----------------------------

      final overdueInstallments =
          installments.where((installment) {
        return installment.dueDate.isBefore(now) &&
            installment.status != 'paid';
      }).toList();

      // -----------------------------
      // Upcoming installments
      // -----------------------------

      final upcomingInstallments =
          installments.where((installment) {
        return !installment.dueDate.isBefore(now) &&
            installment.status != 'paid';
      }).toList();

      // -----------------------------
      // Emit loaded state
      // -----------------------------

      emit(
        CustomerDetailsLoaded(
          customer: customer,
          sales: sales,
          installments: installments,
          payments: payments,
          totalPurchases: totalPurchases,
          totalPaid: totalPaid,
          totalRemaining: totalRemaining,
          overdueInstallments: overdueInstallments,
          upcomingInstallments: upcomingInstallments,
        ),
      );
    } catch (e) {
      emit(
        CustomerDetailsError(
          e.toString(),
        ),
      );
    }
  }
}
