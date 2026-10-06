import 'package:tajir/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';

import '../../../../core/services/installment_notification_service.dart';


class CustomerDeletionService {
  final CustomerRepositoryImpl customerRepository;
  final SaleRepositoryImpl saleRepository;
  final InstallmentRepositoryImpl installmentRepository;
  final PaymentRepositoryImpl paymentRepository;
  final InstallmentNotificationService installmentNotificationService;

  CustomerDeletionService({
    required this.customerRepository,
    required this.saleRepository,
    required this.installmentRepository,
    required this.paymentRepository,
    required this.installmentNotificationService,
  });

  Future<void> deleteCustomer(String customerId) async {
    // =========================
    // 1. التأكد أن العميل موجود
    // =========================

    final customer = customerRepository.getCustomer(customerId);

    if (customer == null) {
      throw Exception('العميل غير موجود');
    }

    // =========================
    // 2. الحصول على البيانات المرتبطة
    // =========================

    final installments =
        installmentRepository.getInstallmentsByCustomer(customerId);

    final payments =
        paymentRepository.getPaymentsByCustomer(customerId);

    final sales =
        saleRepository.getSalesByCustomer(customerId);

    final plans = installmentRepository
        .getPlans()
        .where((plan) => plan.customerId == customerId)
        .toList();

    // =========================
    // 3. إلغاء إشعارات الأقساط
    // =========================

    final installmentIds =
        installments.map((installment) => installment.id).toList();

    if (installmentIds.isNotEmpty) {
      await installmentNotificationService
          .cancelInstallmentNotifications(installmentIds);
    }

    // =========================
    // 4. حذف Payments
    // =========================

    for (final payment in payments) {
      await paymentRepository.deletePayment(payment.id);
    }

    // =========================
    // 5. حذف Installments
    // =========================

    for (final installment in installments) {
      await installmentRepository.deleteInstallment(
        installment.id,
      );
    }

    // =========================
    // 6. حذف Installment Plans
    // =========================

    for (final plan in plans) {
      await installmentRepository.deletePlan(plan.id);
    }

    // =========================
    // 7. حذف Sales
    // =========================

    for (final sale in sales) {
      await saleRepository.deleteSale(sale.id);
    }

    // =========================
    // 8. حذف Customer
    // =========================

    await customerRepository.deleteCustomer(customerId);
  }
}