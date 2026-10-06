import '../datasources/installment_local_data_source.dart';
import '../models/installment_plan_model.dart';
import '../models/installment_model.dart';

class InstallmentRepositoryImpl {
  final InstallmentLocalDataSource localDataSource;

  InstallmentRepositoryImpl(this.localDataSource);

  // =========================
  // Installment Plans
  // =========================

  Future<void> addPlan(
    InstallmentPlanModel plan,
  ) {
    return localDataSource.addPlan(plan);
  }

  InstallmentPlanModel? getPlan(String id) {
    return localDataSource.getPlan(id);
  }

  List<InstallmentPlanModel> getPlans() {
    return localDataSource.getPlans();
  }

  Future<void> deletePlan(String id) {
    return localDataSource.deletePlan(id);
  }

  // =========================
  // Installments
  // =========================

  Future<void> addInstallment(
    InstallmentModel installment,
  ) {
    return localDataSource.addInstallment(
      installment,
    );
  }

  InstallmentModel? getInstallment(String id) {
    return localDataSource.getInstallment(id);
  }

  List<InstallmentModel> getInstallments() {
    return localDataSource.getInstallments();
  }

  List<InstallmentModel> getInstallmentsByPlan(
    String planId,
  ) {
    return localDataSource.getInstallmentsByPlan(
      planId,
    );
  }

  List<InstallmentModel> getInstallmentsByCustomer(
    String customerId,
  ) {
    return localDataSource.getInstallmentsByCustomer(
      customerId,
    );
  }

  List<InstallmentModel> getInstallmentsBySale(
    String saleId,
  ) {
    return localDataSource.getInstallmentsBySale(
      saleId,
    );
  }

  Future<void> updateInstallment(
    InstallmentModel installment,
  ) {
    return localDataSource.updateInstallment(
      installment,
    );
  }

  Future<void> deleteInstallment(String id) {
    return localDataSource.deleteInstallment(id);
  }
}