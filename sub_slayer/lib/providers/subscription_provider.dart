import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/subscription.dart';

// Basis-URL unserer Express-API (10.0.2.2 ist der localhost im Android Emulator)
const String apiUrl = 'http://10.0.2.2:3000/api'; 

// Professionelles Logging-Setup (ersetzt alle print-Befehle)
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, 
    colors: true, 
    printEmojis: true,
  ),
);

class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionNotifier() : super([]) {
    // Beim Start automatisch die Daten laden
    fetchSubscriptions(); 
  }

  // 1. Daten vom Server laden (GET) - Realisiert Meilenstein M3
  Future<void> fetchSubscriptions() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/subscriptions'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = data.map((json) => Subscription.fromJson(json)).toList();
        logger.i('SubSlayer: ${state.length} Abos erfolgreich geladen.');
      } else {
        logger.w('SubSlayer: Fehler beim Laden. Status: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('SubSlayer: API-Verbindungsfehler beim Abrufen der Abos', error: e);
    }
  }

  // 2. Neues Abo hinzufügen (POST) - Für das Add/Edit Formular
  Future<void> addSubscription({
    required String name,
    required double price,
    required String description,
    required String startDate,
    required int categoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/subscriptions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': price,
          'description': description,
          'start_date': startDate,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 201) {
        logger.i('SubSlayer: Abo "$name" erfolgreich auf dem Server gespeichert.');
        // Nach dem Speichern die Liste neu vom Server laden, damit die UI aktuell ist
        await fetchSubscriptions(); 
      } else {
        logger.w('SubSlayer: Speichern fehlgeschlagen. Status: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('SubSlayer: Netzwerkfehler beim Speichern des Abos', error: e);
    }
  }

  // 3. Abo löschen (DELETE) - Für die Swipe-Geste in der Liste
  Future<void> removeSubscription(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/subscriptions/$id'));
      
      if (response.statusCode == 200) {
        // Lokalen Zustand aktualisieren, damit es direkt aus der Liste verschwindet
        state = state.where((sub) => sub.id != id).toList();
        logger.i('SubSlayer: Abo mit ID $id erfolgreich gelöscht.');
      } else {
        logger.e('SubSlayer: Löschen fehlgeschlagen (Status: ${response.statusCode})');
      }
    } catch (e) {
      logger.e('SubSlayer: Netzwerkfehler beim Löschvorgang von ID $id', error: e);
    }
  }
}

// Globaler Provider für die State-Steuerung der App
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
  return SubscriptionNotifier();
});

// Provider für die automatische Kostenberechnung (Dashboard-Feature)
final totalCostProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionProvider);
  // Berechnet automatisch die Summe aller Preise der geladenen Abos
  final total = subs.fold(0.0, (sum, item) => sum + item.price);
  logger.d('SubSlayer: Gesamtausgaben aktualisiert: $total €');
  return total;
});