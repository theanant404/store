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

  final List<String> _products = [
    'iPhone 15 Pro',
    'Samsung S24 Ultra',
    'MacBook Air M3',
    'Nike Air Max',
    'Adidas Ultraboost',
    'Sony WH-1000XM5',
  ];

  void _clearSearch() {
    _controller.clear();
    // Use the controller's built-in view management
    if (_controller.isOpen) {
      _controller.openView(); // Refresh suggestions
    }
    setState(() {});
  }

  void _handleSelection(String selection) {
    // 1. Update text
    _controller.text = selection;

    // 2. CRITICAL: Close the suggestion view properly
    if (_controller.isOpen) {
      _controller.closeView(selection);
    }

    // 3. Remove keyboard focus
    FocusScope.of(context).unfocus();

    // 4. Navigate using your AppShell logic
    // Using a microtask ensures the UI has finished closing the overlay
    Future.microtask(() {
      final appShell = AppShell.of(context);
      appShell?.navigateToMenuWithQuery(selection);
    });
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
              viewHintText: 'Search products...',
              // The search bar in its idle state
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  onTap: () => controller.openView(),
                  onChanged: (_) => controller.openView(),
                  onSubmitted: (value) => _handleSelection(value),
                  hintText: 'Search products...',
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  side: WidgetStateProperty.all(BorderSide.none),
                  // Custom styling to match your attractive design
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  leading: const Icon(
                    Icons.search_rounded,
                    color: Colors.blueAccent,
                  ),
                  trailing: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: _clearSearch,
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: widget.onFilterTap,
                    ),
                  ],
                );
              },
              // The suggestion logic
              suggestionsBuilder: (context, controller) {
                final String input = controller.value.text.toLowerCase();
                final filteredItems = _products
                    .where((item) => item.toLowerCase().contains(input))
                    .toList();

                if (filteredItems.isEmpty) {
                  return [const ListTile(title: Text("No suggestions found"))];
                }

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
