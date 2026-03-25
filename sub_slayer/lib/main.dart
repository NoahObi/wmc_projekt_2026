import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_routes.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';
import 'services/notification_service.dart'; 

void main() async { 
  // 1. Stellt sicher, dass die Flutter-Engine läuft
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. Initialisiert das Benachrichtigungs-Plugin
  await NotificationService().init();
  
  runApp(const ProviderScope(child: SubSlayerApp()));
}

class SubSlayerApp extends ConsumerWidget {
  const SubSlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localizationProvider.notifier).getLocale();
    final language = ref.watch(localizationProvider);

    return MaterialApp(
      title: AppLocalizations.translate(language, 'app_title'),
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.getRoutes(),
    );
  }
}