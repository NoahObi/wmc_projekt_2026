import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/abo_list_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';
import '../models/subscription.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String aboList = '/abo-list';
  static const String addEdit = '/add-edit';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const DashboardScreen(),
      aboList: (context) => const AboListScreen(),
      addEdit: (context) => AddEditScreen(subscription: ModalRoute.of(context)?.settings.arguments as Subscription?),
      analytics: (context) => const AnalyticsScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
}