// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleModelAdapter extends TypeAdapter<SaleModel> {
  @override
  final int typeId = 3;

  @override
  SaleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      items: (fields[2] as List).cast<SaleItemModel>(),
      subtotal: fields[3] as int,
      discount: fields[4] as int,
      totalAmount: fields[5] as int,
      downPayment: fields[6] as int,
      financedAmount: fields[7] as int,
      saleDate: fields[8] as DateTime,
      downPaymentMethod: fields[9] == null ? 'cash' : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SaleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.downPayment)
      ..writeByte(7)
      ..write(obj.financedAmount)
      ..writeByte(8)
      ..write(obj.saleDate)
      ..writeByte(9)
      ..write(obj.downPaymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
