import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/models/price_model.dart';

class LotProvider extends ChangeNotifier {
  String? _selectedCategoryCode = 'CABLE';
  double _approxWeightKg = 5.0;
  String _conditionGrade = 'INTACT'; // or 'DISMANTLED'
  double _estimatedValuation = 0.0;
  
  double _currentBasePrice = 0.0;
  double _currentEprBonus = 0.0;

  LotProvider() {
    _calculateValuation();
  }

  String? get selectedCategoryCode => _selectedCategoryCode;
  double get approxWeightKg => _approxWeightKg;
  String get conditionGrade => _conditionGrade;
  double get estimatedValuation => _estimatedValuation;
  double get currentBasePrice => _currentBasePrice;
  double get currentEprBonus => _currentEprBonus;

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
      _currentBasePrice = 0.0;
      _currentEprBonus = 0.0;
      notifyListeners();
      return;
    }

    try {
      final pricesBox = Hive.box<PriceModel>('pricesBox');
      final priceModel = pricesBox.values.firstWhere(
        (element) => element.categoryCode == _selectedCategoryCode,
      );
      _currentBasePrice = priceModel.marketBuyingPrice;
      _currentEprBonus = priceModel.eprBonusOffset ?? 0.0;
    } catch (e) {
      _currentBasePrice = 0.0;
      _currentEprBonus = 0.0;
    }

    double totalRate = _currentBasePrice + _currentEprBonus;
    double conditionMultiplier = (_conditionGrade == 'INTACT') ? 1.0 : 0.85;

    _estimatedValuation = _approxWeightKg * totalRate * conditionMultiplier;
    notifyListeners();
  }
}
