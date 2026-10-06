import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajir/features/sales/models/sale_model.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';
import 'sale_state.dart';

class SaleCubit extends Cubit<SaleState> {
  final SaleRepositoryImpl repository;

  SaleCubit(this.repository) : super(SaleInitial());

  void loadSales() {
    try {
      emit(SaleLoading());

      final sales = repository.getSales();

      emit(SaleLoaded(sales));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> addSale(SaleModel sale) async {
    try {
      await repository.addSale(sale);

      loadSales();
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await repository.deleteSale(id);

      loadSales();
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }
}