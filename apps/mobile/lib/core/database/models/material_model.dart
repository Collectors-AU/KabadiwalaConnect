import 'package:hive/hive.dart';

part 'material_model.g.dart';

@HiveType(typeId: 0)
class MaterialModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryCode;

  @HiveField(2)
  String? subCategory;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  double? approxWeightKg;

  @HiveField(5)
  String? conditionGrade;

  @HiveField(6)
  double? estimatedValInr;

  MaterialModel({
    required this.id,
    required this.categoryCode,
    this.subCategory,
    this.imagePath,
    this.approxWeightKg,
    this.conditionGrade,
    this.estimatedValInr,
  });
}
