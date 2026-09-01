import 'package:hive/hive.dart';

part 'traceability_model.g.dart';

@HiveType(typeId: 4)
class TraceabilityModel extends HiveObject {
  @HiveField(0)
  String traceId;

  @HiveField(1)
  String lotId;

  @HiveField(2)
  String sha256Hash;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  DateTime timestampUtc;

  @HiveField(6)
  String? photoUri;

  TraceabilityModel({
    required this.traceId,
    required this.lotId,
    required this.sha256Hash,
    required this.latitude,
    required this.longitude,
    required this.timestampUtc,
    this.photoUri,
  });
}
