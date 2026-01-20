import 'package:flutter/material.dart';
import 'package:store/features/auth/data/session_store.dart';
import 'package:store/features/home/presentation/screens/home_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SafeArea(
      child: ValueListenableBuilder<UserSession?>(
        valueListenable: SessionStore.currentUser,
        builder: (context, user, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Welcome Section
              Center(
                child: Text(
                  user == null ? 'Welcome!' : "",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Auth Section (when not logged in)
              if (user == null) ...[
                // Place this inside your ListView or Column in the Account/Home page
                Column(
                  children: [
                    // 1. Auth Section: Converted to a Modern Button Row
                    if (user == null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Unlock exclusive deals and track orders!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pushNamed('/login'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Login'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pushNamed('/register'),
                                      child: const Text('Register'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 2. Shop Related: Offers & Loyalty Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Special Offers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Flash Sale Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "FLASH SALE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Up to 10% OFF",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.bolt, color: Colors.white, size: 40),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Additional Shop Tiles
                          ListTile(
                            leading: const Icon(
                              Icons.local_offer_outlined,
                              color: Colors.green,
                            ),
                            title: const Text('Cash on Delivery Offers'),
                            subtitle: const Text(
                              'Save more with Cash on Delivery',
                            ),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.star_outline,
                              color: Colors.amber,
                            ),
                            title: const Text('100% Trusted Shop'),
                            subtitle: const Text(
                              'Shop with confidence at our trusted store',
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // User logged in section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: _dashboardForRole(context, user.role),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(),

              // Help & Support Section
              const ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support'),
                trailing: Icon(Icons.chevron_right),
              ),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                trailing: Icon(Icons.chevron_right),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}

Widget _dashboardForRole(BuildContext context, String role) {
  final upper = role.toUpperCase();
  switch (upper) {
    case 'ADMIN':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashHeader('Orders & Fulfillment'),
          const _DashTile(Icons.receipt_long_outlined, 'All Orders'),
          const _DashTile(
            Icons.local_shipping_outlined,
            'Shipments & Delivery SLAs',
          ),
          const _DashTile(
            Icons.assignment_return_outlined,
            'Returns & Refunds',
          ),
          const _DashHeader('Products & Inventory'),
          _DashTile(
            Icons.inventory_2_outlined,
            'Products',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HomePage())),
          ),
          _DashTile(
            Icons.category_outlined,
            'Categories',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HomePage())),
          ),
          const _DashTile(Icons.price_change_outlined, 'Pricing & Discounts'),
          const _DashTile(Icons.settings,'Shop Setting'),
          const _DashHeader('People & Access'),
          const _DashTile(Icons.group_outlined, 'Users & Roles'),
          const _DashTile(Icons.support_agent_outlined, 'Support Tickets'),
          const _DashHeader('System'),
          const _DashTile(Icons.analytics_outlined, 'Analytics & Reports'),
          const _DashTile(Icons.security_outlined, 'Security / Audit Logs'),
          const _DashTile(Icons.settings_outlined, 'Settings'),
          
        ],
      );
    case 'STAFF':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DashHeader('Staff Dashboard'),
          _DashTile(Icons.receipt_long_outlined, 'Manage Orders'),
          _DashTile(Icons.inventory_2_outlined, 'Update Inventory'),
          _DashTile(Icons.support_agent_outlined, 'Customer Support'),
        ],
      );
    case 'DELHIVERY':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DashTile(Icons.local_shipping_outlined, 'Assigned Deliveries'),
          _DashTile(Icons.map_outlined, 'Routes / Maps'),
          _DashTile(
            Icons.assignment_turned_in_outlined,
            'Completed Deliveries',
          ),
        ],
      );
    case 'USER':
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DashTile(Icons.favorite_border, 'Wishlist'),
          _DashTile(Icons.receipt_long_outlined, 'My Orders'),
          _DashTile(Icons.location_on_outlined, 'Addresses'),
        ],
      );
  }
}

class _DashHeader extends StatelessWidget {
  const _DashHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile(this.icon, this.title, {this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap ?? () {},
    );
  }
}
