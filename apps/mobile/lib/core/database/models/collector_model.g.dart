// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectorModelAdapter extends TypeAdapter<CollectorModel> {
  @override
  final int typeId = 5;

  @override
  CollectorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectorModel(
      collectorIdHash: fields[0] as String,
      preferredLang: fields[1] as String,
      cumulativeEarningsInr: fields[2] as double,
      txnCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CollectorModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.collectorIdHash)
      ..writeByte(1)
      ..write(obj.preferredLang)
      ..writeByte(2)
      ..write(obj.cumulativeEarningsInr)
      ..writeByte(3)
      ..write(obj.txnCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
