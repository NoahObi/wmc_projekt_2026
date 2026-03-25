import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final notifState = ref.watch(notificationProvider);
    final currencyState = ref.watch(currencyProvider);
    final language = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(language, 'app_title'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THEMES ---
            _buildSectionHeader(AppLocalizations.translate(language, 'themes'), isDarkMode, textColor),
            const SizedBox(height: 15),
            
            // Die ersten 4 Themes erzwungen in einer Zeile (Parameter currentTheme wurde entfernt!)
            Row(
              children: [
                Expanded(child: _buildThemeCard(AppLocalizations.translate(language, 'theme_dark'), const Color(0xFF1A1A2E), Colors.white, ThemeType.dark, isDarkMode, ref)),
                const SizedBox(width: 8),
                Expanded(child: _buildThemeCard(AppLocalizations.translate(language, 'theme_light'), Colors.white, Colors.black, ThemeType.light, isDarkMode, ref)),
                const SizedBox(width: 8),
                Expanded(child: _buildThemeCard(AppLocalizations.translate(language, 'theme_purple'), const Color(0xFF2D1B69), const Color(0xFFE0AAFF), ThemeType.purple, isDarkMode, ref)),
                const SizedBox(width: 8),
                Expanded(child: _buildThemeCard(AppLocalizations.translate(language, 'theme_blue'), const Color(0xFF2196F3), Colors.white, ThemeType.blue, isDarkMode, ref)),
              ],
            ),
            const SizedBox(height: 10),
            
            // "System" in einer neuen Zeile
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildThemeCard(AppLocalizations.translate(language, 'theme_system'), Colors.grey, Colors.white, ThemeType.system, isDarkMode, ref),
                ),
                const Spacer(flex: 3), 
              ],
            ),
            const SizedBox(height: 25),

            // --- BENACHRICHTIGUNGEN ---
            _buildSectionHeader(AppLocalizations.translate(language, 'notifications'), isDarkMode, textColor),
            
            _buildSwitchRow(AppLocalizations.translate(language, 'cancel_reminders'), notifState.enabled, (val) {
              ref.read(notificationProvider.notifier).setNotificationsEnabled(val);
            }, isDarkMode),
            const SizedBox(height: 10),
            Text(AppLocalizations.translate(language, 'reminder_label'),
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 5),
            
            _buildDropdown(
              value: notifState.reminderTime,
              items: const ['reminder_0', 'reminder_1', 'reminder_3', 'reminder_7'],
              language: language,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(notificationProvider.notifier).setReminderTime(newValue);
                }
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 25),

            // --- WÄHRUNG ---
            _buildSectionHeader(AppLocalizations.translate(language, 'currency'), isDarkMode, textColor),
            const SizedBox(height: 10),
            _buildDropdown(
              value: _getCurrencyLabel(currencyState.type),
              items: const ['€ Euro', '\$ US-Dollar', '£ Britische Pfund', 'CHF Schweizer Franken'],
              onChanged: (val) {
                ref.read(currencyProvider.notifier).setCurrency(val!);
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 10),
            _buildSwitchRow(AppLocalizations.translate(language, 'show_cents'), currencyState.showCents, (val) {
              ref.read(currencyProvider.notifier).setShowCents(val);
            }, isDarkMode),
            const SizedBox(height: 25),

            // --- SPRACHE ---
            _buildSectionHeader(AppLocalizations.translate(language, 'language'), isDarkMode, textColor),
            const SizedBox(height: 10),
            _buildDropdown(
              value: _getLanguageLabel(language),
              items: const ['Deutsch', 'English', 'Español', 'Français'],
              onChanged: (val) {
                ref.read(localizationProvider.notifier).setLanguage(val!);
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),

            // --- FOOTER TEXT ---
            Center(
              child: Text(
                AppLocalizations.translate(language, 'save_note'),
                style: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  String _getCurrencyLabel(CurrencyType type) {
    switch (type) {
      case CurrencyType.eur: return '€ Euro';
      case CurrencyType.usd: return '\$ US-Dollar';
      case CurrencyType.gbp: return '£ Britische Pfund';
      case CurrencyType.chf: return 'CHF Schweizer Franken';
    }
  }

  String _getLanguageLabel(Language lang) {
    switch (lang) {
      case Language.deutsch: return 'Deutsch';
      case Language.english: return 'English';
      case Language.espanol: return 'Español';
      case Language.francais: return 'Français';
    }
  }

  // Die Methode holt sich das aktuelle Theme nun wieder selbst!
  Widget _buildThemeCard(String label, Color bgColor, Color innerTextColor, ThemeType themeType, bool isDarkMode, WidgetRef ref) {
    // Hier lesen wir den State direkt aus
    final currentTheme = ref.watch(themeProvider);
    final isSelected = currentTheme == themeType; 
    
    final cardBgColor = isDarkMode ? const Color(0xFF2A2A40) : Colors.grey.shade200;
    final cardTextColor = isDarkMode ? Colors.white : Colors.black;

    // Farbe für den Rahmen und das Leuchten: Weiß im Dark Mode, Blau im Light Mode
    final highlightColor = isDarkMode ? Colors.white : Colors.blueAccent;

    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(themeType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? highlightColor : Colors.transparent,
            width: 3, 
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: highlightColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.withAlpha(128)),
              ),
              child: Text('Aa', style: TextStyle(color: innerTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: TextStyle(
                color: cardTextColor, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: isDarkMode ? const Color(0xFF6B48FF) : Colors.blue,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: isDarkMode ? const Color(0xFF2A2A40) : Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
    Language? language, 
  }) {
    final bgColor = isDarkMode ? const Color(0xFF2A2A40) : Colors.grey.shade200;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dropdownBgColor = isDarkMode ? const Color(0xFF2A2A40) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: dropdownBgColor,
          icon: Icon(Icons.keyboard_arrow_down, color: textColor),
          style: TextStyle(color: textColor, fontSize: 16),
          items: items.map((String item) {
            final displayString = language != null ? AppLocalizations.translate(language, item) : item;
            
            return DropdownMenuItem<String>(
              value: item,
              child: Text(displayString, style: TextStyle(color: textColor)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}