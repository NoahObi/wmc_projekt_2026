import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/notification_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.watch(notificationProvider);
    final subsAsync = ref.watch(subscriptionListProvider);
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final isDarkMode = theme.brightness == Brightness.dark;

    final language = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.translate(language, 'app_title'),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.subscriptions, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.translate(language, 'menu_title'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: textColor),
              title: Text(AppLocalizations.translate(language, 'dashboard'), style: TextStyle(color: textColor)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.list, color: textColor),
              title: Text(AppLocalizations.translate(language, 'subscription_list'), style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/abo-list');
              },
            ),
            ListTile(
              leading: Icon(Icons.pie_chart, color: textColor),
              title: Text(AppLocalizations.translate(language, 'analytics'), style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: textColor),
              title: Text(AppLocalizations.translate(language, 'settings'), style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: subsAsync.when(
        data: (subscriptions) {
          final now = DateTime.now();
          final totalMonthly = subscriptions.fold<double>(0, (sum, s) => sum + s.price);

          // Berechne nächste Zahlungsdaten
          final subscriptionsWithNextPayment = subscriptions.map((s) {
            DateTime nextPayment = s.startDate;
            // Wenn das Startdatum in der Vergangenheit liegt, berechne die nächste Zahlung
            while (nextPayment.isBefore(now)) {
              if (s.billingInterval.toLowerCase() == 'yearly') {
                nextPayment = DateTime(nextPayment.year + 1, nextPayment.month, nextPayment.day);
              } else {
                // monthly
                nextPayment = DateTime(nextPayment.year, nextPayment.month + 1, nextPayment.day);
              }
            }
            return MapEntry(s, nextPayment);
          }).toList();

          subscriptionsWithNextPayment.sort((a, b) => a.value.compareTo(b.value));
          final upcomingPayments = subscriptionsWithNextPayment.toList();

          final last7 = subscriptions
              .where((s) => now.difference(s.startDate).inDays <= 7)
              .fold<double>(0, (sum, s) => sum + s.price);
          final last30 = subscriptions
              .where((s) => now.difference(s.startDate).inDays <= 30)
              .fold<double>(0, (sum, s) => sum + s.price);

          return RefreshIndicator(
            onRefresh: () => ref.read(subscriptionListProvider.notifier).refresh(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Gesamtausgaben ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.translate(language, 'total_monthly_expenses'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyState.formatPrice(totalMonthly),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- Anstehende Zahlungen ---
                    Text(
                      AppLocalizations.translate(language, 'upcoming_payments'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    upcomingPayments.isNotEmpty
                        ? SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: upcomingPayments.length,
                              itemBuilder: (context, index) {
                                final payment = upcomingPayments[index];
                                return Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: _buildPaymentCard(
                                    payment.key.name,
                                    '${AppLocalizations.translate(language, 'next_payment')} ${_formatDate(payment.value)}',
                                    payment.key.name, // Nutzt den Namen für das Icon
                                    isDarkMode,
                                    theme,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF26263A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              AppLocalizations.translate(language, 'no_subscriptions'),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                    const SizedBox(height: 40),

                    // --- Ausgaben Statistik ---
                    Text(
                      AppLocalizations.translate(language, 'expense_stats'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatisticsRow(AppLocalizations.translate(language, 'last_7_days'), currencyState.formatPrice(last7), isDarkMode),
                    Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300, height: 24, thickness: 1),
                    _buildStatisticsRow(AppLocalizations.translate(language, 'last_30_days'), currencyState.formatPrice(last30), isDarkMode),
                    Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300, height: 24, thickness: 1),
                    _buildStatisticsRow(AppLocalizations.translate(language, 'monthly_avg'), currencyState.formatPrice(totalMonthly), isDarkMode),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${AppLocalizations.translate(language, 'error_loading')} $error',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit');
        },
        backgroundColor: theme.primaryColor,
        elevation: 6,
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
    );
  }

  // --- HILFSMETHODE FÜR DIE ICONS (Basierend auf dem Namen) ---
  IconData _getIconForName(String subscriptionName) {
    final name = subscriptionName.toLowerCase();
    
    // Unterhaltung / Video
    if (name.contains('netflix') || name.contains('disney') || name.contains('amazon') || name.contains('tv') || name.contains('youtube') || name.contains('prime')) {
      return Icons.live_tv;
    }
    // Musik
    if (name.contains('spotify') || name.contains('apple music') || name.contains('soundcloud') || name.contains('music')) {
      return Icons.music_note;
    }
    // Gaming
    if (name.contains('xbox') || name.contains('playstation') || name.contains('nintendo') || name.contains('game')) {
      return Icons.sports_esports;
    }
    // Fitness
    if (name.contains('gym') || name.contains('fit') || name.contains('mcfit') || name.contains('clever')) {
      return Icons.fitness_center;
    }
    // Software / Arbeit
    if (name.contains('adobe') || name.contains('microsoft') || name.contains('office') || name.contains('cloud')) {
      return Icons.cloud;
    }
    
    // Standard-Icon, falls der Name nicht erkannt wird
    return Icons.category;
  }

  Widget _buildPaymentCard(String title, String subtitle, String subscriptionName, bool isDarkMode, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF26263A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDarkMode ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIconForName(subscriptionName), color: theme.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          
          // Ohne maxLines und overflow bricht der Text nun komplett um
          Text(
            subtitle,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(String label, String amount, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}