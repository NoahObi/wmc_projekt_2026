import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/subscription_provider.dart'; 

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final currencyState = ref.watch(currencyProvider);
    final language = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(language, 'app_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: analyticsAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(subscriptionListProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), 
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gesamtübersicht
                _buildSummaryCard(data, currencyState, language),
                const SizedBox(height: 30),

                // Tortendiagramm für Kategorien
                Text(
                  AppLocalizations.translate(language, 'category_spending'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildCategoryPieChart(data.categorySpending),
                ),
                const SizedBox(height: 20),
                ..._buildCategoryLegend(data.categorySpending, currencyState),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${AppLocalizations.translate(language, 'analytics_error')} $error',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AnalyticsData data, CurrencyState currencyState, dynamic language) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.translate(language, 'summary'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(AppLocalizations.translate(language, 'monthly'), currencyState.formatPrice(data.totalMonthly)),
              _buildSummaryItem(AppLocalizations.translate(language, 'yearly'), currencyState.formatPrice(data.totalYearly)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> categorySpending) {
    if (categorySpending.isEmpty) {
      return const Center(child: Text('Keine Daten verfügbar', style: TextStyle(color: Colors.white70)));
    }

    final total = categorySpending.values.fold<double>(0.0, (sum, value) => sum + value);
    if (total == 0) {
      return const Center(child: Text('Gesamtsumme ist 0', style: TextStyle(color: Colors.white70)));
    }

    final colors = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.purpleAccent, Colors.orangeAccent];

    int index = 0;
    final sections = categorySpending.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[index % colors.length];
      index++; 
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 90,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: sections,
      ),
    );
  }

  List<Widget> _buildCategoryLegend(Map<String, double> categorySpending, CurrencyState currencyState) {
    if (categorySpending.isEmpty) return [];

    final colors = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.purpleAccent, Colors.orangeAccent];
    final total = categorySpending.values.fold<double>(0.0, (sum, value) => sum + value);

    int index = 0;
    return categorySpending.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
      final color = colors[index % colors.length];
      index++;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildLegendItem(color, '${entry.key}: ${percentage.toStringAsFixed(1)}% (${currencyState.formatPrice(entry.value)})'),
      );
    }).toList();
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}