// login_screen.dart
import 'package:flutter/material.dart';
import 'users_screen.dart'; // Necesario para acceder a UsersDataService
import 'dashboard_screen.dart';

// SERVICIO DE AUTENTICACIÓN MODIFICADO
class AuthService {
  static Future<bool> login(String email, String password) async {
    try {
      // Buscamos al usuario por su email en la lista de usuarios
      final user = UsersDataService.userList.firstWhere(
        (user) => user.email == email,
      );
      // Si el usuario existe, comparamos la contraseña proporcionada con la guardada
      return user.password == password;
    } catch (e) {
      // Si 'firstWhere' no encuentra un usuario, lanza una excepción.
      // En ese caso, el login falla.
      return false;
    }
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  bool get _hasUsers => UsersDataService.userCount > 0;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingrese email y contraseña.';
        _isLoading = false;
        return;
      });
      return;
    }

    final success = await AuthService.login(email, password);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Credenciales inválidas o usuario no registrado.';
        _isLoading = false;
      });
    }
  }

  void _handleRegister() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Limpiamos los controladores para el nuevo registro
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        return AlertDialog(
          title: Text(
            _hasUsers ? 'Registro de Nuevo Usuario' : 'Registro de Administrador Inicial'
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (será su usuario)'),
              ),
              // CAMPO DE CONTRASEÑA MODIFICADO (sin texto de ayuda)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () {
                final name = _nameController.text;
                final email = _emailController.text.trim();
                final password = _passwordController.text; // VALOR OBTENIDO

                final role = _hasUsers ? 'Cliente' : 'Admin';

                // VALIDACIÓN MODIFICADA para asegurar que la contraseña no esté vacía
                if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                  // LLAMADA MODIFICADA para incluir la contraseña
                  UsersDataService.registerUser(name, email, role, password);

                  setState(() {});

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registro exitoso como $role. ¡Ahora puede iniciar sesión!'))
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Todos los campos son obligatorios.'))
                  );
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  // Define un estilo de InputDecoration simple, plano y centrado (GitHub Style)
  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      // Remueve el relleno para un look más plano
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
        borderSide: const BorderSide(color: Colors.blue, width: 2), // Un ligero toque de azul al enfocar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fondo claro o color de contraste muy bajo
    final Color backgroundColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340), // Tarjeta estrecha
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Ícono (Simulando el logo de GitHub)
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 48,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),

                // Título de la tarjeta
                const Text(
                  'Acceso Administrativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                // CARD PRINCIPAL DEL FORMULARIO
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
                        // Título de Campo 1
                        const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            hintText: 'Ingresa tu email',
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Título de Campo 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                            // Aquí iría un TextButton para "¿Olvidaste tu contraseña?"
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('¿Olvidaste?', style: TextStyle(fontSize: 12, color: Colors.blue)),
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
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),

                        // Botón principal de INICIAR SESIÓN (Color primario fuerte)
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800, // Color fuerte y contrastante
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tarjeta de Registro (Separada, con borde simple)
                Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _hasUsers
                          ? '¿Nuevo en Panel Admin?'
                          : '¡Crea el primer administrador!',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: _handleRegister,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _hasUsers ? 'Regístrate' : 'Registrar Admin',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}