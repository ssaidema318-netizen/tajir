import 'package:hive/hive.dart';

part 'sale_item_model.g.dart';

@HiveType(typeId: 2)
class SaleItemModel extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final int unitPrice;

  @HiveField(3)
  final int total;

  SaleItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}