import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CurrencyType { eur, usd, gbp, chf }

class CurrencyState {
  final CurrencyType type;
  final String symbol;
  final double exchangeRate;
  final bool showCents;

  CurrencyState({
    required this.type,
    required this.symbol,
    required this.exchangeRate,
    required this.showCents,
  });

  CurrencyState copyWith({
    CurrencyType? type,
    String? symbol,
    double? exchangeRate,
    bool? showCents,
  }) {
    return CurrencyState(
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      showCents: showCents ?? this.showCents,
    );
  }

  String formatPrice(double priceInEur) {
    final converted = priceInEur * exchangeRate;
    final formatted = showCents ? converted.toStringAsFixed(2) : converted.toStringAsFixed(0);
    return '$formatted $symbol';
  }
}

class CurrencyNotifier extends Notifier<CurrencyState> {
  @override
  CurrencyState build() {
    _loadCurrency();
    return CurrencyState(
      type: CurrencyType.eur,
      symbol: '€',
      exchangeRate: 1.0,
      showCents: true,
    );
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyStr = prefs.getString('currency') ?? '€ Euro';
    final showCents = prefs.getBool('showCents') ?? true;

    final (type, symbol, rate) = _getCurrencyData(currencyStr);
    state = CurrencyState(
      type: type,
      symbol: symbol,
      exchangeRate: rate,
      showCents: showCents,
    );
  }

  Future<void> setCurrency(String currencyLabel) async {
    final (type, symbol, rate) = _getCurrencyData(currencyLabel);
    state = state.copyWith(
      type: type,
      symbol: symbol,
      exchangeRate: rate,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currencyLabel);
  }

  Future<void> setShowCents(bool showCents) async {
    state = state.copyWith(showCents: showCents);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showCents', showCents);
  }

  (CurrencyType, String, double) _getCurrencyData(String label) {
    switch (label) {
      case '€ Euro':
        return (CurrencyType.eur, '€', 1.0);
      case '\$ US-Dollar':
        return (CurrencyType.usd, '\$', 1.08);
      case '£ Britische Pfund':
        return (CurrencyType.gbp, '£', 0.87);
      case 'CHF Schweizer Franken':
        return (CurrencyType.chf, 'CHF', 0.95);
      default:
        return (CurrencyType.eur, '€', 1.0);
    }
  }
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, CurrencyState>(() {
  return CurrencyNotifier();
});
