import 'package:hive/hive.dart';

import '../models/installment_plan_model.dart';
import '../models/installment_model.dart';

class InstallmentLocalDataSource {
  final Box<InstallmentPlanModel> plansBox;
  final Box<InstallmentModel> installmentsBox;

  InstallmentLocalDataSource({
    required this.plansBox,
    required this.installmentsBox,
  });

  // =========================
  // Installment Plans
  // =========================

  Future<void> addPlan(InstallmentPlanModel plan) async {
    await plansBox.put(plan.id, plan);
  }

  InstallmentPlanModel? getPlan(String id) {
    return plansBox.get(id);
  }

  List<InstallmentPlanModel> getPlans() {
    return plansBox.values.toList();
  }

  Future<void> deletePlan(String id) async {
    await plansBox.delete(id);
  }

  // =========================
  // Installments
  // =========================

  Future<void> addInstallment(
    InstallmentModel installment,
  ) async {
    await installmentsBox.put(
      installment.id,
      installment,
    );
  }

  InstallmentModel? getInstallment(String id) {
    return installmentsBox.get(id);
  }

  List<InstallmentModel> getInstallments() {
    return installmentsBox.values.toList();
  }

  List<InstallmentModel> getInstallmentsByPlan(
    String planId,
  ) {
    return installmentsBox.values
        .where((installment) => installment.planId == planId)
        .toList();
  }

  List<InstallmentModel> getInstallmentsByCustomer(
    String customerId,
  ) {
    return installmentsBox.values
        .where(
          (installment) =>
              installment.customerId == customerId,
        )
        .toList();
  }

  List<InstallmentModel> getInstallmentsBySale(
    String saleId,
  ) {
    return installmentsBox.values
        .where(
          (installment) => installment.saleId == saleId,
        )
        .toList();
  }

  Future<void> updateInstallment(
    InstallmentModel installment,
  ) async {
    await installmentsBox.put(
      installment.id,
      installment,
    );
  }

  Future<void> deleteInstallment(String id) async {
    await installmentsBox.delete(id);
  }
}