// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traceability_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TraceabilityModelAdapter extends TypeAdapter<TraceabilityModel> {
  @override
  final int typeId = 4;

  @override
  TraceabilityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TraceabilityModel(
      traceId: fields[0] as String,
      lotId: fields[1] as String,
      sha256Hash: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      timestampUtc: fields[5] as DateTime,
      photoUri: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TraceabilityModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.traceId)
      ..writeByte(1)
      ..write(obj.lotId)
      ..writeByte(2)
      ..write(obj.sha256Hash)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.timestampUtc)
      ..writeByte(6)
      ..write(obj.photoUri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceabilityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
