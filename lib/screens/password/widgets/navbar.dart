import 'package:flutter/material.dart';

class CustomNavbarWidget extends StatelessWidget {
  // Añadimos una función opcional para manejar el retroceso entre pasos
  final VoidCallback? onBack;

  const CustomNavbarWidget({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Flecha a la izquierda
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            // Si le pasamos una función onBack la usa, si no, hace el pop normal
            onPressed: onBack ?? () => Navigator.pop(context),
          ),

          // 2. Texto Central
          Text(
            "Recuperar contraseña",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(24, 41, 163, 1),
            ),
          ),

          // 3. Logo a la derecha
          Image.asset(
            'assets/logo.png',
            height: 40, // Un poco más pequeño para que no rompa el diseño
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.lock_reset, size: 30), // Icono de respaldo
          ),
        ],
      ),
    );
  }
}
