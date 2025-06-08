import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:BabyShop/utils/app_colors.dart';

import 'payment_page.dart';

class AddCardPage extends StatefulWidget {
  final Map<String, dynamic>? existingCard;

  const AddCardPage({super.key, this.existingCard});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();
  final TextEditingController expController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadExistingCard();
  }

  void _loadExistingCard() {
    if (widget.existingCard != null) {
      cardNumberController.text = widget.existingCard!['cardNumber'] ?? '';
      ccvController.text = widget.existingCard!['ccv'] ?? '';
      expController.text = widget.existingCard!['exp'] ?? '';
      nameController.text = widget.existingCard!['name'] ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        expController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  Future<void> _saveCard(BuildContext context) async {
    if (cardNumberController.text.isEmpty ||
        ccvController.text.isEmpty ||
        expController.text.isEmpty ||
        nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cards = prefs.getStringList('userCards') ?? [];

    final newCard = {
      'cardNumber': cardNumberController.text,
      'ccv': ccvController.text,
      'exp': expController.text,
      'name': nameController.text,
    };

    if (widget.existingCard != null) {
      // Update existing card
      final index = cards.indexWhere((card) => 
        json.decode(card)['cardNumber'] == widget.existingCard!['cardNumber']
      );
      if (index != -1) {
        cards[index] = json.encode(newCard);
      }
    } else {
      // Add new card
      cards.add(json.encode(newCard));
    }

    await prefs.setStringList('userCards', cards);

    if (mounted) {
      Navigator.pop(context, newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.existingCard != null ? "Edit Card" : "Add Card",
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
            _buildTextField(
              "Card Number",
              cardNumberController,
              TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "CCV",
                    ccvController,
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: expController,
                        decoration: InputDecoration(
                          hintText: "Expiry (MM/YY)",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Cardholder Name",
              nameController,
              TextInputType.name,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _saveCard(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                widget.existingCard != null ? "Update" : "Save",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
