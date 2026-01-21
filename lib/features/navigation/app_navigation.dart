import 'package:flutter/material.dart';
import 'package:store/core/common_widgets/app_search_field.dart';
import 'package:store/core/common_widgets/main_app_nav.dart';
import 'package:store/features/account/presentation/screens/account_page.dart';
import 'package:store/features/cart/data/services/cart_service.dart';
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
  final CartService _cartService = CartService();
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

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
      body: SafeArea(
        bottom: false, // keep bottom nav flush to screen
        child: Column(
          children: [
            // Search Bar at Top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical:0),
              child: AppSearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
            // Page Content
            Expanded(
              child: _selectedProduct != null
                  ? ProductDetailPage(product: _selectedProduct!)
                  : IndexedStack(
                      index: _index,
                      children: [
                        HomePage(searchQuery: _searchQuery),
                        const CartPage(),
                        const AccountPage(),
                        const Center(child: Text('Menu Page')),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        cartCount: _cartService.totalItems,
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
