// admin_app/admin_login_screen.dart
import 'package:flutter/material.dart';

// Importa el servicio de storage y modelos de datos del admin app
// Asegúrate de que estos archivos existan en la ubicación correcta
import 'package:flutter_application_1/admin_storage_service.dart';
import 'package:flutter_application_1/admin_data_models.dart' as admin_models;

// Importa la pantalla del dashboard del admin app
import 'package:flutter_application_1/dashboard_screen.dart';

// Servicio de autenticación para el Admin, usando AdminStorageService
class AdminAuthService {
  // Ya no se necesita el getter incorrecto

  static Future<bool> login(String email, String password) async {
    try {
      // Obtenemos una única instantánea de los usuarios admin actuales
      final userList = await AdminStorageService.streamUsers()
          .first; // Usa AdminStorageService

      // Buscamos al usuario por su email
      final user = userList.firstWhere((u) => u.email == email);

      // Validamos la contraseña Y que el rol sea 'Admin'
      return user.password == password && user.role == 'Admin';
    } catch (e) {
      // Si 'firstWhere' no encuentra un usuario o hay otro error, el login falla.
      print("Error en login: $e"); // Ayuda a depurar si algo sale mal
      return false;
    }
  }

  // Verificar si hay usuarios (puede ser útil si necesitas una lógica inicial)
  static Future<bool> hasUsers() async {
    try {
      final userList = await AdminStorageService.streamUsers().first;
      return userList.isNotEmpty;
    } catch (e) {
      print("Error al verificar usuarios: $e");
      return false; // Asume que no hay usuarios si hay un error
    }
  }
}

// Pantalla de Login para el Administrador (Estilo GitHub)
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  void _handleAdminLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese email y contraseña.';
        _isLoading = false;
      });
      return;
    }

    final success = await AdminAuthService.login(email, password);

    if (!mounted) return; // Comprobar si el widget sigue montado

    if (success) {
      // Navega al Dashboard de Admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ), // Asegúrate que DashboardScreen sea la correcta
      );
    } else {
      setState(() {
        _errorMessage = 'Credenciales de administrador inválidas.';
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Acceso Administrador'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Acceso Administrativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Correo Electrónico Admin',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            hintText: 'Ingresa tu email de admin',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Contraseña Admin',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                /* Lógica para recuperar contraseña si es necesario */
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '¿Olvidaste?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _buildInputDecoration(
                            hintText: 'Ingresa tu contraseña',
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAdminLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar Sesión Admin',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Se quita la opción de registrarse desde aquí
              ],
            ),
          ),
        ),
      ),
    );
  }
}