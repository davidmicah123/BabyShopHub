import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:BabyShop/utils/app_colors.dart';

import 'address_page.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;

  const AddAddressPage({super.key, this.existingAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  void _loadExistingAddress() {
    if (widget.existingAddress != null) {
      streetController.text = widget.existingAddress!['street'] ?? '';
      cityController.text = widget.existingAddress!['city'] ?? '';
      stateController.text = widget.existingAddress!['state'] ?? '';
      zipController.text = widget.existingAddress!['zip'] ?? '';
    }
  }

  Future<void> _saveAddress(BuildContext context) async {
    if (streetController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        zipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final addresses = prefs.getStringList('userAddresses') ?? [];

    final newAddress = {
      'street': streetController.text,
      'city': cityController.text,
      'state': stateController.text,
      'zip': zipController.text,
    };

    if (widget.existingAddress != null) {
      // Update existing address
      final index = addresses.indexWhere((addr) => 
        json.decode(addr)['street'] == widget.existingAddress!['street'] &&
        json.decode(addr)['city'] == widget.existingAddress!['city']
      );
      if (index != -1) {
        addresses[index] = json.encode(newAddress);
      }
    } else {
      // Add new address
      addresses.add(json.encode(newAddress));
    }

    await prefs.setStringList('userAddresses', addresses);

    if (mounted) {
      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.existingAddress != null ? "Edit Address" : "Add Address",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Street Address", streetController),
            Row(
              children: [
                Expanded(child: _buildTextField("City", cityController)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField("Zip Code", zipController)),
              ],
            ),
            _buildTextField("State", stateController),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _saveAddress(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.existingAddress != null ? "Update" : "Save",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
