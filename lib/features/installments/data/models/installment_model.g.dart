// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstallmentModelAdapter extends TypeAdapter<InstallmentModel> {
  @override
  final int typeId = 5;

  @override
  InstallmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstallmentModel(
      id: fields[0] as String,
      planId: fields[1] as String,
      customerId: fields[2] as String,
      saleId: fields[3] as String,
      installmentNumber: fields[4] as int,
      dueAmount: fields[5] as int,
      paidAmount: fields[6] as int,
      dueDate: fields[7] as DateTime,
      status: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InstallmentModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.saleId)
      ..writeByte(4)
      ..write(obj.installmentNumber)
      ..writeByte(5)
      ..write(obj.dueAmount)
      ..writeByte(6)
      ..write(obj.paidAmount)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
