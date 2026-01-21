import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required this.searchQuery});

  final String searchQuery;

  List<String> _relatedItems() {
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return const [
        'Trending: Wireless earbuds',
        'Trending: Smartwatch combo',
        'Trending: Running shoes',
        'Trending: Laptop accessories',
      ];
    }
    return [
      'Popular $query deals',
      '$query starter pack',
      'Top-rated $query picks',
      '$query accessories bundle',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _relatedItems();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              searchQuery.trim().isEmpty
                  ? 'Browse popular picks'
                  : 'Results for "$searchQuery"',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.blueAccent,
                        ),
                      ),
                      title: Text(item),
                      subtitle: const Text('Tap to view details'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
