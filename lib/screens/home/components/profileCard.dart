// Widget privado para la tarjeta individual
import 'package:app/screens/home/components/models.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel option;

  const ProfileCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(24, 41, 163, 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Contenido principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(24, 41, 163, 1),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.description ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(24, 41, 163, 1),
                    ),
                    overflow: TextOverflow.fade,
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
