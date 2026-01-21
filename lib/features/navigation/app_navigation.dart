import 'package:flutter/material.dart';
import 'package:store/core/common_widgets/main_app_nav.dart';
import 'package:store/features/account/presentation/screens/account_page.dart';
import 'package:store/features/cart/presentation/screens/cart_page.dart';
import 'package:store/features/home/presentation/screens/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static _AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppShellState>();
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _pages = const [
    HomePage(),
    CartPage(),
    AccountPage(), // Profile page
    Center(child: Text('Menu Page')), // Placeholder for Menu
  ];

  void navigateToCart() {
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }
}
