import 'package:hive/hive.dart';

part 'collector_model.g.dart';

@HiveType(typeId: 5)
class CollectorModel extends HiveObject {
  @HiveField(0)
  String collectorIdHash;

  @HiveField(1)
  String preferredLang;

  @HiveField(2)
  double cumulativeEarningsInr;

  @HiveField(3)
  int txnCount;

  CollectorModel({
    required this.collectorIdHash,
    required this.preferredLang,
    required this.cumulativeEarningsInr,
    required this.txnCount,
  });
}
