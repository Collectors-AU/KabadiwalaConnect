import 'package:hive/hive.dart';

part 'price_model.g.dart';

@HiveType(typeId: 1)
class PriceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryCode;

  @HiveField(2)
  String? geohashRegion;

  @HiveField(3)
  double marketBuyingPrice;

  @HiveField(4)
  double? eprBonusOffset;

  @HiveField(5)
  double? movingAvg7Day;

  PriceModel({
    required this.id,
    required this.categoryCode,
    this.geohashRegion,
    required this.marketBuyingPrice,
    this.eprBonusOffset,
    this.movingAvg7Day,
  });
}
