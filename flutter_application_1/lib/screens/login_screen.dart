// customer_app/screens/login_screen.dart
import 'package:flutter/material.dart';

// Importa la pantalla de login de admin (ajusta la ruta!)
import 'package:flutter_application_1/admin_login.dart';

// Renombramos la clase para claridad
class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 175, 139),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Botón para Admin (Esquina superior derecha) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white70),
                    tooltip: 'Acceso Administrador',
                    onPressed: () {
                      // Navega a la pantalla de login de Admin
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                      );
                      // O usa ruta nombrada si la definiste en main.dart:
                      // Navigator.pushNamed(context, '/admin_login');
                    },
                  ),
                ],
              ),
              // --- Fin Botón Admin ---

              const Spacer(),
              const Icon(Icons.local_cafe, size: 80, color: Colors.brown),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido a WolfCoffe",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField("Usuario"),
              const SizedBox(height: 20),
              _buildInputField("Contraseña", isPassword: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Lógica de login de cliente (simplificada por ahora)
                  // En una app real, aquí validarías usuario y contraseña
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 94, 53, 39),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold,
                    shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "¿No tienes cuenta? Crea una",
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500,
                    shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {bool isPassword = false}) {
    // ... (Tu código _buildInputField no cambia) ...
    return Container( decoration: BoxDecoration( color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade400.withOpacity(0.3), blurRadius: 4)], borderRadius: BorderRadius.circular(12), ), child: TextField( obscureText: isPassword, decoration: InputDecoration( labelText: label, labelStyle: const TextStyle(color: Colors.brown), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), ), ), );
  }
}
