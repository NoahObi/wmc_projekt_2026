import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/category.dart';
import '../models/subscription.dart';

class ApiService {
  /// In Android-Emulatoren ist localhost 10.0.2.2.
  /// In Flutter Web ist localhost direkt erreichbar (kein Emulator).
  /// Bei Bedarf kann über --dart-define API_BASE_URL=... überschrieben werden.
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get _defaultBaseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://10.0.2.2:3000/api';
  }

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  final String _baseUrl;
  final _logger = Logger();

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(_uri('/categories'));
    if (response.statusCode != 200) {
      _logger.e('fetchCategories failed: ${response.statusCode} ${response.body}');
      throw Exception('Kategorien konnten nicht geladen werden');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Subscription>> fetchSubscriptions() async {
    final response = await http.get(_uri('/subscriptions'));
    if (response.statusCode != 200) {
      _logger.e('fetchSubscriptions failed: ${response.statusCode} ${response.body}');
      throw Exception('Abonnements konnten nicht geladen werden');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Subscription.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    final body = jsonEncode(subscription.toJson());
    _logger.i('createSubscription request: $body');

    final response = await http.post(
      _uri('/subscriptions'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201) {
      _logger.e('createSubscription failed: ${response.statusCode} ${response.body}');
      throw Exception('Abonnement konnte nicht gespeichert werden (${response.statusCode}).\n${response.body}');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Subscription.fromJson(data);
    } catch (e, st) {
      _logger.e('createSubscription parse failed', error: e, stackTrace: st);
      throw Exception('Abonnement konnte nicht verarbeitet werden: $e');
    }
  }

  Future<void> deleteSubscription(int id) async {
    final response = await http.delete(_uri('/subscriptions/$id'));
    if (response.statusCode != 200) {
      _logger.e('deleteSubscription failed: ${response.statusCode} ${response.body}');
      throw Exception('Abonnement konnte nicht gelöscht werden');
    }
  }

  Future<Subscription> updateSubscription(Subscription subscription) async {
    final body = jsonEncode(subscription.toJson());
    _logger.i('updateSubscription request: $body');

    final response = await http.put(
      _uri('/subscriptions/${subscription.id}'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      _logger.e('updateSubscription failed: ${response.statusCode} ${response.body}');
      throw Exception('Abonnement konnte nicht aktualisiert werden (${response.statusCode}).\n${response.body}');
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Subscription.fromJson(data);
    } catch (e, st) {
      _logger.e('updateSubscription parse failed', error: e, stackTrace: st);
      throw Exception('Abonnement konnte nicht verarbeitet werden: $e');
    }
  }
}
