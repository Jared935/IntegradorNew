import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // datos simulados
    final String nombreUsuario = "omar_dev";
    final String matricula = "A01234567";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre de usuario:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(nombreUsuario, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text(
              "Matrícula:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(matricula, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar sesión"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
