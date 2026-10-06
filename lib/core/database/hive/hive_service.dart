import 'package:hive_flutter/adapters.dart';
import 'package:tajir/core/constants/app_constants.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';
import 'package:tajir/features/installments/data/models/installment_model.dart';
import 'package:tajir/features/installments/data/models/installment_plan_model.dart';
import 'package:tajir/features/payments/data/models/payment_model.dart';
import 'package:tajir/features/sales/models/sale_item_model.dart';
import 'package:tajir/features/sales/models/sale_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CustomerModelAdapter());

    Hive.registerAdapter(SaleItemModelAdapter());
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(InstallmentPlanModelAdapter());
    Hive.registerAdapter(InstallmentModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    await Hive.openBox<CustomerModel>(AppConstants.customersBox);

    await Hive.openBox<SaleModel>(AppConstants.salesBox);
    await Hive.openBox<InstallmentPlanModel>(AppConstants.installmentPlansBox);
    await Hive.openBox<PaymentModel>(AppConstants.paymentsBox);
    await Hive.openBox<InstallmentModel>(AppConstants.installmentsBox);
  }

  static Box<CustomerModel> get customersBox =>
      Hive.box<CustomerModel>(AppConstants.customersBox);
  static Box<SaleModel> get salesBox =>
      Hive.box<SaleModel>(AppConstants.salesBox);
  static Box<InstallmentPlanModel> get installmentPlansBox =>
      Hive.box<InstallmentPlanModel>(AppConstants.installmentPlansBox);

  static Box<InstallmentModel> get installmentsBox =>
      Hive.box<InstallmentModel>(AppConstants.installmentsBox);
  static Box<PaymentModel> get paymentsBox =>
      Hive.box<PaymentModel>(AppConstants.paymentsBox);
}
