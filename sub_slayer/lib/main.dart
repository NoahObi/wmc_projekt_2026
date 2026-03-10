import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SubSlayerApp()));
}

class SubSlayerApp extends StatelessWidget {
  const SubSlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubSeeker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Unser ausgelagertes Theme
      initialRoute: AppRoutes.dashboard, // Startbildschirm
      routes: AppRoutes.getRoutes(), // Die registrierten Routen
    );
  }
}