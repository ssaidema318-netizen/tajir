import 'package:hive/hive.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 6)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String saleId;

  // null = دفعة مقدم وليست مرتبطة بقسط
  @HiveField(3)
  final String? installmentId;

  @HiveField(4)
  final int amount;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
  final DateTime paidAt;

  PaymentModel({
    required this.id,
    required this.customerId,
    required this.saleId,
    this.installmentId,
    required this.amount,
    required this.paymentMethod,
    required this.paidAt,
  });
}
