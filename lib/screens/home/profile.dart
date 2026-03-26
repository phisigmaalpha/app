import 'package:app/screens/home/components/profileCard.dart';
import 'package:app/screens/home/components/models.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mi perfil",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(24, 41, 163, 1),
            ),
          ),
          const SizedBox(height: 10),
          ProfileCard(
            option: ProfileModel(title: "Datos personales", description: ""),
          ),
          ProfileCard(
            option: ProfileModel(title: "Cambiar contraseña", description: ""),
          ),
          ProfileCard(
            option: ProfileModel(
              title: "Cancelar suscripción",
              description:
                  "Al cancelar la suscripción ya no podrás ver las actividades de SIGMA ALPHA",
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
