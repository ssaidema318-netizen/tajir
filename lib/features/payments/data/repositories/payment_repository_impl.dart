import '../datasources/payment_local_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl {
  final PaymentLocalDataSource localDataSource;

  PaymentRepositoryImpl(this.localDataSource);

  Future<void> addPayment(
    PaymentModel payment,
  ) {
    return localDataSource.addPayment(payment);
  }

  PaymentModel? getPayment(String id) {
    return localDataSource.getPayment(id);
  }

  List<PaymentModel> getPayments() {
    return localDataSource.getPayments();
  }

  List<PaymentModel> getPaymentsByCustomer(
    String customerId,
  ) {
    return localDataSource.getPaymentsByCustomer(
      customerId,
    );
  }

  List<PaymentModel> getPaymentsBySale(
    String saleId,
  ) {
    return localDataSource.getPaymentsBySale(
      saleId,
    );
  }

  List<PaymentModel> getPaymentsByInstallment(
    String installmentId,
  ) {
    return localDataSource.getPaymentsByInstallment(
      installmentId,
    );
  }

  Future<void> deletePayment(String id) {
    return localDataSource.deletePayment(id);
  }
}