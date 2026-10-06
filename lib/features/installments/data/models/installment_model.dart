import 'package:hive/hive.dart';

part 'installment_model.g.dart';

@HiveType(typeId: 5)
class InstallmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String planId;

  @HiveField(2)
  final String customerId;

  @HiveField(3)
  final String saleId;

  @HiveField(4)
  final int installmentNumber;

  @HiveField(5)
  final int dueAmount;

  @HiveField(6)
  final int paidAmount;

  @HiveField(7)
  final DateTime dueDate;

  @HiveField(8)
  final String status;

  InstallmentModel({
    required this.id,
    required this.planId,
    required this.customerId,
    required this.saleId,
    required this.installmentNumber,
    required this.dueAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });
}