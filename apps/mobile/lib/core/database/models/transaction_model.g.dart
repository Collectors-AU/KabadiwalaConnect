// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 3;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      txnId: fields[0] as String,
      lotId: fields[1] as String,
      collectorId: fields[2] as String,
      finalWeightKg: fields[3] as double,
      ratePerKg: fields[4] as double,
      totalPayoutInr: fields[5] as double,
      paymentMode: fields[6] as String,
      status: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.txnId)
      ..writeByte(1)
      ..write(obj.lotId)
      ..writeByte(2)
      ..write(obj.collectorId)
      ..writeByte(3)
      ..write(obj.finalWeightKg)
      ..writeByte(4)
      ..write(obj.ratePerKg)
      ..writeByte(5)
      ..write(obj.totalPayoutInr)
      ..writeByte(6)
      ..write(obj.paymentMode)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
