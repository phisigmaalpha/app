import 'package:flutter/material.dart';

class CustomEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String errorMessage;

  const CustomEmailField({
    super.key,
    required this.controller,
    required this.label,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Color.fromRGBO(231, 182, 43, 1), // Tu dorado
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(231, 182, 43, 1),
            width: 2,
          ),
        ),
      ),
      // Validación básica reutilizable
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) ||
            value == "") {
          return 'Introduce un email válido';
        }
        return null;
      },
    );
  }
}
