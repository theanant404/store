import 'package:flutter/material.dart';
import 'package:store/features/auth/data/session_store.dart';

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
                  user == null ? 'Welcome!' : 'Welcome back, ${user.name}!',
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
                            subtitle: const Text('Save more with Cash on Delivery'),
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
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile Settings'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        SessionStore.clear();
                      },
                    ),
                  ],
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

              // Dashboard Section (when logged in)
              if (user != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: _dashboardForRole(context, user.role),
                  ),
                ),
                const Divider(),
              ],
            ],
          );
        },
      ),
    );
  }
}

Widget _dashboardForRole(BuildContext context, String role) {
  final color = Theme.of(context).colorScheme;
  switch (role) {
    case 'admin':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Manage users, products, and view reports.'),
        ],
      );
    case 'seller':
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seller Dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Manage your products and view sales.'),
        ],
      );
    case 'user':
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text('View your orders and wishlist.'),
        ],
      );
  }
}
