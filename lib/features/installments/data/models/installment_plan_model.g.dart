// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstallmentPlanModelAdapter extends TypeAdapter<InstallmentPlanModel> {
  @override
  final int typeId = 4;

  @override
  InstallmentPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstallmentPlanModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      saleId: fields[2] as String,
      frequency: fields[3] as String,
      totalAmount: fields[4] as int,
      numberOfInstallments: fields[5] as int,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InstallmentPlanModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.saleId)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.numberOfInstallments)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallmentPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
