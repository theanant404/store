import 'package:flutter/material.dart';
import 'package:store/features/address/data/models/address_model.dart';

class AddressFormPage extends StatefulWidget {
  final UserAddress? address;
  final bool isEditing;

  const AddressFormPage({super.key, this.address, this.isEditing = false});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _landmarksController;
  late TextEditingController _villageController;
  late TextEditingController _pincodeController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.address?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.address?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.address?.address ?? '',
    );
    _landmarksController = TextEditingController(
      text: widget.address?.landmarks ?? '',
    );
    _villageController = TextEditingController(
      text: widget.address?.village ?? '',
    );
    _pincodeController = TextEditingController(
      text: widget.address?.pincode ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.address?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.address?.longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarksController.dispose();
    _villageController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // TODO: Implement geolocator to get current location
      // For now, show a placeholder message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location feature coming soon...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _submitForm() {
    if (_fullNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _pincodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final address = UserAddress(
      id: widget.address?.id,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      landmarks: _landmarksController.text,
      village: _villageController.text,
      pincode: _pincodeController.text,
      latitude: _latitudeController.text.isNotEmpty
          ? double.tryParse(_latitudeController.text)
          : null,
      longitude: _longitudeController.text.isNotEmpty
          ? double.tryParse(_longitudeController.text)
          : null,
    );

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address *',
                hintText: 'Enter your address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Landmarks
            TextField(
              controller: _landmarksController,
              decoration: InputDecoration(
                labelText: 'Landmarks',
                hintText: 'e.g., Near park, opposite school',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Village
            TextField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: 'Village/City',
                hintText: 'Enter village or city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pincode
            TextField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pincode *',
                hintText: 'Enter pincode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Location Section
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingLocation
                              ? null
                              : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.location_on),
                          label: Text(
                            _isLoadingLocation
                                ? 'Getting location...'
                                : 'Set Current Location',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latitudeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _longitudeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.isEditing ? 'Update Address' : 'Save Address',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
