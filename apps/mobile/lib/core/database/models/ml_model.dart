import 'package:hive/hive.dart';

part 'ml_model.g.dart';

@HiveType(typeId: 6)
class MLModel extends HiveObject {
  @HiveField(0)
  String sampleId;

  @HiveField(1)
  String imageBlobPath;

  @HiveField(2)
  String annotatedClass;

  @HiveField(3)
  double? verifiedWeightKg;

  MLModel({
    required this.sampleId,
    required this.imageBlobPath,
    required this.annotatedClass,
    this.verifiedWeightKg,
  });
}
