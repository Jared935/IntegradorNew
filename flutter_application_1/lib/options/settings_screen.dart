import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        backgroundColor: Colors.brown,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Información Personal"),
            subtitle: Text("Editar nombre, matrícula, etc."),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Cambiar contraseña"),
            subtitle: Text("Actualiza tu contraseña de acceso"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notificaciones"),
            subtitle: Text("Activar o desactivar avisos"),
          ),
        ],
      ),
    );
  }
}