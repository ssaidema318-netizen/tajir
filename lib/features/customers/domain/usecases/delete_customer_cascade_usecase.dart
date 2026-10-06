// features/customers/domain/usecases/delete_customer_cascade_usecase.dart

import 'package:tajir/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';

class DeleteCustomerCascadeUseCase {
  final CustomerRepositoryImpl customerRepository;
  final SaleRepositoryImpl saleRepository;
  final InstallmentRepositoryImpl installmentRepository;
  final PaymentRepositoryImpl paymentRepository;

  DeleteCustomerCascadeUseCase({
    required this.customerRepository,
    required this.saleRepository,
    required this.installmentRepository,
    required this.paymentRepository,
  });

  /// بيرجع ملخص بعدد العناصر اللي اتمسحت (مفيد لو عايز تعرضه في dialog التأكيد)
  Future<CascadeDeleteSummary> call(String customerId) async {
    // 1) الدفعات (أعمق حاجة في السلسلة)
    final payments = paymentRepository.getPaymentsByCustomer(customerId);
    for (final payment in payments) {
      await paymentRepository.deletePayment(payment.id);
    }

    // 2) الأقساط
    final installments =
        installmentRepository.getInstallmentsByCustomer(customerId);
    for (final installment in installments) {
      await installmentRepository.deleteInstallment(installment.id);
    }

    // 3) خطط التقسيط
    // ملحوظة: مفيش getPlansByCustomer جاهزة في الـ repo، فبفلتر يدوي هنا
    // (تقدر تضيفها في InstallmentRepositoryImpl لاحقًا لو استخدمتها في أكتر من مكان)
    final plans = installmentRepository
        .getPlans()
        .where((plan) => plan.customerId == customerId)
        .toList();
    for (final plan in plans) {
      await installmentRepository.deletePlan(plan.id);
    }

    // 4) المبيعات
    final sales = saleRepository.getSalesByCustomer(customerId);
    for (final sale in sales) {
      await saleRepository.deleteSale(sale.id);
    }

    // 5) العميل نفسه
    await customerRepository.deleteCustomer(customerId);

    return CascadeDeleteSummary(
      salesDeleted: sales.length,
      plansDeleted: plans.length,
      installmentsDeleted: installments.length,
      paymentsDeleted: payments.length,
    );
  }
}

class CascadeDeleteSummary {
  final int salesDeleted;
  final int plansDeleted;
  final int installmentsDeleted;
  final int paymentsDeleted;

  const CascadeDeleteSummary({
    required this.salesDeleted,
    required this.plansDeleted,
    required this.installmentsDeleted,
    required this.paymentsDeleted,
  });
}