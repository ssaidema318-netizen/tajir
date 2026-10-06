import 'package:hive/hive.dart';

import '../models/sale_model.dart';

class SaleLocalDataSource {
  final Box<SaleModel> salesBox;

  SaleLocalDataSource(this.salesBox);

  Future<void> addSale(SaleModel sale) async {
    await salesBox.put(sale.id, sale);
  }

  SaleModel? getSale(String id) {
    return salesBox.get(id);
  }

  List<SaleModel> getSales() {
    return salesBox.values.toList();
  }

  Future<void> deleteSale(String id) async {
    await salesBox.delete(id);
  }
}