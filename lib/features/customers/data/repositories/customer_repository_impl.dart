import 'package:tajir/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';

class CustomerRepositoryImpl {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl({
    required this.localDataSource,
  });

  Future<void> addCustomer(CustomerModel customer) async {
    await localDataSource.addCustomer(customer);
  }

  CustomerModel? getCustomer(String id) {
    return localDataSource.getCustomer(id);
  }

  List<CustomerModel> getCustomers() {
    return localDataSource.getCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await localDataSource.updateCustomer(customer);
  }

  Future<void> updateCustomerLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    await localDataSource.updateCustomerLocation(
      customerId: customerId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> deleteCustomer(String id) async {
    await localDataSource.deleteCustomer(id);
  }
}