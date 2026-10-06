import 'package:hive/hive.dart';

part 'installment_plan_model.g.dart';

@HiveType(typeId: 4)
class InstallmentPlanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String saleId;

  @HiveField(3)
  final String frequency;

  @HiveField(4)
  final int totalAmount;

  @HiveField(5)
  final int numberOfInstallments;

  @HiveField(6)
  final DateTime createdAt;

  InstallmentPlanModel({
    required this.id,
    required this.customerId,
    required this.saleId,
    required this.frequency,
    required this.totalAmount,
    required this.numberOfInstallments,
    required this.createdAt,
  });
}