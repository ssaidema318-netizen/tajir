import 'package:hive/hive.dart';

import 'sale_item_model.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class SaleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final List<SaleItemModel> items;

  @HiveField(3)
  final int subtotal;

  @HiveField(4)
  final int discount;

  @HiveField(5)
  final int totalAmount;

  @HiveField(6)
  final int downPayment;

  @HiveField(7)
  final int financedAmount;

  @HiveField(8)
  final DateTime saleDate;

  // طريقة دفع المقدم:
  // cash / orange_money / mtn_momo
  @HiveField(9, defaultValue: 'cash')
  final String downPaymentMethod;

  SaleModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.downPayment,
    required this.financedAmount,
    required this.saleDate,
    this.downPaymentMethod = 'cash',
  });
}
