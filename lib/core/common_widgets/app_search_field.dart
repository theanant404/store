import 'package:flutter/material.dart';
import 'package:store/features/navigation/app_navigation.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({super.key, this.onNotificationTap, this.onFilterTap});

  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final SearchController _controller = SearchController();

  // Simulated product list from your database
  final List<String> _products = [
    'iPhone 15 Pro',
    'Samsung S24 Ultra',
    'MacBook Air M3',
    'Nike Air Max',
    'Adidas Ultraboost',
    'Sony WH-1000XM5',
  ];

  void _handleSelection(String selection) {
    // 1. Auto-fill the search controller
    _controller.text = selection;
    _controller.closeView(selection);

    // 2. Navigate to Menu page with the query using AppShell
    final appShell = AppShell.of(context);
    appShell?.navigateToMenuWithQuery(selection);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SearchAnchor(
              searchController: _controller,
              // This builds the search bar appearance
              builder: (context, controller) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    onTap: () => controller.openView(), // Opens suggestions
                    onChanged: (_) => controller.openView(),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        controller.closeView(value);
                        _handleSelection(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Colors.blueAccent,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: Colors.blueAccent,
                        ),
                        onPressed: widget.onFilterTap,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                );
              },
              // This builds the suggestion list "small screen"
              suggestionsBuilder: (context, controller) {
                final String input = controller.value.text.toLowerCase();

                // Filter the list based on user typing
                final filteredItems = _products
                    .where((item) => item.toLowerCase().contains(input))
                    .toList();

                return filteredItems.map(
                  (item) => ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(item),
                    trailing: const Icon(Icons.north_west, size: 18),
                    onTap: () => _handleSelection(item),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 15),

          // Notification Icon (remains the same)
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: widget.onNotificationTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.orangeAccent],
                ),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: const Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
