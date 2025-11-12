// customer_app/screens/login_screen.dart
import 'package:flutter/material.dart';
// ASEGÚRATE QUE ESTA RUTA SEA CORRECTA PARA TU PROYECTO
import 'package:flutter_application_1/storage_service.dart';
import 'package:flutter_application_1/admin_login.dart'; // Ajusta la ruta si es necesario

// --- Servicio de Autenticación para Clientes ---
class CustomerAuthService {
  static Future<bool> login(String email, String password) async {
    try {
      // 1. Obtiene la lista actualizada de usuarios desde Firestore
      final userList = await StorageService.streamUsers().first;

      // 2. Busca si existe un usuario que coincida en email, contraseña Y rol de Cliente
      final userExists = userList.any((u) => 
          u.email == email && 
          u.password == password && 
          u.role == 'Cliente' // ¡Importante! Solo permite entrar a clientes
      );

      return userExists;
    } catch (e) {
      print("Error en login cliente: $e");
      return false;
    }
  }
}
// ----------------------------------------------

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _obscurePassword = true;
  
  // Variable para controlar el estado de carga (agregada porque faltaba en tu snippet)
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    _usernameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // --- Nueva función para manejar el login ---
  void _handleLogin() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese usuario y contraseña.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() { _isLoading = false; });
      return;
    }

    // Llamada al servicio de autenticación real
    final bool success = await CustomerAuthService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Login exitoso: Navegar al menú
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      // Login fallido: Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas o no es una cuenta de cliente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // -------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // --- Botón para Admin (Esquina superior derecha) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: IconButton(
                          icon: const Icon(Icons.admin_panel_settings, color: Colors.white70, size: 28),
                          tooltip: 'Acceso Administrador',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),

                // --- Logo del Lobo Chef ---
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/wolf_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Texto de Bienvenida ---
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      "¡Bienvenido, a WolfCoffe!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // --- Campo de Usuario ---
                _buildInputField(
                  "Email", // Cambiado a "Email" para ser más claro
                  controller: _usernameController,
                  icon: Icons.email_outlined,
                  focusNode: _usernameFocusNode,
                  keyboardType: TextInputType.emailAddress, // Teclado de email
                ),
                const SizedBox(height: 25),

                // --- Campo de Contraseña ---
                _buildInputField(
                  "Contraseña",
                  controller: _passwordController,
                  isPassword: true,
                  icon: Icons.lock_outline,
                  focusNode: _passwordFocusNode,
                ),
                const SizedBox(height: 40),

                // --- Botón de Iniciar Sesión ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin, // Conectado a la nueva función
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 94, 53, 39),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 8,
                    shadowColor: Colors.brown.shade800,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
                          ),
                        ),
                ),
                const SizedBox(height: 25),

                // --- Botón para Crear Cuenta ---
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "¿No tienes cuenta? Crea una",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white54,
                      shadows: [Shadow(offset: Offset(0.5, 0.5), blurRadius: 1, color: Colors.black)],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label, {
    TextEditingController? controller,
    bool isPassword = false,
    IconData? icon,
    FocusNode? focusNode,
    TextInputType? keyboardType, // Parámetro opcional añadido
  }) {
    bool isFocused = focusNode?.hasFocus ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: Colors.brown.shade300.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isFocused ? Colors.brown.shade200 : Colors.white54,
            fontSize: 16,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: isFocused ? Colors.brown.shade300 : Colors.white54)
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isFocused ? Colors.brown.shade300 : Colors.white54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        cursorColor: Colors.brown.shade300,
      ),
    );
  }
}