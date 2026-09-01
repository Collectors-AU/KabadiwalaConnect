import 'package:hive/hive.dart';

part 'recycler_model.g.dart';

@HiveType(typeId: 2)
class RecyclerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String facilityName;

  @HiveField(2)
  String? cpcbRegNo;

  @HiveField(3)
  double? latitude;

  @HiveField(4)
  double? longitude;

  @HiveField(5)
  List<String> acceptedCategories;

  @HiveField(6)
  Map<String, double> offeredRatesMap;

  RecyclerModel({
    required this.id,
    required this.facilityName,
    this.cpcbRegNo,
    this.latitude,
    this.longitude,
    required this.acceptedCategories,
    required this.offeredRatesMap,
  });
}
