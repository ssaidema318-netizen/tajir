import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajir/core/services/customer_deletion_service.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository_impl.dart';

import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepositoryImpl repository;
  final CustomerDeletionService deletionService;

  CustomerCubit({
    required this.repository,
    required this.deletionService,
  }) : super(CustomerInitial());

  void loadCustomers() {
    try {
      emit(CustomerLoading());

      final customers = repository.getCustomers();

      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);

      loadCustomers();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<bool> deleteCustomer(String id) async {
  try {
    emit(CustomerLoading());

    await deletionService.deleteCustomer(id);

    loadCustomers();

    return true;
  } catch (e) {
    emit(CustomerError(e.toString()));

    return false;
  }
}
}