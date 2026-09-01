// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ml_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MLModelAdapter extends TypeAdapter<MLModel> {
  @override
  final int typeId = 6;

  @override
  MLModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MLModel(
      sampleId: fields[0] as String,
      imageBlobPath: fields[1] as String,
      annotatedClass: fields[2] as String,
      verifiedWeightKg: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MLModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sampleId)
      ..writeByte(1)
      ..write(obj.imageBlobPath)
      ..writeByte(2)
      ..write(obj.annotatedClass)
      ..writeByte(3)
      ..write(obj.verifiedWeightKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MLModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
