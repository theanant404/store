import 'package:flutter/material.dart';
import 'package:store/features/address/data/api/address_api.dart';
import 'package:store/features/address/data/models/address_model.dart';
import 'package:store/features/address/presentation/screens/address_form_page.dart';
import 'package:store/features/auth/data/session_store.dart';
import 'package:store/features/cart/data/models/cart_item.dart';
import 'package:store/features/cart/data/services/cart_service.dart';
import 'package:store/features/checkout/data/api/order_api.dart';
import 'package:store/features/checkout/data/models/order_model.dart';

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
  bool _isPlacingOrder = false;
  final OrderApi _orderApi = OrderApi();

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

  Future<void> _placeOrder(List<UserAddress> addresses) async {
    // Check if user is logged in
    if (SessionStore.currentUser.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    // Validate address selection
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address')),
      );
      return;
    }

    if (_selectedAddressIndex >= addresses.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final selectedAddress = addresses[_selectedAddressIndex];

      // Convert CartItems to OrderItems
      final orderItems = widget.selectedItems.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          varietyId: cartItem.variety.id,
          productTitle: cartItem.product.title,
          price: cartItem.variety.price,
          quantity: cartItem.quantity,
        );
      }).toList();

      // Create order
      await _orderApi.createOrder(
        items: orderItems,
        addressId: selectedAddress.id ?? '',
        totalAmount: widget.selectedTotal,
        paymentMethod: 'cod',
      );

      if (!mounted) return;

      // Clear cart after successful order
      CartService().clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate back to home after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
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
              future: _addressesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final addresses = snapshot.data ?? [];

                return Column(
                  children: [
                    if (addresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No saved addresses. Add a new address to continue.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Column(
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
                      ),
                    const SizedBox(height: 24),
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isPlacingOrder ? null : () => _placeOrder(addresses),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Place Order'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
