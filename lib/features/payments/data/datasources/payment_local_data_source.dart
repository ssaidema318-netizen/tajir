import 'package:hive/hive.dart';

import '../models/payment_model.dart';

class PaymentLocalDataSource {
  final Box<PaymentModel> paymentsBox;

  PaymentLocalDataSource(this.paymentsBox);

  Future<void> addPayment(PaymentModel payment) async {
    await paymentsBox.put(payment.id, payment);
  }

  PaymentModel? getPayment(String id) {
    return paymentsBox.get(id);
  }

  List<PaymentModel> getPayments() {
    return paymentsBox.values.toList();
  }

  List<PaymentModel> getPaymentsByCustomer(
    String customerId,
  ) {
    return paymentsBox.values
        .where((payment) => payment.customerId == customerId)
        .toList();
  }

  List<PaymentModel> getPaymentsBySale(
    String saleId,
  ) {
    return paymentsBox.values
        .where((payment) => payment.saleId == saleId)
        .toList();
  }

  List<PaymentModel> getPaymentsByInstallment(
    String installmentId,
  ) {
    return paymentsBox.values
        .where(
          (payment) =>
              payment.installmentId == installmentId,
        )
        .toList();
  }

  Future<void> deletePayment(String id) async {
    await paymentsBox.delete(id);
  }
}