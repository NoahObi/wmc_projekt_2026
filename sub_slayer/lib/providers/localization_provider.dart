import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { deutsch, english, espanol, francais }

class LocalizationNotifier extends Notifier<Language> {
  @override
  Language build() {
    _loadLanguage();
    return Language.deutsch;
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langStr = prefs.getString('language') ?? 'Deutsch';
    state = _getLanguageEnum(langStr);
  }

  Future<void> setLanguage(String languageLabel) async {
    state = _getLanguageEnum(languageLabel);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageLabel);
  }

  Language _getLanguageEnum(String label) {
    switch (label) {
      case 'Deutsch':
        return Language.deutsch;
      case 'English':
        return Language.english;
      case 'Español':
        return Language.espanol;
      case 'Français':
        return Language.francais;
      default:
        return Language.deutsch;
    }
  }

  Locale getLocale() {
    switch (state) {
      case Language.deutsch:
        return const Locale('de', 'DE');
      case Language.english:
        return const Locale('en', 'US');
      case Language.espanol:
        return const Locale('es', 'ES');
      case Language.francais:
        return const Locale('fr', 'FR');
    }
  }
}

final localizationProvider =
    NotifierProvider<LocalizationNotifier, Language>(() {
  return LocalizationNotifier();
});

// Übersetzungen
class AppLocalizations {
  static const Map<Language, Map<String, String>> translations = {
    Language.deutsch: {
      'app_title': 'SubSeeker',
      'themes': 'Themes',
      'notifications': 'Benachrichtigungen',
      'currency': 'Währung',
      'language': 'Sprache',
      'reminder_label': 'Wann soll ich dich erinnern?',
      'show_cents': 'Cent-Beträge anzeigen',
      'save_note': 'Deine Einstellungen werden automatisch lokal gespeichert.',
      'no_subscriptions': 'Keine Abonnements vorhanden',
      'tap_to_add': 'Tippe auf das +, um ein neues Abo hinzuzufügen.',
      'upcoming_payments': 'Anstehende Zahlungen',
      'next_payment': 'Nächste Zahlung:',
      'expense_stats': 'Ausgaben Statistik',
      'last_7_days': 'Letzte 7 Tage:',
      'last_30_days': 'Letzte 30 Tage:',
      'monthly_avg': 'Monatlich (Ø):',
      'error_loading': 'Fehler beim Laden:',
      'analytics_error': 'Fehler beim Laden der Analytics:',
      'summary': 'Zusammenfassung',
      'monthly': 'Monatlich',
      'yearly': 'Jährlich',
      'category_spending': 'Ausgaben nach Kategorie:',
      'monthly_spending': 'Monatliche Ausgaben:',
      'delete_subscription': 'Abo löschen',
      'delete_confirm': 'Möchtest du {name} wirklich löschen?',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'edit_subscription': 'Abo bearbeiten',
      'new_subscription': 'Neues Abo hinzufügen',
      'subscription_name': 'Name des Abos',
      'price': 'Preis',
      'description_optional': 'Beschreibung (optional)',
      'category': 'Kategorie',
      'billing_interval': 'Rechnungsintervall',
      'start_date': 'Startdatum',
      'save': 'Speichern',
      'cancel_button': 'Abbrechen',
      'please_enter_name': 'Bitte gib einen Namen ein.',
      'please_enter_price': 'Bitte gib einen Preis ein.',
      'category_load_error': 'Kategorien konnten nicht geladen werden: {error}',
      'please_choose_startdate': 'Bitte wähle ein Startdatum aus.',
      'please_choose_category': 'Bitte wähle eine Kategorie aus.',
      'please_choose_billing_interval': 'Bitte wähle ein Rechnungsintervall aus.',
      'save_error': 'Fehler beim Speichern: {error}',
      'subscription_deleted': 'Abonnement gelöscht',
      'delete_error': 'Fehler beim Löschen: {error}',
      'subscription_updated': 'Abonnement aktualisiert',
      'subscription_created': 'Abonnement erstellt',
      'invalid_price': 'Bitte gib einen gültigen Preis ein.',
      'menu_title': 'SubSeeker Menü',
      'dashboard': 'Dashboard',
      'subscription_list': 'Abo-Liste',
      'analytics': 'Analytics',
      'settings': 'Einstellungen',
      'total_monthly_expenses': 'Gesamtausgaben monatlich:',
      'theme_dark': 'Dunkel',
      'theme_light': 'Hell',
      'theme_purple': 'Lila',
      'theme_blue': 'Blau',
      'theme_system': 'System',
      'cancel_reminders': '🔔 Kündigungserinnerungen',
      'reminder_0': 'Am selben Tag',
      'reminder_1': '1 Tag vorher',
      'reminder_3': '3 Tage vorher',
      'reminder_7': '1 Woche vorher',
    },
    Language.english: {
      'app_title': 'SubSeeker',
      'themes': 'Themes',
      'notifications': 'Notifications',
      'currency': 'Currency',
      'language': 'Language',
      'reminder_label': 'When should I remind you?',
      'show_cents': 'Show cents',
      'save_note': 'Your settings are automatically saved locally.',
      'no_subscriptions': 'No subscriptions found',
      'tap_to_add': 'Tap + to add a new subscription.',
      'upcoming_payments': 'Upcoming payments',
      'next_payment': 'Next payment:',
      'expense_stats': 'Expense statistics',
      'last_7_days': 'Last 7 days:',
      'last_30_days': 'Last 30 days:',
      'monthly_avg': 'Monthly (avg):',
      'error_loading': 'Error loading:',
      'analytics_error': 'Error loading analytics:',
      'summary': 'Summary',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'category_spending': 'Spending by category:',
      'monthly_spending': 'Monthly spending:',
      'delete_subscription': 'Delete subscription',
      'delete_confirm': 'Delete {name}?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit_subscription': 'Edit subscription',
      'new_subscription': 'Add new subscription',
      'subscription_name': 'Subscription name',
      'price': 'Price',
      'description_optional': 'Description (optional)',
      'category': 'Category',
      'billing_interval': 'Billing interval',
      'start_date': 'Start date',
      'save': 'Save',
      'cancel_button': 'Cancel',
      'please_enter_name': 'Please enter a name.',
      'please_enter_price': 'Please enter a price.',
      'category_load_error': 'Failed to load categories: {error}',
      'please_choose_startdate': 'Please choose a start date.',
      'please_choose_category': 'Please choose a category.',
      'please_choose_billing_interval': 'Please choose a billing interval.',
      'save_error': 'Error saving: {error}',
      'subscription_deleted': 'Subscription deleted',
      'delete_error': 'Failed to delete: {error}',
      'subscription_updated': 'Subscription updated',
      'subscription_created': 'Subscription created',
      'invalid_price': 'Please enter a valid price.',
      'menu_title': 'SubSeeker Menu',
      'dashboard': 'Dashboard',
      'subscription_list': 'Subscription List',
      'analytics': 'Analytics',
      'settings': 'Settings',
      'total_monthly_expenses': 'Total monthly expenses:',
      'theme_dark': 'Dark',
      'theme_light': 'Light',
      'theme_purple': 'Purple',
      'theme_blue': 'Blue',
      'theme_system': 'System',
      'cancel_reminders': '🔔 Cancellation reminders',
      'reminder_0': 'Same day',
      'reminder_1': '1 day before',
      'reminder_3': '3 days before',
      'reminder_7': '1 week before',
    },
    Language.espanol: {
      'app_title': 'SubSeeker',
      'themes': 'Temas',
      'notifications': 'Notificaciones',
      'currency': 'Moneda',
      'language': 'Idioma',
      'reminder_label': '¿Cuándo debo recordarte?',
      'show_cents': 'Mostrar centavos',
      'save_note': 'Tus ajustes se guardan automáticamente localmente.',
      'no_subscriptions': 'No hay suscripciones',
      'tap_to_add': 'Toca + para agregar una suscripción nueva.',
      'upcoming_payments': 'Pagos próximos',
      'next_payment': 'Próximo pago:',
      'expense_stats': 'Estadísticas de gastos',
      'last_7_days': 'Últimos 7 días:',
      'last_30_days': 'Últimos 30 días:',
      'monthly_avg': 'Mensual (promedio):',
      'error_loading': 'Error al cargar:',
      'analytics_error': 'Error al cargar analytics:',
      'summary': 'Resumen',
      'monthly': 'Mensual',
      'yearly': 'Anual',
      'category_spending': 'Gastos por categoría:',
      'monthly_spending': 'Gastos mensuales:',
      'delete_subscription': 'Eliminar suscripción',
      'delete_confirm': '¿Eliminar {name}?',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit_subscription': 'Editar suscripción',
      'new_subscription': 'Agregar suscripción nueva',
      'subscription_name': 'Nombre de la suscripción',
      'price': 'Precio',
      'description_optional': 'Descripción (opcional)',
      'category': 'Categoría',
      'billing_interval': 'Intervalo de facturación',
      'start_date': 'Fecha de inicio',
      'save': 'Guardar',
      'cancel_button': 'Cancelar',
      'please_enter_name': 'Por favor ingresa un nombre.',
      'please_enter_price': 'Por favor ingresa un precio.',
      'category_load_error': 'No se pudieron cargar las categorías: {error}',
      'please_choose_startdate': 'Por favor selecciona una fecha de inicio.',
      'please_choose_category': 'Por favor selecciona una categoría.',
      'please_choose_billing_interval': 'Por favor selecciona un intervalo de facturación.',
      'save_error': 'Error al guardar: {error}',
      'subscription_deleted': 'Suscripción eliminada',
      'delete_error': 'Error al eliminar: {error}',
      'subscription_updated': 'Suscripción actualizada',
      'subscription_created': 'Suscripción creada',
      'invalid_price': 'Por favor ingresa un precio válido.',
      'menu_title': 'Menú SubSeeker',
      'dashboard': 'Tablero',
      'subscription_list': 'Lista de suscripciones',
      'analytics': 'Analytics',
      'settings': 'Ajustes',
      'total_monthly_expenses': 'Gastos mensuales totales:',
      'theme_dark': 'Oscuro',
      'theme_light': 'Claro',
      'theme_purple': 'Morado',
      'theme_blue': 'Azul',
      'theme_system': 'Sistema',
      'cancel_reminders': '🔔 Recordatorios de cancelación',
      'reminder_0': 'El mismo día',
      'reminder_1': '1 día antes',
      'reminder_3': '3 días antes',
      'reminder_7': '1 semana antes',
    },
    Language.francais: {
      'app_title': 'SubSeeker',
      'themes': 'Thèmes',
      'notifications': 'Notifications',
      'currency': 'Devise',
      'language': 'Langue',
      'reminder_label': 'Quand dois-je te rappeler?',
      'show_cents': 'Afficher les centimes',
      'save_note': 'Vos paramètres sont automatiquement enregistrés localement.',
      'no_subscriptions': 'Aucune abonnement trouvé',
      'tap_to_add': 'Appuyez sur + pour ajouter un nouvel abonnement.',
      'upcoming_payments': 'Paiements à venir',
      'next_payment': 'Prochain paiement:',
      'expense_stats': 'Statistiques de dépenses',
      'last_7_days': '7 derniers jours:',
      'last_30_days': '30 derniers jours:',
      'monthly_avg': 'Mensuel (moy):',
      'error_loading': 'Erreur de chargement:',
      'analytics_error': 'Erreur de chargement des analytics:',
      'summary': 'Résumé',
      'monthly': 'Mensuel',
      'yearly': 'Annuel',
      'category_spending': 'Dépenses par catégorie:',
      'monthly_spending': 'Dépenses mensuelles:',
      'delete_subscription': 'Supprimer l’abonnement',
      'delete_confirm': 'Supprimer {name}?',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit_subscription': 'Modifier l’abonnement',
      'new_subscription': 'Ajouter un nouvel abonnement',
      'subscription_name': 'Nom de l’abonnement',
      'price': 'Prix',
      'description_optional': 'Description (optionnel)',
      'category': 'Catégorie',
      'billing_interval': 'Fréquence de facturation',
      'start_date': 'Date de début',
      'save': 'Enregistrer',
      'cancel_button': 'Annuler',
      'please_enter_name': 'Veuillez entrer un nom.',
      'please_enter_price': 'Veuillez entrer un prix.',
      'category_load_error': 'Impossible de charger les catégories : {error}',
      'please_choose_startdate': 'Veuillez choisir une date de début.',
      'please_choose_category': 'Veuillez choisir une catégorie.',
      'please_choose_billing_interval': 'Veuillez choisir un intervalle de facturation.',
      'save_error': 'Erreur lors de la sauvegarde : {error}',
      'subscription_deleted': 'Abonnement supprimé',
      'delete_error': 'Erreur lors de la suppression : {error}',
      'subscription_updated': 'Abonnement mis à jour',
      'subscription_created': 'Abonnement créé',
      'invalid_price': 'Veuillez entrer un prix valide.',
      'menu_title': 'Menu SubSeeker',
      'dashboard': 'Tableau de bord',
      'subscription_list': 'Liste d’abonnements',
      'analytics': 'Analytics',
      'settings': 'Paramètres',
      'total_monthly_expenses': 'Dépenses mensuelles totales:',
      'theme_dark': 'Sombre',
      'theme_light': 'Clair',
      'theme_purple': 'Violet',
      'theme_blue': 'Bleu',
      'theme_system': 'Système',
      'cancel_reminders': '🔔 Rappels d\'annulation',
      'reminder_0': 'Le jour même',
      'reminder_1': '1 jour avant',
      'reminder_3': '3 jours avant',
      'reminder_7': '1 semaine avant',
    },
  };

  static String translate(Language language, String key) {
    return translations[language]?[key] ?? key;
  }
}