import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/installment_notification_service.dart';
import '../../../../core/utils/id_generator.dart';

import '../../../installments/data/models/installment_model.dart';
import '../../../installments/data/repositories/installment_repository_impl.dart';

import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository_impl.dart';

import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepositoryImpl paymentRepository;
  final InstallmentRepositoryImpl installmentRepository;
  final InstallmentNotificationService installmentNotificationService;

  PaymentCubit({
    required this.paymentRepository,
    required this.installmentRepository,
    required this.installmentNotificationService,
  }) : super(PaymentInitial());

  void loadPayments() {
    try {
      emit(PaymentLoading());

      final payments = paymentRepository.getPayments();

      emit(
        PaymentLoaded(
          payments: payments,
        ),
      );
    } catch (e) {
      emit(
        PaymentError(
          e.toString(),
        ),
      );
    }
  }

  Future<bool> addPayment({
    required InstallmentModel installment,
    required int amount,
    required String paymentMethod,
  }) async {
    try {
      if (amount <= 0) {
        emit(
          const PaymentError(
            'يجب إدخال مبلغ صحيح',
          ),
        );
        return false;
      }

      final remaining =
          installment.dueAmount - installment.paidAmount;

      if (remaining <= 0) {
        emit(
          const PaymentError(
            'هذا القسط تم سداده بالكامل',
          ),
        );
        return false;
      }

      if (amount > remaining) {
        emit(
          PaymentError(
            'المبلغ أكبر من المتبقي على القسط ($remaining)',
          ),
        );
        return false;
      }

      if (paymentMethod.isEmpty) {
        emit(
          const PaymentError(
            'يجب اختيار طريقة الدفع',
          ),
        );
        return false;
      }

      emit(PaymentLoading());

      // Create payment record.
      final payment = PaymentModel(
        id: IdGenerator.generate(),
        customerId: installment.customerId,
        saleId: installment.saleId,
        installmentId: installment.id,
        amount: amount,
        paymentMethod: paymentMethod,
        paidAt: DateTime.now(),
      );

      // Calculate new installment state.
      final newPaidAmount =
          installment.paidAmount + amount;

      final newStatus =
          newPaidAmount == installment.dueAmount
              ? 'paid'
              : 'partial';

      final updatedInstallment = InstallmentModel(
        id: installment.id,
        planId: installment.planId,
        customerId: installment.customerId,
        saleId: installment.saleId,
        installmentNumber: installment.installmentNumber,
        dueAmount: installment.dueAmount,
        paidAmount: newPaidAmount,
        dueDate: installment.dueDate,
        status: newStatus,
      );

      // Save payment first.
      await paymentRepository.addPayment(payment);

      // Update installment.
      await installmentRepository.updateInstallment(
        updatedInstallment,
      );

      // Synchronize its notification immediately.
      await installmentNotificationService
          .scheduleInstallmentNotification(
        updatedInstallment,
      );

      emit(
        PaymentSuccess(
          payment: payment,
          installment: updatedInstallment,
        ),
      );

      // Refresh payment list without returning to Loading.
      final payments = paymentRepository.getPayments();

      emit(
        PaymentLoaded(
          payments: payments,
        ),
      );

      return true;
    } catch (e) {
      emit(
        PaymentError(
          e.toString(),
        ),
      );

      return false;
    }
  }
}
