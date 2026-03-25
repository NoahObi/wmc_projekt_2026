import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_provider.dart';

class AnalyticsData {
  final Map<String, double> categorySpending;
  final List<double> monthlySpending;
  final double totalMonthly;
  final double totalYearly;

  AnalyticsData({
    required this.categorySpending,
    required this.monthlySpending,
    required this.totalMonthly,
    required this.totalYearly,
  });
}

class AnalyticsNotifier extends AsyncNotifier<AnalyticsData> {
  @override
  FutureOr<AnalyticsData> build() async {
    final subscriptions = await ref.watch(subscriptionListProvider.future);

    final categorySpending = <String, double>{};
    double calculatedTotalMonthly = 0.0;

    for (final sub in subscriptions) {
      final category = sub.categoryName ?? 'Unbekannt';
      
      final isYearly = sub.billingInterval.toString().toLowerCase() == 'yearly';
      final monthlyAmount = isYearly ? (sub.price / 12) : sub.price;

      categorySpending[category] = (categorySpending[category] ?? 0) + monthlyAmount;
      calculatedTotalMonthly += monthlyAmount;
    }

    final totalYearly = calculatedTotalMonthly * 12;

    return AnalyticsData(
      categorySpending: categorySpending,
      monthlySpending: [], 
      totalMonthly: calculatedTotalMonthly,
      totalYearly: totalYearly,
    );
  }
}

final analyticsProvider = AsyncNotifierProvider<AnalyticsNotifier, AnalyticsData>(() {
  return AnalyticsNotifier();
});