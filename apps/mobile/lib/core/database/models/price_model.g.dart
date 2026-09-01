// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceModelAdapter extends TypeAdapter<PriceModel> {
  @override
  final int typeId = 1;

  @override
  PriceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceModel(
      id: fields[0] as String,
      categoryCode: fields[1] as String,
      geohashRegion: fields[2] as String?,
      marketBuyingPrice: fields[3] as double,
      eprBonusOffset: fields[4] as double?,
      movingAvg7Day: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PriceModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryCode)
      ..writeByte(2)
      ..write(obj.geohashRegion)
      ..writeByte(3)
      ..write(obj.marketBuyingPrice)
      ..writeByte(4)
      ..write(obj.eprBonusOffset)
      ..writeByte(5)
      ..write(obj.movingAvg7Day);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
