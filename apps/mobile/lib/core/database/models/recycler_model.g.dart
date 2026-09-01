// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recycler_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecyclerModelAdapter extends TypeAdapter<RecyclerModel> {
  @override
  final int typeId = 2;

  @override
  RecyclerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecyclerModel(
      id: fields[0] as String,
      facilityName: fields[1] as String,
      cpcbRegNo: fields[2] as String?,
      latitude: fields[3] as double?,
      longitude: fields[4] as double?,
      acceptedCategories: (fields[5] as List).cast<String>(),
      offeredRatesMap: (fields[6] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecyclerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.facilityName)
      ..writeByte(2)
      ..write(obj.cpcbRegNo)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.acceptedCategories)
      ..writeByte(6)
      ..write(obj.offeredRatesMap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecyclerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
