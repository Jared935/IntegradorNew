import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- DEPENDENCIAS ---
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:glassmorphism/glassmorphism.dart';

// --- TUS IMPORTACIONES ---
import 'package:flutter_application_1/admin_storage_service.dart';
import 'package:flutter_application_1/dashboard_screen.dart';

// --- SERVICIO DE AUTH ---
class AdminAuthService {
  static Future<bool> login(String email, String password) async {
    try {
      final adminList = await AdminStorageService.streamUsers().first;
      final user = adminList.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      if (user.password == password) return true;
      return false; 
    } catch (e) {
      return false;
    }
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAdminLogin() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Credenciales requeridas.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 1500));

    final success = await AdminAuthService.login(email, password);

    if (!mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      HapticFeedback.vibrate();
      _showSnack('ACCESO DENEGADO.', Colors.redAccent);
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      width: 280,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const bgDark = Color(0xFF0F172A); 
    const accentGreen = Color(0xFF10B981); 

    return Scaffold(
      backgroundColor: bgDark,
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // 1. FONDO: Red Neuronal
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _NetworkPainter(_bgController.value),
              );
            },
          ),

          // 2. CONTENIDO PRINCIPAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO SUPERIOR ---
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgDark.withOpacity(0.8),
                        border: Border.all(color: accentGreen, width: 2),
                        boxShadow: [
                          BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                        ]
                      ),
                      child: const Icon(Icons.security, size: 50, color: accentGreen),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.05, duration: 3.seconds, curve: Curves.easeInOut),

                    const SizedBox(height: 50),

                    // --- TARJETA DE ACCESO (GLASS) ---
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: max(size.height * 0.65, 520), 
                      borderRadius: 20,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderGradient: LinearGradient(
                          colors: [accentGreen.withOpacity(0.5), Colors.transparent]),
                      child: Stack(
                        children: [
                          // Escáner
                          _ScannerLine(height: max(size.height * 0.65, 520)),

                          // Contenido de la tarjeta
                          Padding(
                            // Padding superior alto para bajar el texto
                            padding: const EdgeInsets.only(top: 100, left: 30, right: 30, bottom: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start, 
                              children: [
                                // TÍTULO CENTRADO CORREGIDO
                                Center(
                                  child: SizedBox(
                                    height: 30,
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          'Acceso Administrativo', // <--- TEXTO CAMBIADO AQUÍ
                                          textStyle: const TextStyle(
                                            color: accentGreen,
                                            fontFamily: 'Courier',
                                            fontSize: 20, // Ajustado ligeramente para que quepa bien
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                          speed: const Duration(milliseconds: 100),
                                        ),
                                      ],
                                      totalRepeatCount: 1,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 50),

                                // INPUTS
                                _AdminTextField(
                                  controller: _emailController,
                                  label: "CORREO ELECTRÓNICO",
                                  icon: Icons.alternate_email,
                                ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),

                                const SizedBox(height: 30),

                                _AdminTextField(
                                  controller: _passwordController,
                                  label: "CONTRASEÑA",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ).animate().fadeIn(delay: 600.ms).moveX(begin: -20, end: 0),

                                const Spacer(),

                                // BOTÓN
                                _AdminButton(
                                  text: "INICIAR SESIÓN",
                                  isLoading: _isLoading,
                                  onTap: _handleAdminLogin,
                                ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 30),
                    
                    // Botón Salir
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white38, size: 18),
                      label: const Text("VOLVER AL INICIO", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
                    ).animate().fadeIn(delay: 1200.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// --- WIDGETS PERSONALIZADOS ---
// ============================================================================

class _AdminTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;

  const _AdminTextField({required this.label, required this.controller, required this.icon, this.isPassword = false});

  @override
  State<_AdminTextField> createState() => _AdminTextFieldState();
}

class _AdminTextFieldState extends State<_AdminTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    const accentGreen = Color(0xFF10B981);

    return FocusScope(
      child: Focus(
        onFocusChange: (focus) => setState(() => _isFocused = focus),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white.withOpacity(0.05) : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: _isFocused ? accentGreen : Colors.white24, width: 2),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword,
            style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 16),
            cursorColor: accentGreen,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: widget.label,
              labelStyle: TextStyle(
                color: _isFocused ? accentGreen : Colors.white54,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold
              ),
              suffixIcon: Icon(widget.icon, color: _isFocused ? accentGreen : Colors.white24, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _AdminButton({required this.text, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const accentGreen = Color(0xFF10B981);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: accentGreen.withOpacity(0.15),
          border: Border.all(color: accentGreen.withOpacity(0.8), width: 1.5),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: accentGreen.withOpacity(0.2), 
              blurRadius: 10, 
              spreadRadius: 1
            )
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: accentGreen, strokeWidth: 2))
              : Text(
                  text,
                  style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16),
                ),
        ),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .shimmer(duration: 2500.ms, color: Colors.white24, angle: 45); 
  }
}

class _ScannerLine extends StatelessWidget {
  final double height;
  const _ScannerLine({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.6), blurRadius: 15, spreadRadius: 2)],
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .moveY(begin: 0, end: height, duration: 2500.ms, curve: Curves.linear) 
    .fadeOut(curve: Curves.easeInExpo);
  }
}

class _NetworkPainter extends CustomPainter {
  final double animValue;
  final List<_Node> nodes = List.generate(40, (i) => _Node());

  _NetworkPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paintNode = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.fill;
    final paintLine = Paint()..color = const Color(0xFF10B981).withOpacity(0.08)..strokeWidth = 0.5;

    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      double dx = (node.x + node.vx * animValue * 100) % size.width;
      double dy = (node.y + node.vy * animValue * 100) % size.height;
      if (dx < 0) dx += size.width;
      if (dy < 0) dy += size.height;

      canvas.drawCircle(Offset(dx, dy), 2, paintNode);

      for (var j = i + 1; j < nodes.length; j++) {
        var other = nodes[j];
        double odx = (other.x + other.vx * animValue * 100) % size.width;
        double ody = (other.y + other.vy * animValue * 100) % size.height;
        if (odx < 0) odx += size.width;
        if (ody < 0) ody += size.height;

        double dist = sqrt(pow(dx - odx, 2) + pow(dy - ody, 2));
        if (dist < 120) {
          paintLine.color = const Color(0xFF10B981).withOpacity(0.1 * (1 - dist / 120));
          canvas.drawLine(Offset(dx, dy), Offset(odx, ody), paintLine);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Node {
  late double x, y, vx, vy;
  _Node() {
    final rnd = Random();
    x = rnd.nextDouble() * 500;
    y = rnd.nextDouble() * 800;
    vx = (rnd.nextDouble() - 0.5) * 1.5;
    vy = (rnd.nextDouble() - 0.5) * 1.5;
  }
}