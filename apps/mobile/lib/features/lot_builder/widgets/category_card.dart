import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/database/models/price_model.dart';

class CategoryCard extends StatelessWidget {
  final String categoryCode;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.categoryCode,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (categoryCode) {
      case 'CABLE': return Icons.cable;
      case 'PCB_HIGH': return Icons.memory;
      case 'PCB_MED': return Icons.computer;
      case 'CRT': return Icons.tv;
      case 'LCD': return Icons.desktop_mac;
      case 'BATTERY': return Icons.battery_charging_full;
      case 'MOTOR': return Icons.settings;
      case 'PLASTIC': return Icons.recycling;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;
    
    final vernacularTitle = AppTranslations.get(lang, '${categoryCode}_vernacular');
    final enTitle = AppTranslations.get('en', '${categoryCode}_title');
    
    final pricesBox = Hive.box<PriceModel>('pricesBox');
    double basePrice = 0.0;
    try {
      final priceModel = pricesBox.values.firstWhere(
        (element) => element.categoryCode == categoryCode,
      );
      basePrice = priceModel.marketBuyingPrice;
    } catch (e) {
      basePrice = 0.0;
    }
    
    final livePriceText = '₹${basePrice.toStringAsFixed(0)}/kg + EPR';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.successGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.successGreen : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 32,
                  color: isSelected ? AppTheme.successGreen : AppTheme.primaryBlue,
                ),
                const SizedBox(height: 8),
                Text(
                  vernacularTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (vernacularTitle != enTitle)
                  Text(
                    enTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textLight,
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    livePriceText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                )
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
