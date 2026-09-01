import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'models/material_model.dart';
import 'models/price_model.dart';
import 'models/recycler_model.dart';
import 'models/transaction_model.dart';
import 'models/traceability_model.dart';
import 'models/collector_model.dart';
import 'models/ml_model.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(MaterialModelAdapter());
    Hive.registerAdapter(PriceModelAdapter());
    Hive.registerAdapter(RecyclerModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(TraceabilityModelAdapter());
    Hive.registerAdapter(CollectorModelAdapter());
    Hive.registerAdapter(MLModelAdapter());

    // Open Boxes
    await Hive.openBox<MaterialModel>('materialsBox');
    await Hive.openBox<PriceModel>('pricesBox');
    await Hive.openBox<RecyclerModel>('recyclersBox');
    await Hive.openBox<TransactionModel>('transactionsBox');
    await Hive.openBox<TraceabilityModel>('traceabilityBox');
    await Hive.openBox<CollectorModel>('collectorsBox');
    await Hive.openBox<MLModel>('mlBox');

    await _seedInitialData();
  }

  static Future<void> _seedInitialData() async {
    final pricesBox = Hive.box<PriceModel>('pricesBox');
    final recyclersBox = Hive.box<RecyclerModel>('recyclersBox');

    if (pricesBox.isEmpty) {
      AppConstants.baselinePrices.forEach((categoryCode, price) {
        pricesBox.add(
          PriceModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + categoryCode,
            categoryCode: categoryCode,
            marketBuyingPrice: price,
            geohashRegion: 'DEFAULT',
          ),
        );
      });
    }

    if (recyclersBox.isEmpty) {
      recyclersBox.add(
        RecyclerModel(
          id: 'demo_recycler_1',
          facilityName: 'Default Facility',
          acceptedCategories: AppConstants.eWasteCategories,
          offeredRatesMap: AppConstants.baselinePrices,
        ),
      );
    }
  }
}
