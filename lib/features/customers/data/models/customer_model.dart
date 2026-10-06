import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String? idNumber;

  @HiveField(5)
  final String? idImagePath;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final double? latitude;

  @HiveField(8)
  final double? longitude;

  @HiveField(9)
  final String? customerImagePath;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.idNumber,
    this.idImagePath,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.customerImagePath,
  });
}