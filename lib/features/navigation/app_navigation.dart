import 'package:flutter/material.dart';
import 'package:store/core/common_widgets/main_app_nav.dart';
import 'package:store/features/account/presentation/screens/account_page.dart';
import 'package:store/features/cart/presentation/screens/cart_page.dart';
import 'package:store/features/home/presentation/screens/home_page.dart';
import 'package:store/features/product/data/model/product.dart';
import 'package:store/features/product/presentation/screens/product_detail_page.dart';

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
  ProductModel? _selectedProduct;

  final _pages = const [
    HomePage(),
    CartPage(),
    AccountPage(),
    Center(child: Text('Menu Page')),
  ];

  void navigateToCart() {
    setState(() {
      _index = 1;
      _selectedProduct = null;
    });
  }

  void showProductDetail(ProductModel product) {
    setState(() => _selectedProduct = product);
  }

  void closeProductDetail() {
    setState(() => _selectedProduct = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedProduct != null
          ? ProductDetailPage(product: _selectedProduct!)
          : IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
            _selectedProduct = null;
          });
        },
      ),
    );
  }
}
