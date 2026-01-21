import 'package:flutter/material.dart';
import 'package:store/features/address/data/api/address_api.dart';
import 'package:store/features/address/data/models/address_model.dart';
import 'package:store/features/address/presentation/screens/address_form_page.dart';
import 'package:store/features/cart/data/models/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.selectedTotal,
  });

  final List<CartItem> selectedItems;
  final double selectedTotal;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Future<List<UserAddress>> _addressesFuture;
  int _selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    _addressesFuture = AddressRepository.fetchAllAddresses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshAddresses() {
    setState(() {
      _addressesFuture = AddressRepository.fetchAllAddresses();
    });
  }

  void _openAddressForm({UserAddress? address}) async {
    final result = await Navigator.push<UserAddress?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddressFormPage(address: address, isEditing: address != null),
      ),
    );

    if (result != null) {
      try {
        if (address != null) {
          // Update existing address
          await AddressRepository.updateAddress(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        } else {
          // Create new address
          await AddressRepository.addAddress(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        }
        _refreshAddresses();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedItems.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final item = widget.selectedItems[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₹${item.variety.price.toStringAsFixed(2)} x ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(item.variety.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${widget.selectedTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address Section
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                OutlinedButton.icon(
                 onPressed: () => _openAddressForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<UserAddress>>(
              future: AddressRepository.fetchAllAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No saved addresses. Add a new address to continue.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < addresses.length; i++)
                      RadioListTile<int>(
                        title: Text(addresses[i].fullName),
                        subtitle: Text(addresses[i].address),
                        value: i,
                        groupValue: _selectedAddressIndex,
                        onChanged: (value) {
                          setState(() {
                            _selectedAddressIndex = value ?? 0;
                          });
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  const Text('Cash on Delivery'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully!')),
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
