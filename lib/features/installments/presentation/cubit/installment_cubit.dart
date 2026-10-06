import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/installment_notification_service.dart';
import '../../../../core/utils/id_generator.dart';

import '../../data/models/installment_plan_model.dart';
import '../../data/models/installment_model.dart';
import '../../data/repositories/installment_repository_impl.dart';

import 'installment_state.dart';

class InstallmentCubit extends Cubit<InstallmentState> {
  final InstallmentRepositoryImpl repository;
  final InstallmentNotificationService installmentNotificationService;

  InstallmentCubit({
    required this.repository,
    required this.installmentNotificationService,
  }) : super(InstallmentInitial());

  // =========================
  // Load
  // =========================

  void loadInstallments() {
    try {
      emit(InstallmentLoading());

      final plans = repository.getPlans();
      final installments = repository.getInstallments();

      emit(
        InstallmentLoaded(
          plans: plans,
          installments: installments,
        ),
      );
    } catch (e) {
      emit(
        InstallmentError(e.toString()),
      );
    }
  }

  // =========================
  // Create Plan
  // =========================

  Future<void> createPlan({
    required String customerId,
    required String saleId,
    required String frequency,
    required int totalAmount,
    required List<int> amounts,
    required List<DateTime> dueDates,
  }) async {
    try {
      // -------------------------
      // Basic validation
      // -------------------------

      if (customerId.isEmpty) {
        emit(
          const InstallmentError(
            'العميل غير موجود',
          ),
        );
        return;
      }

      if (saleId.isEmpty) {
        emit(
          const InstallmentError(
            'عملية البيع غير موجودة',
          ),
        );
        return;
      }

      if (totalAmount <= 0) {
        emit(
          const InstallmentError(
            'المبلغ المتبقي غير صحيح',
          ),
        );
        return;
      }

      if (amounts.isEmpty) {
        emit(
          const InstallmentError(
            'يجب إضافة قسط واحد على الأقل',
          ),
        );
        return;
      }

      if (amounts.length != dueDates.length) {
        emit(
          const InstallmentError(
            'عدد الأقساط لا يطابق عدد المواعيد',
          ),
        );
        return;
      }

      // -------------------------
      // Validate amounts
      // -------------------------

      for (final amount in amounts) {
        if (amount <= 0) {
          emit(
            const InstallmentError(
              'قيمة القسط يجب أن تكون أكبر من صفر',
            ),
          );
          return;
        }
      }

      // -------------------------
      // Check total
      // -------------------------

      final installmentsTotal = amounts.fold<int>(
        0,
        (sum, amount) => sum + amount,
      );

      if (installmentsTotal != totalAmount) {
        emit(
          InstallmentError(
            'مجموع الأقساط ($installmentsTotal) '
            'لا يساوي المبلغ المتبقي ($totalAmount)',
          ),
        );
        return;
      }

      emit(InstallmentLoading());

      // -------------------------
      // Create Plan
      // -------------------------

      final planId = IdGenerator.generate();

      final plan = InstallmentPlanModel(
        id: planId,
        customerId: customerId,
        saleId: saleId,
        frequency: frequency,
        totalAmount: totalAmount,
        numberOfInstallments: amounts.length,
        createdAt: DateTime.now(),
      );

      await repository.addPlan(plan);

      // -------------------------
      // Create Installments
      // -------------------------

      for (int i = 0; i < amounts.length; i++) {
        final installment = InstallmentModel(
          id: IdGenerator.generate(),
          planId: planId,
          customerId: customerId,
          saleId: saleId,
          installmentNumber: i + 1,
          dueAmount: amounts[i],
          paidAmount: 0,
          dueDate: dueDates[i],
          status: 'pending',
        );

        // Save installment
        await repository.addInstallment(installment);

        // Schedule notification
        await installmentNotificationService
            .scheduleInstallmentNotification(installment);
      }

      emit(InstallmentSuccess());

      loadInstallments();
    } catch (e) {
      emit(
        InstallmentError(
          e.toString(),
        ),
      );
    }
  }
}
