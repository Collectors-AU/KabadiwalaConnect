import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/models/price_model.dart';

class LotProvider extends ChangeNotifier {
  String? _selectedCategoryCode;
  double _approxWeightKg = 5.0;
  String _conditionGrade = 'INTACT'; // or 'DISMANTLED'
  double _estimatedValuation = 0.0;

  String? get selectedCategoryCode => _selectedCategoryCode;
  double get approxWeightKg => _approxWeightKg;
  String get conditionGrade => _conditionGrade;
  double get estimatedValuation => _estimatedValuation;

  void setCategoryCode(String categoryCode) {
    _selectedCategoryCode = categoryCode;
    _calculateValuation();
  }

  void setWeight(double weight) {
    _approxWeightKg = weight;
    _calculateValuation();
  }

  void setConditionGrade(String condition) {
    _conditionGrade = condition;
    _calculateValuation();
  }

  void _calculateValuation() {
    if (_selectedCategoryCode == null) {
      _estimatedValuation = 0.0;
      notifyListeners();
      return;
    }

    final pricesBox = Hive.box<PriceModel>('pricesBox');
    
    // Find price for category
    double basePrice = 0.0;
    try {
      final priceModel = pricesBox.values.firstWhere(
        (element) => element.categoryCode == _selectedCategoryCode,
      );
      basePrice = priceModel.marketBuyingPrice + (priceModel.eprBonusOffset ?? 0.0);
    } catch (e) {
      // Fallback if not found
      basePrice = 0.0;
    }

    double conditionMultiplier = (_conditionGrade == 'INTACT') ? 1.0 : 0.85;

    _estimatedValuation = _approxWeightKg * basePrice * conditionMultiplier;
    notifyListeners();
  }
}
