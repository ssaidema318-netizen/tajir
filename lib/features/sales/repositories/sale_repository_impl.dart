import '../datasources/sale_local_data_source.dart';
import '../models/sale_model.dart';

class SaleRepositoryImpl {
  final SaleLocalDataSource localDataSource;
  SaleRepositoryImpl(this.localDataSource);
  Future<void> addSale(SaleModel sale) {
    return localDataSource.addSale(sale);
  }

  SaleModel? getSale(String id) {
    return localDataSource.getSale(id);
  }

  List<SaleModel> getSales() {
    return localDataSource.getSales();
  }

  List<SaleModel> getSalesByCustomer(String customerId) {
    return localDataSource
        .getSales()
        .where((sale) => sale.customerId == customerId)
        .toList();
  }

  Future<void> deleteSale(String id) {
    return localDataSource.deleteSale(id);
  }
}
