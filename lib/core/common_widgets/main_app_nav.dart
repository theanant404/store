import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Theme colors for easier management
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // Padding around the bar to give it a "floating" look
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 65, // Reduced height for a sleeker look
            backgroundColor: Colors.transparent,
            // Keep the same background when an item is selected
            indicatorColor: Colors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                );
              }
              return TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(size: 26, color: colorScheme.primary);
              }
              return IconThemeData(
                size: 24,
                color: colorScheme.onSurfaceVariant,
              );
            }),
          ),
          child: NavigationBar(
            labelPadding: const EdgeInsets.only(bottom: 0),
            backgroundColor: const Color.fromARGB(0, 253, 21, 21),
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            // Removes the default gray background from the system component
            // backgroundColor: Colors.red,
            elevation: 0,
            // Hide labels so icons sit centered in the fixed-height bar
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
