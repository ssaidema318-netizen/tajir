import 'package:hive/hive.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';

class CustomerLocalDataSource {
  final Box<CustomerModel> customersBox;

  CustomerLocalDataSource({
    required this.customersBox,
  });

  Future<void> addCustomer(CustomerModel customer) async {
    await customersBox.put(customer.id, customer);
  }

  CustomerModel? getCustomer(String id) {
    return customersBox.get(id);
  }

  List<CustomerModel> getCustomers() {
    return customersBox.values.toList();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await customersBox.put(customer.id, customer);
  }

  Future<void> updateCustomerLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    final customer = customersBox.get(customerId);

    if (customer == null) {
      throw Exception('العميل غير موجود');
    }

    final updatedCustomer = CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      idNumber: customer.idNumber,
      idImagePath: customer.idImagePath,
      createdAt: customer.createdAt,
      latitude: latitude,
      longitude: longitude,
      customerImagePath: customer.customerImagePath,
    );

    await customersBox.put(
      customer.id,
      updatedCustomer,
    );
  }

  Future<void> deleteCustomer(String id) async {
    await customersBox.delete(id);
  }
}