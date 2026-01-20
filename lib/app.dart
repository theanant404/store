import 'package:flutter/material.dart';
import 'package:store/features/navigation/app_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store',
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
      routes: {},
    );
  }
}
