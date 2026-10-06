// lib/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import '../database/hive/hive_service.dart';

import '../../features/customers/data/datasources/customer_local_data_source.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/usecases/delete_customer_cascade_usecase.dart';

import '../../features/sales/datasources/sale_local_data_source.dart';
import '../../features/sales/models/sale_model.dart';
import '../../features/sales/repositories/sale_repository_impl.dart';

import '../../features/installments/data/datasources/installment_local_data_source.dart';
import '../../features/installments/data/models/installment_model.dart';
import '../../features/installments/data/models/installment_plan_model.dart';
import '../../features/installments/data/repositories/installment_repository_impl.dart';

import '../../features/payments/data/datasources/payment_local_data_source.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';

final getIt = GetIt.instance;

/// لازم تتنادى بعد ما كل الـ Hive boxes تتفتح، وقبل runApp()
void setupServiceLocator() {
  // ===== Data Sources =====
  getIt.registerLazySingleton(
    () => CustomerLocalDataSource(
      customersBox: Hive.box<CustomerModel>(AppConstants.customersBox),
    ),
  );
  getIt.registerLazySingleton(
    () => SaleLocalDataSource(Hive.box<SaleModel>(AppConstants.salesBox)),
  );
  getIt.registerLazySingleton(
    () => InstallmentLocalDataSource(
      plansBox: Hive.box<InstallmentPlanModel>(AppConstants.installmentPlansBox),
      installmentsBox: Hive.box<InstallmentModel>(AppConstants.installmentsBox),
    ),
  );
  getIt.registerLazySingleton(
    () => PaymentLocalDataSource(HiveService.paymentsBox),
  );

  // ===== Repositories =====
  getIt.registerLazySingleton(
    () => CustomerRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => SaleRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => InstallmentRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => PaymentRepositoryImpl(getIt()));

  // ===== Use Cases =====
  getIt.registerLazySingleton(
    () => DeleteCustomerCascadeUseCase(
      customerRepository: getIt(),
      saleRepository: getIt(),
      installmentRepository: getIt(),
      paymentRepository: getIt(),
    ),
  );
}