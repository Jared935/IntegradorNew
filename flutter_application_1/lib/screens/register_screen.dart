import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- LIBRERÍAS DE ANIMACIÓN ---
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:glassmorphism/glassmorphism.dart';

// --- TUS IMPORTACIONES ---
import 'package:flutter_application_1/storage_service.dart';
import 'package:flutter_application_1/data_models.dart' as data_models;

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Por favor, completa todos los campos.', Colors.orangeAccent);
      return;
    }

    if (password != confirmPassword) {
      _showSnack('Las contraseñas no coinciden.', Colors.redAccent);
      return;
    }

    if (password.length < 6) {
       _showSnack('La contraseña es muy corta (mínimo 6).', Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingUsers = await StorageService.streamUsers().first;
      if (existingUsers.any((u) => u.email == email)) {
        _showSnack('Este correo ya está registrado.', Colors.redAccent);
        setState(() => _isLoading = false);
        return;
      }

      final newUser = data_models.User(
        id: '',
        name: email.split('@')[0],
        email: email,
        role: 'Cliente',
        password: password,
      );

      await StorageService.addUser(newUser);

      if (!mounted) return;
      
      HapticFeedback.heavyImpact();
      _showSnack('¡CUENTA CREADA CON ÉXITO!', Colors.greenAccent);
      
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      // Regresa al login
      Navigator.pop(context); 

    } catch (e) {
      _showSnack('Error de conexión: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const deepDark = Color(0xFF0A0A0A);

    return Scaffold(
      backgroundColor: deepDark,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. FONDO
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF000000), Color(0xFF1A0F00)],
              ),
            ),
          ),

          // 2. FONDO: Partículas
          const _AnimatedParticles(),

          // 3. CONTENIDO
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- ICONO REACTIVO ---
                    const _ReactiveRegisterIcon(),

                    const SizedBox(height: 30),

                    // --- TÍTULO ---
                    SizedBox(
                      height: 40,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Crear Nueva Cuenta',
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- INPUTS ---
                    _CyberTextField(
                      controller: _emailController,
                      icon: Icons.alternate_email,
                      hint: "EMAIL / ID",
                      keyboardType: TextInputType.emailAddress,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCirc),

                    const SizedBox(height: 20),

                    _CyberTextField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: "CONTRASEÑA",
                      isPassword: true,
                    ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCirc),

                    const SizedBox(height: 20),

                    _CyberTextField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock_reset,
                      hint: "CONFIRMAR CONTRASEÑA",
                      isPassword: true,
                    ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCirc),

                    const SizedBox(height: 40),

                    // --- BOTÓN ---
                    _CyberButton(
                      text: "REGISTRARSE",
                      isLoading: _isLoading,
                      onTap: _handleRegister,
                    ).animate(delay: 600.ms).fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                    const SizedBox(height: 30),
                    
                    // --- VOLVER ---
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "¿YA TIENES ID? ",
                          style: TextStyle(color: Colors.white54, letterSpacing: 1),
                          children: [
                            TextSpan(
                              text: "INICIAR SESIÓN",
                              style: TextStyle(color: Color(0xFFFF8F00), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 800.ms).fadeIn(),
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
// --- WIDGETS REUTILIZABLES (Mismo estilo que Login) ---
// ============================================================================

// 1. ICONO REACTIVO (Para Registro)
class _ReactiveRegisterIcon extends StatefulWidget {
  const _ReactiveRegisterIcon();

  @override
  State<_ReactiveRegisterIcon> createState() => _ReactiveRegisterIconState();
}

class _ReactiveRegisterIconState extends State<_ReactiveRegisterIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cyberOrange = Color(0xFFFF8F00);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glowValue = _controller.value; 
          final borderSize = _isPressed ? 6.0 : 3.0 + (glowValue * 1.5);
          final shadowSpread = _isPressed ? 2.0 : 5.0 + (glowValue * 10);
          final shadowColor = _isPressed ? Colors.white : cyberOrange;

          return AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: shadowColor.withOpacity(0.8), width: borderSize),
                boxShadow: [
                  BoxShadow(color: cyberOrange.withOpacity(0.4 + (glowValue * 0.2)), blurRadius: 20 + (glowValue * 10), spreadRadius: shadowSpread),
                  BoxShadow(color: cyberOrange.withOpacity(0.2), blurRadius: 10, spreadRadius: -5)
                ],
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, size: 50, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

// 2. INPUT CYBERPUNK
class _CyberTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;

  const _CyberTextField({required this.controller, required this.icon, required this.hint, this.isPassword = false, this.keyboardType = TextInputType.text});

  @override
  State<_CyberTextField> createState() => _CyberTextFieldState();
}

class _CyberTextFieldState extends State<_CyberTextField> {
  bool _isFocused = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    const cyberOrange = Color(0xFFFF8F00);

    return FocusScope(
      child: Focus(
        onFocusChange: (focus) => setState(() => _isFocused = focus),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 60,
          borderRadius: 12,
          blur: 20,
          alignment: Alignment.center,
          border: 1.5,
          linearGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], stops: const [0.1, 1]),
          borderGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _isFocused ? [cyberOrange, Colors.orangeAccent] : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(boxShadow: _isFocused ? [BoxShadow(color: cyberOrange.withOpacity(0.2), blurRadius: 20, spreadRadius: 0)] : []),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword && _obscure,
                keyboardType: widget.keyboardType,
                style: const TextStyle(color: Colors.white, letterSpacing: 1.1),
                cursorColor: cyberOrange,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(widget.icon, color: _isFocused ? cyberOrange : Colors.white38),
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 1.5, fontSize: 14),
                  suffixIcon: widget.isPassword ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white30), onPressed: () => setState(() => _obscure = !_obscure)) : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 3. BOTÓN CYBERPUNK
class _CyberButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _CyberButton({required this.text, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cyberOrange = Color(0xFFD84315);
    const cyberGold = Color(0xFFFF8F00);

    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [cyberOrange, cyberGold]),
        boxShadow: [BoxShadow(color: cyberGold.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white24,
          child: Center(
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2000.ms, color: Colors.white54, angle: 45);
  }
}

// 4. PARTÍCULAS
class _AnimatedParticles extends StatefulWidget {
  const _AnimatedParticles();
  @override
  State<_AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<_AnimatedParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(_rnd));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  _Particle(Random rnd) : x = rnd.nextDouble(), y = rnd.nextDouble(), size = rnd.nextDouble() * 3 + 1, speed = rnd.nextDouble() * 0.002 + 0.001, opacity = rnd.nextDouble() * 0.5 + 0.1;
  void update() { y -= speed; if (y < 0) y = 1.0; }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  _ParticlePainter(this.particles, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFF8F00);
    for (var p in particles) {
      p.update();
      paint.color = const Color(0xFFFF8F00).withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}