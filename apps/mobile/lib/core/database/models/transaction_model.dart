import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String txnId;

  @HiveField(1)
  String lotId;

  @HiveField(2)
  String collectorId;

  @HiveField(3)
  double finalWeightKg;

  @HiveField(4)
  double ratePerKg;

  @HiveField(5)
  double totalPayoutInr;

  @HiveField(6)
  String paymentMode;

  @HiveField(7)
  String status;

  @HiveField(8, defaultValue: 'CABLE')
  String categoryCode;

  TransactionModel({
    required this.txnId,
    required this.lotId,
    required this.collectorId,
    required this.finalWeightKg,
    required this.ratePerKg,
    required this.totalPayoutInr,
    required this.paymentMode,
    required this.status,
    this.categoryCode = 'CABLE',
  });
}
