import 'package:flutter/material.dart';
import 'package:store/core/theme/app_theme.dart';
import 'package:store/features/auth/presentation/screens/register_page.dart';
import 'package:store/features/navigation/app_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
      routes: {'/register': (context) => const RegisterPage()},
    );
  }
}
